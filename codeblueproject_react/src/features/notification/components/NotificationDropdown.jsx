import React from 'react';
import NotificationItem from "./NotificationItem";

/* 알림 리스트 감싸는 목록창 */
const NotificationDropdown = ({notifications, onReadAll, onReadOne}) => {
    return (
        <div className="dropdown-menu w-[480px] shadow-lg border rounded-md bg-white" style={{ position: 'absolute', right: 0, top: '100%', zIndex: 1000, display: 'block', marginTop: '10px'}}>
            <div className="dropdown-header flex justify-between items-center p-3 border-bottom">
                <span className="font-bold text-lg">알림</span>
                <div className="flex items-center gap-2">
                <span className="badge badge-primary bg-blue-500 text-white px-2 py-1 rounded-full text-xs">
                    {notifications.length}
                </span>
                <button type="button" className="text-sm text-blue-600 font-semibold" onClick={onReadAll}>
                    모두 확인
                </button>
                </div>
            </div>

            <div className="max-h-[400px] overflow-y-auto">
                {notifications.length === 0 ? (
                <div className="p-5 text-center text-gray-500">새로운 알림이 없습니다.</div>
                ) : (
                notifications.map(alarm => (
                    <NotificationItem 
                    key={alarm.alertNo} 
                    alarm={alarm} 
                    onReadOne={onReadOne} 
                    />
                ))
                )}
            </div>

            {/* <div className="dropdown-footer p-2 text-center border-top">
                <button className="text-blue-500 text-sm hover:underline">모든 알림 보기</button>
            </div> */}
        </div>
    );
};

export default NotificationDropdown;