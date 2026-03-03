# AURA UI Design System v4.9

> 새로운 화면을 추가하거나 기존 화면을 수정할 때 참조하는 디자인 가이드 문서입니다.

---

## 1. 브랜드 개요

| 항목 | 값 |
|---|---|
| 앱 이름 | **Aura** |
| 슬로건 | STYLE REIMAGINED |
| 컨셉 | AI 기반 패션 코디 매칭 — 인플루언서 코디를 내 옷장으로 재현 |
| 디자인 무드 | 글래스모피즘, 소프트 그라디언트, 에디토리얼 |
| 프레임 | 375 × 812 (iPhone 13/14 기준), border-radius: 44px |

---

## 2. 색상 시스템 (Color Tokens)

### 2.1 Primary Palette

| 토큰 | HEX | 용도 |
|---|---|---|
| `primary` | `#4F46E5` | 메인 브랜드 컬러, CTA, 활성 상태 |
| `indigo` | `#6366F1` | 그라디언트 세컨더리, 보조 강조 |
| `violet` | `#7C3AED` | 온보딩 그라디언트 끝점 |

### 2.2 Neutral Palette

| 토큰 | HEX | 용도 |
|---|---|---|
| `ink` | `#1A1A1A` | 주요 텍스트, 타이틀 |
| `sec` | `#555555` | 보조 텍스트, 서브헤딩 |
| `ter` | `#999999` | 캡션, 힌트 텍스트 |
| `mute` | `#C0C0C0` | 비활성 아이콘, 약한 구분선 |
| `white` | `#FFFFFF` | 배경, 카드 |

### 2.3 Glass & Overlay

| 토큰 | 값 | 용도 |
|---|---|---|
| `glass` | `rgba(255,255,255,0.65)` | 기본 글래스 카드 배경 |
| `glassStrong` | `rgba(255,255,255,0.82)` | 강조 글래스 카드 배경 |
| `glassBorder` | `rgba(255,255,255,0.45)` | 글래스 카드 테두리 |

### 2.4 특수 색상

| 용도 | 값 |
|---|---|
| 카카오 로그인 | `#FEE500` (텍스트: `#1A1A1A`) |
| Apple 로그인 | `#000000` (텍스트: `#FFFFFF`) |
| 프리미엄 왕관 | `#D4A017` (골드) |
| 프리미엄 CTA 그라디언트 | `linear-gradient(135deg, #4F46E5, #6366F1)` |

---

## 3. 배경 그라디언트 (Background Gradients)

### 3.1 앱 기본 배경 — `bgSoft`

```css
background: linear-gradient(180deg, #E8E4F8 0%, #DDE4F8 30%, #D8E8FA 55%, #E4F2FC 100%);
```

모든 일반 화면(홈, 옷장, 매칭, 마이, 로그인)에 동일하게 적용한다. 새 페이지를 만들 때도 이 배경을 기본으로 사용한다.

### 3.2 온보딩 배경 — `bgOnboard`

```css
background: linear-gradient(160deg, #4F46E5 0%, #6366F1 40%, #7C3AED 100%);
```

온보딩, 스플래시 A 등 브랜드 몰입형 화면 전용이다.

### 3.3 프리미엄 모달 오버레이

```css
background: rgba(0,0,0,0.65);
```

바텀시트 모달의 배경 딤 처리 용도이다.

---

## 4. 타이포그래피 (Typography)

### 4.1 폰트 패밀리

| 용도 | 폰트 | import |
|---|---|---|
| 앱 이름 (Aura) | `'Lobster', cursive` | Google Fonts |
| 영문 페이지 타이틀 | `'Lobster', cursive` | Google Fonts |
| 본문 (한글/영문) | `'Noto Sans KR', sans-serif` | Google Fonts |
| fallback | `-apple-system, 'Apple SD Gothic Neo', sans-serif` | 시스템 |

```html
<link href="https://fonts.googleapis.com/css2?family=Lobster&family=Noto+Sans+KR:wght@400;500;600;700;800&display=swap" rel="stylesheet">
```

### 4.2 텍스트 스케일

