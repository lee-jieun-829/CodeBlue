import axiosOriginal from "axios";
import { useCallback, useEffect, useRef, useState } from "react"

/** 
    웹소켓 연결 및 알림 데이터 관리
*/

// 알림 전용 독립적인 API 설정
const notificationApi = axiosOriginal.create({
    //baseURL: 'http://localhost:8060', // 백엔드 주소 고정
    baseURL: 'http://${window.location.hostname}:8060',
    withCredentials: true,            // HttpOnly 쿠키(ACCESS_TOKEN) 자동 전송
    headers: {
        'Content-Type': 'application/json'
    }  
});

export const useNotification = () => {
    const [notifications, setNotifications] = useState([]); // 알림 목록
    const [unreadCount, setUnreadCount] = useState(0); // 안 읽은 개수
    const [lastAlert, setLastAlert] = useState(null); // 최신 알림 저장
    const socketRef = useRef(null); // 소켓 담아둘 박스 생성

    // 알림 목록 불러오기(alarmLoadList 역할)
    const fetchNotifications = useCallback(async () => {
        try{
            const response = await notificationApi.get('/notification/list');
            console.log("로드된 알림 목록:", response.data);
            const data = response.data || [];
            setNotifications(data);
            setUnreadCount(data.length);
        }catch(error){
            console.error("알림 로드 실패 : ", error);
        }
    }, []);

    // 한명에게 알림 전송
    const sendNewNotification = async(empNo, name, content, type, url, urgent) => {
        try{
            await notificationApi.post('/notification/insert', {
                employeeNo: empNo,
                alertName: name || '알림',
                alertContent: content,
                alertType: type,
                alertUrl: url || '#',
                alertUrgent: urgent || 'N'
            });
            console.log("단일 알림 전송 성공");
        }catch(err){
            console.error("단일 알림 전송 실패", err);
        }
    };

    // 여러명에게 알림 전송
    const sendManyNotifications = async (target, name, content, type, url, urgent) => {
        try{

            const data = {
                alertName: name || '알림',
                alertContent: content,
                alertType: type,
                alertUrl: url || '#',
                alertUrgent: urgent || 'N'
            }

            // target의 타입에 따라 적절한 필드에 할당
            if(Array.isArray(target)){
                // 배열 내 요소가 숫자(사번)인지 문자열(부서코드)인지 판별
                if(typeof target[0] === 'number'){
                    data.empNoList = target;    // 각 직원들 단체 알림(사번 리스트)
                }else{
                    data.deptCodeList = target; // 여러 부서 알림(부서 코드 리스트)
                }
            }else{
                data.employeeCode = target;     // 단일 부서 알림(문자열)
            }

            await notificationApi.post('/notification/insertMany', data);
            console.log("다수 알림 전송 성공");
        }catch(err){
            console.error("다수 알림 전송 실패", err);
        }
    };

    // 전체 알림 전송
    const sendAllNotification = async (name, content, type, url, urgent) => {
        try{
            await notificationApi.post('/notification/broadcast', {
                alertName: name || '전체 공지',
                alertContent: content,
                alertType: type,
                alertUrl: url || '#',
                alertUrgent: urgent || 'N'
            });
            console.log("전체 알림 전송 성공");
        }catch(err){
            console.error("전체 알림 전송 실패", err);
        }
    };

    // [테스트용 추가] 콘솔에서 바로 호출할 수 있게 window에 등록
    window.sendNewNotification = sendNewNotification; 
    window.sendManyNotifications = sendManyNotifications;
    window.sendAllNotification = sendAllNotification;

    // 개별 읽기(alarmReadOne 역할)
    const readOne = async (alertNo) => {
        try{
            await notificationApi.post(`/notification/read?alertNo=${alertNo}`);
            fetchNotifications(); // 목록 갱신
        }catch(error){
            console.error("읽기 실패 : ", error);
        }
    };

    // 모두 읽기(alarmReadAll 역할)
    const readAll = async () => {
        try{
            await notificationApi.post('/notification/readAll');
            fetchNotifications(); // 목록 갱신
        }catch(error){
            console.error("전체 읽기 실패 : ", error);
        }
    };

    // 웹소켓 연결(connectNotificationsWs 역할)
    useEffect(() => {
        console.log("알림 웹소켓 시도 시작");

        // 이미 연결되었거나 연결 중이면 중단
        if (socketRef.current && socketRef.current.readyState === WebSocket.OPEN) {
            return;
        }

        // 리액트에서 sts로 접속
        //const wsUri = `ws://localhost:8060/ws/alarm`;
        const wsUri = `ws://${window.location.hostname}:8060/ws/alarm`;
        const socket = new WebSocket(wsUri);
        socketRef.current = socket;

        // 연결 성공 시
        socket.onopen = () => console.log("알림 웹소켓 연결 성공");

        // 서버로부터 알림 받았을 때
        socket.onmessage = (event) => {
            console.log("새 알림 수신 : ", event.data);
            try {
                // 서버에서 온 JSON 데이터 객체로 변환 
                const alertData = JSON.parse(event.data);
                setLastAlert(alertData); // Notification.jsx의 useEffect를 실행시킴
                fetchNotifications();    // 목록 갱신
            } catch (e) {
                // 단순 문자열 "NEW_ALARM" 등이 올 경우 처리
                if(event.data === "NEW_ALARM") fetchNotifications();
            }
        };

        // 연결 종료 시
        socket.onclose = () => {
            console.log("알림 웹소켓 연결 종료");
            socketRef.current = null; // 종료 시 박스 비우기
        }

        // 에러 발생 시
        socket.onerror = (err) => console.log("알림 웹소켓 에러 : ", err);

        fetchNotifications(); // 첫 로드 시 실행

        return () => {
           // 컴포넌트가 재렌더링되거나 언마운트될 때 무조건 기존 소켓을 닫음
            if (socketRef.current && socketRef.current.readyState === WebSocket.OPEN) {
                console.log("이전 세션 정리 중...");
                socketRef.current.close();
                socketRef.current = null;
            } 
        }

    }, [fetchNotifications]);

    return {notifications, unreadCount, fetchNotifications, readOne, readAll, lastAlert, sendNewNotification, sendManyNotifications, sendAllNotification};
};