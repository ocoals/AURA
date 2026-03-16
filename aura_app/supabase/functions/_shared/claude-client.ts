/** Claude Haiku API wrapper — 레퍼런스 패션 이미지 분석 */

import Anthropic from "npm:@anthropic-ai/sdk";
import { CATEGORIES } from "./types.ts";
import { rgbToHsl, hslToKoreanName } from "./color-extraction.ts";

// --- Constants ---

const MODEL = "claude-haiku-4-5-20251001";
const MAX_TOKENS = 1024;
const TIMEOUT_MS = 10_000;
const MAX_RETRIES = 2;
const RETRY_DELAYS = [1000, 2000];

// --- Types ---

export interface AnalyzedItemColor {
  hex: string;
  name: string;
  hsl: { h: number; s: number; l: number };
}

export interface AnalyzedItem {
  index: number;
  category: string;
  subcategory: string;
  color: AnalyzedItemColor;
  style: string[];
  fit: string | null;
  pattern: string | null;
  material: string | null;
}

export interface AnalysisResult {
  items: AnalyzedItem[];
  overall_style: string;
  occasion: string;
}

// --- Error ---

export class ClaudeError extends Error {
  constructor(
    message: string,
    public code: "AI_TIMEOUT" | "AI_ERROR" | "NO_FASHION_ITEMS"
  ) {
    super(message);
    this.name = "ClaudeError";
  }
}

// --- Client Factory ---

let _client: Anthropic | null = null;

function getClient(): Anthropic {
  if (!_client) {
    _client = new Anthropic({
      apiKey: Deno.env.get("ANTHROPIC_API_KEY")!,
    });
  }
  return _client;
}

// --- Prompt ---

const PROMPT = `이 사진에 보이는 패션 아이템을 분석해주세요.
반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트는 절대 포함하지 마세요.

{
  "items": [
    {
      "index": 0,
      "category": "tops|bottoms|outerwear|dresses|shoes|bags|accessories",
      "subcategory": "구체적 소분류",
      "color": {"hex": "#000000", "name": "한국어 색상명", "hsl": {"h":0,"s":0,"l":0}},
      "style": ["casual", "formal", ...],
      "fit": "oversized|regular|slim|null",
      "pattern": "solid|stripe|check|...|null",
      "material": "cotton|denim|...|null"
    }
  ],
  "overall_style": "전체 코디 스타일",
  "occasion": "daily|office|date|formal|sport|outdoor"
}

규칙:
- 명확히 보이는 패션 아이템만 포함
- 배경 소품, 인테리어 제외
- 색상은 가장 넓은 면적의 대표 색상
- HSL 값 정확 계산
- 패션 아이템이 없는 이미지라면 items를 빈 배열([])로 반환하세요`;

// --- Validation Helpers ---

function hexToRgb(hex: string): { r: number; g: number; b: number } | null {
  const m = hex.replace("#", "").match(/^([0-9a-f]{2})([0-9a-f]{2})([0-9a-f]{2})$/i);
  if (!m) return null;
  return { r: parseInt(m[1], 16), g: parseInt(m[2], 16), b: parseInt(m[3], 16) };
}

function parseJsonResponse(text: string): unknown {
  // Strip markdown fences (```json ... ``` or ``` ... ```)
  const stripped = text.replace(/^```(?:json)?\s*\n?/i, "").replace(/\n?```\s*$/i, "");
  return JSON.parse(stripped);
}

function validateStructure(
  data: unknown
): asserts data is { items: unknown[]; overall_style: string; occasion: string } {
  if (
    typeof data !== "object" ||
    data === null ||
    !Array.isArray((data as Record<string, unknown>).items) ||
    typeof (data as Record<string, unknown>).overall_style !== "string" ||
    typeof (data as Record<string, unknown>).occasion !== "string"
  ) {
    throw new Error("Invalid response structure");
  }
}