| 용도 | 크기 | 굵기 | 색상 |
|---|---|---|---|
| 스플래시 로고 | 72px | Lobster | `#fff` 또는 `primary` |
| 로그인 로고 | 56px | Lobster | `primary` |
| 페이지 타이틀 (Home, Closet, Match, My) | 32px | Lobster | `ink` |
| 온보딩 헤딩 | 26px | 700 | `#fff` |
| 로그인 헤딩 | 24px | 700 | `ink` |
| 스탯 숫자 | 22px | 700 | `ink` |
| 매칭 점수 (대형) | 64px | 800, Lobster | `primary` |
| 프리미엄 가격 | 24px | 800 | `ink` |
| 섹션 제목 | 15px | 600 | `ink` |
| 본문 | 14px | 400~500 | `ink` |
| 캡션 / 힌트 | 12~13px | 400~500 | `ter` |
| 작은 라벨 | 10~11px | 400~500 | `ter` |
| 법적 고지 | 11px | 400 | `mute` |

### 4.3 페이지 타이틀 규칙

페이지 타이틀은 **영문 Lobster**로 통일한다.

| 탭 | 타이틀 |
|---|---|
| Home | Aura |
| Closet | Closet |
| Match | Match |
| My | My |

서브타이틀이나 설명문은 한글 Noto Sans KR을 사용한다.

---

## 5. 글래스모피즘 (Glassmorphism)

AURA의 핵심 시각 요소이다. 모든 카드, 입력 영역, 리스트 컨테이너에 적용한다.

### 5.1 Glass 기본형

```css
background: rgba(255, 255, 255, 0.65);
border: 0.5px solid rgba(255, 255, 255, 0.45);
border-radius: 20px;
backdrop-filter: blur(20px);
-webkit-backdrop-filter: blur(20px);
box-shadow: 0 4px 24px rgba(0, 0, 0, 0.04);
```

### 5.2 Glass Strong (강조형)

```css
background: rgba(255, 255, 255, 0.82);
/* 나머지 동일 */
```

통계 카드, 리스트 컨테이너, 메뉴 등 가독성이 중요한 영역에 사용한다.

### 5.3 적용 가이드

| 사용처 | 타입 | radius |
|---|---|---|
| 스탯 카드 | Strong | 16px |
| 리스트 컨테이너 | Strong | 16px |
| 메뉴 리스트 | Strong | 16px |
| 퀵 액션 버튼 | Strong | 14px |
| 카테고리 원형 | 기본 | 26px (원형) |
| 태그 / 뱃지 | 기본 | 8px |
| 온보딩 CTA 버튼 | Strong | 14px |
| 업로드 영역 | Strong | 20px |

---

## 6. 컴포넌트 패턴 (Component Patterns)

### 6.1 상태바 (Status Bar)

```
[9:41]                          [signal] [battery]
```

- 라이트 모드: 텍스트 `ink`, 15px, fontWeight 600
- 다크 모드 (온보딩): 텍스트 `#fff`
- padding: `14px 28px 0`

### 6.2 페이지 헤더

```
[← 뒤로가기]   [타이틀 (Lobster 32px)]   [액션 아이콘]
```

- padding: `8px 20px 0`
- 뒤로가기 아이콘: 20×20, strokeWidth 2
- 우측 액션 아이콘: 글래스 원형 (36×36, radius 18, blur 12)
- 서브타이틀: 13px, `ter`, margin-top 4px

### 6.3 탭바 (Floating Pill Tab Bar)

```
         ┌──────────────────────────┐
         │  [🏠] [📦] [🔍] [👤]   │
         └──────────────────────────┘
```

