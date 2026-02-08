import React from 'react';
import { Link, useLocation } from 'react-router-dom';

import IconUser from '../../assets/icon/users.svg';
import IconFolder from '../../assets/icon/folder.svg';
import IconMegaphone from '../../assets/icon/megaphone.svg';
import IconBox from '../../assets/icon/box.svg';
import IconGraph from '../../assets/icon/chart-graph.svg';
import IconCalendar from '../../assets/icon/calendar.svg';
import IconChat from '../../assets/icon/chat-messages.svg';

function LeftAdmin() {
  const location = useLocation(); // 현재 URL 경로를 가져오기 위함 (선택사항)

  // 백엔드 서버.. 프로토콜 살리기 프로젝트 시작합니다
  const SPRING_URL = `${window.location.protocol}//${window.location.hostname}:8060`;

  // 상단 메뉴 그룹 데이터
  const mainMenus = [    
    { id: 'gnb-outpatient', label: '계정관리', icon: IconUser, to: '/admin/employees', type: 'react' },
    { id: 'gnb-myorder', label: '나의 오더', icon: IconFolder, to: '/admin/macro', type: 'react' },
    { id: 'gnb-nurse', label: '통계', icon: IconGraph, to: '/admin/stats', type: 'react' },    
    { id: 'gnb-order', label: '물품 발주', icon: IconBox, to: '/admin/orders', type: 'react' },
    
  ];

  // 하단 메뉴 그룹 데이터
  const bottomMenus = [
    { id: 'gnb-notice', label: '공지사항', icon: IconMegaphone, to: '/admin/notice/list', type: 'spring' },
    { id: 'gnb-calendar', label: '일정', icon: IconCalendar, to: '/calendar', type: 'react'},
    { id: 'gnb-messenger', label: '메신저', icon: IconChat, to: '#', type: 'react' },
  ];

  // 공통 메뉴 렌더링 함수
  const renderMenuItem = (menu) => {
    // 현재 경로 확인 (선택 사항)
    const isActive = menu.type === 'react' ? location.pathname === menu.to : false;
    
    // 1. 리액트 내부 이동 (기존 코드 스타일 100% 유지)
    if (menu.type === 'react') {
      return (
      <li key={menu.id}>
        <Link
          to={menu.to}
          id={menu.id}
          className={`
            flex flex-col items-center justify-center py-3 px-1 rounded-lg transition-colors duration-200
            ${isActive ? 'bg-blue-50 text-blue-600' : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900'}
          `}
        >
          {/* 기존 CSS 클래스(icon 등)가 글로벌로 있다면 그대로 적용됩니다 */}
          <img 
            src={menu.icon} 
            alt={menu.label} 
            className={`w-6 h-6 mb-1 ${isActive ? '' : 'opacity-70'}`} 
            style={{ filter: isActive ? 'invert(31%) sepia(94%) saturate(2251%) hue-rotate(211deg) brightness(95%) contrast(92%)' : 'none' }}
          />
          <span className="text-xs font-medium">{menu.label}</span>
        </Link>
      </li>
    );
  };

  // 2. 스프링 외부 이동 (CSS 클래스는 위랑 똑같이 복사함 + 태그만 a로 변경)
    return (
      <li key={menu.id}>
        <a
          href={`${SPRING_URL}${menu.to}`} 
          id={menu.id}
          className={`
            flex flex-col items-center justify-center py-3 px-1 rounded-lg transition-colors duration-200
            text-gray-600 hover:bg-gray-50 hover:text-gray-900
          `}
        >
          {/* 이미지는 활성화될 일이 없으니 기본 스타일만 적용 */}
          <img 
            src={menu.icon} 
            alt={menu.label} 
            className="w-6 h-6 mb-1 opacity-70" 
            style={{ filter: 'none' }}
          />
          <span className="text-xs font-medium">{menu.label}</span>
        </a>
      </li>
    );
  };

  return (
    <aside className="flex w-28 shrink-0 flex-col border-r border-neutral-200 bg-white h-full">
      
      {/* 로고 영역이 필요하다면 여기에 추가 */}

      {/* 스크롤 영역 */}
      <nav className="side-nav flex-1 flex flex-col overflow-y-auto px-2 py-4">
        
        {/* 첫 번째 그룹 */}
        <ul className="flex flex-col gap-1 mb-6">
          {mainMenus.map(menu => renderMenuItem(menu))}
        </ul>
        <div className="flex-grow"></div>
        {/* 구분선 (필요 시) */}
        <div className="border-t border-gray-100 my-2 mx-2"></div>

        {/* 두 번째 그룹 */}
        <ul className="flex flex-col gap-1 mt-2">
          {bottomMenus.map(menu => renderMenuItem(menu))}
        </ul>
        
      </nav>
    </aside>
  );
}

export default LeftAdmin;