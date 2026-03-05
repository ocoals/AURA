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
