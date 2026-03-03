import { useState, useEffect } from "react";

/* ── Load Lobster + Noto Sans KR + Nanum Brush Script from Google Fonts ── */
const fontLink = document.createElement("link");
fontLink.href = "https://fonts.googleapis.com/css2?family=Lobster&family=Noto+Sans+KR:wght@400;500;600;700;800&family=Nanum+Brush+Script&display=swap";
fontLink.rel = "stylesheet";
document.head.appendChild(fontLink);

const C = {
  ink: "#1A1A1A", sec: "#555", ter: "#999", mute: "#C0C0C0",
  white: "#FFF", primary: "#4F46E5", violet: "#7C3AED", indigo: "#6366F1",
  glass: "rgba(255,255,255,0.65)", glassBorder: "rgba(255,255,255,0.45)",
  glassStrong: "rgba(255,255,255,0.82)",
};
const blur = (n=20) => ({ backdropFilter:`blur(${n}px)`, WebkitBackdropFilter:`blur(${n}px)` });
const lobster = "'Lobster', cursive";
const brush = "'Nanum Brush Script', cursive";
const sys = "'Noto Sans KR', -apple-system, 'Apple SD Gothic Neo', sans-serif";

const ph = {
  width:375, height:812, borderRadius:44, overflow:"hidden", position:"relative",
  boxShadow:"0 20px 60px rgba(0,0,0,0.18), 0 0 0 0.5px rgba(0,0,0,0.06)",
  fontFamily:sys, flexShrink:0,
};

/* ── Soft BG Gradients ── */
const bgSoft = "linear-gradient(180deg, #E8E4F8 0%, #DDE4F8 30%, #D8E8FA 55%, #E4F2FC 100%)";
const bgWarm = bgSoft;
const bgCool = bgSoft;
const bgOnboard = "linear-gradient(160deg, #4F46E5 0%, #6366F1 40%, #7C3AED 100%)";

/* ── Icons ── */
const I = {
  home:(c,s=22)=><svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M3 9.5L12 3l9 6.5V20a1 1 0 01-1 1H4a1 1 0 01-1-1V9.5z"/></svg>,
  homeF:(c,s=22)=><svg width={s} height={s} viewBox="0 0 24 24" fill={c} stroke={c} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"><path d="M3 9.5L12 3l9 6.5V20a1 1 0 01-1 1H4a1 1 0 01-1-1V9.5z"/></svg>,
  grid:(c,s=22)=><svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.5"><rect x="3" y="3" width="7.5" height="7.5" rx="1.5"/><rect x="13.5" y="3" width="7.5" height="7.5" rx="1.5"/><rect x="3" y="13.5" width="7.5" height="7.5" rx="1.5"/><rect x="13.5" y="13.5" width="7.5" height="7.5" rx="1.5"/></svg>,
  gridF:(c,s=22)=><svg width={s} height={s} viewBox="0 0 24 24" fill={c}><rect x="3" y="3" width="7.5" height="7.5" rx="1.5"/><rect x="13.5" y="3" width="7.5" height="7.5" rx="1.5"/><rect x="3" y="13.5" width="7.5" height="7.5" rx="1.5"/><rect x="13.5" y="13.5" width="7.5" height="7.5" rx="1.5"/></svg>,
  scan:(c,s=22)=><svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.5" strokeLinecap="round"><path d="M7 3H5a2 2 0 00-2 2v2"/><path d="M17 3h2a2 2 0 012 2v2"/><path d="M7 21H5a2 2 0 01-2-2v-2"/><path d="M17 21h2a2 2 0 002-2v-2"/><circle cx="12" cy="12" r="3.5"/></svg>,
  scanF:(c,s=22)=><svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round"><path d="M7 3H5a2 2 0 00-2 2v2"/><path d="M17 3h2a2 2 0 012 2v2"/><path d="M7 21H5a2 2 0 01-2-2v-2"/><path d="M17 21h2a2 2 0 002-2v-2"/><circle cx="12" cy="12" r="3.5" fill={c}/></svg>,
  cal:(c,s=22)=><svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.5" strokeLinecap="round"><rect x="3" y="4" width="18" height="18" rx="2"/><path d="M3 10h18"/><path d="M8 2v4"/><path d="M16 2v4"/></svg>,
  calF:(c,s=22)=><svg width={s} height={s} viewBox="0 0 24 24" fill={c}><rect x="3" y="4" width="18" height="18" rx="2.5"/></svg>,
  user:(c,s=22)=><svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.5"><circle cx="12" cy="8" r="3.5"/><path d="M6 21v-1a6 6 0 0112 0v1"/></svg>,
  userF:(c,s=22)=><svg width={s} height={s} viewBox="0 0 24 24" fill={c}><circle cx="12" cy="8" r="4"/><path d="M5 21a7 7 0 0114 0H5z"/></svg>,
  plus:(c="#fff",s=18)=><svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2.5" strokeLinecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/></svg>,
  back:(c="#fff")=><svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round"><path d="M15 18l-6-6 6-6"/></svg>,
  right:(c=C.mute)=><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round"><path d="M9 6l6 6-6 6"/></svg>,
  cam:(c=C.ter,s=24)=><svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.4" strokeLinecap="round"><path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z"/><circle cx="12" cy="13" r="4"/></svg>,
  share:(c)=><svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.5" strokeLinecap="round"><path d="M4 12v8a2 2 0 002 2h12a2 2 0 002-2v-8"/><polyline points="16 6 12 2 8 6"/><line x1="12" y1="2" x2="12" y2="15"/></svg>,
  ext:(c="#fff")=><svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="2" strokeLinecap="round"><path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/><polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/></svg>,
  lock:(c=C.ter)=><svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.5" strokeLinecap="round"><rect x="3" y="11" width="18" height="11" rx="2"/><path d="M7 11V7a5 5 0 0110 0v4"/></svg>,
  hanger:(c,s=22)=><svg width={s} height={s} viewBox="0 0 24 24" fill="none" stroke={c} strokeWidth="1.4"><path d="M12 6a2 2 0 002-2c0-1-1-2-2-2s-2 1-2 2"/><path d="M12 6L4 16h16L12 6z"/></svg>,
};

