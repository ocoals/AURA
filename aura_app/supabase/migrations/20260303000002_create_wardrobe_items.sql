-- Migration: create_wardrobe_items
-- 옷장 아이템 테이블

CREATE TABLE public.wardrobe_items (
  id                 UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id            UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  image_url          TEXT NOT NULL,
  original_image_url TEXT,
  category           TEXT NOT NULL CHECK (category IN (
    'tops','bottoms','outerwear','dresses','shoes','bags','accessories'
  )),
  subcategory        TEXT,
  color_hex          TEXT NOT NULL,
  color_name         TEXT NOT NULL,
  color_hsl          JSONB NOT NULL,
  style_tags         TEXT[] DEFAULT '{}',
  fit                TEXT CHECK (fit IN ('oversized','regular','slim',NULL)),
  pattern            TEXT CHECK (pattern IN ('solid','stripe','check','floral','dot','print','other',NULL)),
  brand              TEXT,
  season             TEXT[] DEFAULT '{spring,summer,fall,winter}',
  wear_count         INTEGER NOT NULL DEFAULT 0,
  last_worn_at       TIMESTAMPTZ,
  is_active          BOOLEAN NOT NULL DEFAULT TRUE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at         TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 인덱스
CREATE INDEX idx_wardrobe_user ON wardrobe_items(user_id) WHERE is_active = TRUE;
CREATE INDEX idx_wardrobe_category ON wardrobe_items(user_id, category) WHERE is_active = TRUE;

-- RLS
ALTER TABLE public.wardrobe_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own wardrobe items"
  ON public.wardrobe_items FOR ALL
  USING (auth.uid() = user_id);

-- updated_at 트리거
CREATE TRIGGER on_wardrobe_items_updated
  BEFORE UPDATE ON public.wardrobe_items
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();
