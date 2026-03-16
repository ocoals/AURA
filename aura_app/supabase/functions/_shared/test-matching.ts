/**
 * test-matching.ts — 매칭 엔진 + CIEDE2000 검증 테스트
 *
 * 실행:
 *   cd aura_app/supabase/functions
 *   deno run --allow-read _shared/test-matching.ts
 */

import { hexToLab, deltaE2000, colorScore } from "./color-utils.ts";
import { matchWardrobe } from "./matching-engine.ts";
import type { AnalyzedItem } from "./claude-client.ts";
import type { WardrobeItemRow } from "./types.ts";

// --- Helpers ---

let passed = 0;
let failed = 0;

function assert(condition: boolean, msg: string): void {
  if (condition) {
    passed++;
  } else {
    failed++;
    console.error(`  ❌ FAIL: ${msg}`);
  }
}

function approxEqual(a: number, b: number, tolerance: number): boolean {
  return Math.abs(a - b) <= tolerance;
}

function makeRef(overrides: Partial<AnalyzedItem> & { index: number; category: string }): AnalyzedItem {
  return {
    subcategory: "",
    color: { hex: "#000000", name: "블랙", hsl: { h: 0, s: 0, l: 0 } },
    style: [],
    fit: null,
    pattern: null,
    material: null,
    ...overrides,
  };
}

function makeWardrobe(overrides: Partial<WardrobeItemRow> & { id: string; category: WardrobeItemRow["category"] }): WardrobeItemRow {
  return {
    subcategory: null,
    color_hex: "#000000",
    color_name: "블랙",
    style_tags: [],
    fit: null,
    pattern: null,
    ...overrides,
  };
}

// =====================================================
// Test 1: CIEDE2000 정확도
// =====================================================

function testCIEDE2000(): void {
  console.log("\n=== 테스트 1: CIEDE2000 정확도 ===");

  // 동일 색상 → deltaE = 0
  const d0 = deltaE2000("#FF0000", "#FF0000");
  assert(d0 === 0, `동일 색상 deltaE = 0 (실제: ${d0})`);

  // 매우 유사한 색상 → deltaE < 5
  const d1 = deltaE2000("#FF0000", "#FE0502");
  assert(d1 < 5, `유사한 빨강 deltaE < 5 (실제: ${d1.toFixed(2)})`);

  // 보색 (빨강 vs 시안) → deltaE > 40
  const d2 = deltaE2000("#FF0000", "#00FFFF");
  assert(d2 > 40, `보색 deltaE > 40 (실제: ${d2.toFixed(2)})`);

  // 검정 vs 흰색 → deltaE ~ 100
  const d3 = deltaE2000("#000000", "#FFFFFF");
  assert(d3 > 90, `검정-흰색 deltaE > 90 (실제: ${d3.toFixed(2)})`);

  // 네이비 vs 블루 → deltaE 10~30 정도
  const d4 = deltaE2000("#1B2A4A", "#3B5998");
  assert(d4 > 5 && d4 < 35, `네이비-블루 deltaE 5~35 (실제: ${d4.toFixed(2)})`);

  // hexToLab: 흰색 → L ~100
  const [Lw] = hexToLab("#FFFFFF");
  assert(approxEqual(Lw, 100, 1), `흰색 L* ~ 100 (실제: ${Lw.toFixed(2)})`);

  // hexToLab: 검정 → L ~0
  const [Lb] = hexToLab("#000000");
  assert(approxEqual(Lb, 0, 1), `검정 L* ~ 0 (실제: ${Lb.toFixed(2)})`);

  console.log("  CIEDE2000 테스트 완료");
}

// =====================================================
// Test 2: colorScore 변환
// =====================================================

function testColorScore(): void {
  console.log("\n=== 테스트 2: colorScore 변환 ===");

  // 동일 색상 → 30점
  const s0 = colorScore("#336699", "#336699");
  assert(s0 === 30, `동일 색상 = 30점 (실제: ${s0})`);

  // 매우 유사 → 28~30
  const s1 = colorScore("#336699", "#35689B");
  assert(s1 >= 26 && s1 <= 30, `유사 색상 26~30점 (실제: ${s1.toFixed(1)})`);

  // 완전히 다른 색 → 0~10
  const s2 = colorScore("#FF0000", "#00FF00");
  assert(s2 <= 15, `다른 색 <= 15점 (실제: ${s2.toFixed(1)})`);

  // 범위 확인: 항상 0~30
  const s3 = colorScore("#000000", "#FFFFFF");
  assert(s3 >= 0 && s3 <= 30, `점수 범위 0~30 (실제: ${s3.toFixed(1)})`);

  console.log("  colorScore 테스트 완료");
}

// =====================================================
// Test 3: 완벽 매칭
// =====================================================