| 속성 | 값 |
|---|---|
| 위치 | 하단 고정, bottom: 0, padding-bottom: 24px |
| 배경 | `rgba(255,255,255,0.92)` + blur(24px) |
| radius | 22px (외부 컨테이너) |
| padding | 6px 8px |
| 그림자 | `0 2px 20px rgba(0,0,0,0.08), 0 0 0 0.5px rgba(0,0,0,0.04)` |
| 탭 아이템 | 44×44px, radius 14px, 아이콘만 (라벨 없음) |
| 활성 탭 배경 | `rgba(79,70,229,0.1)` |
| 활성 아이콘 | `primary` (#4F46E5), filled 스타일, 22px |
| 비활성 아이콘 | `#999`, outline 스타일, 22px |

탭 구성:

| ID | 아이콘 | 화면 |
|---|---|---|
| `home` | 집 | 홈 대시보드 |
| `wardrobe` | 4분할 그리드 | 옷장 |
| `rec` | 스캔 (뷰파인더) | 룩 매칭 |
| `profile` | 사람 | 마이 페이지 |

### 6.4 Glass 카드 리스트

리스트 형태의 글래스 카드 패턴이다.

```
┌─────────────────────────────────┐
│ [썸네일 44×44 r12]  제목     값  │
│                     설명         │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│ [썸네일 44×44 r12]  제목     값  │
│                     설명         │
└─────────────────────────────────┘
```

- 컨테이너: Glass Strong, radius 16px, overflow hidden
- 각 행: padding `13px 16px`, gap 12px, flex row
- 구분선: `0.5px solid rgba(0,0,0,0.06)`, 마지막 행 없음
- 썸네일: 44×44px, radius 12px
- 제목: 14px, fontWeight 600, `ink`
- 설명: 12px, `ter`
- 우측 값: 14px, fontWeight 700, `primary`

### 6.5 스탯 카드 (3분할)

```
┌─────────┬─────────┬─────────┐
│   8     │   7     │   3     │
│  내 옷  │ 룩 매칭 │코디 기록│
└─────────┴─────────┴─────────┘
```

- Glass Strong, radius 16px, padding 16px
- 3분할: flex, 각 항목 `flex:1, textAlign:center`
- 구분선: `1px solid rgba(0,0,0,0.06)`, 마지막 없음
- 숫자: 22px, fontWeight 700, `ink`
- 라벨: 11px, `ter`

### 6.6 플랜 배너

```
┌─ gradient(primary → indigo) ─────────────┐
│ [👑 원형]  무료 플랜          [>]         │
│            옷장 8/30벌 · 매칭 3/5회       │
└───────────────────────────────────────────┘
```

- 배경: `linear-gradient(135deg, #4F46E5, #6366F1)`
- radius: 16px, padding: `16px 18px`
- 왕관 아이콘: 원형 배경 `rgba(255,255,255,0.18)`, 42×42px
- 제목: 15px, 700, `#fff`
- 설명: 12px, `rgba(255,255,255,0.6)`

### 6.7 메뉴 리스트

```
┌─────────────────────────────────┐
│ 알림 설정                    >  │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│ 자주 묻는 질문               >  │
├─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ┤
│ 앱 버전 1.0.0                   │
└─────────────────────────────────┘
```

- Glass Strong, radius 16px, overflow hidden
- 각 행: padding `14px 18px`, justify space-between
- 구분선: `0.5px solid rgba(0,0,0,0.05)`
- 텍스트: 14px, `ink` (마지막 행은 `ter`)
- 우측 화살표: chevron-right 14px, `mute`

### 6.8 퀵 액션 버튼

```
┌──────┐ ┌──────┐ ┌──────┐
│  📷  │ │  🔍  │ │  📅  │
│옷 등록│ │룩 매칭│ │코디  │
└──────┘ └──────┘ └──────┘
```

- Glass Strong, flex:1, radius 14px, padding `16px 14px`
- 아이콘 원형: 40×40px, radius 20, 배경 `rgba(79,70,229,0.08)`
- 아이콘 색상: `primary`, 22px
- 라벨: 12px, fontWeight 600, `ink`

### 6.9 FAB (Floating Action Button)

- 위치: absolute, bottom 96px, right 18px
- 크기: 48×48px, radius 24 (원형)
- 배경: `primary`
- 그림자: `0 6px 20px rgba(79,70,229,0.35)`
- 아이콘: plus, `#fff`, 20px
- zIndex: 40 (탭바보다 아래)

### 6.10 프리미엄 바텀시트 모달

```
┌─────────── 반투명 오버레이 ───────────┐
│                                       │
│                                       │
│  ┌─ 화이트 카드 (r: 24px 24px 0 0) ─┐│
│  │ 👑 프리미엄              ✕        ││
│  │ 모든 기능을 제한 없이 사용하세요   ││
│  │                                   ││
│  │ ✓ 무제한 옷장 등록                ││
│  │ ✓ 무제한 룩 재현                  ││
│  │ ✓ 상세 갭 분석                    ││
│  │ ✓ 데일리 코디 추천                ││
│  │                                   ││
│  │ ┌─ 월간 ─┐  ┌─ 연간 ──┐          ││
│  │ │ ₩6,900 │  │ ₩59,000 │          ││
│  │ │  /월   │  │₩4,917/월│          ││
│  │ └────────┘  └─────────┘          ││
│  │                                   ││
│  │ [ 프리미엄 시작하기 ]              ││
│  └───────────────────────────────────┘│
└───────────────────────────────────────┘
```

- 오버레이: `rgba(0,0,0,0.65)`, flex-end
- 카드: 배경 `#fff`, radius `24px 24px 0 0`, padding `24px 20px 40px`
- 왕관 아이콘: Crown 컴포넌트, 24px, `#D4A017` (골드)
- 체크 아이콘: SVG 체크마크, `primary`, strokeWidth 2.5
- 월간 카드: 테두리 `1.5px solid #E5E7EB`, radius 14px
- 연간 카드: 테두리 `1.5px solid primary`, radius 14px, 배경 `rgba(79,70,229,0.03)`
- 할인 뱃지: 배경 `primary`, radius 8px, 10px fontWeight 700 `#fff`
- CTA: 그라디언트 버튼, radius 14px, shadow `0 6px 20px rgba(79,70,229,0.25)`

---

## 7. 아이콘 시스템

모든 아이콘은 커스텀 SVG이며, `viewBox="0 0 24 24"` 기준이다.

### 7.1 아이콘 목록

| 이름 | 용도 | 기본 크기 | 스타일 |
|---|---|---|---|
| `home` / `homeF` | 홈 탭 | 22px | outline / filled |
| `grid` / `gridF` | 옷장 탭 | 22px | outline / filled |
| `scan` / `scanF` | 매칭 탭 | 22px | outline / filled |
| `user` / `userF` | 프로필 탭 | 22px | outline / filled |
| `cam` | 카메라 / 사진 촬영 | 24px | outline |
| `cal` / `calF` | 캘린더 | 22px | outline / filled |
| `plus` | FAB 추가 | 18px | outline |
| `back` | 뒤로가기 | 20px | outline |
| `right` | 더보기 화살표 | 14px | outline |
| `share` | 공유하기 | 18px | outline |
| `ext` | 외부 링크 | 12px | outline |
| `lock` | 잠금/프리미엄 | 16px | outline |
| `hanger` | 옷걸이 (빠진 아이템) | 22px | outline |
| `Crown` | 왕관 (프리미엄) | 22px | filled |

### 7.2 아이콘 컬러 규칙

| 상태 | 색상 |
|---|---|
| 탭바 활성 (filled) | `primary` (#4F46E5) |
| 탭바 비활성 (outline) | `#999` |
| 온보딩 아이콘 | `rgba(255,255,255,0.85)` |
| 헤더 액션 아이콘 | `sec` (#555) |
| 퀵 액션 아이콘 | `primary` |
| 뒤로가기 (라이트) | `ink` (#1A1A1A) |
| 뒤로가기 (다크) | `rgba(255,255,255,0.7)` |

---

## 8. 간격 & 레이아웃 규칙 (Spacing)

### 8.1 기본 여백

| 영역 | 값 |
|---|---|
| 화면 좌우 padding | 16px (카드), 20px (헤더), 24px (온보딩), 28px (로그인) |
| 섹션 간격 | 12px (compact), 16px (normal), 20px (spacious) |
| 카드 내부 padding | 16~18px |
| 리스트 행 padding | 13~14px 16~18px |
| 리스트 아이템 gap | 12px |
| 탭바~콘텐츠 여백 | bottom padding 100px (스크롤 가능 화면) |

### 8.2 라운딩 스케일

| 크기 | 용도 |
|---|---|
| 8px | 태그, 뱃지 |
| 10~12px | 작은 썸네일, 버튼 |
| 14px | CTA 버튼, 탭바 아이템 |
| 16px | 카드, 리스트 컨테이너 |
| 20px | 큰 카드, 업로드 영역 |
| 22px | 탭바 외부 |
| 24px | 바텀시트 상단 |
| 26px | 카테고리 원형 |
| 44px | 디바이스 프레임 |

---

## 9. 화면 구성 (Screen Inventory)

### 9.1 전체 화면 목록 (12개)

| # | 화면 | 배경 | 탭바 | 비고 |
|---|---|---|---|---|
| 1 | 스플래시 A | bgOnboard | 없음 | 인디고 배경 + 화이트 로고 |
| 2 | 스플래시 B | bgSoft | 없음 | 소프트 배경 + 인디고 로고 |
| 3 | 온보딩 1 | bgOnboard | 없음 | 옷걸이 아이콘 |
| 4 | 온보딩 2 | bgOnboard | 없음 | 카메라 아이콘 + ← 뒤로 |
| 5 | 온보딩 3 | bgOnboard | 없음 | 스캔 아이콘 + ← 뒤로 |
| 6 | 로그인 | bgSoft | 없음 | 카카오+Apple + ← 뒤로 |
| 7 | 홈 | bgSoft | home | 대시보드, 퀵 액션, 최근 매칭 |
| 8 | 옷장 | bgSoft | wardrobe | 카테고리 + Masonry 그리드 + FAB |
| 9 | 룩 매칭 (업로드) | bgSoft | rec | 사진 업로드 + 최근 분석 |
| 10 | 룩 매칭 (결과) | bgSoft | rec | 매칭 점수 + 아이템 리스트 |
| 11 | 마이 | bgSoft | profile | 플랜 배너 + 스탯 + 코디 캘린더 + 메뉴 |
| 12 | 프리미엄 | 오버레이 | 없음 | 바텀시트 모달 |

### 9.2 네비게이션 플로우

```
스플래시 → 온보딩 1 → 2 → 3 → 로그인 → 홈
                                          ↕
                              홈 ↔ 옷장 ↔ 매칭 ↔ 마이
                                                  ↓
                                              프리미엄 (모달)
```

---

## 10. 새 페이지 추가 가이드

### 10.1 기본 템플릿

```jsx
const NewScreen = () => <div style={{...ph, background: bgSoft}}>
  <SB/>
  {/* 헤더 */}
  <div style={{padding:"8px 20px 0"}}>
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}>
      <span style={{fontSize:32,fontFamily:lobster,color:C.ink}}>Title</span>
      {/* 우측 액션 아이콘 (필요시) */}
    </div>
    <p style={{fontSize:13,color:C.ter,margin:"4px 0 0"}}>서브타이틀</p>
  </div>

  {/* 콘텐츠 영역 */}
  <div style={{padding:"16px 16px 100px"}}>
    <Glass strong style={{borderRadius:16,padding:16}}>
      {/* 내용 */}
    </Glass>
  </div>

  <TabBar active="home"/>
</div>;
```

### 10.2 뒤로가기가 있는 서브 페이지

```jsx
const SubScreen = () => <div style={{...ph, background: bgSoft}}>
  <SB/>
  <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"8px 20px 0"}}>
    {I.back(C.ink)}
    <span style={{fontSize:16,fontWeight:600,color:C.ink}}>페이지 제목</span>
    <div style={{width:20}}/>  {/* 우측 정렬용 빈 공간 */}
  </div>

  {/* 콘텐츠 */}
  <div style={{padding:"16px 16px 40px"}}>
    {/* ... */}
  </div>
</div>;
```

### 10.3 바텀시트 모달

```jsx
const ModalScreen = () => <div style={{...ph, background:"rgba(0,0,0,0.65)", display:"flex", flexDirection:"column", justifyContent:"flex-end"}}>
  <div style={{flex:1}}/>
  <div style={{background:"#fff",borderRadius:"24px 24px 0 0",padding:"24px 20px 40px"}}>
    {/* 헤더: 타이틀 + X 닫기 */}
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:20}}>
      <span style={{fontSize:18,fontWeight:700,color:C.ink}}>모달 타이틀</span>
      {/* X 닫기 아이콘 */}
    </div>
    {/* 모달 콘텐츠 */}
  </div>
</div>;
```

### 10.4 체크리스트

새 페이지를 만들 때 아래 항목을 확인한다.

- [ ] 배경이 `bgSoft`인가? (온보딩/스플래시 제외)
- [ ] 폰트가 `sys` (Noto Sans KR)을 기본으로 사용하는가?
- [ ] 페이지 타이틀이 Lobster 영문인가?
- [ ] 카드가 Glass 또는 Glass Strong을 사용하는가?
- [ ] 탭바가 포함된 화면이면 하단 padding 100px 이상인가?
- [ ] 아이콘 색상이 규칙에 맞는가?
- [ ] 리스트 구분선이 `0.5px solid rgba(0,0,0,0.06)`인가?
- [ ] CTA 버튼이 인디고 그라디언트인가?

---

## 11. 버전 히스토리

| 버전 | 날짜 | 주요 변경 |
|---|---|---|
| v1 | 2025-02 | 초기 UI — 이모지, 핑크 테마 |
| v2 | 2025-02 | 이모지 제거, 토스+인스타 패턴 |
| v3 | 2025-02 | 화이트 카드, 뉴트럴 컬러, Masonry |
| v4.0 | 2025-03 | AURA 리브랜딩, 글래스모피즘, Lobster |
| v4.2 | 2025-03 | 배경 통일, 핑크→인디고 색상 변경 |
| v4.3 | 2025-03 | 탭 구조 변경 (홈 추가, 데일리→마이 통합) |
| v4.5 | 2025-03 | 온보딩 중앙 정렬, Noto Sans KR 적용 |
| v4.7 | 2025-03 | 프리미엄 바텀시트 모달, Crown 아이콘 |
| v4.8 | 2025-03 | 영문 Lobster 타이틀, 프리미엄 월간/연간 |
| v4.9 | 2025-03 | 화이트 글래스 탭바, 아이콘 전용 |