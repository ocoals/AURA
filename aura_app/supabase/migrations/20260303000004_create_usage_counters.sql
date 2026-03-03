-- Migration: create_usage_counters
-- 월별 사용량 카운터 테이블

CREATE TABLE public.usage_counters (
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  month_key        TEXT NOT NULL,
  wardrobe_count   INTEGER NOT NULL DEFAULT 0,
  recreation_count INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, month_key)
);

-- RLS
ALTER TABLE public.usage_counters ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own usage counters"
  ON public.usage_counters FOR ALL
  USING (auth.uid() = user_id);
