import { Buffer } from "node:buffer";
import { handleCors } from "../_shared/cors.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { uploadToR2, r2Paths } from "../_shared/r2-client.ts";
import {
  CATEGORIES,
  FREE_LIMITS,
  errorResponse,
  successResponse,
} from "../_shared/types.ts";
import { removeBackground } from "../_shared/background-removal.ts";
import { extractDominantColor } from "../_shared/color-extraction.ts";
import { PNG } from "npm:pngjs@7";

const MAX_IMAGE_SIZE = 10 * 1024 * 1024; // 10MB
const ALLOWED_TYPES = new Set(["image/jpeg", "image/png"]);

Deno.serve(async (req) => {
  // CORS preflight
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  // POST only
  if (req.method !== "POST") {
    return errorResponse("Method not allowed", "VALIDATION_ERROR", 405);
  }

  // Auth
  const auth = await authenticateRequest(req);
  if (!auth) {
    return errorResponse("Authentication required", "AUTH_REQUIRED", 401);
  }
  const { userId, supabase } = auth;

  // Parse FormData
  let formData: FormData;
  try {
    formData = await req.formData();
  } catch {
    return errorResponse("Invalid form data", "VALIDATION_ERROR", 400);
  }

  // Extract fields
  const imageFile = formData.get("image");
  const category = formData.get("category") as string | null;
  const subcategory = (formData.get("subcategory") as string | null) || null;
  const styleTagsRaw = formData.get("style_tags") as string | null;
  const fit = (formData.get("fit") as string | null) || null;
  const pattern = (formData.get("pattern") as string | null) || null;
  const brand = (formData.get("brand") as string | null) || null;
  const seasonRaw = formData.get("season") as string | null;

  // Validate image
  if (!imageFile || !(imageFile instanceof File)) {
    return errorResponse("Image file is required", "INVALID_IMAGE", 400);
  }
  if (imageFile.size > MAX_IMAGE_SIZE) {
    return errorResponse("Image exceeds 10MB limit", "VALIDATION_ERROR", 413);
  }
  if (!ALLOWED_TYPES.has(imageFile.type)) {
    return errorResponse(
      "Only JPEG and PNG images are allowed",
      "INVALID_IMAGE",
      400
    );
  }

  // Validate category
  if (!category || !CATEGORIES.includes(category as typeof CATEGORIES[number])) {
    return errorResponse(
      `Invalid category. Must be one of: ${CATEGORIES.join(", ")}`,
      "VALIDATION_ERROR",
      400
    );
  }

  // Usage limit check
  const { count, error: countError } = await supabase
    .from("wardrobe_items")
    .select("*", { count: "exact", head: true })
    .eq("user_id", userId)
    .eq("is_active", true);

  if (countError) {
    console.error("Count query error:", countError);
    return errorResponse("Failed to check usage", "INTERNAL_ERROR", 500);
  }

  if ((count ?? 0) >= FREE_LIMITS.wardrobeItems) {
    return errorResponse(
      `Free plan limit: ${FREE_LIMITS.wardrobeItems} items`,
      "WARDROBE_LIMIT_REACHED",
      403
    );
  }

  // Read image bytes
  const imageBytes = new Uint8Array(await imageFile.arrayBuffer());
  const itemId = crypto.randomUUID();

  // Background removal
  let processedBytes: Uint8Array;
  try {
    processedBytes = await removeBackground(imageBytes);
  } catch (e) {
    console.error("Background removal error:", e);
    processedBytes = imageBytes; // fallback to original
  }

  // Color extraction from processed image (PNG decode)
  let colorResult;
  try {
    const png = PNG.sync.read(Buffer.from(processedBytes));
    colorResult = extractDominantColor(
      new Uint8Array(png.data),
      png.width,
      png.height
    );
  } catch {
    // If PNG decode fails (e.g., mock mode returns JPEG), use a default
    console.warn("PNG decode failed, using default color");
    colorResult = {
      hex: "#808080",
      name: "그레이",
      hsl: { h: 0, s: 0, l: 50 },
    };
  }

  // R2 upload (parallel)
  const originalKey = r2Paths.original(userId, itemId);
  const processedKey = r2Paths.processed(userId, itemId);

  let imageUrl: string;
  let originalImageUrl: string;
  try {
    [originalImageUrl, imageUrl] = await Promise.all([
      uploadToR2(originalKey, imageBytes, "image/jpeg"),
      uploadToR2(processedKey, processedBytes, "image/png"),
    ]);
  } catch (e) {
    console.error("R2 upload error:", e);
    return errorResponse("Failed to upload image", "INTERNAL_ERROR", 500);
  }

  // Parse optional arrays
  const styleTags = styleTagsRaw
    ? styleTagsRaw.split(",").map((t) => t.trim()).filter(Boolean)
    : [];
  const season = seasonRaw
    ? seasonRaw.split(",").map((s) => s.trim()).filter(Boolean)
    : ["spring", "summer", "fall", "winter"];

  // DB INSERT
  const { data: item, error: insertError } = await supabase
    .from("wardrobe_items")
    .insert({
      id: itemId,
      user_id: userId,
      image_url: imageUrl,
      original_image_url: originalImageUrl,
      category,
      subcategory,
      color_hex: colorResult.hex,
      color_name: colorResult.name,
      color_hsl: colorResult.hsl,
      style_tags: styleTags,
      fit,
      pattern,
      brand,
      season,
    })
    .select()
    .single();

  if (insertError) {
    console.error("DB insert error:", insertError);
    return errorResponse("Failed to save item", "INTERNAL_ERROR", 500);
  }

  // UPSERT usage_counters
  const monthKey = new Date().toISOString().slice(0, 7); // "2026-03"

  // 기존 레코드 확인
  const { data: existing } = await supabase
    .from("usage_counters")
    .select("wardrobe_count, recreation_count")
    .eq("user_id", userId)
    .eq("month_key", monthKey)
    .maybeSingle();

  const newWardrobeCount = (existing?.wardrobe_count ?? 0) + 1;
  const { error: upsertError } = await supabase
    .from("usage_counters")
    .upsert(
      {
        user_id: userId,
        month_key: monthKey,
        wardrobe_count: newWardrobeCount,
        recreation_count: existing?.recreation_count ?? 0,
      },
      { onConflict: "user_id,month_key" }
    );

  if (upsertError) {
    // 치명적이지 않으므로 로그만 남김
    console.warn("Usage counter upsert failed:", upsertError);
  }

  return successResponse(item, 201);
});
