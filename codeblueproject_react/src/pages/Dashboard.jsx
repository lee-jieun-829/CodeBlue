import React, { useEffect, useState } from 'react';
import api from '../api/axios';
import { useNavigate } from 'react-router-dom';
import ForcePwModal from '../components/common/ForcePwModal';
import '../assets/css/design-tokens.css';
import '../assets/css/common.css';

const Dashboard = () => {
  const navigate = useNavigate();
  const [emName, setEmName] = useState('');
  const [roles, setRoles] = useState([]);
  const [showForceModal, setShowForceModal] = useState(false);

  // 백엔드 서버.. 프로토콜 살리기 프로젝트 시작합니다
  const SPRING_URL = `${window.location.protocol}//${window.location.hostname}:8060`;

  useEffect(() => {
    const initDashboard = async () => {
      try {
        // 내 정보 가져오기
        const res = await api.get('/auth/me');
        
        setEmName(res.data.employeeName);
        setRoles(res.data.roles);

        // pwTempYn === 'Y' 이면 강제로 모달 띄우기
        if (res.data.pwTempYn === 'Y') {
             setShowForceModal(true);
        }

      } catch (err) {
        setServerMsg('서버 응답 없음 🔴');
      }
    };
    initDashboard();
  }, []);

  // 권한 체크 함수
  const hasAnyRole = (...requiredRoles) =>
    requiredRoles.some(role => roles.includes(role));

  // 마이페이지 이동 함수
  const handleMypage=()=>{
    // navigate('/mypage');
    window.location.href = `${SPRING_URL}/employee/mypage`
  }

  // 로그아웃 함수
  const handleLogout = () => {
      // 로그아웃시 쿠키 지우고 화면 이동해야함
      window.location.href = `${SPRING_URL}/logout`
  };

  // 로그아웃 함수
  const handleWaitList = () => {
      navigate('/waiting');
  };

  // 직책별 메뉴
  const actorMenu = [

    // 의사 (외래)
    { 
      icon: "👨‍⚕️",
      label: "의사 (외)",
      path : `${SPRING_URL}/doctor/outpatient`,
      allow: ["ROLE_DOCTOR", "ROLE_ADMIN"]
    },


    // 간호사 (외래)
    { icon: "🩺",
      label: "외래 간호사",
      path : `${SPRING_URL}/nurse/outpatientnurse`,
      allow: ["ROLE_NURSE_OUT", "ROLE_NURSE_IN", "ROLE_ADMIN"]
    },
    
    // 원무과
    { 
      icon: "📝",
      label: "원무과",
      path : `${SPRING_URL}/management/reception`,
      allow: ["ROLE_OFFICE", "ROLE_ADMIN"]
    },

    
    // 방사선사 (영상실)
    { 
      icon: "💻",
      label: "방사선사",
      path : `${SPRING_URL}/radiologist/workview`,
      allow: ["ROLE_RADIOLOGIST", "ROLE_ADMIN"]
    },
    
    // 의사 (입원)
    { 
      icon: "🏥",
      label: "의사 (입)",
      path : `${SPRING_URL}/doctor/inpatient/main`,
      allow: ["ROLE_DOCTOR", "ROLE_ADMIN"],
      //viewAllow : ["ROLE_DOCTOR", "ROLE_ADMIN"]
    },
    
    // 간호사 (입원)
    { 
      icon: "🛏️",
      label: "입원 간호사",
      path : `${SPRING_URL}/nurse/inpatientnurse`,
      allow: ["ROLE_NURSE_IN", "ROLE_NURSE_OUT", "ROLE_ADMIN"],
      //viewAllow : ["ROLE_NURSE_IN", "ROLE_NURSE_OUT", "ROLE_ADMIN"]
    },
    
    // 약사
    {
      icon: "💊",
      label: "약사",
      path : `${SPRING_URL}/pharmacist/workview`,
      allow: ["ROLE_PHARMACIST", "ROLE_ADMIN"]
    },

    // 물리치료실
    { 
      icon: "🩹",
      label: "물리치료사",
      path : `${SPRING_URL}/therapist/workview`,
      allow: ["ROLE_THERAPIST", "ROLE_ADMIN"]
    }

  ];
  
  // 기능별 메뉴
  const functionMenu = [

    // 관리자 - 계정 관리
    {
      icon: "🎛️",
      label: "계정 관리",
      type: "react",
      path : "/admin/employees",
      allow: ["ROLE_ADMIN"],
      hideRestricted: true
    },

    // 나의 오더 관리
    {
      icon: "⌨️",
      label: "나의 오더 관리",
      path : `${SPRING_URL}/macro/shared`,
      allow: [
        "ROLE_DOCTOR",
        "ROLE_NURSE_IN",
        "ROLE_ADMIN"
      ],
      adminType: "react",
      adminPath : "/admin/macro",
      hideRestricted: true
    },

    // 공지사항
    {
      icon: "🔊",
      label: "공지사항",
      path : `${SPRING_URL}/notice/main`,
      adminPath : `${SPRING_URL}/admin/notice/list`,
      allow: [
        "ROLE_DOCTOR",
        "ROLE_NURSE_OUT",
        "ROLE_NURSE_IN",
        "ROLE_RADIOLOGIST",
        "ROLE_OFFICE",
        "ROLE_PHARMACIST",
        "ROLE_THERAPIST",
        "ROLE_ADMIN"
      ]
    },

    // 일정
    {
      icon: "📅",
      label: "일정",
      path : `${SPRING_URL}/schedule/main`,
      adminType: "react",
      adminPath : "/calendar",
      allow: [
        "ROLE_DOCTOR",
        "ROLE_NURSE_OUT",
        "ROLE_NURSE_IN",
        "ROLE_RADIOLOGIST",
        "ROLE_OFFICE",
        "ROLE_PHARMACIST",
        "ROLE_THERAPIST",
        "ROLE_ADMIN"
      ]
    },
    
    // 물품 관리
    { 
      icon: "🛍️",
      label: "물품 관리",
      path : `${SPRING_URL}/order/drug`,
      adminType: "react",
      adminPath : "/admin/orders",
      allow: [
        "ROLE_DOCTOR",
        "ROLE_NURSE_OUT",
        "ROLE_NURSE_IN",
        "ROLE_RADIOLOGIST",
        "ROLE_OFFICE",
        "ROLE_PHARMACIST",
        "ROLE_THERAPIST",
        "ROLE_ADMIN"
      ]
    },
        
    // 관리자 - 통계
    {
      icon: "📊",
      label: "통계",
      type: "react",
      path : "/admin/stats",
      allow: ["ROLE_ADMIN"],
      hideRestricted: true
    },

    // 서류
    {
      icon: "🗃️",
      label: "서류 관리",
      path : `${SPRING_URL}/certificate/main`,
      allow: [
        "ROLE_DOCTOR",
        "ROLE_NURSE_OUT",
        "ROLE_NURSE_IN",
        "ROLE_RADIOLOGIST",
        "ROLE_OFFICE",
        "ROLE_PHARMACIST",
        "ROLE_THERAPIST",
        "ROLE_ADMIN"
      ]
    },

    // 의사 - 협진
    {
      icon: "🤝",
      label: "협진",
      path : `${SPRING_URL}/consultation/main`,
      allow: [
        "ROLE_DOCTOR",
        "ROLE_ADMIN"
      ],
      hideRestricted: true
    },
    
/*     // 관리자 - 시스템 관리(상병, 약품 추가 등)
    {
      icon: "🛠️",
      label: "시스템 관리",
      //type: "react",
      path : `${SPRING_URL}/`,
      allow: ["ROLE_ADMIN"],
      hideRestricted: true
    } */
    
  ];

  // 메뉴 그리드에 대한 함수
  const renderMenuGrid = (items, gridClass, cardSize) => (
    <div className={`grid ${gridClass} gap-4 w-[100%] justify-items-center`}>
      {items.map((item, index) => {
        const active = hasAnyRole(...item.allow);
        const isAdmin = roles.includes("ROLE_ADMIN");

        // allow에 담당 권한 없으면 숨기기
        if (item.hideRestricted && !active) return null;

        return (
          <div key={index}
            className={`app-card ${cardSize} aspect-square flex flex-col justify-center items-center rounded-2xl border border-slate-100 shadow-sm
              ${active ? 'cursor-pointer hover:bg-slate-50 transition-all' : 'opacity-30 cursor-not-allowed grayscale bg-slate-50'}`}
            onClick={() => {if (!active) { alert("접근 권한 없음!"); return; }
              
              let targetPath = item.path;
              let targetType = item.type;

              // 관리자는 관리자용 url로 이동시킴~
              if (isAdmin && item.adminPath) {
                  targetPath = item.adminPath;
                  targetType = item.adminType; 
              }

              // 경로가 비어있거나 준비중인 경우
              if (!targetPath || targetPath === `${SPRING_URL}/`) { 
                  alert("🚧 준 비 중 🚧 \n ~ 아직 연결되지 않은 페이지 입니당~ "); 
                  return; 
              }

              // 타입에따라 react 아님 jsp 보냄
              if (targetType === 'react') {
                  navigate(targetPath);
              } else {
                  window.location.href = targetPath;
              }
            }}
          >
            <div className="app-icon-box">{item.icon}</div>
            <div className="app-label-wrapper">
              <p className="app-label">{item.label}</p>
            </div>
          </div>
        );
      })}
    </div>
  );

  return (
    <div className="flex flex-col h-screen bg-white font-pretendard">
      {/* 임시 비밀번호 모달 */}
      {showForceModal && <ForcePwModal springUrl={SPRING_URL} />}

      {/* 헤더 */}
      <header className="border-0" >
        <div className="header-inner justify-start gap-3 pl-6">
          <h1 className="header-title">
            <span className="header-title-highlight">SB</span> 정형외과
          </h1>
        </div>
      </header>

      {/* 메인 */}
      <main className="main-container flex-1 flex items-start justify-center overflow-y-auto pb-10">
        {/* 전체 컨테이너 */}
        <div className="flex items-center gap-20 max-w-screen-2xl w-full px-16 h-full">

          {/* 왼쪽 : 이미지 및 프로필 */}
          <div className="w-[75%] flex flex-col justify-center gap-10">
            <div className="main-visual-container w-full rounded-xl overflow-hidden shadow-lg">
              <img src="/src/assets/mainDashBoard.png" alt="mainDashBoard" className="w-full h-full object-cover"/>
            </div>

            <div className="flex gap-8 px-6">
              <div className="flex items-center gap-3 bg-slate-50 self-start px-5 py-2.5 rounded-full border border-slate-100 shadow-sm">
                <div className="w-10 h-10 rounded-full bg-slate-200 flex items-center justify-center text-xl">🧑‍⚕️</div>
                <div className="flex items-center gap-2">
                  <span className="font-bold text-slate-800 text-lg">{emName}님</span>
                </div>
              </div>
              <div className="flex gap-6 items-center pl-2">
                <div className="relative">
                  <button className="util-btn" onClick={handleMypage}>
                    <span className="text-lg font-black tracking-tighter text-slate-900">MY</span>
                  </button>
                </div>
                <button className="util-btn" onClick={handleLogout}>
                  <img src="https://img.icons8.com/?size=100&id=vGj0AluRnTSa&format=png&color=000000" alt="Settings" width="29" />
                </button>
                <button className="util-btn" onClick={handleWaitList}>
                  <div className="text-xl w-full h-full rounded-full bg-slate-100 flex items-center justify-center">📢</div>
                </button>
              </div>
            </div>
          </div>

          {/* 오른쪽 : 메뉴 섹션 */}
          <div className="flex flex-col h-full w-full max-w-[1000px] ">
          
            <div className="flex-1 flex flex-col justify-start pb-4 pl-2">
              <h3 className="text-sm font-bold text-slate-600 mb-4 px-2">부서별</h3>
              {renderMenuGrid(actorMenu, "grid-cols-4 !gap-3 !w-fit pl-10", "!w-[160px] !h-[150px]")}
            </div>

            <hr className="border-t border-slate-200 w-[90%] mx-auto" />

            <div className="flex-1 flex flex-col justify-start pt-8 pl-2">
              <h3 className="text-sm font-bold text-slate-600 mb-4 px-2">기능별</h3>
                {renderMenuGrid(functionMenu, "grid-cols-4 !gap-3 !w-fit pl-10", "!w-[160px] !h-[150px]")}
            </div>

          </div>

        </div>
      </main>
    </div>
  );
};

export default Dashboard;