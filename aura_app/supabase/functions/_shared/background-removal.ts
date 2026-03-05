/** 배경 제거 — remove.bg -> HuggingFace -> mock 폴백 */

export async function removeBackground(
  imageBytes: Uint8Array
): Promise<Uint8Array> {
  // 1) remove.bg
  const removeBgKey = Deno.env.get("REMOVEBG_API_KEY");
  if (removeBgKey) {
    try {
      return await callRemoveBg(imageBytes, removeBgKey);
    } catch (e) {
      console.warn("remove.bg failed, trying HuggingFace:", e);
    }
  }

  // 2) HuggingFace RMBG-1.4
  const hfToken = Deno.env.get("HUGGINGFACE_API_TOKEN");
  if (hfToken) {
    try {
      return await callHuggingFace(imageBytes, hfToken);
    } catch (e) {
      console.warn("HuggingFace failed, falling back to mock:", e);
    }
  }

  // 3) Mock — 원본 그대로 반환
  console.warn(
    "[background-removal] No API keys configured. Returning original image (mock mode)."
  );
  return imageBytes;
}

async function callRemoveBg(
  imageBytes: Uint8Array,
  apiKey: string
): Promise<Uint8Array> {
  const formData = new FormData();
  formData.append(
    "image_file",
    new Blob([imageBytes], { type: "image/jpeg" }),
    "image.jpg"
  );
  formData.append("size", "auto");

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 10_000);

  try {
    const res = await fetch("https://api.remove.bg/v1.0/removebg", {
      method: "POST",
      headers: { "X-Api-Key": apiKey },
      body: formData,
      signal: controller.signal,
    });

    if (!res.ok) {
      throw new Error(`remove.bg HTTP ${res.status}: ${await res.text()}`);
    }

    return new Uint8Array(await res.arrayBuffer());
  } finally {
    clearTimeout(timeout);
  }
}

async function callHuggingFace(
  imageBytes: Uint8Array,
  token: string
): Promise<Uint8Array> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 20_000);

  try {
    const res = await fetch(
      "https://api-inference.huggingface.co/models/briaai/RMBG-1.4",
      {
        method: "POST",
        headers: {
          Authorization: `Bearer ${token}`,
          "Content-Type": "application/octet-stream",
        },
        body: imageBytes,
        signal: controller.signal,
      }
    );

    if (!res.ok) {
      throw new Error(`HuggingFace HTTP ${res.status}: ${await res.text()}`);
    }

    return new Uint8Array(await res.arrayBuffer());
  } finally {
    clearTimeout(timeout);
  }
}