/* ── Status Bar ── */
const SB = ({dark}) => <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"14px 28px 0",fontSize:15,fontWeight:600,color:dark?"#fff":C.ink}}>
  <span>9:41</span>
  <div style={{display:"flex",gap:5,alignItems:"center"}}>
    <svg width="16" height="11" viewBox="0 0 16 11"><rect x="0" y="1" width="3" height="10" rx=".5" fill={dark?"#fff":C.ink} opacity=".4"/><rect x="4.5" y="3" width="3" height="8" rx=".5" fill={dark?"#fff":C.ink} opacity=".6"/><rect x="9" y=".5" width="3" height="10.5" rx=".5" fill={dark?"#fff":C.ink} opacity=".8"/><rect x="13" y="3" width="3" height="8" rx=".5" fill={dark?"#fff":C.ink}/></svg>
    <div style={{width:24,height:11,border:`1.2px solid ${dark?"rgba(255,255,255,.5)":"#aaa"}`,borderRadius:3,position:"relative",marginLeft:2}}>
      <div style={{position:"absolute",top:2,left:2,width:14,height:5.5,background:dark?"#fff":C.ink,borderRadius:1.5}}/>
    </div>
  </div>
</div>;

/* ── Glass Card ── */
const Glass = ({children, style:s, strong}) => <div style={{
  background: strong ? C.glassStrong : C.glass, border:`0.5px solid ${C.glassBorder}`,
  borderRadius:20, ...blur(20), boxShadow:"0 4px 24px rgba(0,0,0,0.04)", ...s
}}>{children}</div>;

/* ── Tab Bar (Floating Pill) ── */
const TabBar = ({active}) => {
  const tabs=[
    {id:"home",ic:I.home,icA:I.homeF,l:"Home"},
    {id:"wardrobe",ic:I.grid,icA:I.gridF,l:"Closet"},
    {id:"rec",ic:I.scan,icA:I.scanF,l:"Match"},
    {id:"profile",ic:I.user,icA:I.userF,l:"My"},
  ];
  return <div style={{position:"absolute",bottom:0,left:0,right:0,display:"flex",justifyContent:"center",zIndex:50,padding:"0 0 24px"}}>
    <div style={{background:"rgba(255,255,255,0.92)",...blur(24),borderRadius:22,padding:"6px 8px",display:"flex",gap:4,alignItems:"center",boxShadow:"0 2px 20px rgba(0,0,0,0.08), 0 0 0 0.5px rgba(0,0,0,0.04)"}}>
      {tabs.map(t=>{
        const isActive = active===t.id;
        return <div key={t.id} style={{
          display:"flex",alignItems:"center",justifyContent:"center",
          width:44,height:44,borderRadius:14,
          background:isActive?"rgba(79,70,229,0.1)":"transparent",
          cursor:"pointer",
        }}>
          {isActive?t.icA(C.primary,22):t.ic("#999",22)}
        </div>;
      })}
    </div>
  </div>;
};

/* ── Data ── */
const W=[
  {id:1,color:"#2C3E50",cat:"아우터",name:"네이비 코트",h:180},
  {id:2,color:"#E8D5B7",cat:"상의",name:"크림 니트",h:140},
  {id:3,color:"#1A1A2E",cat:"하의",name:"블랙 슬랙스",h:165},
  {id:4,color:"#8B4513",cat:"신발",name:"브라운 로퍼",h:120},
  {id:5,color:"#F0EBE3",cat:"상의",name:"아이보리 셔츠",h:150},
  {id:6,color:"#4A6741",cat:"아우터",name:"카키 자켓",h:175},
  {id:7,color:"#C4A882",cat:"가방",name:"탄 숄더백",h:130},
  {id:8,color:"#6B7B8D",cat:"하의",name:"그레이 데님",h:155},
];
const CATS=["전체","상의","하의","아우터","신발","가방"];
const REC=[{id:1,color:"#D4B896",score:91,label:"캐주얼 코디"},{id:2,color:"#8B9DAF",score:87,label:"오피스룩"},{id:3,color:"#A0826D",score:76,label:"데이트룩"}];

/* ══════════════════════════════════════
   SCREENS
   ══════════════════════════════════════ */

