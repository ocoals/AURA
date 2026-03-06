import { handleCors } from "../_shared/cors.ts";
import { authenticateRequest } from "../_shared/auth.ts";
import {
  CATEGORIES,
  FITS,
  PATTERNS,
  errorResponse,
  successResponse,
} from "../_shared/types.ts";

const EDITABLE_FIELDS = [
  "category",
  "subcategory",
  "style_tags",
  "fit",
  "pattern",
  "brand",
  "season",
] as const;

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  // Auth
  const auth = await authenticateRequest(req);
  if (!auth) {
    return errorResponse("Authentication required", "AUTH_REQUIRED", 401);
  }
  const { userId, supabase } = auth;

  const url = new URL(req.url);

  // --- PATCH: Update item ---
  if (req.method === "PATCH") {
    const id = url.searchParams.get("id");
    if (!id) {
      return errorResponse("Missing ?id parameter", "VALIDATION_ERROR", 400);
    }

    let body: Record<string, unknown>;
    try {
      body = await req.json();
    } catch {
      return errorResponse("Invalid JSON body", "VALIDATION_ERROR", 400);
    }

    // Whitelist editable fields only
    const updates: Record<string, unknown> = {};
    for (const field of EDITABLE_FIELDS) {
      if (field in body) {
        updates[field] = body[field];
      }
    }

    if (Object.keys(updates).length === 0) {
      return errorResponse("No editable fields provided", "VALIDATION_ERROR", 400);
    }

    // Validate enums
    if (updates.category && !CATEGORIES.includes(updates.category as typeof CATEGORIES[number])) {
      return errorResponse(
        `Invalid category. Must be one of: ${CATEGORIES.join(", ")}`,
        "VALIDATION_ERROR",
        400
      );
    }
    if (updates.fit && !FITS.includes(updates.fit as typeof FITS[number])) {
      return errorResponse(
        `Invalid fit. Must be one of: ${FITS.join(", ")}`,
        "VALIDATION_ERROR",
        400
      );
    }
    if (updates.pattern && !PATTERNS.includes(updates.pattern as typeof PATTERNS[number])) {
      return errorResponse(
        `Invalid pattern. Must be one of: ${PATTERNS.join(", ")}`,
        "VALIDATION_ERROR",
        400
      );
    }

    const { data: item, error } = await supabase
      .from("wardrobe_items")
      .update(updates)
      .eq("id", id)
      .eq("user_id", userId)
      .eq("is_active", true)
      .select()
      .single();

    if (error) {
      console.error("DB update error:", error);
      if (error.code === "PGRST116") {
        return errorResponse("Item not found", "NOT_FOUND", 404);
      }
      return errorResponse("Failed to update item", "INTERNAL_ERROR", 500);
    }

    return successResponse(item);
  }

  // --- DELETE: Soft delete item(s) ---
  if (req.method === "DELETE") {
    const singleId = url.searchParams.get("id");
    const bulkIds = url.searchParams.get("ids");

    if (!singleId && !bulkIds) {
      return errorResponse("Missing ?id or ?ids parameter", "VALIDATION_ERROR", 400);
    }

    const ids = singleId ? [singleId] : bulkIds!.split(",").map((s) => s.trim()).filter(Boolean);

    if (ids.length === 0) {
      return errorResponse("No valid ids provided", "VALIDATION_ERROR", 400);
    }

    const { data, error } = await supabase
      .from("wardrobe_items")
      .update({ is_active: false })
      .in_("id", ids)
      .eq("user_id", userId)
      .eq("is_active", true)
      .select("id");

    if (error) {
      console.error("DB soft-delete error:", error);
      return errorResponse("Failed to delete item(s)", "INTERNAL_ERROR", 500);
    }

    return successResponse({ success: true, deleted_count: data?.length ?? 0 });
  }

  return errorResponse("Method not allowed", "VALIDATION_ERROR", 405);
});
