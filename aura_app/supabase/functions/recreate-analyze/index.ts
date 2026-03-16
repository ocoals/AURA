import { handleCors } from "../_shared/cors.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import { uploadToR2, r2Paths } from "../_shared/r2-client.ts";
import {
  FREE_LIMITS,
  errorResponse,
  successResponse,
} from "../_shared/types.ts";
import type { WardrobeItemRow } from "../_shared/types.ts";
import { analyzeReferenceImage, ClaudeError } from "../_shared/claude-client.ts";
import { matchWardrobe } from "../_shared/matching-engine.ts";

const MAX_IMAGE_SIZE = 10 * 1024 * 1024; // 10MB
const ALLOWED_TYPES = new Set(["image/jpeg", "image/png"]);

Deno.serve(async (req) => {
  // Step 1: CORS preflight
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  // POST only
  if (req.method !== "POST") {
    return errorResponse("Method not allowed", "VALIDATION_ERROR", 405);
  }

  // JWT 인증
  const auth = await authenticateRequest(req);
  if (!auth) {
    return errorResponse("Authentication required", "AUTH_REQUIRED", 401);
  }
  const { userId, supabase } = auth;

  // Step 2: 이미지 검증
  let formData: FormData;
  try {
    formData = await req.formData();
  } catch {
    return errorResponse("Invalid form data", "INVALID_IMAGE", 400);
  }

  const imageFile = formData.get("reference_image");
  if (!imageFile || !(imageFile instanceof File)) {
    return errorResponse("Reference image is required", "INVALID_IMAGE", 400);
  }
  if (imageFile.size > MAX_IMAGE_SIZE) {
    return errorResponse("Image exceeds 10MB limit", "INVALID_IMAGE", 400);
  }
  if (!ALLOWED_TYPES.has(imageFile.type)) {
    return errorResponse(
      "Only JPEG and PNG images are allowed",
      "INVALID_IMAGE",
      400
    );
  }

  // Step 3: 사용량 제한 체크
  const monthKey = new Date().toISOString().slice(0, 7); // "2026-03"

  const { data: usageData, error: usageError } = await supabase
    .from("usage_counters")
    .select("recreation_count")
    .eq("user_id", userId)
    .eq("month_key", monthKey)
    .maybeSingle();

  if (usageError) {
    console.error("Usage query error:", usageError);
    return errorResponse("Failed to check usage", "INTERNAL_ERROR", 500);
  }

  const currentCount = usageData?.recreation_count ?? 0;
  if (currentCount >= FREE_LIMITS.recreationsPerMonth) {
    return errorResponse(
      `Free plan limit: ${FREE_LIMITS.recreationsPerMonth} recreations per month`,
      "RECREATION_LIMIT_REACHED",
      403
    );
  }

  // Step 4: R2 업로드
  const recId = crypto.randomUUID();
  const imageBytes = new Uint8Array(await imageFile.arrayBuffer());

  let referenceImageUrl: string;
  try {
    const key = r2Paths.reference(userId, recId);
    referenceImageUrl = await uploadToR2(key, imageBytes, imageFile.type);
  } catch (e) {
    console.error("R2 upload error:", e);
    return errorResponse("Failed to upload image", "INTERNAL_ERROR", 500);
  }

  // Step 5: Claude Haiku 분석
  const imageBase64 = btoa(
    imageBytes.reduce((data, byte) => data + String.fromCharCode(byte), "")
  );

  let analysisResult;
  try {
    analysisResult = await analyzeReferenceImage(imageBase64, imageFile.type);
  } catch (e) {
    if (e instanceof ClaudeError) {
      switch (e.code) {
        case "AI_TIMEOUT":
          return errorResponse(e.message, "AI_TIMEOUT", 408);
        case "NO_FASHION_ITEMS":
          return errorResponse(e.message, "NO_FASHION_ITEMS", 422);
        case "AI_ERROR":
          return errorResponse(e.message, "AI_ERROR", 502);
      }
    }
    console.error("Analysis error:", e);
    return errorResponse("Image analysis failed", "AI_ERROR", 502);
  }

  // Step 6: 옷장 아이템 조회
  const { data: wardrobeRows, error: wardrobeError } = await supabase
    .from("wardrobe_items")
    .select("id, category, subcategory, color_hex, color_name, style_tags, fit, pattern")
    .eq("user_id", userId)
    .eq("is_active", true);

  if (wardrobeError) {
    console.error("Wardrobe query error:", wardrobeError);
    return errorResponse("Failed to fetch wardrobe", "INTERNAL_ERROR", 500);
  }

  const wardrobeItems = (wardrobeRows ?? []) as WardrobeItemRow[];

  // Step 7: 매칭 엔진 실행
  const matchingResult = matchWardrobe(analysisResult.items, wardrobeItems);

  // Step 8: DB 저장
  const { error: insertError } = await supabase
    .from("look_recreations")
    .insert({
      id: recId,
      user_id: userId,
      reference_image_url: referenceImageUrl,
      reference_analysis: analysisResult,
      matched_items: matchingResult.matched_items,
      gap_items: matchingResult.gap_items,
      overall_score: matchingResult.overall_score,
    });

  if (insertError) {
    console.error("DB insert error:", insertError);
    return errorResponse("Failed to save recreation", "INTERNAL_ERROR", 500);
  }

  // Step 9: 사용량 카운터 증가
  const { data: existing } = await supabase
    .from("usage_counters")
    .select("wardrobe_count, recreation_count")
    .eq("user_id", userId)
    .eq("month_key", monthKey)
    .maybeSingle();

  const newRecreationCount = (existing?.recreation_count ?? 0) + 1;
  const { error: upsertError } = await supabase
    .from("usage_counters")
    .upsert(
      {
        user_id: userId,
        month_key: monthKey,
        wardrobe_count: existing?.wardrobe_count ?? 0,
        recreation_count: newRecreationCount,
      },
      { onConflict: "user_id,month_key" }
    );

  if (upsertError) {
    console.warn("Usage counter upsert failed:", upsertError);
  }

  // Step 10: 응답 반환
  return successResponse({
    id: recId,
    overall_score: matchingResult.overall_score,
    reference_analysis: analysisResult,
    matched_items: matchingResult.matched_items,
    gap_items: matchingResult.gap_items,
  }, 201);
});