/* ── Splash A (Indigo) ── */
const SplashA = () => <div style={{...ph, background: bgOnboard}}>
  <div style={{height:"100%",display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center"}}>
    <span style={{fontSize:72,fontFamily:lobster,color:"#fff",lineHeight:1}}>Aura</span>
    <p style={{fontSize:13,color:"rgba(255,255,255,0.45)",letterSpacing:4,marginTop:12,fontWeight:500}}>STYLE REIMAGINED</p>
  </div>
</div>;

/* ── Splash B (White) ── */
const SplashB = () => <div style={{...ph, background: bgSoft}}>
  <div style={{height:"100%",display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center"}}>
    <span style={{fontSize:72,fontFamily:lobster,color:C.primary,lineHeight:1}}>Aura</span>
    <p style={{fontSize:13,color:C.ter,letterSpacing:4,marginTop:12,fontWeight:500}}>STYLE REIMAGINED</p>
  </div>
</div>;

/* ── Onboarding ── */
const OnboardScr = ({page=0}) => {
  const sl = [
    { t:"인플루언서 코디,\n내 옷장으로 따라입기", s:"인스타에서 본 코디를 새 옷 없이\n이미 가진 옷으로 재현하세요",
      icon: <svg width="44" height="44" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,0.85)" strokeWidth="1.2"><path d="M12 6a2 2 0 002-2c0-1-1-2-2-2s-2 1-2 2"/><path d="M12 6L4 16h16L12 6z"/><line x1="4" y1="16" x2="4" y2="20"/><line x1="20" y1="16" x2="20" y2="20"/><line x1="4" y1="20" x2="20" y2="20"/></svg> },
    { t:"사진 한 장이면 끝,\n30초 옷장 등록", s:"AI가 배경을 제거하고\n색상과 카테고리를 자동 분석해요",
      icon: I.cam("rgba(255,255,255,0.85)",44) },
    { t:"AI 코디 매칭으로\n나만의 스타일 완성", s:"원하는 코디 사진만 올리면\n내 옷장에서 최적 조합을 찾아줘요",
      icon: I.scan("rgba(255,255,255,0.85)",44) },
  ];
  const p = sl[page];
  return <div style={{...ph, background: bgOnboard, display:"flex", flexDirection:"column"}}>
    <SB dark/>
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"8px 24px 0"}}>
      <div style={{width:32,height:32,display:"flex",alignItems:"center",justifyContent:"center",cursor:"pointer",opacity:page>0?1:0}}>
        {I.back("rgba(255,255,255,0.7)")}
      </div>
      <span style={{fontSize:14,color:"rgba(255,255,255,.4)"}}>건너뛰기</span>
    </div>
    {/* Center content */}
    <div style={{flex:1,display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",textAlign:"center",padding:"0 36px"}}>
      {/* Concentric circles + icon */}
      <div style={{width:180,height:180,borderRadius:90,background:"rgba(255,255,255,0.06)",display:"flex",alignItems:"center",justifyContent:"center",marginBottom:40}}>
        <div style={{width:120,height:120,borderRadius:60,background:"rgba(255,255,255,0.06)",display:"flex",alignItems:"center",justifyContent:"center"}}>
          {p.icon}
        </div>
      </div>
      <h1 style={{fontSize:26,fontWeight:700,color:"#fff",lineHeight:1.4,whiteSpace:"pre-line",margin:"0 0 14px",letterSpacing:-.3}}>{p.t}</h1>
      <p style={{fontSize:14,color:"rgba(255,255,255,.45)",lineHeight:1.7,whiteSpace:"pre-line",margin:0}}>{p.s}</p>
    </div>
    {/* Dots + Button pinned to bottom */}
    <div style={{padding:"0 28px 52px"}}>
      <div style={{display:"flex",justifyContent:"center",gap:6,marginBottom:20}}>
        {sl.map((_,i)=><div key={i} style={{width:i===page?20:6,height:6,borderRadius:3,background:i===page?"#fff":"rgba(255,255,255,.25)"}}/>)}
      </div>
      <Glass strong style={{padding:"16px",textAlign:"center",cursor:"pointer",borderRadius:14}}>
        <span style={{fontSize:15,fontWeight:700,color:C.primary}}>{page<2?"다음":"시작하기"}</span>
      </Glass>
    </div>
  </div>;
};

/* ── Login ── */
const LoginScr = () => <div style={{...ph, background: bgSoft, display:"flex", flexDirection:"column"}}>
  <SB/>
  <div style={{padding:"8px 24px 0"}}>
    <div style={{width:32,height:32,display:"flex",alignItems:"center",justifyContent:"center",cursor:"pointer"}}>
      {I.back(C.ink)}
    </div>
  </div>
  {/* Top spacer */}
  <div style={{flex:1}}/>
  {/* Logo + text - centered */}
  <div style={{padding:"0 28px",textAlign:"center"}}>
    <span style={{fontSize:56,fontFamily:lobster,color:C.primary,lineHeight:1,display:"block",marginBottom:20}}>Aura</span>
    <h1 style={{fontSize:24,fontWeight:700,color:C.ink,margin:"0 0 8px",lineHeight:1.4}}>나만의 스타일을<br/>발견하세요</h1>
    <p style={{fontSize:14,color:C.ter,margin:0}}>간편하게 시작하세요</p>
  </div>
  {/* Spacer */}
  <div style={{flex:1}}/>
  {/* Buttons */}
  <div style={{padding:"0 28px 16px"}}>
    <div style={{padding:"15px",background:"#FEE500",borderRadius:12,textAlign:"center",cursor:"pointer",marginBottom:10}}>
      <span style={{fontSize:15,fontWeight:600,color:"#1A1A1A"}}>카카오로 시작하기</span>
    </div>
    <div style={{padding:"15px",background:"#000",borderRadius:12,textAlign:"center",cursor:"pointer"}}>
      <span style={{fontSize:15,fontWeight:600,color:"#fff"}}>Apple로 시작하기</span>
    </div>
  </div>
  <p style={{textAlign:"center",fontSize:11,color:C.mute,padding:"0 28px 44px",lineHeight:1.7}}>
    시작하면 <span style={{textDecoration:"underline"}}>이용약관</span> 및 <span style={{textDecoration:"underline"}}>개인정보처리방침</span>에 동의합니다
  </p>
</div>;

/* ── Home ── */
const HomeScr = () => <div style={{...ph, background: bgSoft}}>
  <SB/>
  <div style={{padding:"8px 20px 0"}}>
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}>
      <span style={{fontSize:32,fontFamily:lobster,color:C.ink}}>Aura</span>
      <div style={{width:36,height:36,borderRadius:18,background:"rgba(255,255,255,0.6)",...blur(12),display:"flex",alignItems:"center",justifyContent:"center"}}>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={C.sec} strokeWidth="1.5" strokeLinecap="round"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
      </div>
    </div>
    <p style={{fontSize:14,color:C.ter,margin:"4px 0 0"}}>오늘도 멋진 하루 보내세요</p>
  </div>
  {/* Quick stats */}
  <div style={{padding:"16px 16px 0"}}>
    <Glass strong style={{borderRadius:16,padding:16}}>
      <div style={{display:"flex"}}>
        {[{n:"8",l:"내 옷",ic:"👔"},{n:"7",l:"매칭 완료",ic:"✨"},{n:"91%",l:"최고 점수",ic:"🏆"}].map((s,i)=><div key={i} style={{flex:1,textAlign:"center",borderRight:i<2?"1px solid rgba(0,0,0,0.06)":"none"}}>
          <p style={{fontSize:22,fontWeight:700,color:C.ink,margin:"0 0 2px"}}>{s.n}</p>
          <p style={{fontSize:11,color:C.ter,margin:0}}>{s.l}</p>
        </div>)}
      </div>
    </Glass>
  </div>
  {/* Quick actions */}
  <div style={{display:"flex",gap:8,padding:"12px 16px 0"}}>
    <Glass strong style={{flex:1,borderRadius:14,padding:"16px 14px",display:"flex",flexDirection:"column",alignItems:"center",gap:8,cursor:"pointer"}}>
      <div style={{width:40,height:40,borderRadius:20,background:"rgba(79,70,229,0.08)",display:"flex",alignItems:"center",justifyContent:"center"}}>
        {I.cam(C.primary,22)}
      </div>
      <span style={{fontSize:12,fontWeight:600,color:C.ink}}>옷 등록</span>
    </Glass>
    <Glass strong style={{flex:1,borderRadius:14,padding:"16px 14px",display:"flex",flexDirection:"column",alignItems:"center",gap:8,cursor:"pointer"}}>
      <div style={{width:40,height:40,borderRadius:20,background:"rgba(79,70,229,0.08)",display:"flex",alignItems:"center",justifyContent:"center"}}>
        {I.scan(C.primary,22)}
      </div>
      <span style={{fontSize:12,fontWeight:600,color:C.ink}}>룩 매칭</span>
    </Glass>
    <Glass strong style={{flex:1,borderRadius:14,padding:"16px 14px",display:"flex",flexDirection:"column",alignItems:"center",gap:8,cursor:"pointer"}}>
      <div style={{width:40,height:40,borderRadius:20,background:"rgba(79,70,229,0.08)",display:"flex",alignItems:"center",justifyContent:"center"}}>
        {I.cal(C.primary,22)}
      </div>
      <span style={{fontSize:12,fontWeight:600,color:C.ink}}>코디 기록</span>
    </Glass>
  </div>
  {/* Recent matches */}
  <div style={{padding:"16px 16px 0"}}>
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:10,padding:"0 4px"}}>
      <p style={{fontSize:15,fontWeight:600,color:C.ink,margin:0}}>최근 매칭</p>
      <span style={{fontSize:13,color:C.ter}}>더보기</span>
    </div>
    <Glass strong style={{borderRadius:16,overflow:"hidden"}}>
      {REC.map((r,i)=><div key={r.id} style={{display:"flex",alignItems:"center",gap:12,padding:"13px 16px",borderBottom:i<2?"0.5px solid rgba(0,0,0,0.06)":"none"}}>
        <div style={{width:44,height:44,borderRadius:12,background:r.color,flexShrink:0}}/>
        <div style={{flex:1}}>
          <p style={{fontSize:14,fontWeight:600,color:C.ink,margin:"0 0 1px"}}>{r.label}</p>
          <p style={{fontSize:12,color:C.ter,margin:0}}>매칭 완료</p>
        </div>
        <span style={{fontSize:14,fontWeight:700,color:C.primary}}>{r.score}%</span>
      </div>)}
    </Glass>
  </div>
  {/* Premium CTA */}
  <div style={{padding:"12px 16px 0"}}>
    <div style={{background:`linear-gradient(135deg, ${C.primary} 0%, ${C.indigo} 100%)`,borderRadius:14,padding:"14px 16px",display:"flex",alignItems:"center",gap:12}}>
      {I.lock("#fff")}
      <div style={{flex:1}}>
        <p style={{fontSize:13,fontWeight:600,color:"#fff",margin:"0 0 2px"}}>프리미엄으로 더 많은 기능을 잠금해제</p>
        <p style={{fontSize:11,color:"rgba(255,255,255,.5)",margin:0}}>7일 무료 체험</p>
      </div>
      {I.right("rgba(255,255,255,0.5)")}
    </div>
  </div>
  <TabBar active="home"/>
</div>;

/* ── Wardrobe (Home) ── */
const WardrobeScr = () => {
  const L=W.filter((_,i)=>i%2===0), R=W.filter((_,i)=>i%2===1);
  return <div style={{...ph, background: bgSoft}}>
    <SB/>
    <div style={{padding:"8px 20px 0"}}>
      <div style={{display:"flex",justifyContent:"space-between",alignItems:"center"}}>
        <span style={{fontSize:32,fontFamily:lobster,color:C.ink}}>Closet</span>
        <span style={{fontSize:12,color:C.ter}}>{W.length}/30</span>
      </div>
    </div>
    {/* Story-like categories */}
    <div style={{display:"flex",gap:12,padding:"14px 20px",overflowX:"auto"}}>
      {CATS.map((c,i)=>{
        const active=i===0;
        const count=c==="전체"?W.length:W.filter(w=>w.cat===c).length;
        return <div key={c} style={{display:"flex",flexDirection:"column",alignItems:"center",gap:6,flexShrink:0}}>
          <Glass style={{width:52,height:52,borderRadius:26,display:"flex",alignItems:"center",justifyContent:"center",
            border:active?`2px solid ${C.primary}`:`0.5px solid ${C.glassBorder}`,padding:0}}>
            <span style={{fontSize:14,fontWeight:700,color:active?C.primary:C.ter}}>{count}</span>
          </Glass>
          <span style={{fontSize:11,color:active?C.ink:C.ter,fontWeight:active?600:400}}>{c}</span>
        </div>;
      })}
    </div>
    {/* Grid */}
    <div style={{display:"flex",gap:4,padding:"0 4px",height:485,overflowY:"auto"}}>
      {[L,R].map((col,ci)=><div key={ci} style={{flex:1,display:"flex",flexDirection:"column",gap:4}}>
        {col.map(item=><div key={item.id} style={{background:item.color,height:item.h,borderRadius:16,position:"relative",overflow:"hidden"}}>
          <div style={{position:"absolute",bottom:0,left:0,right:0,padding:"24px 12px 10px",background:"linear-gradient(transparent,rgba(0,0,0,.4))"}}>
            <p style={{fontSize:10,color:"rgba(255,255,255,.6)",margin:"0 0 2px",fontWeight:500}}>{item.cat}</p>
            <p style={{fontSize:13,color:"#fff",margin:0,fontWeight:600}}>{item.name}</p>
          </div>
        </div>)}
      </div>)}
    </div>
    {/* FAB */}
    <div style={{position:"absolute",bottom:96,right:18,width:48,height:48,borderRadius:24,background:C.primary,display:"flex",alignItems:"center",justifyContent:"center",boxShadow:"0 6px 20px rgba(79,70,229,.35)",zIndex:40}}>
      {I.plus("#fff",20)}
    </div>
    <TabBar active="wardrobe"/>
  </div>;
};

/* ── Recreation Upload ── */
const RecUploadScr = () => <div style={{...ph, background: bgWarm}}>
  <SB/>
  <div style={{padding:"8px 20px 0"}}>
    <span style={{fontSize:32,fontFamily:lobster,color:C.ink}}>Match</span>
    <p style={{fontSize:13,color:C.ter,margin:"4px 0 0"}}>따라입고 싶은 코디 사진을 올려주세요</p>
  </div>
  <div style={{padding:"20px 16px 0"}}>
    <Glass strong style={{height:200,display:"flex",flexDirection:"column",alignItems:"center",justifyContent:"center",gap:10,cursor:"pointer",borderRadius:20}}>
      <div style={{width:52,height:52,borderRadius:26,background:"rgba(79,70,229,0.08)",display:"flex",alignItems:"center",justifyContent:"center"}}>
        {I.cam(C.primary,28)}
      </div>
      <p style={{fontSize:15,fontWeight:600,color:C.ink,margin:0}}>사진 선택하기</p>
      <p style={{fontSize:13,color:C.ter,margin:0}}>갤러리에서 고르거나 직접 찍어주세요</p>
    </Glass>
  </div>
  {/* Recent */}
  <div style={{padding:"20px 16px 0"}}>
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:10,padding:"0 4px"}}>
      <p style={{fontSize:15,fontWeight:600,color:C.ink,margin:0}}>최근 분석</p>
      <span style={{fontSize:13,color:C.ter}}>더보기</span>
    </div>
    <Glass strong style={{borderRadius:16,overflow:"hidden"}}>
      {REC.map((r,i)=><div key={r.id} style={{display:"flex",alignItems:"center",gap:12,padding:"13px 16px",borderBottom:i<2?"0.5px solid rgba(0,0,0,0.06)":"none"}}>
        <div style={{width:44,height:44,borderRadius:12,background:r.color,flexShrink:0}}/>
        <div style={{flex:1}}>
          <p style={{fontSize:14,fontWeight:600,color:C.ink,margin:"0 0 1px"}}>{r.label}</p>
          <p style={{fontSize:12,color:C.ter,margin:0}}>매칭 완료</p>
        </div>
        <span style={{fontSize:14,fontWeight:700,color:C.primary}}>{r.score}%</span>
      </div>)}
    </Glass>
  </div>
  <div style={{display:"flex",justifyContent:"center",marginTop:16}}>
    <Glass style={{borderRadius:20,padding:"6px 14px"}}>
      <span style={{fontSize:12,color:C.ter}}>이번 달 남은 횟수 <span style={{fontWeight:700,color:C.primary}}>3/5</span></span>
    </Glass>
  </div>
  <TabBar active="rec"/>
