# AURA — 기술 설계 문서 (Technical Design Document)

> **서비스:** AURA — AI 패션 코디 매칭
> **버전:** 2.0 (MVP)
> **작성일:** 2026-03-02
> **관련 문서:** 02-PRD.md, 03-ui-ux-design.md, AURA-UI-Design-System.md
> **UI 버전:** v4.9

---

## 1. 아키텍처 총괄

### 1.1 핵심 설계 결정

**자체 AI 서버 0대.** 모든 AI 추론은 Claude Haiku API 호출. 1인 개발자가 관리할 것은 "앱 + Edge Functions"뿐.

```
CLIENT (Flutter iOS/Android)
    │
    │ HTTPS (REST API)
    ▼
API LAYER (Supabase Edge Functions - Deno/TypeScript)
    │
    ├── Supabase PostgreSQL (DB + Auth + RLS)
    ├── Cloudflare R2 (이미지 저장 + CDN)
    └── Claude Haiku API (AI 추론, 룩 재현 전용)
```

### 1.2 기술 스택

| 계층 | 기술 | 선택 근거 |
|------|------|----------|
| 모바일 앱 | Flutter (Dart) | iOS/Android 동시 개발, 1인 개발자 최적 |
| API 서버 | Supabase Edge Functions (Deno/TS) | 서버 관리 불필요, 자동 스케일링 |
| 데이터베이스 | Supabase PostgreSQL | RLS 내장, Realtime 구독, Free → Pro |
| 이미지 저장 | Cloudflare R2 | S3 호환, egress 무료, 무료 10GB, CDN 내장 |
| AI 추론 | Claude Haiku API | 건당 ~$0.001, 프롬프트 변경만으로 분석 범위 조정 |
| 인증 | Supabase Auth | 카카오/Apple 소셜 로그인, JWT, RLS 연동 |
| 배경 제거 | remove.bg API (Free) → rembg fallback | 월 50회 무료(고품질), 초과 시 HF API |
| 푸시 알림 | Firebase Cloud Messaging | 무료, Flutter 네이티브 지원 |
| 날씨 | OpenWeather API | 무료 1,000 calls/day |
| 모니터링 | Sentry (Free tier) | 에러 추적, Flutter + Edge Function |

### 1.3 AI 사용 지점 (전체 서비스에서 단 1곳)

