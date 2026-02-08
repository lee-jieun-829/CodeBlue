import React from 'react';

/* 헤더 종 아이콘  */
const NotificationBell = ({count, onClick}) => {
    return(
        <button 
            className="header-icon-btn relative p-2 rounded-full hover:bg-gray-100" 
            onClick={onClick}
            aria-label="알림"
            >
            {/* 나중에는 이걸로 써야함 */}    
            {/* <i className="icon icon-bell icon-lg text-gray-600"></i> */}

            {/* SVG 종 아이콘(테스트) */}
            <svg 
                width="24" 
                height="24" 
                viewBox="0 0 24 24" 
                fill="none" 
                stroke="currentColor" 
                strokeWidth="1.5" 
                strokeLinecap="round" 
                strokeLinejoin="round"
                className="text-slate-600"
            >
                <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>
                <path d="M13.73 21a2 2 0 0 1-3.46 0"></path>
            </svg>
            
            {/* 알림 숫자가 0보다 클 때만 Dot 표시 */}
            {count > 0 && (
                <span className="absolute top-0 right-0 block h-3 w-3 rounded-full bg-red-500 text-white text-[10px] flex items-center justify-center border-2 border-white">
               {/*  {count > 99 ? '99+' : count} */} {/* 빨간 점에 숫자 보이게 */}
                </span>
            )}
        </button>
    );
};

export default NotificationBell;