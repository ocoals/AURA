import { S3Client, PutObjectCommand, DeleteObjectCommand, GetObjectCommand } from "npm:@aws-sdk/client-s3@3";
import { getSignedUrl } from "npm:@aws-sdk/s3-request-presigner@3";

function getR2Client(): S3Client {
  return new S3Client({
    region: "auto",
    endpoint: `https://${Deno.env.get("R2_ACCOUNT_ID")}.r2.cloudflarestorage.com`,
    credentials: {
      accessKeyId: Deno.env.get("R2_ACCESS_KEY_ID")!,
      secretAccessKey: Deno.env.get("R2_SECRET_ACCESS_KEY")!,
    },
  });
}

const BUCKET = () => Deno.env.get("R2_BUCKET_NAME") ?? "aura-dev";

/**
 * R2에 파일 업로드.
 */
export async function uploadToR2(
  key: string,
  body: Uint8Array | ReadableStream,
  contentType: string
): Promise<string> {
  const client = getR2Client();
  await client.send(
    new PutObjectCommand({
      Bucket: BUCKET(),
      Key: key,
      Body: body,
      ContentType: contentType,
    })
  );
  return `${Deno.env.get("R2_PUBLIC_URL")}/${key}`;
}

/**
 * R2에서 파일 삭제.
 */
export async function deleteFromR2(key: string): Promise<void> {
  const client = getR2Client();
  await client.send(
    new DeleteObjectCommand({
      Bucket: BUCKET(),
      Key: key,
    })
  );
}

/**
 * 서명 URL 생성 (private 파일 접근용, 기본 1시간).
 */
export async function getSignedR2Url(
  key: string,
  expiresIn = 3600
): Promise<string> {
  const client = getR2Client();
  return await getSignedUrl(
    client,
    new GetObjectCommand({
      Bucket: BUCKET(),
      Key: key,
    }),
    { expiresIn }
  );
}

/**
 * R2 저장 경로 헬퍼.
 */
export const r2Paths = {
  original: (userId: string, itemId: string) =>
    `originals/${userId}/${itemId}.jpg`,
  processed: (userId: string, itemId: string) =>
    `processed/${userId}/${itemId}.png`,
  reference: (userId: string, recId: string) =>
    `references/${userId}/${recId}.jpg`,
  outfit: (userId: string, date: string) =>
    `outfits/${userId}/${date}.jpg`,
};