</div>;

/* ── Recreation Result ── */
const RecResultScr = () => {
  const matched=[{name:"크림 니트",score:95,cat:"상의",color:"#E8D5B7"},{name:"블랙 슬랙스",score:88,cat:"하의",color:"#1A1A2E"},{name:"브라운 로퍼",score:78,cat:"신발",color:"#8B4513"}];
  return <div style={{...ph, background: bgWarm}}>
    <SB/>
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",padding:"8px 20px 0"}}>
      {I.back(C.ink)}<span style={{fontSize:16,fontWeight:600,color:C.ink}}>분석 결과</span>{I.share(C.sec)}
    </div>
    {/* Score */}
    <div style={{textAlign:"center",padding:"28px 0 20px"}}>
      <p style={{fontSize:13,color:C.ter,margin:"0 0 8px"}}>매칭 점수</p>
      <span style={{fontSize:64,fontWeight:800,color:C.primary,letterSpacing:-3,fontFamily:lobster}}>87<span style={{fontSize:24,color:C.ter}}>%</span></span>
    </div>
    {/* Actions */}
    <div style={{display:"flex",padding:"0 16px 16px",gap:8}}>
      <div style={{flex:1,padding:"12px",background:C.primary,borderRadius:12,textAlign:"center"}}>
        <span style={{fontSize:13,fontWeight:600,color:"#fff"}}>코디 저장</span>
      </div>
      <Glass strong style={{flex:1,padding:"12px",borderRadius:12,textAlign:"center",cursor:"pointer"}}>
        <span style={{fontSize:13,fontWeight:600,color:C.ink}}>공유하기</span>
      </Glass>
    </div>
    {/* Matched */}
    <div style={{padding:"0 16px 100px"}}>
      <p style={{fontSize:13,fontWeight:600,color:C.sec,margin:"0 0 8px"}}>매칭된 아이템 3</p>
      <Glass strong style={{borderRadius:16,overflow:"hidden",marginBottom:14}}>
        {matched.map((m,i)=><div key={i} style={{display:"flex",alignItems:"center",gap:12,padding:"13px 16px",borderBottom:i<2?"0.5px solid rgba(0,0,0,0.06)":"none"}}>
          <div style={{width:42,height:42,borderRadius:10,background:m.color,flexShrink:0}}/>
          <div style={{flex:1}}>
            <p style={{fontSize:14,fontWeight:600,color:C.ink,margin:"0 0 1px"}}>{m.name}</p>
            <p style={{fontSize:12,color:C.ter,margin:0}}>{m.cat}</p>
          </div>
          <span style={{fontSize:14,fontWeight:700,color:C.primary}}>{m.score}%</span>
        </div>)}
      </Glass>
      <p style={{fontSize:13,fontWeight:600,color:C.sec,margin:"0 0 8px"}}>빠진 아이템 1</p>
      <Glass strong style={{borderRadius:16,padding:"13px 16px",display:"flex",alignItems:"center",gap:12}}>
        <div style={{width:42,height:42,borderRadius:10,background:"rgba(79,70,229,0.06)",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
          {I.hanger(C.mute,20)}
        </div>
        <div style={{flex:1}}>
          <p style={{fontSize:14,fontWeight:600,color:C.ink,margin:"0 0 1px"}}>베이지 머플러</p>
          <p style={{fontSize:12,color:C.ter,margin:0}}>액세서리</p>
        </div>
        <div style={{background:C.ink,borderRadius:8,padding:"7px 12px",display:"flex",alignItems:"center",gap:4}}>
          <span style={{fontSize:12,fontWeight:600,color:"#fff"}}>쇼핑</span>{I.ext()}
        </div>
      </Glass>
    </div>
    <TabBar active="rec"/>
  </div>;
};

/* ── Daily ── */
const DailyScr = () => {
  const days=["일","월","화","수","목","금","토"], today=4;
  return <div style={{...ph, background: bgCool}}>
    <SB/>
    <div style={{padding:"8px 20px 16px"}}>
      <span style={{fontSize:32,fontFamily:lobster,color:C.ink}}>Daily</span>
      {/* Week */}
      <div style={{display:"flex",justifyContent:"space-between",marginTop:16}}>
        {days.map((d,i)=>{
          const act=i===today, past=i<today;
          return <div key={d} style={{textAlign:"center",width:36}}>
            <p style={{fontSize:11,color:act?C.primary:C.ter,margin:"0 0 6px",fontWeight:500}}>{d}</p>
            <Glass style={{width:34,height:34,borderRadius:17,margin:"0 auto",display:"flex",alignItems:"center",justifyContent:"center",padding:0,
              background:act?C.primary:past?"rgba(255,255,255,0.7)":"rgba(255,255,255,0.4)",
              border:act?"none":`0.5px solid ${C.glassBorder}`}}>
              <span style={{fontSize:12,fontWeight:act?700:500,color:act?"#fff":past?C.ink:C.mute}}>{22+i}</span>
            </Glass>
            {past&&<div style={{width:3,height:3,borderRadius:1.5,background:C.primary,margin:"4px auto 0",opacity:.4}}/>}
          </div>;
        })}
      </div>
    </div>
    <div style={{padding:"0 16px"}}>
      <Glass strong style={{borderRadius:20,padding:18}}>
        <div style={{display:"flex",justifyContent:"space-between",marginBottom:14}}>
          <div><p style={{fontSize:15,fontWeight:700,color:C.ink,margin:"0 0 2px"}}>오늘의 코디</p><p style={{fontSize:12,color:C.ter,margin:0}}>2월 26일 목요일</p></div>
        </div>
        <div style={{display:"flex",gap:6,marginBottom:14}}>
          {[{color:"#E8D5B7",name:"크림 니트"},{color:"#1A1A2E",name:"블랙 슬랙스"},{color:"#8B4513",name:"브라운 로퍼"}].map((m,i)=>
            <div key={i} style={{flex:1}}>
              <div style={{height:88,background:m.color,borderRadius:12,marginBottom:5}}/>
              <p style={{fontSize:11,color:C.ter,margin:0,textAlign:"center"}}>{m.name}</p>
            </div>
          )}
        </div>
        <div style={{display:"flex",gap:4}}>
          <Glass style={{borderRadius:8,padding:"4px 10px"}}><span style={{fontSize:11,color:C.sec}}>미니멀</span></Glass>
          <Glass style={{borderRadius:8,padding:"4px 10px"}}><span style={{fontSize:11,color:C.sec}}>가을코디</span></Glass>
        </div>
      </Glass>
      {/* Premium */}
      <div style={{background:C.primary,borderRadius:16,padding:"15px 18px",marginTop:10,display:"flex",alignItems:"center",gap:12}}>
        {I.lock("#fff")}
        <div style={{flex:1}}>
          <p style={{fontSize:13,fontWeight:600,color:"#fff",margin:"0 0 2px"}}>데일리 코디는 프리미엄 기능이에요</p>
          <p style={{fontSize:11,color:"rgba(255,255,255,.5)",margin:0}}>7일 무료 체험 시작하기</p>
        </div>
        {I.right("#fff")}
      </div>
    </div>
    <TabBar active="daily"/>
  </div>;
};

/* ── Crown Icon ── */
const Crown = ({size=22,color="#D4A017"}) => <svg width={size} height={size} viewBox="0 0 24 24" fill={color} stroke={color} strokeWidth="0.5"><path d="M2.5 18.5h19v2h-19zM3 16.5l2.5-8 4.5 4 2-6 2 6 4.5-4 2.5 8z"/></svg>;

/* ── Profile (with Daily integrated) ── */
const ProfileScr = () => {
  const days=["일","월","화","수","목","금","토"], today=4;
  return <div style={{...ph, background: bgSoft, overflowY:"auto"}}>
  <SB/>
  <div style={{padding:"8px 20px 0"}}>
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"flex-start"}}>
      <div>
        <span style={{fontSize:32,fontFamily:lobster,color:C.ink}}>My</span>
        <p style={{fontSize:13,color:C.ter,margin:"4px 0 0"}}>패션 라이프를 기록하세요</p>
      </div>
      <div style={{width:36,height:36,borderRadius:18,background:"rgba(255,255,255,0.6)",...blur(12),display:"flex",alignItems:"center",justifyContent:"center",marginTop:6}}>
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke={C.sec} strokeWidth="1.5" strokeLinecap="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 01-2.83 2.83l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg>
      </div>
    </div>
  </div>
  {/* Plan banner */}
  <div style={{padding:"16px 16px 0"}}>
    <div style={{background:`linear-gradient(135deg, ${C.primary} 0%, ${C.indigo} 100%)`,borderRadius:16,padding:"16px 18px",display:"flex",alignItems:"center",gap:14,cursor:"pointer"}}>
      <div style={{width:42,height:42,borderRadius:21,background:"rgba(255,255,255,0.18)",display:"flex",alignItems:"center",justifyContent:"center",flexShrink:0}}>
        <Crown size={20} color="#fff"/>
      </div>
      <div style={{flex:1}}>
        <p style={{fontSize:15,fontWeight:700,color:"#fff",margin:"0 0 2px"}}>무료 플랜</p>
        <p style={{fontSize:12,color:"rgba(255,255,255,0.6)",margin:0}}>옷장 8/30벌 · 매칭 3/5회</p>
      </div>
      {I.right("rgba(255,255,255,0.5)")}
    </div>
  </div>
  {/* Stats */}
  <div style={{padding:"12px 16px 0"}}>
    <Glass strong style={{borderRadius:16,padding:16}}>
      <div style={{display:"flex"}}>
        {[{n:"8",l:"내 옷"},{n:"7",l:"룩 매칭"},{n:"3",l:"코디 기록"}].map((s,i)=><div key={i} style={{flex:1,textAlign:"center",borderRight:i<2?"1px solid rgba(0,0,0,0.06)":"none"}}>
          <p style={{fontSize:22,fontWeight:700,color:C.ink,margin:"0 0 2px"}}>{s.n}</p>
          <p style={{fontSize:11,color:C.ter,margin:0}}>{s.l}</p>
        </div>)}
      </div>
    </Glass>
  </div>
  {/* Daily Calendar — integrated */}
  <div style={{padding:"12px 16px 0"}}>
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:10,padding:"0 4px"}}>
      <p style={{fontSize:15,fontWeight:600,color:C.ink,margin:0}}>코디 캘린더</p>
      <span style={{fontSize:13,color:C.ter}}>전체보기</span>
    </div>
    <Glass strong style={{borderRadius:16,padding:16}}>
      {/* Week row */}
      <div style={{display:"flex",justifyContent:"space-between",marginBottom:14}}>
        {days.map((d,i)=>{
          const act=i===today, past=i<today;
          return <div key={d} style={{textAlign:"center",width:34}}>
            <p style={{fontSize:10,color:act?C.primary:C.ter,margin:"0 0 5px",fontWeight:500}}>{d}</p>
            <div style={{width:30,height:30,borderRadius:15,margin:"0 auto",display:"flex",alignItems:"center",justifyContent:"center",
              background:act?C.primary:past?"rgba(79,70,229,0.06)":"transparent",
              border:act?"none":past?"none":`1px solid rgba(0,0,0,0.06)`}}>
              <span style={{fontSize:11,fontWeight:act?700:500,color:act?"#fff":past?C.ink:C.mute}}>{22+i}</span>
            </div>
            {past&&<div style={{width:3,height:3,borderRadius:1.5,background:C.primary,margin:"3px auto 0",opacity:.4}}/>}
          </div>;
        })}
      </div>
      {/* Today's outfit */}
      <div style={{borderTop:"0.5px solid rgba(0,0,0,0.05)",paddingTop:14}}>
        <div style={{display:"flex",justifyContent:"space-between",marginBottom:10}}>
          <p style={{fontSize:13,fontWeight:600,color:C.ink,margin:0}}>오늘의 코디</p>
          <p style={{fontSize:11,color:C.ter,margin:0}}>2월 26일</p>
        </div>
        <div style={{display:"flex",gap:6}}>
          {[{color:"#E8D5B7",name:"크림 니트"},{color:"#1A1A2E",name:"블랙 슬랙스"},{color:"#8B4513",name:"브라운 로퍼"}].map((m,i)=>
            <div key={i} style={{flex:1}}>
              <div style={{height:72,background:m.color,borderRadius:10,marginBottom:4}}/>
              <p style={{fontSize:10,color:C.ter,margin:0,textAlign:"center"}}>{m.name}</p>
            </div>
          )}
        </div>
      </div>
    </Glass>
  </div>
  {/* Menu */}
  <div style={{padding:"12px 16px 100px"}}>
    <Glass strong style={{borderRadius:16,overflow:"hidden"}}>
      {["알림 설정","자주 묻는 질문","문의하기","이용약관","개인정보처리방침","앱 버전 1.0.0"].map((l,i,a)=>
        <div key={i} style={{display:"flex",alignItems:"center",justifyContent:"space-between",padding:"14px 18px",borderBottom:i<a.length-1?"0.5px solid rgba(0,0,0,0.05)":"none"}}>
          <span style={{fontSize:14,color:i===a.length-1?C.ter:C.ink}}>{l}</span>
          {i<a.length-1&&I.right()}
        </div>
      )}
    </Glass>
  </div>
  <TabBar active="profile"/>
