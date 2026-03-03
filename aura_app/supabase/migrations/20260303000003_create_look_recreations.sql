-- Migration: create_look_recreations
-- 룩 재현 결과 테이블

CREATE TABLE public.look_recreations (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id               UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reference_image_url   TEXT NOT NULL,
  reference_analysis    JSONB NOT NULL,
  matched_items         JSONB NOT NULL DEFAULT '[]',
  gap_items             JSONB NOT NULL DEFAULT '[]',
  overall_score         INTEGER NOT NULL DEFAULT 0,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 인덱스
CREATE INDEX idx_recreations_user ON look_recreations(user_id);

-- RLS
ALTER TABLE public.look_recreations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own recreations"
  ON public.look_recreations FOR ALL
  USING (auth.uid() = user_id);
