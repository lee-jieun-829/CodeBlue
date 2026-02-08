import React, { useState, useEffect, useMemo, useRef } from 'react';
import axios from 'axios';
import { Client } from '@stomp/stompjs';
import SockJS from 'sockjs-client';

const WaitingList = () => {
    const [patients, setPatients] = useState([]);
    const [currentTime, setCurrentTime] = useState(new Date());
    const [currentPage, setCurrentPage] = useState(0);
    const [callModal, setCallModal] = useState({ show: false, name: '', room: '', doctor: '' });
    
    const calledPatients = useRef(new Set());
    const isInitialLoad = useRef(true);

    const CLINICS_PER_PAGE = 3; 
    const PAGE_DURATION = 8000; 
    const ROWS_PER_CLINIC = 8; 

    const groupedByDoctor = useMemo(() => {
        const rooms = {};
        patients.forEach(p => {
            const doctorKey = p.doctor || '미배정';
            if (!rooms[doctorKey]) rooms[doctorKey] = [];
            rooms[doctorKey].push(p);
        });
        return Object.entries(rooms).map(([doctorName, list], index) => ({
            roomTitle: doctorName === '미배정' ? '대기실' : `제 ${index + 1} 진료실`,
            doctorName: doctorName,
            patientList: list.slice(0, ROWS_PER_CLINIC)
        }));
    }, [patients]);

    const currentClinics = useMemo(() => {
        const startIndex = currentPage * CLINICS_PER_PAGE;
        return groupedByDoctor.slice(startIndex, startIndex + CLINICS_PER_PAGE);
    }, [groupedByDoctor, currentPage]);

    // 상태 및 음성 안내 함수
    const getStatusInfo = (code) => {
        const statusMap = {
            '001': { label: '대기', color: 'bg-slate-100 text-slate-400' },
            '002': { label: '진료대기', color: 'bg-slate-100 text-slate-400' },
            '003': { label: '진료중', color: 'bg-green-100 text-green-700' },
            '004': { label: '수납대기', color: 'bg-blue-100 text-blue-700' },
            '005': { label: '수납완료', color: 'bg-gray-200 text-gray-500' }
        };
        return statusMap[code] || { label: '대기', color: 'bg-slate-100 text-slate-400' };
    };

    const announcePatient = (patientName, doctorName) => {
        const roomName = groupedByDoctor.find(r => r.doctorName === doctorName)?.roomTitle || '진료실';
        setCallModal({ show: true, name: patientName, room: roomName, doctor: doctorName });
        
        if (window.speechSynthesis) {
            const text = `띵! ${patientName} 님, ${roomName} ${doctorName || '박의사'} 원장님 진료실로 들어오세요.`;
            const utterance = new SpeechSynthesisUtterance(text);
            utterance.lang = 'ko-KR';
            utterance.rate = 1;
            utterance.pitch = 1.2;
            window.speechSynthesis.speak(utterance);
        }
        setTimeout(() => setCallModal({ show: false, name: '', room: '', doctor: '' }), 5000);
    };

    const patientWaitingList = async () => {
        try {
            const response = await axios.get('/api/waiting/realTime');
            const data = Array.isArray(response.data) ? response.data : [];
            const mappedData = data.map(p => ({ 
                id: p.patientNo,
                name: p.patientName,
                doctor: p.employeeName,
                isReserved: p.registrationVO?.reservationYn === 'Y',
                statusCode: p.registrationVO?.registrationStatus
            }));

            mappedData.forEach(p => {
                if (p.statusCode === '003' && !isInitialLoad.current && !calledPatients.current.has(p.id)) {
                    announcePatient(p.name, p.doctor);
                    calledPatients.current.add(p.id);
                }
            });
            setPatients(mappedData);
            if (isInitialLoad.current) isInitialLoad.current = false;
        } catch (error) { console.error("데이터 로드 실패:", error); }
    };

    useEffect(() => {
        const clockTimer = setInterval(() => setCurrentTime(new Date()), 1000);
        return () => clearInterval(clockTimer);
    }, []);

    useEffect(() => {
        patientWaitingList();
        const socket = new SockJS('http://192.168.143.48:8060/ws/chat');
        const stompClient = new Client({
            webSocketFactory: () => socket,
            reconnectDelay: 5000,
            onConnect: () => {
                console.log('✅ STOMP 연결 성공');
                stompClient.subscribe('/topic/waitingList', (message) => {
                    if (message.body === "REFRESH") patientWaitingList(); 
                });
            },
        });
        stompClient.activate();
        return () => stompClient.deactivate();
    }, []); 

    useEffect(() => {
        const totalPages = Math.ceil(groupedByDoctor.length / CLINICS_PER_PAGE);
        if (totalPages <= 1) {
            setCurrentPage(0);
            return;
        }
        const rotationTimer = setInterval(() => {
            setCurrentPage((prev) => (prev + 1) % totalPages);
        }, PAGE_DURATION);
        return () => clearInterval(rotationTimer);
    }, [groupedByDoctor.length]); // 진료실 개수 기준으로 타이머 설정

    return (
        <div className="min-h-screen pt-28 p-8 bg-slate-50 flex flex-col overflow-hidden relative">
            {/* 호출 알림 모달 */}
            {callModal.show && (
                <div className="fixed inset-0 z-[100] flex items-center justify-center bg-black/60 backdrop-blur-sm animate-in fade-in duration-300">
                    <div className="bg-white rounded-[4rem] shadow-[0_0_100px_rgba(37,99,235,0.4)] p-16 text-center border-[12px] border-blue-600 animate-in zoom-in duration-300 max-w-4xl w-full">
                        <div className="bg-blue-100 text-blue-600 px-8 py-3 rounded-full inline-block text-2xl font-black mb-8 tracking-widest uppercase">
                            {callModal.doctor} 원장님
                        </div>
                        <h2 className="text-[6rem] font-black text-slate-900 leading-none mb-6">
                            {callModal.name} <span className="text-4xl text-slate-400">님</span>
                        </h2>
                        <div className="h-2 w-32 bg-slate-100 mx-auto mb-8 rounded-full"></div>
                        <p className="text-5xl font-bold text-blue-600 tracking-tight">
                            {callModal.room}로 들어오세요
                        </p>
                    </div>
                </div>
            )}

            <header className="flex items-center justify-between p-12 mb-8 bg-white shadow-lg rounded-3xl border-l-[12px] border-blue-600 shrink-0">
                <div>
                    <h1 className="text-3xl font-black text-slate-800 flex items-center gap-4">
                        SB 정형외과 <span className="text-blue-600">실시간 대기 현황</span>
                        <button 
                            onClick={() => {
                                const testP = patients.find(p => p.statusCode === '003') || patients[0];
                                if (testP) announcePatient(testP.name, testP.doctor);
                                else alert("환자 데이터가 없습니다.");
                            }}
                            className="bg-orange-500 text-white text-[10px] px-4 py-1.5 rounded-full hover:bg-orange-600 shadow-md transition-all active:scale-90 font-bold"
                        >
                            🔊 호출 테스트
                        </button>
                    </h1>
                </div>
                <div className="text-right">
                    <div className="text-lg text-slate-500 font-semibold uppercase">
                        {currentTime.toLocaleDateString('ko-KR', { year: 'numeric', month: 'long', day: 'numeric', weekday: 'short' })}
                    </div>
                    <div className="text-5xl font-black text-blue-600 tracking-tighter tabular-nums">
                        {currentTime.toLocaleTimeString('ko-KR', { hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: false })}
                    </div>
                </div>
            </header>

            <div className="grid grid-cols-3 gap-8 flex-1 mb-8 overflow-hidden">
                {currentClinics.map((room) => (
                    <div key={room.doctorName} className="bg-white rounded-[2rem] shadow-xl border border-slate-100 overflow-hidden flex flex-col">
                        <div className="bg-blue-600 p-6 text-center shrink-0">
                            <h2 className="text-white text-3xl font-black mb-1">{room.roomTitle}</h2>
                            <p className="text-blue-100 text-sm font-bold">{room.doctorName !== '미배정' ? `${room.doctorName} 원장님` : '진료 대기'}</p>
                        </div>

                        <div className="flex-1 flex flex-col bg-white overflow-hidden">
                            <table className="w-full h-full border-collapse table-fixed">
                                <thead className="bg-slate-50 border-b border-slate-100 shrink-0">
                                    <tr className="text-slate-400 text-sm font-bold uppercase tracking-widest">
                                        <th className="py-4 w-[15%] text-center">순번</th>
                                        <th className="py-4 w-[55%] text-left pl-6">성함</th>
                                        <th className="py-4 w-[30%] text-center">상태</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    {[...Array(ROWS_PER_CLINIC)].map((_, rowIndex) => {
                                        const p = room.patientList[rowIndex];
                                        if (p) {
                                            const statusInfo = getStatusInfo(p.statusCode);
                                            const isCalling = p.statusCode === '003';
                                            return (
                                                <tr key={p.id} className={`border-b border-slate-50 ${isCalling ? 'bg-blue-50/50' : ''}`} style={{ height: '12.5%' }}>
                                                    <td className="text-center">
                                                        <span className={`text-xl font-bold ${isCalling ? 'text-blue-600' : 'text-slate-300'}`}>
                                                            {(rowIndex + 1).toString().padStart(2, '0')}
                                                        </span>
                                                    </td>
                                                    <td className="pl-6 overflow-hidden">
                                                        <div className="flex items-center gap-3 truncate">
                                                            <span className={`text-3xl font-black ${isCalling ? 'text-slate-900' : 'text-slate-700'}`}>{p.name}</span>
                                                            {p.isReserved && <span className="bg-blue-100 text-blue-600 text-[10px] px-1.5 py-0.5 rounded-md font-black border border-blue-200 shrink-0">예약</span>}
                                                        </div>
                                                    </td>
                                                    <td className="text-center">
                                                        <span className={`text-xs font-bold px-3 py-1 rounded-xl shadow-sm ${statusInfo.color}`}>{statusInfo.label}</span>
                                                    </td>
                                                </tr>
                                            );
                                        }
                                        return (
                                            <tr key={`empty-${room.doctorName}-${rowIndex}`} className="border-b border-slate-50" style={{ height: '12.5%' }}>
                                                <td className="text-center text-slate-100 font-bold">{(rowIndex + 1).toString().padStart(2, '0')}</td>
                                                <td></td>
                                                <td></td>
                                            </tr>
                                        );
                                    })}
                                </tbody>
                            </table>
                        </div>
                    </div>
                ))}
            </div>

            <footer>
                <div className="flex items-center gap-4 p-5 bg-slate-900 rounded-[1.5rem] shadow-xl overflow-hidden border-b-4 border-blue-500">
                    <div className="flex items-center gap-2 bg-blue-600 px-4 py-2 rounded-xl text-white font-black text-sm shrink-0">안내사항</div>
                    <div className="flex-1 text-white font-bold text-xl italic tracking-wide overflow-hidden">
                        <marquee scrollamount="6">
                            성함이 호출된 환자분께서는 해당 진료실로 입장해 주시기 바랍니다. • 예약 환자분들은 도착 시 데스크에 반드시 말씀해 주세요. • 진료 상황에 따라 대기 시간이 다소 길어질 수 있습니다.
                        </marquee>
                    </div>
                </div>
            </footer>
        </div>
    );
};

export default WaitingList;