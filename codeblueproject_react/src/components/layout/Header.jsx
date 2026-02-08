import React, { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import Notification from '../../features/notification/Notification';


import api from '../../api/axios'; 

const Header = () => {
  const navigate = useNavigate();

  // 백엔드 서버.. 프로토콜 살리기 프로젝트 시작합니다
  const SPRING_URL = `${window.location.protocol}//${window.location.hostname}:8060`;
  
  // 드롭다운 상태 관리
  const [isProfileOpen, setIsProfileOpen] = useState(false);
  
  // 외부 클릭 감지를 위한 Ref
  const profileRef = useRef(null);

  // [수정] 사용자 이름 상태 (기본값 설정)
  const [userName, setUserName] = useState(""); 

  // [수정] 컴포넌트 마운트 시 서버에서 내 정보 가져오기 (Dashboard와 동일 방식)
  useEffect(() => {
    const fetchUserInfo = async () => {
      try {
        // 서버에 내 정보 요청 (/auth/me)
        const res = await api.get('/auth/me');
        
        // 받아온 데이터에서 이름(employeeName) 세팅
        if (res.data && res.data.employeeName) {
          setUserName(res.data.employeeName);
        }
      } catch (err) {
        console.error("Header 사용자 정보 로딩 실패:", err);
        // 에러 발생 시(로그인이 풀렸거나 등), 필요하면 로그인 페이지로 보내거나 "사용자" 유지
      }
    };

    fetchUserInfo();
  }, []);

  // 외부 클릭 시 드롭다운 닫기
  useEffect(() => {
    const handleClickOutside = (event) => {
      if (profileRef.current && !profileRef.current.contains(event.target)) {
        setIsProfileOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleLogout = () => {
    // 로그아웃 처리 (서버 로그아웃 API 호출 후 이동하는 것이 정석이나, 일단 href 이동 유지)
    window.location.href = `${SPRING_URL}/logout`
  };

  return (
    <div className="flex items-center justify-between w-full h-full px-6 bg-white border-b border-slate-200 z-50 relative">
      
      {/* 좌측: 로고/타이틀 */}
      <div 
        className="flex items-center cursor-pointer" 
        onClick={() => navigate('/')} 
      >
        <h1 className="header-title">
          <span className="header-title-highlight">SB</span> 정형외과
        </h1>
      </div>

      {/* 우측: 액션 버튼들 */}
      <div className="flex items-center gap-3">
        
        {/* 🏠 홈 버튼 */}
        <button 
          className="p-2 text-slate-500 rounded-full hover:bg-slate-100 transition-colors"
          aria-label="홈"
          onClick={() => navigate('/')}
        >
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
            <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
            <polyline points="9 22 9 12 15 12 15 22"></polyline>
          </svg>
        </button>

        {/* 🔔 알림 */}
        <Notification/>

        {/* 구분선 */}
        <div className="w-px h-8 bg-slate-200 mx-1"></div>

        {/* 👤 프로필 영역 (드롭다운 포함) */}
        <div className="relative" ref={profileRef}>
          <div 
            className="flex items-center gap-3 cursor-pointer p-1 rounded-lg hover:bg-slate-50 transition-all"
            onClick={() => setIsProfileOpen(!isProfileOpen)}
          >
            {/* 사용자 정보 텍스트 */}
            <div className="hidden md:flex flex-col items-end text-sm leading-tight">
              <span className="text-slate-900">
                {/* API로 받아온 이름이 여기에 표시됩니다 */}
                <b>{userName}</b> 님
              </span>
              <span className="text-slate-500 text-xs">반갑습니다!</span>
            </div>

            {/* 프로필 이미지 */}
            <img 
              src="https://placehold.co/36x36" 
              alt="프로필" 
              className="w-9 h-9 rounded-full border border-slate-200 object-cover shadow-sm" 
            />
          </div>

          {/* ▼ 드롭다운 메뉴 */}
          {isProfileOpen && (
            <div className="absolute right-0 mt-2 w-48 bg-white rounded-xl shadow-xl border border-slate-100 py-2 animate-in fade-in zoom-in duration-200 z-50">
              <div className="px-4 py-2 text-xs font-bold text-slate-400 uppercase tracking-wider">
                계정
              </div>
              
              {/* 마이페이지 링크 */}
              <a 
                href="http://localhost:8060/employee/mypage" 
                className="flex items-center gap-2 px-4 py-2.5 text-sm text-slate-700 hover:bg-blue-50 hover:text-blue-600 transition-colors"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
                  <circle cx="12" cy="7" r="4"></circle>
                </svg>
                마이페이지
              </a>

              <div className="h-px bg-slate-100 my-1"></div>

              {/* 로그아웃 버튼 */}
              <button 
                onClick={handleLogout}
                className="w-full flex items-center gap-2 px-4 py-2.5 text-sm text-red-600 hover:bg-red-50 transition-colors text-left"
              >
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                  <polyline points="16 17 21 12 16 7"></polyline>
                  <line x1="21" y1="12" x2="9" y2="12"></line>
                </svg>
                로그아웃
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};


export default Header;