function validateAndFixHsl(item: AnalyzedItem): AnalyzedItem {
  const { h, s, l } = item.color.hsl;
  const outOfRange = h < 0 || h > 360 || s < 0 || s > 100 || l < 0 || l > 100;

  if (outOfRange) {
    const rgb = hexToRgb(item.color.hex);
    if (rgb) {
      const hsl = rgbToHsl(rgb.r, rgb.g, rgb.b);
      const name = hslToKoreanName(hsl.h, hsl.s, hsl.l);
      return { ...item, color: { hex: item.color.hex, name, hsl } };
    }
  }

  return item;
}

const categorySet = new Set<string>(CATEGORIES);

function validateItems(items: unknown[]): AnalyzedItem[] {
  const valid: AnalyzedItem[] = [];

  for (const raw of items) {
    if (typeof raw !== "object" || raw === null) continue;
    const item = raw as Record<string, unknown>;

    // Must have valid category
    if (typeof item.category !== "string" || !categorySet.has(item.category)) continue;

    // Must have color with hex
    if (
      typeof item.color !== "object" ||
      item.color === null ||
      typeof (item.color as Record<string, unknown>).hex !== "string"
    ) continue;

    const analyzed: AnalyzedItem = {
      index: typeof item.index === "number" ? item.index : valid.length,
      category: item.category as string,
      subcategory: typeof item.subcategory === "string" ? item.subcategory : "",
      color: item.color as AnalyzedItemColor,
      style: Array.isArray(item.style) ? (item.style as string[]) : [],
      fit: typeof item.fit === "string" ? item.fit : null,
      pattern: typeof item.pattern === "string" ? item.pattern : null,
      material: typeof item.material === "string" ? item.material : null,
    };

    valid.push(validateAndFixHsl(analyzed));
  }

  if (valid.length === 0) {
    throw new ClaudeError(
      "No valid fashion items found in image",
      "NO_FASHION_ITEMS"
    );
  }

  return valid;
}

// --- API Call ---

async function callClaude(
  imageBase64: string,
  mediaType: string
): Promise<string> {
  const client = getClient();
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), TIMEOUT_MS);

  try {
    const response = await client.messages.create(
      {
        model: MODEL,
        max_tokens: MAX_TOKENS,
        messages: [
          {
            role: "user",
            content: [
              {
                type: "image",
                source: {
                  type: "base64",
                  media_type: mediaType as
                    | "image/jpeg"
                    | "image/png"
                    | "image/gif"
                    | "image/webp",
                  data: imageBase64,
                },
              },
              { type: "text", text: PROMPT },
            ],
          },
        ],
      },
      { signal: controller.signal }
    );

    const block = response.content[0];
    if (block.type !== "text") {
      throw new Error("Unexpected response content type");
    }
    return block.text;
  } finally {
    clearTimeout(timeout);
  }
}

// --- Main Function ---

export async function analyzeReferenceImage(
  imageBase64: string,
  mediaType: string
): Promise<AnalysisResult> {
  const maxAttempts = 1 + MAX_RETRIES;
  let lastError: Error | null = null;

  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      const text = await callClaude(imageBase64, mediaType);
      const data = parseJsonResponse(text);
      validateStructure(data);
      const items = validateItems(data.items);

      return {
        items,
        overall_style: data.overall_style,
        occasion: data.occasion,
      };
    } catch (e) {
      lastError = e instanceof Error ? e : new Error(String(e));

      // NO_FASHION_ITEMS — don't retry
      if (e instanceof ClaudeError && e.code === "NO_FASHION_ITEMS") {
        throw e;
      }

      // Last attempt — don't wait
      if (attempt < MAX_RETRIES) {
        console.warn(
          `[claude-client] Attempt ${attempt + 1} failed: ${lastError.message}. Retrying...`
        );
        await new Promise((r) => setTimeout(r, RETRY_DELAYS[attempt]));
      }
    }
  }

  // Determine error code from last error
  const isTimeout =
    lastError?.name === "AbortError" ||
    lastError?.message?.includes("abort");
  const code = isTimeout ? "AI_TIMEOUT" : "AI_ERROR";

  throw new ClaudeError(
    `Claude API failed after ${maxAttempts} attempts: ${lastError?.message}`,
    code
  );
}