function testPerfectMatch(): void {
  console.log("\n=== 테스트 3: 완벽 매칭 ===");

  const refs: AnalyzedItem[] = [
    makeRef({
      index: 0,
      category: "tops",
      subcategory: "니트",
      color: { hex: "#1B1B1B", name: "블랙", hsl: { h: 0, s: 0, l: 10 } },
      style: ["casual", "minimal"],
      fit: "regular",
      pattern: "solid",
    }),
  ];

  const wardrobe: WardrobeItemRow[] = [
    makeWardrobe({
      id: "w1",
      category: "tops",
      subcategory: "니트",
      color_hex: "#1B1B1B",
      color_name: "블랙",
      style_tags: ["casual", "minimal"],
      fit: "regular",
      pattern: "solid",
    }),
  ];

  const result = matchWardrobe(refs, wardrobe);

  assert(result.matched_items.length === 1, `매칭 1개 (실제: ${result.matched_items.length})`);
  assert(result.gap_items.length === 0, `갭 0개 (실제: ${result.gap_items.length})`);
  assert(result.overall_score >= 90, `점수 >= 90 (실제: ${result.overall_score})`);

  if (result.matched_items.length > 0) {
    const m = result.matched_items[0];
    assert(m.breakdown.category === 40, `카테고리 40점`);
    assert(m.breakdown.color >= 28, `색상 >= 28점 (실제: ${m.breakdown.color})`);
    assert(m.breakdown.style === 20, `스타일 20점 (실제: ${m.breakdown.style})`);
    assert(m.breakdown.bonus === 10, `보너스 10점 (실제: ${m.breakdown.bonus})`);
  }

  console.log("  완벽 매칭 테스트 완료");
}

// =====================================================
// Test 4: 양호 매칭
// =====================================================

function testGoodMatch(): void {
  console.log("\n=== 테스트 4: 양호 매칭 (유사 속성) ===");

  const refs: AnalyzedItem[] = [
    makeRef({
      index: 0,
      category: "tops",
      subcategory: "셔츠",
      color: { hex: "#1A3B6E", name: "네이비", hsl: { h: 215, s: 60, l: 27 } },
      style: ["formal", "classic", "office"],
      fit: "regular",
      pattern: "solid",
    }),
  ];

  const wardrobe: WardrobeItemRow[] = [
    makeWardrobe({
      id: "w1",
      category: "tops",
      subcategory: "블라우스",
      color_hex: "#2B4F82",
      color_name: "블루",
      style_tags: ["classic", "minimal"],
      fit: "regular",
      pattern: "solid",
    }),
  ];

  const result = matchWardrobe(refs, wardrobe);

  assert(result.matched_items.length === 1, `매칭 1개`);
  const score = result.overall_score;
  assert(score >= 60 && score <= 90, `점수 60~90 (실제: ${score})`);

  console.log("  양호 매칭 테스트 완료");
}

// =====================================================
// Test 5: 임계값 경계 (50점 미만 → 갭)
// =====================================================

function testThreshold(): void {
  console.log("\n=== 테스트 5: 임계값 경계 ===");

  const refs: AnalyzedItem[] = [
    makeRef({
      index: 0,
      category: "tops",
      subcategory: "셔츠",
      color: { hex: "#FF0000", name: "레드", hsl: { h: 0, s: 100, l: 50 } },
      style: ["street", "punk"],
      fit: "oversized",
      pattern: "print",
    }),
  ];

  // 카테고리만 같고 나머지 전부 다름
  const wardrobe: WardrobeItemRow[] = [
    makeWardrobe({
      id: "w1",
      category: "tops",
      subcategory: "블라우스",
      color_hex: "#00FF00",
      color_name: "그린",
      style_tags: ["elegant", "romantic"],
      fit: "slim",
      pattern: "floral",
    }),
  ];

  const result = matchWardrobe(refs, wardrobe);

  // 카테고리 40 + 색상 낮음 + 스타일 0 + 보너스 0 → < 50
  assert(result.gap_items.length === 1, `갭 1개 (실제: ${result.gap_items.length})`);
  assert(result.matched_items.length === 0, `매칭 0개 (실제: ${result.matched_items.length})`);

  console.log("  임계값 테스트 완료");
}

// =====================================================
// Test 6: 중복 방지
// =====================================================

function testNoDuplicate(): void {
  console.log("\n=== 테스트 6: 중복 방지 ===");

  // 레퍼런스: tops 2개
  const refs: AnalyzedItem[] = [
    makeRef({
      index: 0,
      category: "tops",
      subcategory: "니트",
      color: { hex: "#333333", name: "차콜", hsl: { h: 0, s: 0, l: 20 } },
      style: ["casual"],
    }),
    makeRef({
      index: 1,
      category: "tops",
      subcategory: "셔츠",
      color: { hex: "#FFFFFF", name: "화이트", hsl: { h: 0, s: 0, l: 100 } },
      style: ["formal"],
    }),
  ];

  // 옷장: tops 2개
  const wardrobe: WardrobeItemRow[] = [
    makeWardrobe({
      id: "w1",
      category: "tops",
      subcategory: "니트",
      color_hex: "#333333",
      color_name: "차콜",
      style_tags: ["casual"],
    }),
    makeWardrobe({
      id: "w2",
      category: "tops",
      subcategory: "셔츠",
      color_hex: "#FAFAFA",
      color_name: "화이트",
      style_tags: ["formal"],
    }),
  ];

  const result = matchWardrobe(refs, wardrobe);

  assert(result.matched_items.length === 2, `매칭 2개 (실제: ${result.matched_items.length})`);
  assert(result.gap_items.length === 0, `갭 0개 (실제: ${result.gap_items.length})`);

  // 서로 다른 옷장 아이템에 매칭
  if (result.matched_items.length === 2) {
    const ids = result.matched_items.map((m) => m.wardrobe_item.id);
    assert(ids[0] !== ids[1], `서로 다른 아이템 매칭 (${ids[0]} vs ${ids[1]})`);
  }

  console.log("  중복 방지 테스트 완료");
}

