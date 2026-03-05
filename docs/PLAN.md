# AURA — MVP 개발 계획서

> **버전:** 1.0
> **작성일:** 2026-03-03
> **예상 기간:** ~10-11주 (2.5~3개월)
> **개발 형태:** 1인 개발자 (Solo Developer)
> **관련 문서:** PRD.md, technical-design.md, UI-UX-design.md, content-copy.md

---

## 개요

8개 Part로 구성된 단계별 MVP 개발 계획. 각 Part는 이전 Part의 완료를 전제로 한다.

```
Part 1 → Part 2 → Part 3 → Part 4 → Part 5 → Part 6 → Part 7 → Part 8
기반구축   로그인    옷장    AI매칭   홈&마이   결제     품질     배포
```

| Part | 주제 | 예상 기간 |
|------|------|----------|
| 1 | 프로젝트 기반 구축 | 5~7일 |
| 2 | 로그인 & 온보딩 | 5~7일 |
| 3 | 옷장 (Closet) | 7~10일 |
| 4 | AI 매칭 (Match) | 7~10일 |
| 5 | 홈 & 마이 페이지 | 5~7일 |
| 6 | 결제 & 프리미엄 | 7~10일 |
| 7 | 품질 & 베타 테스트 | 7~10일 |
| 8 | 배포 & 마치며 | 5~7일 |

---

## Part 1: 프로젝트 기반 구축 (5~7일)

> 코드 한 줄도 없는 상태에서 개발 환경, DB, 스토리지, CI를 잡는다.
> 이 Part가 끝나면 Flutter 앱이 Supabase와 통신하고, 이미지가 R2에 올라간다.

### 1.1 Flutter 프로젝트 셋업

- [x] `flutter create --org kr.aura aura` (iOS/Android)
- [x] 폴더 구조 설정 (feature-first)
  ```
  lib/
  ├── app/           # 앱 진입점, 라우팅, 테마
  ├── core/          # 공유 유틸, 상수, 에러 처리
  ├── features/      # 기능별 모듈
  │   ├── auth/
  │   ├── wardrobe/
  │   ├── match/
  │   ├── home/
  │   ├── profile/
  │   └── billing/
  └── shared/        # 공유 위젯, 모델
  ```
- [x] 핵심 패키지 설치
  - 상태 관리: `flutter_riverpod`
  - 라우팅: `go_router`
  - HTTP: `supabase_flutter`
  - 이미지: `cached_network_image`, `image_picker`
  - 로컬 DB: `sqflite` (캐싱용)