</div>;
};

/* ── Premium Plan (Bottom Sheet Modal) ── */
const PremiumScr = () => {
  const Chk = () => <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke={C.primary} strokeWidth="2.5" strokeLinecap="round"><path d="M5 13l4 4L19 7"/></svg>;
  return <div style={{...ph, background:"rgba(0,0,0,0.65)", display:"flex", flexDirection:"column", justifyContent:"flex-end"}}>
  <div style={{flex:1}}/>
  <div style={{background:"#fff",borderRadius:"24px 24px 0 0",padding:"24px 20px 40px"}}>
    {/* Header */}
    <div style={{display:"flex",justifyContent:"space-between",alignItems:"center",marginBottom:6}}>
      <div style={{display:"flex",alignItems:"center",gap:8}}>
        <Crown size={24}/>
        <span style={{fontSize:18,fontWeight:700,color:C.ink}}>프리미엄</span>
      </div>
      <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke={C.mute} strokeWidth="2" strokeLinecap="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
    </div>
    <p style={{fontSize:13,color:C.ter,margin:"0 0 18px"}}>모든 기능을 제한 없이 사용하세요</p>
    {/* Features */}
    <div style={{marginBottom:18}}>
      {["무제한 옷장 등록","무제한 룩 재현","상세 갭 분석","데일리 코디 추천"].map((f,i)=><div key={i} style={{display:"flex",alignItems:"center",gap:10,marginBottom:10}}>
        <Chk/>
        <span style={{fontSize:14,color:C.ink}}>{f}</span>
      </div>)}
    </div>
    {/* Plan cards: Monthly vs Annual */}
    <div style={{display:"flex",gap:10,marginBottom:20}}>
      {/* Monthly */}
      <div style={{flex:1,border:"1.5px solid #E5E7EB",borderRadius:14,padding:"16px 12px",textAlign:"center",cursor:"pointer"}}>
        <p style={{fontSize:12,color:C.ter,margin:"0 0 6px",fontWeight:500}}>월간</p>
        <p style={{fontSize:24,fontWeight:800,color:C.ink,margin:"0 0 2px"}}>₩6,900</p>
        <p style={{fontSize:11,color:C.ter,margin:0}}>/월</p>
      </div>
      {/* Annual */}
      <div style={{flex:1,border:`1.5px solid ${C.primary}`,borderRadius:14,padding:"16px 12px",textAlign:"center",cursor:"pointer",position:"relative",background:"rgba(79,70,229,0.03)"}}>
        <div style={{position:"absolute",top:-9,right:10,background:C.primary,borderRadius:8,padding:"2px 10px"}}>
          <span style={{fontSize:10,fontWeight:700,color:"#fff"}}>29% 할인</span>
        </div>
        <p style={{fontSize:12,color:C.primary,margin:"0 0 6px",fontWeight:600}}>연간</p>
        <p style={{fontSize:24,fontWeight:800,color:C.ink,margin:"0 0 2px"}}>₩59,000</p>
        <p style={{fontSize:11,color:C.ter,margin:0}}>₩4,917/월</p>
      </div>
    </div>
    {/* CTA */}
    <div style={{background:`linear-gradient(135deg, ${C.primary} 0%, ${C.indigo} 100%)`,borderRadius:14,padding:"16px",textAlign:"center",cursor:"pointer",boxShadow:"0 6px 20px rgba(79,70,229,0.25)"}}>
      <span style={{fontSize:16,fontWeight:700,color:"#fff"}}>프리미엄 시작하기</span>
    </div>
    <p style={{textAlign:"center",fontSize:11,color:C.mute,margin:"10px 0 0"}}>언제든지 해지 가능</p>
  </div>
</div>;
};

