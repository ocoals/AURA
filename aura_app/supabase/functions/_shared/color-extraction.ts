/** K-Means 색상 추출 + RGB/HSL/한국어명 변환 */

export interface ColorResult {
  hex: string;
  name: string;
  hsl: { h: number; s: number; l: number };
}

// --- 색상 변환 ---

export function rgbToHex(r: number, g: number, b: number): string {
  const toHex = (v: number) =>
    Math.round(Math.max(0, Math.min(255, v)))
      .toString(16)
      .padStart(2, "0");
  return `#${toHex(r)}${toHex(g)}${toHex(b)}`.toUpperCase();
}

export function rgbToHsl(
  r: number,
  g: number,
  b: number
): { h: number; s: number; l: number } {
  r /= 255;
  g /= 255;
  b /= 255;
  const max = Math.max(r, g, b);
  const min = Math.min(r, g, b);
  const l = (max + min) / 2;
  if (max === min) return { h: 0, s: 0, l: Math.round(l * 100) };

  const d = max - min;
  const s = l > 0.5 ? d / (2 - max - min) : d / (max + min);
  let h: number;
  if (max === r) h = ((g - b) / d + (g < b ? 6 : 0)) / 6;
  else if (max === g) h = ((b - r) / d + 2) / 6;
  else h = ((r - g) / d + 4) / 6;

  return {
    h: Math.round(h * 360),
    s: Math.round(s * 100),
    l: Math.round(l * 100),
  };
}

// --- 한국어 색상명 ---

const ACHROMATIC_NAMES: [number, string][] = [
  [95, "화이트"],
  [80, "라이트그레이"],
  [55, "그레이"],
  [25, "차콜"],
  [0, "블랙"],
];

interface HueEntry {
  max: number;
  light: string;
  base: string;
  dark: string;
}

const HUE_MAP: HueEntry[] = [
  { max: 10, light: "살몬", base: "레드", dark: "다크레드" },
  { max: 25, light: "피치", base: "오렌지레드", dark: "마룬" },
  { max: 40, light: "라이트오렌지", base: "오렌지", dark: "브라운" },
  { max: 50, light: "골드", base: "다크옐로우", dark: "올리브" },
  { max: 65, light: "라이트옐로우", base: "옐로우", dark: "다크옐로우" },
  { max: 80, light: "라임", base: "옐로우그린", dark: "올리브그린" },
  { max: 150, light: "라이트그린", base: "그린", dark: "다크그린" },
  { max: 170, light: "민트", base: "틸", dark: "다크틸" },
  { max: 190, light: "라이트시안", base: "시안", dark: "다크시안" },
  { max: 220, light: "스카이블루", base: "블루", dark: "다크블루" },
  { max: 250, light: "라이트인디고", base: "인디고", dark: "네이비" },
  { max: 270, light: "라벤더", base: "퍼플", dark: "다크퍼플" },
  { max: 290, light: "라이트바이올렛", base: "바이올렛", dark: "다크바이올렛" },
  { max: 320, light: "라이트마젠타", base: "마젠타", dark: "다크마젠타" },
  { max: 340, light: "핑크", base: "핫핑크", dark: "다크핑크" },
  { max: 355, light: "로즈", base: "크림슨", dark: "다크크림슨" },
  { max: 361, light: "살몬", base: "레드", dark: "다크레드" },
];

export function hslToKoreanName(h: number, s: number, l: number): string {
  // 무채색
  if (s < 10) {
    for (const [threshold, name] of ACHROMATIC_NAMES) {
      if (l >= threshold) return name;
    }
    return "블랙";
  }

  // 유채색 — hue 범위 탐색
  for (const entry of HUE_MAP) {
    if (h < entry.max) {
      if (l >= 70) return entry.light;
      if (l >= 30) return entry.base;
      return entry.dark;
    }
  }
  return "레드";
}

// --- K-Means++ 색상 추출 ---

type RGB = [number, number, number];

function distSq(a: RGB, b: RGB): number {
  const dr = a[0] - b[0];
  const dg = a[1] - b[1];
  const db = a[2] - b[2];
  return dr * dr + dg * dg + db * db;
}

