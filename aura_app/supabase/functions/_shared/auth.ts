import { createClient } from "jsr:@supabase/supabase-js@2";

export interface AuthResult {
  userId: string;
  supabase: ReturnType<typeof createClient>;
}

/**
 * JWT 검증 + 인증된 Supabase 클라이언트 생성.
 * 실패 시 null 반환.
 */
export async function authenticateRequest(
  req: Request
): Promise<AuthResult | null> {
  const authHeader = req.headers.get("Authorization");
  if (!authHeader) return null;

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_ANON_KEY")!,
    {
      global: {
        headers: { Authorization: authHeader },
      },
    }
  );

  const {
    data: { user },
    error,
  } = await supabase.auth.getUser();

  if (error || !user) return null;

  return { userId: user.id, supabase };
}