// =====================================================
// Test 7: 빈 옷장
// =====================================================

function testEmptyWardrobe(): void {
  console.log("\n=== 테스트 7: 빈 옷장 ===");

  const refs: AnalyzedItem[] = [
    makeRef({
      index: 0,
      category: "tops",
      subcategory: "니트",
      color: { hex: "#000000", name: "블랙", hsl: { h: 0, s: 0, l: 0 } },
    }),
    makeRef({
      index: 1,
      category: "bottoms",
      subcategory: "청바지",
      color: { hex: "#3B5998", name: "블루", hsl: { h: 220, s: 45, l: 41 } },
    }),
  ];

  const result = matchWardrobe(refs, []);

  assert(result.matched_items.length === 0, `매칭 0개`);
  assert(result.gap_items.length === 2, `갭 2개 (실제: ${result.gap_items.length})`);
  assert(result.overall_score === 0, `점수 0 (실제: ${result.overall_score})`);

  console.log("  빈 옷장 테스트 완료");
}

// =====================================================
// Test 8: 빈 분석 결과
// =====================================================

function testEmptyAnalysis(): void {
  console.log("\n=== 테스트 8: 빈 분석 결과 ===");

  const result = matchWardrobe([], [
    makeWardrobe({ id: "w1", category: "tops" }),
  ]);

  assert(result.matched_items.length === 0, `매칭 0개`);
  assert(result.gap_items.length === 0, `갭 0개`);
  assert(result.overall_score === 0, `점수 0`);

  console.log("  빈 분석 결과 테스트 완료");
}

// =====================================================
// Test 9: 딥링크 URL 검증
// =====================================================

function testDeeplinks(): void {
  console.log("\n=== 테스트 9: 딥링크 URL 검증 ===");

  const refs: AnalyzedItem[] = [
    makeRef({
      index: 0,
      category: "outerwear",
      subcategory: "자켓",
      color: { hex: "#8B4513", name: "브라운", hsl: { h: 25, s: 75, l: 31 } },
    }),
  ];

  const result = matchWardrobe(refs, []);

  assert(result.gap_items.length === 1, `갭 1개`);

  if (result.gap_items.length > 0) {
    const gap = result.gap_items[0];
    assert(gap.description === "브라운 자켓", `설명 = "브라운 자켓" (실제: "${gap.description}")`);
    assert(
      gap.deeplinks.musinsa.includes("keyword="),
      `무신사 딥링크에 keyword 포함`
    );
    assert(
      gap.deeplinks.ably.includes("keyword="),
      `에이블리 딥링크에 keyword 포함`
    );
    assert(
      gap.deeplinks.zigzag.includes("keyword="),
      `지그재그 딥링크에 keyword 포함`
    );
    // 한국어 인코딩 확인
    assert(
      gap.deeplinks.musinsa.includes("+"),
      `무신사 URL + 구분자 사용`
    );
    assert(
      gap.deeplinks.ably.includes("%"),
      `에이블리 URL encodeURIComponent 사용`
    );
  }

  console.log("  딥링크 테스트 완료");
}

// =====================================================
// Test 10: 잘못된 hex 방어
// =====================================================

function testInvalidHex(): void {
  console.log("\n=== 테스트 10: 잘못된 hex 방어 ===");

  // 잘못된 hex → 에러 없이 동작
  const d = deltaE2000("#ZZZZZZ", "#FF0000");
  assert(typeof d === "number" && !isNaN(d), `잘못된 hex에도 숫자 반환 (실제: ${d})`);

  const s = colorScore("#invalid", "#000000");
  assert(typeof s === "number" && s >= 0 && s <= 30, `잘못된 hex 점수 범위 내 (실제: ${s})`);

  console.log("  잘못된 hex 방어 테스트 완료");
}

// --- Main ---

function main(): void {
  console.log("🧪 매칭 엔진 테스트 시작\n");

  testCIEDE2000();
  testColorScore();
  testPerfectMatch();
  testGoodMatch();
  testThreshold();
  testNoDuplicate();
  testEmptyWardrobe();
  testEmptyAnalysis();
  testDeeplinks();
  testInvalidHex();

  console.log(`\n${"─".repeat(40)}`);
  console.log(`✅ 통과: ${passed}`);
  if (failed > 0) {
    console.log(`❌ 실패: ${failed}`);
    Deno.exit(1);
  } else {
    console.log("🎉 모든 테스트 통과!");
  }
}

main();