/* ══ Gallery ══ */
export default function App() {
  const screens = [
    { label:"스플래시 A\n(인디고)", comp:<SplashA/> },
    { label:"스플래시 B\n(소프트)", comp:<SplashB/> },
    { label:"온보딩 1", comp:<OnboardScr page={0}/> },
    { label:"온보딩 2", comp:<OnboardScr page={1}/> },
    { label:"온보딩 3", comp:<OnboardScr page={2}/> },
    { label:"로그인", comp:<LoginScr/> },
    { label:"홈", comp:<HomeScr/> },
    { label:"옷장", comp:<WardrobeScr/> },
    { label:"룩 매칭\n(업로드)", comp:<RecUploadScr/> },
    { label:"룩 매칭\n(결과)", comp:<RecResultScr/> },
    { label:"마이", comp:<ProfileScr/> },
    { label:"프리미엄\n플랜", comp:<PremiumScr/> },
  ];

  return <div style={{background:"#E8E6E1",minHeight:"100vh",padding:"40px 20px"}}>
    <div style={{maxWidth:1800,margin:"0 auto"}}>
      <div style={{marginBottom:32,display:"flex",alignItems:"baseline",gap:12}}>
        <span style={{fontSize:36,fontFamily:lobster,color:C.primary}}>Aura</span>
        <span style={{fontSize:16,fontWeight:600,color:C.sec}}>UI Screens · v4.9</span>
        <span style={{fontSize:13,color:C.ter,marginLeft:8}}>전체 {screens.length}개 화면</span>
      </div>
      <div style={{display:"flex",gap:24,overflowX:"auto",paddingBottom:40}}>
        {screens.map((s,i)=><div key={i} style={{display:"flex",flexDirection:"column",alignItems:"center",gap:12,flexShrink:0}}>
          {s.comp}
          <p style={{fontSize:12,fontWeight:600,color:"rgba(0,0,0,0.45)",textAlign:"center",whiteSpace:"pre-line",lineHeight:1.4,margin:0}}>{s.label}</p>
        </div>)}
      </div>
    </div>
  </div>;
}
