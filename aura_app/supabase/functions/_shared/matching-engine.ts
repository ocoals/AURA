/** 매칭 엔진 — 레퍼런스 아이템 vs 사용자 옷장 매칭/갭 산출 */

import type { AnalyzedItem } from "./claude-client.ts";
import type {
  WardrobeItemRow,
  ScoreBreakdown,
  MatchedItem,
  GapItem,
  Deeplinks,
  MatchingResult,
} from "./types.ts";
import { colorScore } from "./color-utils.ts";

// --- 상수 ---

const MATCH_THRESHOLD = 50;

// --- 점수 계산 ---

function calcStyleScore(refTags: string[], wardrobeTags: string[]): number {
  if (refTags.length === 0 && wardrobeTags.length === 0) return 10;
  if (refTags.length === 0 || wardrobeTags.length === 0) return 10;

  const refSet = new Set(refTags.map((t) => t.toLowerCase()));
  const wardSet = new Set(wardrobeTags.map((t) => t.toLowerCase()));
  let overlap = 0;
  for (const tag of refSet) {
    if (wardSet.has(tag)) overlap++;
  }

  const union = new Set([...refSet, ...wardSet]).size;
  return Math.round((overlap / union) * 20);
}

function calcBonus(
  ref: AnalyzedItem,
  wardrobe: WardrobeItemRow
): { score: number; reasons: string[] } {
  let score = 0;
  const reasons: string[] = [];

  // 소분류 매칭 (4점)
  if (
    ref.subcategory &&
    wardrobe.subcategory &&
    ref.subcategory.toLowerCase() === wardrobe.subcategory.toLowerCase()
  ) {
    score += 4;
    reasons.push(`같은 ${wardrobe.subcategory} 소분류`);
  }

  // 핏 매칭 (3점)
  if (ref.fit && wardrobe.fit && ref.fit === wardrobe.fit) {
    score += 3;
    reasons.push(`${wardrobe.fit} 핏 일치`);
  }

  // 패턴 매칭 (3점)
  if (ref.pattern && wardrobe.pattern && ref.pattern === wardrobe.pattern) {
    score += 3;
    reasons.push(`${wardrobe.pattern} 패턴 일치`);
  }

  return { score, reasons };
}

function scoreCandidate(
  ref: AnalyzedItem,
  wardrobe: WardrobeItemRow
): { total: number; breakdown: ScoreBreakdown; reasons: string[] } {
  const reasons: string[] = [];

  // 카테고리 (필터 통과 = 40점)
  const categoryPts = 40;
  reasons.push(`같은 ${wardrobe.subcategory || wardrobe.category} 카테고리`);

  // 색상 (0~30점)
  const colorPts = colorScore(ref.color.hex, wardrobe.color_hex);
  if (colorPts >= 25) {
    reasons.push(`유사한 ${wardrobe.color_name} 톤`);
  } else if (colorPts >= 15) {
    reasons.push("비슷한 계열의 색상");
  }

  // 스타일 (0~20점)
  const stylePts = calcStyleScore(ref.style, wardrobe.style_tags);
  if (stylePts >= 15) {
    reasons.push("비슷한 스타일 태그");
  }

  // 보너스 (0~10점)
  const bonus = calcBonus(ref, wardrobe);
  reasons.push(...bonus.reasons);

  const breakdown: ScoreBreakdown = {
    category: categoryPts,
    color: Math.round(colorPts * 10) / 10,
    style: stylePts,
    bonus: bonus.score,
  };

  return {
    total: categoryPts + colorPts + stylePts + bonus.score,
    breakdown,
    reasons,
  };
}

// --- 딥링크 생성 ---

function buildDeeplinks(colorName: string, subcategory: string): Deeplinks {
  const keywords = `${colorName} ${subcategory}`.trim();
  return {
    musinsa: `https://www.musinsa.com/search/goods?keyword=${keywords.replace(/ /g, "+")}`,
    ably: `https://m.a-bly.com/search?keyword=${encodeURIComponent(keywords)}`,
    zigzag: `https://zigzag.kr/search?keyword=${encodeURIComponent(keywords)}`,
  };
}

function buildGapItem(ref: AnalyzedItem): GapItem {
  const colorName = ref.color.name || "";
  const subcategory = ref.subcategory || ref.category;
  return {
    ref_index: ref.index,
    category: ref.category,
    description: `${colorName} ${subcategory}`.trim(),
    search_keywords: `${colorName} ${subcategory}`.trim(),
    deeplinks: buildDeeplinks(colorName, subcategory),
  };
}

// --- 메인 함수 ---

export function matchWardrobe(
  analyzedItems: AnalyzedItem[],
  wardrobeItems: WardrobeItemRow[]
): MatchingResult {
  // 엣지 케이스: 빈 분석 결과
  if (analyzedItems.length === 0) {
    return { matched_items: [], gap_items: [], overall_score: 0 };
  }

  const matched_items: MatchedItem[] = [];
  const gap_items: GapItem[] = [];
  const usedWardrobeIds = new Set<string>();

  for (const ref of analyzedItems) {
    // 1. 같은 카테고리 필터 + 이미 사용된 아이템 제외
    const candidates = wardrobeItems.filter(
      (w) => w.category === ref.category && !usedWardrobeIds.has(w.id)
    );

    // 2. 후보 없으면 → gap
    if (candidates.length === 0) {
      gap_items.push(buildGapItem(ref));
      continue;
    }

    // 3. 후보별 점수 계산
    let bestScore = -1;
    let bestResult: {
      wardrobe: WardrobeItemRow;
      total: number;
      breakdown: ScoreBreakdown;
      reasons: string[];
    } | null = null;

    for (const candidate of candidates) {
      const result = scoreCandidate(ref, candidate);
      if (result.total > bestScore) {
        bestScore = result.total;
        bestResult = { wardrobe: candidate, ...result };
      }
    }

    // 4. 임계값 판정
    if (bestResult && bestResult.total >= MATCH_THRESHOLD) {
      usedWardrobeIds.add(bestResult.wardrobe.id);
      matched_items.push({
        ref_index: ref.index,
        wardrobe_item: bestResult.wardrobe,
        score: Math.round(bestResult.total * 10) / 10,
        breakdown: bestResult.breakdown,
        match_reasons: bestResult.reasons,
      });
    } else {
      gap_items.push(buildGapItem(ref));
    }
  }

  // overall_score: 매칭 점수 합 / 전체 아이템 수
  const totalScore = matched_items.reduce((sum, m) => sum + m.score, 0);
  const overall_score =
    analyzedItems.length > 0
      ? Math.round((totalScore / analyzedItems.length) * 10) / 10
      : 0;

  return { matched_items, gap_items, overall_score };
}
