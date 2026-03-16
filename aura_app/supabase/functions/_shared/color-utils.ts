/** CIEDE2000 색차 계산 + 매칭 점수 변환 */

// --- sRGB → XYZ → CIELAB ---

function hexToRgb(hex: string): [number, number, number] {
  const h = hex.replace("#", "");
  if (!/^[0-9a-fA-F]{6}$/.test(h)) return [0, 0, 0]; // invalid → black
  return [
    parseInt(h.slice(0, 2), 16),
    parseInt(h.slice(2, 4), 16),
    parseInt(h.slice(4, 6), 16),
  ];
}

function rgbToXyz(r: number, g: number, b: number): [number, number, number] {
  // sRGB inverse companding
  let rr = r / 255;
  let gg = g / 255;
  let bb = b / 255;

  rr = rr > 0.04045 ? Math.pow((rr + 0.055) / 1.055, 2.4) : rr / 12.92;
  gg = gg > 0.04045 ? Math.pow((gg + 0.055) / 1.055, 2.4) : gg / 12.92;
  bb = bb > 0.04045 ? Math.pow((bb + 0.055) / 1.055, 2.4) : bb / 12.92;

  rr *= 100;
  gg *= 100;
  bb *= 100;

  // D65 matrix
  return [
    rr * 0.4124564 + gg * 0.3575761 + bb * 0.1804375,
    rr * 0.2126729 + gg * 0.7151522 + bb * 0.0721750,
    rr * 0.0193339 + gg * 0.1191920 + bb * 0.9503041,
  ];
}

function xyzToLab(x: number, y: number, z: number): [number, number, number] {
  // D65 reference
  const Xn = 95.047;
  const Yn = 100.0;
  const Zn = 108.883;

  const f = (t: number): number =>
    t > 0.008856 ? Math.cbrt(t) : 7.787 * t + 16 / 116;

  const fx = f(x / Xn);
  const fy = f(y / Yn);
  const fz = f(z / Zn);

  return [
    116 * fy - 16,
    500 * (fx - fy),
    200 * (fy - fz),
  ];
}

/** hex → CIELAB [L, a, b] */
export function hexToLab(hex: string): [number, number, number] {
  const [r, g, b] = hexToRgb(hex);
  const [x, y, z] = rgbToXyz(r, g, b);
  return xyzToLab(x, y, z);
}

// --- CIEDE2000 ---

const RAD = Math.PI / 180;
const DEG = 180 / Math.PI;

/** CIEDE2000 색차 (deltaE00) */
export function deltaE2000(hex1: string, hex2: string): number {
  const [L1, a1, b1] = hexToLab(hex1);
  const [L2, a2, b2] = hexToLab(hex2);

  // Step 1: Calculate C' and h'
  const C1 = Math.sqrt(a1 * a1 + b1 * b1);
  const C2 = Math.sqrt(a2 * a2 + b2 * b2);
  const Cab = (C1 + C2) / 2;

  const Cab7 = Math.pow(Cab, 7);
  const G = 0.5 * (1 - Math.sqrt(Cab7 / (Cab7 + 6103515625))); // 25^7 = 6103515625

  const a1p = a1 * (1 + G);
  const a2p = a2 * (1 + G);

  const C1p = Math.sqrt(a1p * a1p + b1 * b1);
  const C2p = Math.sqrt(a2p * a2p + b2 * b2);

  let h1p = Math.atan2(b1, a1p) * DEG;
  if (h1p < 0) h1p += 360;
  let h2p = Math.atan2(b2, a2p) * DEG;
  if (h2p < 0) h2p += 360;

  // Step 2: Calculate delta values
  const dLp = L2 - L1;
  const dCp = C2p - C1p;

  let dhp: number;
  if (C1p * C2p === 0) {
    dhp = 0;
  } else if (Math.abs(h2p - h1p) <= 180) {
    dhp = h2p - h1p;
  } else if (h2p - h1p > 180) {
    dhp = h2p - h1p - 360;
  } else {
    dhp = h2p - h1p + 360;
  }

  const dHp = 2 * Math.sqrt(C1p * C2p) * Math.sin((dhp / 2) * RAD);

  // Step 3: Calculate CIEDE2000
  const Lp = (L1 + L2) / 2;
  const Cp = (C1p + C2p) / 2;

  let hp: number;
  if (C1p * C2p === 0) {
    hp = h1p + h2p;
  } else if (Math.abs(h1p - h2p) <= 180) {
    hp = (h1p + h2p) / 2;
  } else if (h1p + h2p < 360) {
    hp = (h1p + h2p + 360) / 2;
  } else {
    hp = (h1p + h2p - 360) / 2;
  }

  const T =
    1 -
    0.17 * Math.cos((hp - 30) * RAD) +
    0.24 * Math.cos(2 * hp * RAD) +
    0.32 * Math.cos((3 * hp + 6) * RAD) -
    0.20 * Math.cos((4 * hp - 63) * RAD);

  const Lp50sq = (Lp - 50) * (Lp - 50);
  const SL = 1 + 0.015 * Lp50sq / Math.sqrt(20 + Lp50sq);
  const SC = 1 + 0.045 * Cp;
  const SH = 1 + 0.015 * Cp * T;

  const Cp7 = Math.pow(Cp, 7);
  const RC = 2 * Math.sqrt(Cp7 / (Cp7 + 6103515625));
  const dTheta = 30 * Math.exp(-Math.pow((hp - 275) / 25, 2));
  const RT = -Math.sin(2 * dTheta * RAD) * RC;

  const dLr = dLp / SL;
  const dCr = dCp / SC;
  const dHr = dHp / SH;

  return Math.sqrt(
    dLr * dLr + dCr * dCr + dHr * dHr + RT * dCr * dHr
  );
}

// --- 매칭 점수 변환 ---

/**
 * 두 hex 색상의 유사도를 0~30 점수로 반환.
 * deltaE < 5: 28~30 (거의 동일)
 * deltaE 5~15: 20~28 (유사)
 * deltaE 15~30: 10~20 (같은 톤)
 * deltaE > 30: 0~10 (다른 색)
 */
export function colorScore(hex1: string, hex2: string): number {
  const dE = deltaE2000(hex1, hex2);

  if (dE < 5) {
    // 0→30, 5→28 (linear interpolation)
    return 30 - (dE / 5) * 2;
  } else if (dE < 15) {
    // 5→28, 15→20
    return 28 - ((dE - 5) / 10) * 8;
  } else if (dE < 30) {
    // 15→20, 30→10
    return 20 - ((dE - 15) / 15) * 10;
  } else {
    // 30→10, 100→0 (clamped at 0)
    return Math.max(0, 10 - ((dE - 30) / 70) * 10);
  }
}