function kMeansPP(pixels: RGB[], k: number): RGB[] {
  const centroids: RGB[] = [];
  // 첫 centroid: 랜덤
  centroids.push(pixels[Math.floor(Math.random() * pixels.length)]);

  for (let c = 1; c < k; c++) {
    const dists = pixels.map((p) =>
      Math.min(...centroids.map((cen) => distSq(p, cen)))
    );
    const total = dists.reduce((a, b) => a + b, 0);
    let r = Math.random() * total;
    for (let i = 0; i < pixels.length; i++) {
      r -= dists[i];
      if (r <= 0) {
        centroids.push(pixels[i]);
        break;
      }
    }
    if (centroids.length === c) centroids.push(pixels[pixels.length - 1]);
  }
  return centroids;
}

/**
 * RGBA 바이트 배열에서 대표 색상 추출.
 * 투명 픽셀(alpha < 128) 제외, 최대 10,000 픽셀 다운샘플, K-Means(k=3).
 */
export function extractDominantColor(
  rgba: Uint8Array,
  width: number,
  height: number
): ColorResult {
  // 불투명 픽셀만 수집
  const opaquePixels: RGB[] = [];
  const totalPixels = width * height;
  for (let i = 0; i < totalPixels; i++) {
    const offset = i * 4;
    if (rgba[offset + 3] >= 128) {
      opaquePixels.push([rgba[offset], rgba[offset + 1], rgba[offset + 2]]);
    }
  }

  // 불투명 픽셀 없으면 흰색 반환
  if (opaquePixels.length === 0) {
    return { hex: "#FFFFFF", name: "화이트", hsl: { h: 0, s: 0, l: 100 } };
  }

  // 다운샘플링 (최대 10,000개)
  const MAX_SAMPLES = 10_000;
  let samples: RGB[];
  if (opaquePixels.length <= MAX_SAMPLES) {
    samples = opaquePixels;
  } else {
    samples = [];
    const step = opaquePixels.length / MAX_SAMPLES;
    for (let i = 0; i < MAX_SAMPLES; i++) {
      samples.push(opaquePixels[Math.floor(i * step)]);
    }
  }

  // K-Means (k=3, 20 iterations)
  const k = Math.min(3, samples.length);
  let centroids = kMeansPP(samples, k);
  const assignments = new Int32Array(samples.length);

  for (let iter = 0; iter < 20; iter++) {
    // Assign
    for (let i = 0; i < samples.length; i++) {
      let minDist = Infinity;
      let best = 0;
      for (let c = 0; c < k; c++) {
        const d = distSq(samples[i], centroids[c]);
        if (d < minDist) {
          minDist = d;
          best = c;
        }
      }
      assignments[i] = best;
    }

    // Update centroids
    const sums = Array.from({ length: k }, () => [0, 0, 0]);
    const counts = new Int32Array(k);
    for (let i = 0; i < samples.length; i++) {
      const c = assignments[i];
      sums[c][0] += samples[i][0];
      sums[c][1] += samples[i][1];
      sums[c][2] += samples[i][2];
      counts[c]++;
    }

    centroids = centroids.map((prev, c) => {
      if (counts[c] === 0) return prev;
      return [
        sums[c][0] / counts[c],
        sums[c][1] / counts[c],
        sums[c][2] / counts[c],
      ] as RGB;
    });
  }

  // 가장 큰 클러스터 = 대표색
  const clusterCounts = new Int32Array(k);
  for (let i = 0; i < samples.length; i++) {
    clusterCounts[assignments[i]]++;
  }
  let dominantIdx = 0;
  for (let c = 1; c < k; c++) {
    if (clusterCounts[c] > clusterCounts[dominantIdx]) dominantIdx = c;
  }

  const [r, g, b] = centroids[dominantIdx].map(Math.round);
  const hex = rgbToHex(r, g, b);
  const hsl = rgbToHsl(r, g, b);
  const name = hslToKoreanName(hsl.h, hsl.s, hsl.l);

  return { hex, name, hsl };
}
