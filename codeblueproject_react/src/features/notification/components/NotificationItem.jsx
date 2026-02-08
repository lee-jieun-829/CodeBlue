import React from 'react';

/* 알림 개별 항목 */
const NotificationItem = ({alarm, onReadOne}) => {
    // 아이콘 및 구분코드 매핑
    const getIcon = (type, isUrgent) => {
        const iconProps = {
            width: "20",
            height: "20",
            viewBox: "0 0 24 24",
            fill: "none",
            stroke: "currentColor",
            strokeWidth: "2",
            strokeLinecap: "round",
            strokeLinejoin: "round",
            className: isUrgent ? "text-red-500" : "text-slate-500"
        }

         // 긴급일 때 확성기
        if (isUrgent){
            return (
                <svg {...iconProps}>
                    <path d="m3 11 18-5v12L3 14v-3z" />
                    <path d="M11.6 16.8a3 3 0 1 1-5.8-1.6" />
                </svg>
            );
        }

        switch (type) {
            case '001': // 접수 (클립보드)
                return (
                    <svg {...iconProps}>
                        <rect x="8" y="2" width="8" height="4" rx="1" ry="1" />
                        <path d="M16 4h2a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2h2" />
                    </svg>
            );
            case '002': // 치료 (청진기/의사)
                return (
                    <svg {...iconProps}>
                        <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2" />
                        <circle cx="12" cy="7" r="4" />
                    </svg>
            );
            case '003': // 검사 (가방)
                return (
                    <svg {...iconProps}>
                        <rect x="3" y="7" width="18" height="13" rx="2" />
                        <path d="M16 7V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v2" />
                    </svg>
            );
            case '004': // 약/주사 (알약)
                return (
                    <svg {...iconProps}>
                        <path d="m10.5 20.5 10-10a4.95 4.95 0 1 0-7-7l-10 10a4.95 4.95 0 1 0 7 7Z" />
                        <path d="m8.5 8.5 7 7" />
                    </svg>
            );
            case '005': // 협진 (사용자들)
                return (
                    <svg {...iconProps}>
                        <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
                        <circle cx="9" cy="7" r="4" />
                        <path d="M22 21v-2a4 4 0 0 0-3-3.87" />
                        <path d="M16 3.13a4 4 0 0 1 0 7.75" />
                    </svg>
            );
            case '006': // 물품 (박스)
                return (
                    <svg {...iconProps}>
                        <path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z" />
                        <path d="m3.3 7 8.7 5 8.7-5" />
                        <path d="M12 22V12" />
                    </svg>
            );
            default: // 기본 (종)
                return (
                    <svg {...iconProps}>
                        <path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9" />
                        <path d="M10.3 21a1.94 1.94 0 0 0 3.4 0" />
                    </svg>
            );
        }
    
    };

    const isUrgent = alarm.alertUrgent === 'Y';
    const isUnread = alarm.alertReadYn === 'N'; 

    return (
        <div 
            className={`flex items-start gap-4 p-4 border-b border-gray-100 hover:bg-gray-50 transition-colors cursor-pointer ${isUnread ? 'bg-blue-50/40' : 'bg-white'}`}
            onClick={() => {
                if(alarm.alertUrl && alarm.alertUrl !== '#') window.location.href = alarm.alertUrl;
            }}
        >
            {/* 아이콘 영역 (동그라미 배경) */}
            <div className={`flex-shrink-0 w-10 h-10 rounded-full flex items-center justify-center ${isUrgent ? 'bg-red-50' : 'bg-slate-100'}`}>
                {getIcon(alarm.alertType, isUrgent)}
            </div>

            {/* 내용 영역 */}
            <div className="flex-1 min-w-0 text-left">
                <div className={`text-[14px] font-bold truncate ${isUrgent ? 'text-red-600' : 'text-slate-800'}`}>
                    {isUrgent ? '🚨 [긴급] ' : ''}{alarm.alertName}
                </div>
                <div className={`text-[13px] mt-1 line-clamp-2 ${isUrgent ? 'text-red-500' : 'text-slate-600'}`}>
                    {alarm.alertContent}
                </div>
                <div className="text-[11px] text-gray-400 mt-2 italic">
                    {alarm.alertDate}
                </div>
            </div>

            {/* 확인 버튼 */}
            <button 
                type="button" 
                className="flex-shrink-0 px-3 py-1.5 text-[12px] font-semibold text-slate-500 bg-white border border-slate-200 rounded-md hover:bg-slate-100 hover:text-slate-800 transition-all self-center"
                onClick={(e) => { 
                    e.stopPropagation(); 
                    onReadOne(alarm.alertNo); 
                }}
            >
                확인
            </button>
        </div>
    );
};

export default NotificationItem;