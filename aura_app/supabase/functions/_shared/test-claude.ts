/**
 * test-claude.ts — claude-client.ts 수동 검증 테스트
 *
 * 실행:
 *   cd supabase/functions
 *   ANTHROPIC_API_KEY="sk-ant-..." deno run --allow-net --allow-env --allow-read _shared/test-claude.ts
 *
 * ⚠️ 테스트 완료 후 이 파일은 삭제합니다.
 */

import { analyzeReferenceImage, ClaudeError } from "./claude-client.ts";
import { CATEGORIES } from "./types.ts";
import { encodeBase64 } from "https://deno.land/std@0.224.0/encoding/base64.ts";

const categorySet = new Set<string>(CATEGORIES);

// --- Helpers ---

async function loadLocalImage(path: string): Promise<{ base64: string; bytes: number }> {
  const buf = await Deno.readFile(path);
  const base64 = encodeBase64(buf);
  return { base64, bytes: buf.length };
}

async function downloadImage(url: string): Promise<{ base64: string; bytes: number }> {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Download failed: ${res.status} ${res.statusText}`);
  const buf = new Uint8Array(await res.arrayBuffer());
  const base64 = encodeBase64(buf);
  return { base64, bytes: buf.length };
}

function assert(condition: boolean, msg: string): void {
  if (!condition) throw new Error(`❌ ASSERTION FAILED: ${msg}`);
}

// --- Test 1: 패션 이미지 분석 ---

async function testFashionImage(): Promise<void> {
  console.log("\n=== 테스트 1: 로컬 패션 이미지 분석 (검정 니트) ===");

  const imagePath = "/Users/ochaemin/Pictures/Photos Library.photoslibrary/resources/derivatives/masters/8/8878C015-3C04-4FF4-9A21-5825D844D1E7_4_5005_c.jpeg";
  const { base64, bytes } = await loadLocalImage(imagePath);
  console.log(`✅ 로컬 이미지 로드 완료 (${bytes} bytes)`);

  console.log("⏳ Claude Haiku 호출 중...");
  const result = await analyzeReferenceImage(base64, "image/jpeg");

  // items 배열 검증
  assert(result.items.length >= 1, `items가 1개 이상이어야 함 (실제: ${result.items.length})`);
  console.log(`✅ 분석 성공! (${result.items.length}개 아이템)`);

  // 각 아이템 검증
  for (const item of result.items) {
    // 카테고리 화이트리스트
    assert(categorySet.has(item.category), `카테고리 "${item.category}"가 화이트리스트에 없음`);

    // HEX 형식
    assert(/^#[0-9A-Fa-f]{6}$/.test(item.color.hex), `HEX 형식 오류: ${item.color.hex}`);

    // HSL 범위
    const { h, s, l } = item.color.hsl;
    assert(h >= 0 && h <= 360, `h 범위 오류: ${h}`);
    assert(s >= 0 && s <= 100, `s 범위 오류: ${s}`);
    assert(l >= 0 && l <= 100, `l 범위 오류: ${l}`);
  }

  console.log("  ✅ 카테고리 검증 통과");
  console.log("  ✅ 색상 HEX 형식 검증 통과");
  console.log("  ✅ HSL 범위 검증 통과");

  // overall_style / occasion 존재
  assert(typeof result.overall_style === "string" && result.overall_style.length > 0,
    "overall_style이 비어 있음");
  assert(typeof result.occasion === "string" && result.occasion.length > 0,
    "occasion이 비어 있음");
  console.log("  ✅ overall_style / occasion 존재");

  // 상세 출력 (디버깅용)
  console.log("\n  [상세 결과]");
  for (const item of result.items) {
    console.log(`    #${item.index} ${item.category}/${item.subcategory} — ${item.color.name}(${item.color.hex})`);
  }
  console.log(`    스타일: ${result.overall_style} / 상황: ${result.occasion}`);
}

// --- Test 2: 비패션 이미지 (NO_FASHION_ITEMS) ---

async function testNonFashionImage(): Promise<void> {
  console.log("\n=== 테스트 2: 비패션 이미지 (NO_FASHION_ITEMS) ===");

  // 로컬 초밥 사진
  const imagePath = "/Users/ochaemin/Pictures/Photos Library.photoslibrary/resources/derivatives/masters/B/BF8A5CEE-0001-4D59-AE4D-574B0C9ABBB0_4_5005_c.jpeg";
  const { base64, bytes } = await loadLocalImage(imagePath);
  console.log(`✅ 로컬 이미지 로드 완료 (${bytes} bytes)`);

  console.log("⏳ Claude Haiku 호출 중...");
  try {
    await analyzeReferenceImage(base64, "image/jpeg");
    throw new Error("❌ 에러가 발생하지 않음 — NO_FASHION_ITEMS 예상했으나 성공함");
  } catch (e) {
    if (e instanceof ClaudeError && e.code === "NO_FASHION_ITEMS") {
      console.log("✅ 예상대로 NO_FASHION_ITEMS 에러 발생");
    } else {
      throw e;
    }
  }
}

// --- Main ---

async function main(): Promise<void> {
  // 환경변수 확인
  const key = Deno.env.get("ANTHROPIC_API_KEY");
  if (!key) {
    console.error("❌ ANTHROPIC_API_KEY 환경변수가 설정되지 않았습니다.");
    console.error('   ANTHROPIC_API_KEY="sk-ant-..." deno run --allow-net --allow-env --allow-read _shared/test-claude.ts');
    Deno.exit(1);
  }

  console.log("🔑 API 키 확인됨 (앞 10자: " + key.slice(0, 10) + "...)");

  try {
    await testFashionImage();
    await testNonFashionImage();
    console.log("\n🎉 모든 테스트 통과!");
  } catch (e) {
    console.error("\n💥 테스트 실패:", e);
    Deno.exit(1);
  }
}

main();
