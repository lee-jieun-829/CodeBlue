import React, { useEffect, useState } from 'react'
import { useNotification } from './hooks/useNotification'
import NotificationBell from './components/NotificationBell';
import NotificationDropdown from './components/NotificationDropdown';
import Swal from 'sweetalert2';

const Notification = () => {

    // 훅에서 데이터(알림 목록, 개수, 읽기 함수들) 가져옴
    const {notifications, unreadCount, readOne, readAll, lastAlert} = useNotification(); 
    const [isOpen, setIsOpen] = useState(false); // 드롭다운 열림 상태

    // 새로운 알림 오면 알림창 띄워짐
    useEffect(() => {
        // 가장 최근 알림이 존재할 때 실행
        if(lastAlert){
            // 제목 설정
            const alertTitle = lastAlert.alertName || '새로운 알림';
            // 긴급 여부에 따른 팝업 스타일 
            const isUrgent = lastAlert.alertUrgent === 'Y';		 

            Swal.fire({
                toast: true,
                position: 'top-end',
                showConfirmButton: false,
                timer: 3000,
                timerProgressBar: true,
                showCloseButton: true, // 닫기 버튼

                icon: isUrgent ? 'error' : 'info',
                title: (isUrgent ? '🚨 [긴급] ' : '') + alertTitle,
                text: lastAlert.alertContent,
                background: '#ffffff',
                color: '#1e293b',
                iconColor: isUrgent ? '#ef4444' : '#3b82f6',
                
                customClass: {
                    popup: 'shadow-lg border-0'
                },
                showClass: {
                    popup: 'animate__animated animate__fadeInRight'
                },
                didOpen: (toast) => {
                    toast.addEventListener('mouseenter', Swal.stopTimer);
                    toast.addEventListener('mouseleave', Swal.resumeTimer);
                }
            });
        }
    }, [lastAlert]); // 알림 개수가 변할 때만 감지


    return (
        <div style={{position: 'relative', display: 'inline-block'}}>
            {/* 종 아이콘 클릭 시 열림/닫힘 토글 */}
            <NotificationBell count={unreadCount} onClick={() => setIsOpen(!isOpen)}/>
            
            {/* 알림 목록 창(열림 상태일 때만 표시) */}
            {isOpen && (
                <NotificationDropdown notifications={notifications} 
                onReadOne={readOne} onReadAll={readAll}/>
            )}
        </div>
    );
 
};

export default Notification;