- [x] 디자인 시스템 토큰 코드화
  - 컬러 (primary #4F46E5, neutral, glass)
  - 타이포 (Lobster + Noto Sans KR)
  - bgSoft / bgOnboard 그라디언트
  - 글래스모피즘 카드 위젯

### 1.2 Supabase 프로젝트 & DB

- [x] Supabase 프로젝트 생성 (dev 환경)
- [x] 마이그레이션 파일 작성 & 실행
  - `profiles` 테이블 (→ `technical-design.md` 3.2절)
  - `wardrobe_items` 테이블
  - `look_recreations` 테이블
  - `usage_counters` 테이블
- [x] RLS 정책 적용 (모든 테이블: `auth.uid() = user_id`)
- [x] profiles 자동 생성 트리거 (auth.users INSERT → profiles INSERT)

### 1.3 Cloudflare R2 스토리지

- [x] `aura-dev` 버킷 생성
- [x] 경로 구조 설정: `/originals/`, `/processed/`, `/references/`
- [x] 서명 URL 생성 로직 (private 이미지용)
- [x] Public CDN 설정 (processed 이미지용)

### 1.4 Edge Functions 기본 구조

- [x] `_shared/` 공유 유틸리티 생성
  - `cors.ts`, `auth.ts`, `r2-client.ts`, `types.ts`
- [x] 헬스체크 엔드포인트 (`GET /health`)
- [x] Flutter ↔ Edge Function 통신 확인

### 1.5 CI/CD & 개발 환경

- [x] GitHub 리포지토리 생성
- [x] GitHub Actions: Flutter 빌드 + 린트 체크
- [x] Sentry 연동 (Flutter + Edge Functions)
- [x] 환경 변수 관리 (Supabase Secrets)

### 1.6 얼리버드 랜딩페이지

- [ ] 단일 페이지 (Next.js 또는 정적 HTML)
- [ ] 내용: 가치 제안 + 스크린샷 목업 + 이메일 수집
- [ ] 도메인 연결 (aura-app.kr 등)
- [ ] 기본 분석 (방문, 이메일 전환)

### Part 1 완료 기준

- Flutter 앱이 Supabase DB에 CRUD 가능
- R2에 이미지 업로드/조회 가능
- Edge Function 배포 & 호출 성공
- CI에서 빌드 통과
- 랜딩페이지 라이브

---

## Part 2: 로그인 & 온보딩 (5~7일)

> 사용자가 앱을 켜면 스플래시 → 온보딩 → 로그인 → Home 탭까지 도달한다.
> 참조: `UI-UX-design.md` 플로우 A, `content-copy.md` 온보딩 카피

### 2.1 스플래시 화면

- [x] #1 스플래시 A: 삭제 (불필요)
- [x] #2 스플래시 B: 소프트 그라디언트 (bgSoft) + Lobster 72px 인디고 로고 → 1초
- [x] 자동 전환 애니메이션 (fade) — Splash A 삭제로 불필요

### 2.2 온보딩 (3장)

- [x] #3 온보딩 1: 옷걸이 동심원 아이콘 + "나만의 옷장을 AI로 관리하세요"
- [x] #4 온보딩 2: 카메라 동심원 아이콘 + "사진 한 장이면 충분해요" + ← 뒤로
- [x] #5 온보딩 3: 스캔 동심원 아이콘 + "인플루언서 룩을 내 옷으로" + ← 뒤로
- [x] 건너뛰기 (우상단, 모든 화면에서 → 로그인)
- [x] 인디고 배경, 중앙 정렬, 글래스 버튼
- [x] 페이지 인디케이터 (도트 3개)

### 2.3 소셜 로그인

- [x] #6 로그인 화면: bgSoft + Lobster 56px "Aura" + "STYLE REIMAGINED"
- [x] 이메일 로그인 (`supabase.auth.signInWithPassword`)
- [x] 이메일 회원가입 (`supabase.auth.signUp`) + 비밀번호 확인
- [x] 회원가입 화면: 글래스 폼 + CTA 버튼 + 로그인 링크
- [ ] 카카오 OAuth 연동 (`supabase.auth.signInWithOAuth({ provider: 'kakao' })`)
  - 카카오 개발자 앱 등록, 리다이렉트 URI 설정
  - 버튼: #FEE500 배경, 텍스트 #1A1A1A
- [ ] Apple 로그인 연동 (`supabase.auth.signInWithOAuth({ provider: 'apple' })`)
  - Apple Developer 설정, Sign in with Apple capability
  - 버튼: #000 배경, 텍스트 #fff
- [x] 법적 고지 텍스트 (11px, mute) — 개인정보처리방침, 이용약관 링크

### 2.4 프로필 자동 생성

- [x] 로그인 성공 시 profiles 레코드 확인/생성
- [x] `onboarding_completed = false` 상태로 시작
- [ ] 온보딩 촬영 완료 후 `onboarding_completed = true`

### 2.5 라우팅 & 인증 상태 관리

- [ ] GoRouter 설정: 인증 상태에 따른 리다이렉트
  - 미인증 → 스플래시 → 온보딩 → 로그인
  - 인증 완료 + 온보딩 미완 → 촬영 유도
  - 인증 완료 + 온보딩 완료 → Home 탭
- [ ] JWT 토큰 자동 갱신 (Supabase Flutter SDK)
- [ ] 로그아웃 기능

### Part 2 완료 기준

- 카카오/Apple 로그인 → Home 도달 가능
- 온보딩 슬라이드 건너뛰기/뒤로 동작
- 프로필 자동 생성 확인
- 재실행 시 로그인 유지

---

## Part 3: 옷장 — Closet 탭 (7~10일)

> 핵심 자산인 옷장을 만든다. 이미지 처리 파이프라인(배경 제거 + 색상 추출)이 가장 기술적으로 도전적인 부분.
> 참조: `PRD.md` F1/F3, `technical-design.md` 4.1~4.4절 + 7장

### 3.1 이미지 처리 파이프라인 (Edge Function)

- [ ] `wardrobe-upload` Edge Function 구현
  - EXIF 회전 보정 + 리사이즈 (max 2048px, JPEG q85)
  - 배경 제거: remove.bg API (Primary) → HuggingFace rembg (Fallback)
  - K-Means 색상 추출 (k=3, 투명 픽셀 제외, 최대 클러스터 = 대표색)
  - RGB → hex → HSL 변환
  - HSL → 한국어 색상명 매핑 (19개 유채색 + 5개 무채색)
  - R2 저장 (원본 JPEG + 배경제거 WebP max 1024px q80)
  - DB INSERT (wardrobe_items)

### 3.2 아이템 등록 UI

- [ ] FAB (+) 버튼 → OS 카메라 호출 (`image_picker`)
- [ ] 촬영/갤러리 선택 후 → 로딩 (배경 제거 중 애니메이션)
- [ ] 아이템 확인 화면
  - 배경 제거된 이미지 미리보기
  - 자동 추출된 색상 표시 (hex 컬러 원)
  - 카테고리 탭 선택 UI (상의/하의/아우터/원피스/신발/가방/액세서리)
  - 선택 속성: subcategory, style_tags, fit, pattern, brand, season
- [ ] 저장 → 옷장 목록으로 복귀

### 3.3 옷장 목록 (Closet 탭 #8)

- [ ] 헤더: "Closet" Lobster 32px + "N벌의 옷이 있어요"
- [ ] 카테고리 스토리 행 (원형 52x52, 가로 스크롤, 활성: primary 테두리)
- [ ] Masonry 그리드 (2열, 교차 높이, 글래스 카드 radius 14px)
- [ ] 배경 제거된 이미지 표시 (R2 CDN URL)
- [ ] 필터: 카테고리 / 정렬: 최근 등록순, 착용 횟수순
- [ ] 페이지네이션 (무한 스크롤, limit 20)
- [ ] Pull-to-refresh

### 3.4 아이템 상세 & CRUD

- [ ] 아이템 탭 → 상세 (서브 페이지)
  - 이미지 + 모든 속성 표시
  - 수정 (`PATCH /wardrobe/items/:id`)
  - 삭제 확인 다이얼로그 → 소프트 삭제 (`DELETE /wardrobe/items/:id`)
- [ ] 롱프레스 → 다중 선택 모드 → 일괄 삭제

### 3.5 온보딩 촬영 흐름

- [ ] 가입 직후 "첫 번째 옷을 등록해볼까요?" 촬영 유도 (→ `content-copy.md`)
- [ ] 전신 사진 1장 → 배경 제거 → 아이템 분리 → 카테고리 탭 → 저장
- [ ] 완료 후 `onboarding_completed = true`
- [ ] 추가 유도: "3벌 이상 등록하면 재현이 더 정확해져요"

### 3.6 사용량 제한

- [ ] 무료 30벌 한도 체크 (`usage_counters.wardrobe_count`)
- [ ] 한도 도달 시 에러 `WARDROBE_LIMIT_REACHED` → 프리미엄 모달 트리거 (Part 6)

### 3.7 빈 상태

- [ ] 옷장 0개: "아직 옷장이 비어있어요" + "첫 번째 옷 등록하기" CTA

### Part 3 완료 기준

- 사진 촬영 → 배경 제거 → 색상 추출 → 카테고리 선택 → 저장 (< 3초)
- Closet 탭 Masonry 그리드에 아이템 표시
- CRUD 모두 동작
- 온보딩 촬영 흐름 완료

---

## Part 4: AI 매칭 — Match 탭 (7~10일)

> AURA의 핵심 차별점인 "인플루언서 룩 재현"을 구현한다.
> Claude Haiku API 연동 + 매칭 엔진 + 갭 분석 + 딥링크.
> 참조: `PRD.md` F2/F4, `technical-design.md` 4.5절 + 5~6장

### 4.1 Claude Haiku API 연동 (Edge Function)

- [ ] `_shared/claude-client.ts` — API 래퍼
  - 모델: `claude-haiku-4-5-20251001`
  - max_tokens: 1024
  - 타임아웃: 10초
  - 재시도: 최대 2회 (1초, 2초 대기)
- [ ] 프롬프트 구현 (→ `technical-design.md` 5.2절)
  - 이미지(base64) + 패션 아이템 분석 지시
  - JSON 출력 강제 (items, overall_style, occasion)
- [ ] 응답 검증
  - JSON 파싱, items 배열 존재, category 허용 목록, HSL 범위
  - 검증 실패 시 재시도

### 4.2 매칭 엔진 (Edge Function)

- [ ] `_shared/matching-engine.ts` 구현
  - 점수 계산: 카테고리(40) + 색상(30) + 스타일(20) + 보너스(10)
  - `_shared/color-utils.ts` — CIEDE2000 색차 계산
  - 매칭 프로세스: 카테고리 필터 → 중복 제외 → 점수 계산 → 최고 점수 선택
  - 임계값: 50점 이상 = 매칭 성공, 미만 = 갭 아이템

### 4.3 `recreate-analyze` 핵심 API

- [ ] `POST /recreate/analyze` (→ `technical-design.md` 4.5절)
  - 레퍼런스 이미지 수신 → R2 저장
  - Claude Haiku 호출 → 아이템 분석 JSON
  - 매칭 엔진 실행 → matched_items + gap_items
  - `look_recreations` 테이블에 결과 저장
  - `usage_counters.recreation_count` 증가
  - 응답 반환 (overall_score, matched_items, gap_items)

### 4.4 갭 분석 & 딥링크

- [ ] 갭 아이템별 딥링크 생성
  - 무신사: `https://www.musinsa.com/search/musinsa/goods?q={keywords}`
  - 에이블리: `https://m.a-bly.com/search?keyword={keywords}`
  - 지그재그: `https://zigzag.kr/search?keyword={keywords}`
  - keywords = "{색상명} {subcategory}" (예: "브라운 로퍼")
- [ ] 앱 미설치 시 웹 URL 폴백

### 4.5 Match 탭 UI

- [ ] #9 매칭 업로드 화면
  - "Match" Lobster 32px + "인플루언서 룩을 내 옷으로 재현해보세요"
  - 사진 업로드 영역 (글래스 카드, 점선 테두리, 카메라 아이콘)
  - 갤러리 선택 또는 Share Extension (외부 앱에서 공유)
  - 최근 분석 리스트 (`GET /recreate/history`)
- [ ] 분석 중 로딩 화면 (단계별 체크 애니메이션)
- [ ] #10 매칭 결과 화면
  - 매칭 점수: Lobster 64px, primary + "Match Score"
  - 매칭 성공 아이템: 글래스 카드 + 초록 ✓ + 점수 + 매칭 이유
  - 갭 아이템: 글래스 카드 + 빨간 ✗ + "이 아이템이 있으면 완벽해요!" + [찾기] 버튼
  - [찾기] 탭 → 딥링크 바텀시트 (무신사/에이블리/지그재그)

### 4.6 사용량 제한

- [ ] 무료 월 5회 한도 체크
- [ ] 한도 도달 시 `RECREATION_LIMIT_REACHED` → 프리미엄 모달 트리거 (Part 6)

### 4.7 빈 상태

- [ ] 히스토리 0건: "아직 룩 재현을 해본 적이 없어요" + CTA

### Part 4 완료 기준

- 레퍼런스 이미지 → Claude 분석 → 매칭 결과 (< 5초)
- 매칭/갭 아이템 정확히 구분되어 표시
- 갭 아이템 [찾기] → 외부 쇼핑몰 이동 확인
- 다양한 코디 사진 10장으로 프롬프트 품질 검증

---

## Part 5: 홈 & 마이 페이지 (5~7일)

> 4개 탭 중 나머지 2개(Home, My)를 완성한다. 대시보드, 통계, 플랜 배너, 코디 캘린더.
> 참조: `UI-UX-design.md` 플로우 D/E, `content-copy.md` 빈 상태

### 5.1 Home 탭 (#7)

- [ ] 헤더: "Aura" Lobster 32px + 프로필 아이콘 (글래스 원형 36x36)
- [ ] "오늘도 스타일리시하게!" 서브 텍스트
- [ ] 스탯 카드 3분할 (Glass Strong): 내 옷 / 룩 매칭 / 코디 기록
- [ ] 퀵 액션 3버튼 (Glass Strong): 옷 등록 → Closet FAB, 룩 매칭 → Match 탭, 코디 기록 → (Tier 2)
- [ ] 최근 매칭 섹션
  - "최근 매칭" + "전체보기 →"
  - Glass Strong 카드 리스트 (썸네일 + 스타일명 + 점수 + 매칭/부족 카운트)
  - 탭 → 매칭 결과 상세 (#10)
- [ ] 프리미엄 배너 (무료 유저)
  - 인디고 그라디언트 배경, CTA → 프리미엄 모달 (#12)

### 5.2 My 탭 (#11)

- [ ] 헤더: "My" Lobster 32px
- [ ] 프로필 섹션: 아바타 원형 48px + 이름 + 가입일
- [ ] 플랜 배너 (인디고 그라디언트)
  - 왕관 아이콘 + "무료 플랜" + "옷장 N/30벌 · 매칭 N/5회"
  - 탭 → 프리미엄 모달 (#12)
  - 사용량 데이터: `GET /usage/status`
- [ ] 스탯 카드 (3분할): 내 옷 / 매칭 / 코디
- [ ] 코디 캘린더 (글래스 카드, 월간 뷰)
  - 기록 있는 날짜: 인디고 도트
  - 오늘: 인디고 원형 배경
  - (Part 3까지는 데이터 없으므로 빈 상태)
- [ ] 메뉴 리스트 (글래스 카드)
  - 알림 설정, 자주 묻는 질문, 의견 보내기, 앱 버전
  - 개인정보처리방침 (→ `privacy-policy.md`)
  - 이용약관 (→ `terms-of-service.md`)
  - 로그아웃, 계정 삭제

### 5.3 탭바 구현

- [x] 플로팅 알약 탭바 (4탭)
  - `rgba(255,255,255,0.92)` + blur(24px), radius 22px
  - 아이콘 전용 (라벨 없음), 44x44 터치 타겟
  - 활성: primary 배경 tint + filled 아이콘 + 슬라이딩 하이라이트 애니메이션
  - 비활성: 투명 + outline 아이콘
  - 하단 여백 고려 (Safe Area)
  - 컴팩트 폭 (Center 정렬 + 고정 폭)

### 5.4 캐싱

- [ ] 옷장 목록: 로컬 SQLite 캐시 (TTL 5분)
- [ ] 구독 상태: 앱 메모리 캐시 (TTL 30분)
- [ ] 매칭 히스토리: 앱 메모리 캐시

### Part 5 완료 기준

- 4개 탭 모두 동작 (Home, Closet, Match, My)
- Home에서 1탭으로 모든 핵심 기능 접근 가능
- My에서 사용량 정확히 표시
- 탭 전환 자연스러움 (Crossfade 300ms)

---

## Part 6: 결제 & 프리미엄 (7~10일)

> 수익 모델을 구현한다. Apple IAP + Google Play Billing → 서버 영수증 검증 → 구독 상태 관리.
> 참조: `PRD.md` F7, `technical-design.md` 8장, `UI-UX-design.md` 프리미엄 모달

### 6.1 프리미엄 바텀시트 모달 (#12)

- [ ] 다크 오버레이 `rgba(0,0,0,0.65)` + 바텀시트 slide-up 300ms
- [ ] 구조 (→ `UI-UX-design.md` 3.4절)
  - 왕관 + "프리미엄으로 업그레이드" + 닫기(X)
  - 혜택 리스트: 인디고 SVG 체크 아이콘 (무제한 옷장, 룩 재현, 갭 분석, 코디 추천)
  - 월간 카드: ₩6,900/월 (기본 테두리)
  - 연간 카드: ₩59,000 (₩4,917/월, 29% 할인 뱃지, primary 테두리)
  - CTA: "프리미엄 시작하기" (그라디언트 버튼)
  - "언제든 해지 가능 · 7일 무료 체험"
- [ ] 트리거별 카피 분기 (→ `content-copy.md` 5장)
  - WARDROBE_LIMIT_REACHED: "옷장이 가득 찼어요!"
  - RECREATION_LIMIT_REACHED: "이번 달 무료 분석을 다 썼어요"
  - 직접 방문: "더 스마트한 옷장 관리"

### 6.2 Apple IAP (iOS)

- [ ] StoreKit 2 연동 (Flutter `in_app_purchase` 패키지)
- [ ] App Store Connect에 구독 상품 등록
  - `aura_monthly` (₩6,900)
  - `aura_yearly` (₩59,000)
- [ ] 구매 플로우: 상품 선택 → StoreKit 결제 → 영수증 획득

### 6.3 Google Play Billing (Android)

- [ ] Google Play Billing Library 연동
- [ ] Google Play Console에 구독 상품 등록
- [ ] 구매 플로우 동일

### 6.4 서버 영수증 검증 (Edge Functions)

- [ ] `billing-subscribe` Edge Function
  - 클라이언트 영수증 수신
  - Apple: App Store Server API v2 검증
  - Google: Google Play Developer API 검증
  - 검증 성공 → `subscriptions` 테이블 INSERT/UPDATE
  - 구독 상태 활성화
- [ ] `billing-webhook` Edge Function
  - Apple/Google 서버 알림 수신
  - 갱신, 만료, 취소 처리
  - `subscriptions.status` 업데이트

### 6.5 구독 상태 관리

- [ ] 요금제 체크 로직 통합
  - `subscriptions` 테이블에서 active + 미만료 확인
  - 프리미엄이면 wardrobe/recreation 한도 해제
- [ ] My 탭 플랜 배너 업데이트 (무료/프리미엄 분기)
- [ ] 구독 관리 (해지 → 앱스토어 설정으로 딥링크)

### Part 6 완료 기준

- 프리미엄 모달에서 구독 결제 → 서버 검증 → 한도 해제
- 모든 Paywall 트리거에서 모달 정상 표시
- 구독 만료 시 무료로 자동 전환
- Sandbox/테스트 계정으로 전체 플로우 검증

---

## Part 7: 품질 & 베타 테스트 (7~10일)

> 디자인 폴리시, QA, 디바이스 호환, 보안, 베타 20명.
> 참조: `user-research.md` (핵심 가설 검증 방법론)

### 7.1 디자인 폴리시

- [ ] 전체 화면 bgSoft 그라디언트 일관성 확인
- [ ] 글래스모피즘 카드 blur, opacity 통일
- [ ] 타이포그래피 Lobster/Noto Sans KR 일관성
- [ ] 다크/라이트 모드: MVP는 라이트만 (다크 모드 Tier 2)
- [ ] 인터랙션: Confetti (매칭 결과), Haptic 피드백, Pull-to-refresh 바운스
- [ ] 빈 상태 모든 화면 확인 (→ `content-copy.md` 3장)
- [ ] 에러 메시지 모든 케이스 확인 (→ `content-copy.md` 2장)

### 7.2 디바이스 호환

- [ ] iOS: iPhone SE 3, iPhone 14, iPhone 15 Pro Max
- [ ] Android: 갤럭시 S22 (소형), 갤럭시 S24 Ultra (대형), Pixel 7
- [ ] Safe Area 처리 (노치, 다이내믹 아일랜드, 홈 인디케이터)
- [ ] 가로 모드 차단 (세로 고정)

### 7.3 보안 체크

- [ ] EXIF GPS 데이터 제거 확인
- [ ] 원본 이미지: 서명 URL만 접근 가능 (1시간 만료)
- [ ] RLS 동작 확인 (다른 사용자 데이터 접근 불가)
- [ ] API 키 노출 없음 (Supabase Secrets)
- [ ] Rate Limit 동작 확인 (IP당 60req/min)

### 7.4 성능 확인

- [ ] 아이템 등록: < 3초
- [ ] 룩 재현: < 5초
- [ ] 옷장 목록 로딩: < 500ms
- [ ] 이미지 로딩: < 1초 (R2 CDN + WebP)
- [ ] 앱 콜드 스타트: < 2초

### 7.5 베타 테스트 (20명)

- [ ] TestFlight (iOS) + 내부 테스트 (Android) 배포
- [ ] 베타 대상: 타겟 세그먼트 A/B에서 각 10명
- [ ] 핵심 가설 검증 (→ `user-research.md`)
  - 갤러리에 전신 코디 사진이 충분한가? (목표: 월 10장+)
  - 룩 재현 결과가 쓸 만한가? (목표: 만족도 3.5/5+)
- [ ] 인앱 피드백 수집 (간단한 별점 + 텍스트)
- [ ] 크리티컬 버그 수정

### Part 7 완료 기준

- 디자인 시스템 일관성 100%
- 6개 디바이스에서 정상 동작
- 보안 체크리스트 모두 통과
- 성능 목표 모두 달성
- 베타 피드백 기반 크리티컬 이슈 0개

---

## Part 8: 배포 & 마치며 (5~7일)

> Production 환경 세팅, 앱스토어 출시, 운영 준비.

### 8.1 Production 환경

- [ ] Supabase Production 프로젝트 (Pro 플랜)
- [ ] Cloudflare R2 `aura-prod` 버킷
- [ ] 환경 변수 분리 (dev/staging/prod)
- [ ] DB 마이그레이션 Production 적용
- [ ] Edge Functions Production 배포

### 8.2 앱스토어 출시 준비

- [ ] App Store Connect
  - 앱 이름: "AURA - AI 옷장 코디 매칭"
  - 부제목: "인플루언서 코디, 내 옷장으로 따라입기"
  - 키워드 (→ `content-copy.md` 6장)
  - 설명 텍스트 (→ `content-copy.md` 6장)
  - 스크린샷 5장 (iPhone 6.7", 6.1")
  - 개인정보처리방침 URL (→ `privacy-policy.md`)
  - 심사 제출
- [ ] Google Play Console
  - 스토어 등록정보
  - 스크린샷 (phone, 7" tablet)
  - 콘텐츠 등급 설문
  - 프로덕션 출시

### 8.3 모니터링 & 알림

- [ ] Sentry: 새 에러 시 Slack 알림
- [ ] Supabase Dashboard: 쿼리 > 1초 모니터링
- [ ] Anthropic Console: AI API 월 예산 80% 알림
- [ ] 가입자/MAU 일일 Slack 리포트 (간단한 Edge Function cron)

### 8.4 운영 루틴

- [ ] 일간: Sentry 에러 확인, 가입자 수 체크
- [ ] 주간: MAU, 리텐션, 전환율 확인
- [ ] 월간: 비용 리뷰 (Supabase + R2 + Claude API)

### 8.5 출시 후 로드맵 (Tier 2 준비)

출시 직후에는 안정화에 집중하고, 안정화 후 Tier 2 기능을 순서대로 추가한다:

| 우선순위 | 기능 | 설명 |
|---------|------|------|
| 1 | F5. 데일리 코디 기록 | My 탭 코디 캘린더 + Home 퀵 액션 |
| 2 | F6. 기본 코디 추천 | 날씨 + 착용이력 기반 규칙 추천 (AI 호출 0) |
| 3 | Share Extension | 인스타 등에서 직접 공유 → Match 탭 연결 |
| 4 | 푸시 알림 | FCM 연동, 데일리 리마인드, 기능 알림 |

### Part 8 완료 기준

- 앱스토어 심사 통과 & 공개
- Production 환경 안정 동작
- 모니터링 알림 정상 수신
- 얼리버드 사용자 앱 접근 가능

---

## 부록: 문서 참조 맵

각 Part에서 참조하는 문서:

| Part | PRD.md | technical-design.md | UI-UX-design.md | content-copy.md |
|------|--------|--------------------|-----------------|-----------------|
| 1 | 5장 기술 아키텍처 | 1~3장 아키텍처, DB | 4장 디자인 시스템 | — |
| 2 | 3.1 온보딩 전략 | 8.1 인증 흐름 | 3.1 플로우 A | 1장 온보딩 카피 |
| 3 | F1, F3 | 4.1~4.4, 7장 이미지 | 3.3 플로우 C | 3장 빈 상태 |
| 4 | F2, F4 | 4.5, 5~6장 AI/매칭 | 3.2 플로우 B | 2장 에러 메시지 |
| 5 | — | 4.9 사용량 API | 3.4~3.5 플로우 D/E | 3장 빈 상태 |
| 6 | F7 | 8.2~8.4 결제 | 프리미엄 모달 | 5장 전환 카피 |
| 7 | 10장 검증 가정 | 9장 보안/성능 | 4.7 접근성 | 2~3장 에러/빈상태 |
| 8 | 11장 로드맵 | 10장 배포/운영 | — | 6장 앱스토어 |

---

## 변경 이력

| 버전 | 날짜 | 변경 내용 |
|------|------|----------|
| 1.0 | 2026-03-03 | 초안 작성. 8 Part 구조. PRD v2.0 / technical-design v2.0 / UI-UX-design v2.0 기반. |
