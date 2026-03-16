import { corsHeaders } from "./cors.ts";

/** 에러 코드 */
export type ErrorCode =
  | "AUTH_REQUIRED"
  | "WARDROBE_LIMIT_REACHED"
  | "RECREATION_LIMIT_REACHED"
  | "INVALID_IMAGE"
  | "NO_FASHION_ITEMS"
  | "AI_TIMEOUT"
  | "AI_ERROR"
  | "RATE_LIMITED"
  | "VALIDATION_ERROR"
  | "NOT_FOUND"
  | "INTERNAL_ERROR";

/** 카테고리 */
export const CATEGORIES = [
  "tops",
  "bottoms",
  "outerwear",
  "dresses",
  "shoes",
  "bags",
  "accessories",
] as const;

export type Category = (typeof CATEGORIES)[number];

/** 핏 */
export const FITS = ["oversized", "regular", "slim"] as const;
export type Fit = (typeof FITS)[number];

/** 패턴 */
export const PATTERNS = [
  "solid",
  "stripe",
  "check",
  "floral",
  "dot",
  "print",
  "other",
] as const;
export type Pattern = (typeof PATTERNS)[number];

/** API 에러 응답 */
export interface ApiError {
  error: string;
  code: ErrorCode;
}

/** 무료 플랜 제한 */
export const FREE_LIMITS = {
  wardrobeItems: 30,
  recreationsPerMonth: 5,
} as const;

export function errorResponse(
  message: string,
  code: ErrorCode,
  status: number
): Response {
  return new Response(JSON.stringify({ error: message, code }), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

export function successResponse(
  data: unknown,
  status = 200
): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// --- 매칭 엔진 타입 ---

/** DB에서 가져온 옷장 아이템 (매칭에 필요한 필드만) */
export interface WardrobeItemRow {
  id: string;
  category: Category;
  subcategory: string | null;
  color_hex: string;
  color_name: string;
  style_tags: string[];
  fit: Fit | null;
  pattern: Pattern | null;
}

/** 점수 내역 */
export interface ScoreBreakdown {
  category: number;
  color: number;
  style: number;
  bonus: number;
}

/** 딥링크 (쇼핑 앱) */
export interface Deeplinks {
  musinsa: string;
  ably: string;
  zigzag: string;
}

/** 매칭 성공 아이템 */
export interface MatchedItem {
  ref_index: number;
  wardrobe_item: WardrobeItemRow;
  score: number;
  breakdown: ScoreBreakdown;
  match_reasons: string[];
}

/** 갭 아이템 (옷장에 없는 것) */
export interface GapItem {
  ref_index: number;
  category: string;
  description: string;
  search_keywords: string;
  deeplinks: Deeplinks;
}

/** 매칭 결과 전체 */
export interface MatchingResult {
  matched_items: MatchedItem[];
  gap_items: GapItem[];
  overall_score: number;
}