| 기능 | AI 사용 | 기술 | 앱 내 위치 (v4.9) |
|------|---------|------|-------------------|
| 배경 제거 | ❌ | remove.bg API / rembg | Closet 탭 → FAB |
| 색상 추출 | ❌ | K-Means 클러스터링 (코드 로직) | Closet 탭 → FAB |
| 카테고리 선택 | ❌ | 사용자 탭 UI | Closet 탭 → FAB |
| **룩 재현 (레퍼런스 분석)** | **✅ Claude Haiku 1회** | **이미지 → 아이템 JSON** | **Match 탭 (#9→#10)** |
| 옷장 매칭 | ❌ | DB 쿼리 + 점수 계산 코드 | Match 탭 (#10) |
| 코디 추천 | ❌ | 규칙 기반 (날씨 + 착용이력) | Home 탭 (#7) |
| 갭 분석 딥링크 | ❌ | URL 문자열 생성 | Match 탭 (#10) |

---

## 2. 인프라 설계

### 2.1 Edge Functions 구조

```
supabase/functions/
├── _shared/                    # 공유 유틸리티
│   ├── cors.ts                 # CORS 헤더
│   ├── auth.ts                 # JWT 검증 + 사용자 조회
│   ├── rate-limit.ts           # 요금제별 Rate Limit
│   ├── r2-client.ts            # Cloudflare R2 업로드/삭제
│   ├── claude-client.ts        # Claude Haiku API 래퍼
│   ├── color-utils.ts          # 색상 변환/거리 계산 (CIEDE2000)
│   ├── matching-engine.ts      # 매칭 점수 계산 핵심
│   └── types.ts                # 공유 타입 정의
├── wardrobe-upload/            # POST — 이미지 처리 + 아이템 생성
├── wardrobe-items/             # GET/PATCH/DELETE — CRUD
├── recreate-analyze/           # POST — AI분석 + 매칭 (핵심 API)
├── recreate-history/           # GET — 재현 히스토리
├── outfit-daily/               # POST/GET — 데일리 코디 (Tier 2)
├── outfit-recommend/           # GET — 코디 추천 (Tier 2)
├── billing-subscribe/          # POST — IAP 영수증 검증 (Tier 2)
└── billing-webhook/            # POST — 스토어 서버 알림 (Tier 2)
```

### 2.2 Cloudflare R2 이미지 저장 구조

| 경로 | 용도 | 접근 | 보존 |
|------|------|------|------|
| `/originals/{user_id}/{item_id}.jpg` | 원본 전신 사진 | Private (서명 URL) | 계정 삭제 시 |
| `/processed/{user_id}/{item_id}.webp` | 배경 제거된 아이템 | Public CDN | 계정 삭제 시 |
| `/references/{user_id}/{rec_id}.jpg` | 룩 재현 레퍼런스 | Private (서명 URL) | 6개월 |
| `/outfits/{user_id}/{date}.jpg` | 데일리 코디 전신 | Private (서명 URL) | 계정 삭제 시 |

**이미지 최적화:** 원본 JPEG max 2048px q85, 배경제거 WebP max 1024px q80, 아이템당 ~450KB

**R2 버킷 네이밍:**

| 환경 | 버킷명 |
|------|--------|
| Development | aura-dev |
| Staging | aura-staging |
| Production | aura-prod |

### 2.3 사용자 규모별 월 인프라 비용

| 구성요소 | 1,000명 | 5,000명 | 10,000명 |
|----------|---------|---------|----------|
| Supabase | Free (0원) | Pro (3.3만원) | Pro (3.3만원) |
| Cloudflare R2 | Free (0원) | ~2만원 | ~5만원 |
| Claude Haiku API | ~5,000원 | ~3.6만원 | ~7만원 |
| remove.bg | Free (0원) | ~1만원 | ~3만원 |
| **합계** | **~1.3만원** | **~11만원** | **~19만원** |

---

## 3. 데이터베이스 설계

### 3.1 ER 다이어그램 (핵심 관계)

```
profiles (1) ──── (N) wardrobe_items
    │                      │
    │                      │ (referenced in JSONB)
    │                      │
    ├──── (N) look_recreations
    │
    ├──── (N) daily_outfits ──── (N:M) outfit_items ──── wardrobe_items
    │
    ├──── (N) subscriptions
    │
    └──── (N) usage_counters (월별)
```

### 3.2 핵심 테이블 DDL

#### profiles (Supabase Auth 확장)

```sql
CREATE TABLE public.profiles (
  id              UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name    TEXT NOT NULL DEFAULT '',
  gender          TEXT CHECK (gender IN ('female','male','other','unset')) DEFAULT 'unset',
  birth_year      INTEGER,
  onboarding_completed BOOLEAN NOT NULL DEFAULT FALSE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

#### wardrobe_items (옷장 아이템)

```sql
CREATE TABLE public.wardrobe_items (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  image_url         TEXT NOT NULL,           -- 배경 제거된 WebP (R2 public CDN)
  original_image_url TEXT,                   -- 원본 JPEG (R2 key)
  category          TEXT NOT NULL CHECK (category IN (
    'tops','bottoms','outerwear','dresses','shoes','bags','accessories'
  )),
  subcategory       TEXT,                    -- 'knit','jeans','sneakers' 등
  color_hex         TEXT NOT NULL,           -- '#2C3E50'
  color_name        TEXT NOT NULL,           -- '네이비'
  color_hsl         JSONB NOT NULL,          -- {"h":210,"s":35,"l":24}
  style_tags        TEXT[] DEFAULT '{}',     -- {'casual','minimal'}
  fit               TEXT CHECK (fit IN ('oversized','regular','slim',NULL)),
  pattern           TEXT CHECK (pattern IN ('solid','stripe','check','floral','dot','print','other',NULL)),
  brand             TEXT,
  season            TEXT[] DEFAULT '{spring,summer,fall,winter}',
  wear_count        INTEGER NOT NULL DEFAULT 0,
  last_worn_at      TIMESTAMPTZ,
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_wardrobe_user ON wardrobe_items(user_id) WHERE is_active = TRUE;
CREATE INDEX idx_wardrobe_category ON wardrobe_items(user_id, category) WHERE is_active = TRUE;
```

#### look_recreations (룩 재현 결과)

```sql
CREATE TABLE public.look_recreations (
  id                   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id              UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  reference_image_url  TEXT NOT NULL,
  reference_analysis   JSONB NOT NULL,    -- Claude Haiku 응답 원본
  matched_items        JSONB NOT NULL DEFAULT '[]',
  gap_items            JSONB NOT NULL DEFAULT '[]',
  overall_score        INTEGER NOT NULL DEFAULT 0,
  created_at           TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

#### usage_counters (요금제 제한 관리)

```sql
CREATE TABLE public.usage_counters (
  user_id          UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  month_key        TEXT NOT NULL,          -- '2026-03'
  wardrobe_count   INTEGER NOT NULL DEFAULT 0,
  recreation_count INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, month_key)
);
```

#### daily_outfits + outfit_items (Tier 2)

```sql
CREATE TABLE public.daily_outfits (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  outfit_date DATE NOT NULL,
  image_url   TEXT,
  notes       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, outfit_date)
);

CREATE TABLE public.outfit_items (
  outfit_id UUID NOT NULL REFERENCES daily_outfits(id) ON DELETE CASCADE,
  item_id   UUID NOT NULL REFERENCES wardrobe_items(id) ON DELETE CASCADE,
  position  INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (outfit_id, item_id)
);
```

#### subscriptions (Tier 2)

```sql
CREATE TABLE public.subscriptions (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  plan           TEXT NOT NULL CHECK (plan IN ('monthly','yearly','early_bird')),
  status         TEXT NOT NULL CHECK (status IN ('active','expired','cancelled','pending')) DEFAULT 'pending',
  platform       TEXT NOT NULL CHECK (platform IN ('apple','google')),
  receipt_data   TEXT,
  transaction_id TEXT,
  started_at     TIMESTAMPTZ,
  expires_at     TIMESTAMPTZ,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

### 3.3 Row Level Security (모든 테이블)

```sql
-- 모든 테이블에 동일 패턴 적용
ALTER TABLE public.[테이블명] ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own data"
  ON public.[테이블명] FOR ALL USING (auth.uid() = user_id);
```

### 3.4 카테고리 enum 매핑

| DB (영문) | 한국어 | subcategory 예시 |
|-----------|--------|-----------------|
| tops | 상의 | tshirt, shirt, blouse, knit, sweatshirt, hoodie, vest |
| bottoms | 하의 | jeans, slacks, shorts, skirt, leggings |
| outerwear | 아우터 | jacket, coat, padding, cardigan, windbreaker |
| dresses | 원피스 | mini, midi, maxi, jumpsuit |
| shoes | 신발 | sneakers, boots, sandals, loafers, heels |
| bags | 가방 | backpack, shoulder, crossbody, tote, clutch |
| accessories | 액세서리 | hat, scarf, belt, jewelry, sunglasses |

---

## 4. API 명세서

### 4.0 공통 사항

- **Base URL:** `https://[PROJECT_REF].supabase.co/functions/v1`
- **인증:** `Authorization: Bearer <supabase_access_token>`
- **Content-Type:** `application/json` (이미지 업로드는 `multipart/form-data`)
- **에러 응답:** `{"error": "message", "code": "ERROR_CODE"}`

### 4.1 POST /wardrobe/upload — 아이템 등록

전신 사진 업로드 → 배경 제거 → 색상 추출 → 아이템 생성. **AI 호출 0회.**

**앱 내 위치:** Closet 탭 (#8) → FAB (+) → 카메라

**Request** (multipart/form-data):

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| image | File | ✅ | JPEG/PNG, max 10MB |
| category | string | ✅ | tops/bottoms/outerwear/dresses/shoes/bags/accessories |
| subcategory | string | | 세부 카테고리 |
| style_tags | string | | JSON array 문자열 `'["casual"]'` |
| fit | string | | oversized/regular/slim |
| pattern | string | | solid/stripe/check/floral/dot/print/other |
| brand | string | | 브랜드명 |
| season | string | | JSON array 문자열 `'["fall","winter"]'` |

**Response 201:**
```json
{
  "id": "uuid",
  "image_url": "https://images.aura-app.kr/processed/...",
  "category": "tops",
  "color_hex": "#5B7DB1",
  "color_name": "스틸블루",
  "color_hsl": {"h": 214, "s": 32, "l": 53},
  "style_tags": ["casual"],
  "wear_count": 0,
  "created_at": "2026-03-02T09:00:00Z"
}
```

**에러:** 400 (이미지 누락), 403 (WARDROBE_LIMIT_REACHED → 프리미엄 모달 #12 트리거), 413 (10MB 초과)

### 4.2 GET /wardrobe/items — 아이템 목록

**앱 내 위치:** Closet 탭 (#8) — 카테고리 스토리 행 필터 + Masonry 그리드

**Query Parameters:**

| 파라미터 | 기본값 | 설명 |
|----------|--------|------|
| category | (전체) | 카테고리 필터 |
| sort | created_at | created_at / wear_count / last_worn_at |
| order | desc | desc / asc |
| limit | 20 | 1~50 |
| offset | 0 | 페이지네이션 |

**Response 200:** `{ "items": [...], "total": 28, "has_more": true }`

### 4.3 PATCH /wardrobe/items/:id — 아이템 수정

**Body:** 수정할 필드만 포함 (category, subcategory, style_tags, fit, pattern, brand, season)

### 4.4 DELETE /wardrobe/items/:id — 아이템 삭제

소프트 삭제 (is_active = false). R2 이미지는 30일 후 정리.

### 4.5 POST /recreate/analyze — 룩 재현 (핵심 API)

레퍼런스 이미지 → **Claude Haiku 1회 호출** → 매칭 엔진 → 결과 반환

**앱 내 위치:** Match 탭 (#9 업로드) → (#10 결과)

**Request** (multipart/form-data):

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| reference_image | File | ✅ | JPEG/PNG, max 10MB |

**Response 200:**
```json
{
  "id": "rec-uuid",
  "overall_score": 78,
  "reference_analysis": {
    "items": [
      {
        "index": 0,
        "category": "tops",
        "subcategory": "knit",
        "color": {"hex": "#F5F0E8", "name": "크림", "hsl": {"h":40,"s":50,"l":93}},
        "style": ["casual", "minimal"],
        "fit": "oversized",
        "pattern": "solid"
      }
    ],
    "overall_style": "casual_minimal",
    "occasion": "daily"
  },
  "matched_items": [
    {
      "ref_index": 0,
      "wardrobe_item": { "id": "...", "image_url": "...", "color_name": "아이보리" },
      "score": 92,
      "breakdown": {"category": 40, "color": 29, "style": 18, "bonus": 5},
      "match_reasons": ["같은 니트 카테고리", "유사한 크림 톤"]
    }
  ],
  "gap_items": [
    {
      "ref_index": 2,
      "category": "shoes",
      "description": "브라운 캐주얼 로퍼",
      "search_keywords": "브라운 로퍼 캐주얼",
      "deeplinks": {
        "musinsa": "https://www.musinsa.com/search/musinsa/goods?q=브라운+로퍼",
        "ably": "https://m.a-bly.com/search?keyword=브라운+로퍼",
        "zigzag": "https://zigzag.kr/search?keyword=브라운+로퍼"
      }
    }
  ]
}
```

**에러:** 400, 403 (RECREATION_LIMIT_REACHED → 프리미엄 모달 #12 트리거), 408 (AI_TIMEOUT), 422 (NO_FASHION_ITEMS), 502 (AI_ERROR)

### 4.6 GET /recreate/history — 재현 히스토리

**앱 내 위치:** Match 탭 (#9) — "최근 분석" 리스트, Home 탭 (#7) — "최근 매칭" 리스트

**Query:** `?limit=10&offset=0`

### 4.7 POST /outfit/daily — 데일리 코디 기록 (Tier 2)

**앱 내 위치:** My 탭 (#11) — 코디 캘린더, Home 탭 (#7) — 퀵 액션 "코디 기록"

**Body:** `{ "outfit_date": "2026-03-02", "item_ids": ["uuid",...], "notes": "..." }`

### 4.8 GET /outfit/recommend — 코디 추천 (Tier 2)

**앱 내 위치:** Home 탭 (#7)

날씨 + 착용이력 기반 규칙 추천. AI 호출 없음.

### 4.9 GET /usage/status — 사용량 조회

**앱 내 위치:** My 탭 (#11) — 플랜 배너 ("옷장 8/30벌 · 매칭 3/5회")

**Response 200:**
```json
{
  "plan": "free",
  "wardrobe": { "used": 8, "limit": 30 },
  "recreation": { "used": 3, "limit": 5, "month": "2026-03" }
}
```

### 4.10 에러 코드 전체 목록

| 코드 | HTTP | 설명 | 클라이언트 대응 (v4.9) |
|------|------|------|----------------------|
| AUTH_REQUIRED | 401 | 토큰 누락/만료 | 로그인 화면 (#6) |
| WARDROBE_LIMIT_REACHED | 403 | 무료 30벌 한도 | 프리미엄 바텀시트 (#12) |
| RECREATION_LIMIT_REACHED | 403 | 무료 월 5회 한도 | 프리미엄 바텀시트 (#12) |
| INVALID_IMAGE | 400 | 이미지 파싱 실패 | 재촬영 유도 |
| NO_FASHION_ITEMS | 422 | 패션 아이템 없음 | 다른 이미지 선택 |
| AI_TIMEOUT | 408 | Claude 10초 초과 | 재시도 버튼 |
| AI_ERROR | 502 | Claude API 오류 | 재시도 버튼 |
| RATE_LIMITED | 429 | 요청 과다 | 잠시 후 재시도 |

---

## 5. AI 파이프라인 (Claude Haiku)

### 5.1 호출 스펙

- **모델:** `claude-haiku-4-5-20251001`
- **max_tokens:** 1024
- **입력:** 이미지 (base64 JPEG) + 분석 프롬프트
- **출력:** JSON (아이템 목록 + 속성)
- **타임아웃:** 10초
- **재시도:** 최대 2회 (1초, 2초 대기)

### 5.2 프롬프트

```
이 사진에 보이는 패션 아이템을 분석해주세요.
반드시 아래 JSON 형식으로만 응답하세요. 다른 텍스트는 절대 포함하지 마세요.

{
  "items": [
    {
      "index": 0,
      "category": "tops|bottoms|outerwear|dresses|shoes|bags|accessories",
      "subcategory": "구체적 소분류",
      "color": {"hex": "#000000", "name": "한국어 색상명", "hsl": {"h":0,"s":0,"l":0}},
      "style": ["casual", "formal", ...],
      "fit": "oversized|regular|slim|null",
      "pattern": "solid|stripe|check|...|null",
      "material": "cotton|denim|...|null"
    }
  ],
  "overall_style": "전체 코디 스타일",
  "occasion": "daily|office|date|formal|sport|outdoor"
}

규칙:
- 명확히 보이는 패션 아이템만 포함
- 배경 소품, 인테리어 제외
- 색상은 가장 넓은 면적의 대표 색상
- HSL 값 정확 계산
```

### 5.3 응답 검증

1. JSON 파싱 검증
2. items 배열 존재 확인
3. 각 아이템 category가 허용 목록에 포함 확인
4. HSL 범위 검증 (h: 0~360, s: 0~100, l: 0~100), 범위 초과 시 hex에서 재계산
5. 검증 실패 시 재시도

### 5.4 비용 추정

| 시나리오 | 월 호출 | 월 비용 |
|----------|---------|---------| 
| 1,000 MAU × 5회 | 5,000 | ~₩5,000 |
| 5,000 MAU × 5.6회 | 28,000 | ~₩36,000 |
| 10,000 MAU × 5.6회 | 56,000 | ~₩72,000 |

---

## 6. 매칭 엔진 설계

### 6.1 알고리즘 개요

AI 호출 없이 순수 코드 로직으로 동작. 각 레퍼런스 아이템에 대해 사용자 옷장에서 최적 매칭을 찾는다.

**점수 구성 (총 100점):**

| 요소 | 배점 | 산출 방식 |
|------|------|----------|
| 카테고리 일치 | 40 | 같은 카테고리 = 40, 불일치 = 0 (필터로 사전 처리) |
| 색상 유사도 | 30 | CIEDE2000 색차 → 0~30점 변환 |
| 스타일 일치 | 20 | 태그 겹침 비율 × 20 |
| 보너스 | 10 | 핏(3) + 패턴(3) + 소분류(4) 일치 보너스 |

**매칭 임계값:** 50점 이상 = 매칭 성공 (초록 체크 ✓), 미만 = 갭 아이템 (빨간 ✗ + "찾기" 버튼)

### 6.2 색상 유사도 계산

CIEDE2000 색차 공식 사용 (인간 색상 인지와 가장 유사한 색차 공식).

| deltaE 범위 | 의미 | 점수 (0~30) |
|-------------|------|------------|
| < 5 | 거의 같은 색 | 28~30 |
| 5~15 | 유사한 색 | 20~28 |
| 15~30 | 같은 톤 | 10~20 |
| > 30 | 다른 색 | 0~10 |

### 6.3 매칭 프로세스

```
for each refItem in referenceAnalysis.items:
    1. 같은 카테고리로 필터 (tops↔tops)
    2. 이미 매칭된 아이템 제외 (중복 방지)
    3. 후보별 점수 계산 (color + style + bonus)
    4. 최고 점수 아이템 선택
    5. 점수 ≥ 50 → matched_items에 추가
       점수 < 50 → gap_items에 추가 + 딥링크 생성
```

### 6.4 딥링크 생성 (갭 아이템)

```
무신사: https://www.musinsa.com/search/musinsa/goods?q={keywords}
에이블리: https://m.a-bly.com/search?keyword={keywords}
지그재그: https://zigzag.kr/search?keyword={keywords}

keywords = "{색상명} {subcategory}" (예: "브라운 로퍼")
```

Phase 2에서 CPA 파라미터 추가: `&ref=aura&utm_source=aura`

---

## 7. 이미지 처리 파이프라인

### 7.1 처리 흐름

```
앱에서 이미지 수신 (JPEG, max 10MB)
  → 1. EXIF 회전 보정 + 리사이즈 (max 2048px) + JPEG q85
  → 2. 배경 제거 (remove.bg API → HF API fallback)
  → 3. 색상 추출 (K-Means k=3, 투명 픽셀 제외)
  → 4. R2 저장 (원본 JPEG + 처리본 WebP)
```

### 7.2 배경 제거 전략

| 우선순위 | 방법 | 품질 | 비용 | 비고 |
|----------|------|------|------|------|
| Primary | remove.bg API | 높음 | 월 50회 무료 | 초과 시 $0.20/건 |
| Fallback | HuggingFace RMBG-1.4 | 중간 | 무료 (추론 API) | 속도 느릴 수 있음 |

### 7.3 색상 추출 (K-Means)

1. 배경 제거된 이미지에서 투명 픽셀 제외
2. RGB 공간에서 K-Means 클러스터링 (k=3, 20 iterations)
3. 가장 큰 클러스터의 centroid = 대표 색상
4. RGB → hex → HSL 변환
5. HSL → 한국어 색상명 매핑 (무채색 판별 포함)

### 7.4 한국어 색상명 매핑 규칙

- 채도 < 10%: 무채색 (화이트/라이트그레이/그레이/차콜/블랙, 명도 기준)
- 유채색: HSL hue 범위 + 명도 범위로 19개 색상명 매핑
- 예: h=210 s=35 l=24 → 네이비, h=40 s=50 l=93 → 크림

---

## 8. 인증 & 결제 시스템

### 8.1 인증 흐름

Supabase Auth OAuth → JWT 발급 → 모든 API에서 JWT 검증 → RLS로 데이터 격리

**앱 내 위치:** 로그인 화면 (#6) — 카카오 (#FEE500) + Apple (#000000) 버튼

- 카카오 로그인: `supabase.auth.signInWithOAuth({ provider: 'kakao' })`
- Apple 로그인: `supabase.auth.signInWithOAuth({ provider: 'apple' })`
- 신규 가입 시 트리거로 profiles 자동 생성

### 8.2 요금제 제한 체크

| 기능 | 무료 | 프리미엄 |
|------|------|---------| 
| 옷장 아이템 | 30벌 | 무제한 |
| 룩 재현 | 월 5회 | 무제한 |

**무료 사용량 표시 (v4.9):** My 탭 (#11) 플랜 배너 — "옷장 8/30벌 · 매칭 3/5회"

**한도 도달 시:** 프리미엄 바텀시트 모달 (#12) 자동 표시 — 월간 ₩6,900 / 연간 ₩59,000 (29% 할인)

확인 로직: subscriptions 테이블에서 active + 미만료 확인 → usage_counters에서 현재 사용량 비교

### 8.3 IAP 영수증 검증 (Tier 2)

- Apple: App Store Server API v2로 서버사이드 검증
- Google: Google Play Developer API로 서버사이드 검증
- 클라이언트 영수증 절대 신뢰하지 않음

### 8.4 구독 가격 구조

| 플랜 | 가격 | 월 환산 | 할인 |
|------|------|---------|------|
| 월간 | ₩6,900 | ₩6,900 | — |
| 연간 | ₩59,000 | ₩4,917 | 29% |
| 얼리버드 연간 | ₩39,000 | ₩3,250 | 53% |

---

## 9. 보안 & 성능

### 9.1 보안 체크리스트

| 영역 | 대책 |
|------|------|
| 인증 | JWT 기반, 모든 Edge Function에서 검증 |
| 데이터 격리 | Row Level Security (자기 데이터만) |
| 이미지 접근 | 원본은 서명 URL (1시간 만료) |
| API 키 | Supabase Secrets에 저장 |
| 입력 검증 | Zod 스키마 + 파라미터 바인딩 |
| Rate Limit | IP당 60req/min + 요금제별 한도 |
| 개인정보 | EXIF GPS 데이터 제거 |
| 계정 삭제 | CASCADE + R2 이미지 cleanup |

### 9.2 성능 목표

| 지표 | 목표 | 최적화 |
|------|------|--------|
| 아이템 등록 | < 3초 | 배경 제거 API 병렬, 이미지 전처리 최소화 |
| 룩 재현 | < 5초 | Claude 스트리밍, 매칭 인메모리 |
| 옷장 목록 | < 500ms | 인덱스 + 페이지네이션 20개 |
| 이미지 로딩 | < 1초 | R2 CDN + WebP + 썸네일 |
| 앱 콜드 스타트 | < 2초 | Flutter AOT 컴파일 |

### 9.3 캐싱 전략

| 대상 | 위치 | TTL | 무효화 |
|------|------|-----|--------|
| 배경제거 이미지 | R2 CDN | 365일 | 아이템 삭제 시 |
| 옷장 목록 | 앱 로컬 SQLite | 5분 | 변경 시 push 무효화 |
| 구독 상태 | 앱 메모리 | 30분 | 구독 변경 시 |
| 날씨 데이터 | Edge Function 메모리 | 1시간 | 자동 만료 |

---

## 10. 배포 & 운영

### 10.1 환경 분리

| 환경 | Supabase | R2 | 용도 |
|------|----------|-----|------|
| Development | Local (Docker) | aura-dev | 로컬 개발 |
| Staging | Free (별도 프로젝트) | aura-staging | QA / 베타 |
| Production | Pro | aura-prod | 프로덕션 |

### 10.2 모니터링

| 도구 | 대상 | 알림 조건 |
|------|------|----------|
| Sentry | 앱 크래시, Edge Function 에러 | 새 에러 시 Slack |
| Supabase Dashboard | DB 성능, 연결 수 | 쿼리 > 1초 |
| Anthropic Console | API 사용량/비용 | 월 예산 80% |
| Custom | 가입자, MAU, 전환율 | 매일 Slack 리포트 |

### 10.3 DB 마이그레이션

```
supabase/migrations/
├── 20260302000001_create_profiles.sql
├── 20260302000002_create_wardrobe_items.sql
├── 20260302000003_create_look_recreations.sql
├── 20260302000004_create_usage_counters.sql
├── 20260401000001_create_daily_outfits.sql        # Tier 2
├── 20260401000002_create_subscriptions.sql        # Tier 2
```

### 10.4 배포 명령어

```bash
supabase db push                  # 마이그레이션 적용
supabase functions deploy --all   # Edge Functions 배포
flutter build ios --release       # iOS 빌드
flutter build appbundle           # Android 빌드
```

---

## 부록: 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| 1.0 | 2026-02-22 | 초안 작성 (ClosetIQ). 10개 섹션 완성. |
| 2.0 | 2026-03-02 | AURA 리브랜딩. UI v4.9 화면 번호/탭 매핑 추가. R2 버킷 네이밍 통일. 사용량 API (GET /usage/status) 추가. CPA 파라미터 aura 반영. 프리미엄 가격 구조 섹션 추가. |