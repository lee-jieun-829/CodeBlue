import React, { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import Swal from 'sweetalert2';

// --- 라이브러리 ---
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import timeGridPlugin from '@fullcalendar/timegrid';
import interactionPlugin from '@fullcalendar/interaction';
import { ChevronDown, CheckCircle } from 'lucide-react';

// --- 컴포넌트 ---
import Header from '../../components/layout/Header.jsx';
import LeftAdmin from "../../components/layout/LeftAdmin.jsx";
import EventModal from "../../features/calendar/EventModal";

// --- 상수 및 설정 ---
const HOSPITAL_COMMON_ID = '26020908'; // 병원 공통 일정용 ID (문자열)
const API_BASE_URL = 'http://localhost:8060/api/calendar';

// --- 유틸리티 함수 ---
const normalizeDate = (dateStr, isEnd = false) => {
  if (!dateStr) return null;
  if (!dateStr.includes('T')) {
    return isEnd ? `${dateStr}T18:00` : `${dateStr}T09:00`;
  }
  return dateStr;
};

// =============================================================================
// 캘린더 전용 메뉴 사이드바
// =============================================================================
const MenuSidebar = ({ viewType, setViewType, selectedDoctorId, setSelectedDoctorId, doctorList }) => (
  <div className="content-area flex flex-col w-[240px] bg-white rounded-lg shadow-sm border border-gray-200 p-4 shrink-0 hidden md:flex h-full">
    <div className="mb-4">
      <div style={{ fontSize: 'var(--font-lg)', fontWeight: 'var(--font-medium)' }}>
        일정 관리 메뉴
      </div>
    </div>
    <hr className="mb-4 border-gray-200" />

    <div className="space-y-2">
      {/* 병원 공통 일정 버튼 */}
      <button
        onClick={() => setViewType('COMMON')}
        className={`w-full text-left px-4 py-3 rounded-lg font-bold text-[13px] flex justify-between items-center transition-all ${
          viewType === 'COMMON' ? 'bg-blue-50 text-blue-600' : 'text-slate-500 hover:bg-gray-50'
        }`}
      >
        병원 공통 일정 {viewType === 'COMMON' && <CheckCircle size={14} />}
      </button>

      {/* 의사별 개인 일정 영역 */}
      <div className={`rounded-lg transition-all ${viewType === 'PERSONAL' ? 'bg-blue-50/50 border border-blue-100' : ''}`}>
        <button
          onClick={() => setViewType('PERSONAL')}
          className={`w-full text-left px-4 py-3 rounded-lg font-bold text-[13px] flex justify-between items-center transition-all ${
            viewType === 'PERSONAL' ? 'text-blue-600' : 'text-slate-500 hover:bg-gray-50'
          }`}
        >
          의사별 개인 일정 {viewType === 'PERSONAL' && <CheckCircle size={14} />}
        </button>

        {/* 개인 일정 선택 시, 드롭다운 메뉴 표시 */}
        {viewType === 'PERSONAL' && (
          <div className="px-4 pb-3 animate-fadeIn">
            <div className="relative">
              <select
                value={selectedDoctorId}
                onChange={(e) => setSelectedDoctorId(Number(e.target.value))}
                className="w-full p-2.5 pl-3 pr-8 text-xs font-bold text-slate-700 bg-white border border-blue-200 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500 appearance-none cursor-pointer shadow-sm"
              >
                {(!Array.isArray(doctorList) || doctorList.length === 0) ? (
                  <option value="0">목록 없음</option>
                ) : (
                  doctorList.map((doc) => (
                    <option key={doc.employeeNo} value={doc.employeeNo}>{doc.empName}</option>
                  ))
                )}
              </select>
              <ChevronDown className="absolute right-2.5 top-1/2 -translate-y-1/2 text-slate-400 pointer-events-none" size={14} />
            </div>
          </div>
        )}
      </div>
    </div>
  </div>
);


// =============================================================================
// [메인 컴포넌트] 의사 캘린더 페이지
// =============================================================================
function DoctorCalendarPage() {
  const navigate = useNavigate();

  // --- 상태 관리 ---
  const [viewType, setViewType] = useState('COMMON'); // 'COMMON' or 'PERSONAL'
  const [selectedDoctorId, setSelectedDoctorId] = useState(0);

  const [events, setEvents] = useState([]);
  const [doctorList, setDoctorList] = useState([]);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [selectedEvent, setSelectedEvent] = useState(null);
  const [selectedDateRange, setSelectedDateRange] = useState(null);

  // [Helper] 선택된 의사 이름 가져오기
  const getSelectedDoctorName = () => {
    const doctor = doctorList.find(d => d.employeeNo === selectedDoctorId);
    return doctor ? doctor.empName : '선택된 의사';
  };

  // ===========================================================================
  // 1. 데이터 조회 (API 연동)
  // ===========================================================================

  // (1) 의사 목록 조회
  useEffect(() => {
    const fetchDoctors = async () => {
      try {
        const res = await axios.get(`${API_BASE_URL}/doctors`);
        if (Array.isArray(res.data)) {
          setDoctorList(res.data);
          if (res.data.length > 0) setSelectedDoctorId(res.data[0].employeeNo);
        } else {
          setDoctorList([]);
        }
      } catch (err) {
        console.error("의사 목록 로딩 실패:", err);
        setDoctorList([]);
      }
    };
    fetchDoctors();
  }, []);

  // (2) 일정 데이터 조회 및 필터링
  const fetchEvents = useCallback(async () => {
    try {
      // API 호출 시 파라미터 설정
      // 개인 일정일 때는 해당 의사 ID, 공통일 때는 0(또는 공통 ID) 전송
      const empNoParam = viewType === 'COMMON' ? 0 : selectedDoctorId;
      
      if (viewType === 'PERSONAL' && empNoParam === 0) return;

      const response = await axios.get(`${API_BASE_URL}/list`, {
        params: { employeeNo: empNoParam }
      });

      console.log("일정 로딩 성공:", response.data);

      const dataList = Array.isArray(response.data) ? response.data : [];
      
      // ★ 중요: 프론트엔드 레벨에서 엄격한 필터링 수행
      const filteredList = dataList.filter(item => {
        // 1. 기본 타입 체크
        if (item.type !== '001') return false;

        const itemEmpNo = String(item.employeeNo); // 비교를 위해 문자열 변환
        const targetDocId = String(selectedDoctorId);
        const commonId = String(HOSPITAL_COMMON_ID);

        if (viewType === 'COMMON') {
          // 공통 뷰: 공통 ID만 허용
          return itemEmpNo === commonId;
        } else {
          // 개인 뷰: [선택된 의사] OR [공통 일정]만 허용 (다른 의사 일정 차단)
          return itemEmpNo === targetDocId || itemEmpNo === commonId;
        }
      });

      // FullCalendar 형식 매핑
      const mappedEvents = filteredList.map(item => ({
        id: String(item.scheduleNo),
        title: item.title,
        start: item.start,
        end: item.end,
        allDay: item.allDay === 1 || (item.start && !item.start.includes('T')),
        backgroundColor: item.backgroundColor,
        borderColor: item.backgroundColor,
        textColor: '#334155',
        extendedProps: { 
          scheduleNo: item.scheduleNo,
          type: item.type,
          employeeNo: item.employeeNo,
          description: item.description,
          scheduleDoctorNo: item.scheduleDoctorNo
        }
      }));
      
      setEvents(mappedEvents);
    } catch (error) {
      console.error("일정 로딩 실패:", error);
      setEvents([]);
    }
  }, [viewType, selectedDoctorId]);

  useEffect(() => { fetchEvents(); }, [fetchEvents]);

  // ===========================================================================
  // 2. 이벤트 핸들러 (저장, 삭제, 드롭)
  // ===========================================================================

  const handleSaveEvent = async (formData) => {
    const selectedEmpNo = Number(formData.employeeNo);

    const eventData = {
      scheduleNo: selectedEvent ? selectedEvent.extendedProps.scheduleNo : 0,
      title: formData.title,
      description: formData.description,
      start: normalizeDate(formData.start),
      end: normalizeDate(formData.end, true),
      type: '001',
      employeeNo: selectedEmpNo || HOSPITAL_COMMON_ID,
      scheduleDoctorNo: selectedEmpNo,
      allDay: formData.allDay ? 1 : 0
    };

    try {
      if (selectedEvent) {
        await axios.post(`${API_BASE_URL}/update`, eventData);
        Swal.fire('성공', '일정이 수정되었습니다.', 'success');
      } else {
        await axios.post(`${API_BASE_URL}/add`, eventData);
        Swal.fire('성공', '새 일정이 등록되었습니다.', 'success');
      }
      fetchEvents();
      setIsModalOpen(false);
    } catch (error) {
      console.error("저장 실패:", error);
      Swal.fire('오류', '저장 중 오류가 발생했습니다.', 'error');
    }
  };

  const handleDeleteEvent = async (eventId) => {
    const result = await Swal.fire({
      title: '삭제 확인',
      text: '정말 삭제하시겠습니까?',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: '삭제',
      cancelButtonText: '취소'
    });

    if (result.isConfirmed) {
      try {
        await axios.post(`${API_BASE_URL}/delete/${eventId}`);
        Swal.fire('삭제됨', '일정이 삭제되었습니다.', 'success');
        fetchEvents();
        setIsModalOpen(false);
      } catch (error) {
        Swal.fire('오류', '삭제에 실패했습니다.', 'error');
      }
    }
  };

  // [수정] 일정 이동 핸들러 (성공 알림 추가)
  const handleEventDrop = async (info) => {
    const result = await Swal.fire({
      title: '일정 이동',
      text: `'${info.event.title}' 일정을 이동하시겠습니까?`,
      icon: 'question',
      showCancelButton: true,
      confirmButtonText: '이동',
      cancelButtonText: '취소'
    });

    if (!result.isConfirmed) {
      info.revert();
      return;
    }

    let safeStart = normalizeDate(info.event.startStr);
    let safeEnd = normalizeDate(info.event.endStr || info.event.startStr, true);
    safeStart = safeStart.slice(0, 16);
    safeEnd = safeEnd.slice(0, 16);

    const props = info.event.extendedProps;
    let safeEmployeeNo = Number(props.employeeNo);
    
    // 이동 시에도 권한 유지 (공통 일정은 공통으로 유지)
    if (String(safeEmployeeNo) === HOSPITAL_COMMON_ID || !safeEmployeeNo) {
      safeEmployeeNo = HOSPITAL_COMMON_ID;
    }

    const updatedEvent = {
      scheduleNo: props.scheduleNo,
      title: info.event.title,
      start: safeStart,
      end: safeEnd,
      type: '001',
      employeeNo: safeEmployeeNo,
      scheduleDoctorNo: props.scheduleDoctorNo || safeEmployeeNo,
      description: props.description,
      allDay: info.event.allDay ? 1 : 0
    };

    try {
      await axios.post(`${API_BASE_URL}/update`, updatedEvent);
      
      // [추가] 성공 알림창
      await Swal.fire({
        title: '변경 완료',
        text: '일정 변경이 완료되었습니다.',
        icon: 'success',
        confirmButtonText: '확인'
      });

    } catch (error) {
      console.error(error);
      Swal.fire('오류', '이동 중 오류가 발생했습니다.', 'error');
      info.revert();
    }
  };

  // ===========================================================================
  // 3. UI
  // ===========================================================================
  const handleDateSelect = (selectInfo) => {
    setSelectedEvent(null);
    setSelectedDateRange(selectInfo);
    setIsModalOpen(true);
  };

  const handleEventClick = (clickInfo) => {
    setSelectedEvent(clickInfo.event);
    setSelectedDateRange({
      startStr: clickInfo.event.startStr,
      endStr: clickInfo.event.endStr || clickInfo.event.startStr,
      allDay: clickInfo.event.allDay
    });
    setIsModalOpen(true);
  };

  return (
    <div className="app h-screen w-full flex flex-col bg-neutral-100 text-zinc-950">
      
      <EventModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSave={handleSaveEvent}
        onDelete={handleDeleteEvent}
        initialDate={selectedDateRange}
        eventData={selectedEvent}
        currentViewType={viewType}
        currentDoctorId={selectedDoctorId}
        doctorList={doctorList}
      />

      {/* 헤더 */}
      <header className='h-16 w-full bg-white border-b border-neutral-200 shrink-0'>
          <Header />
        </header>

       <div className="main-container body flex flex-1 w-full overflow-hidden">
          {/* --- 사이드바 --- */}
          <aside className="side-bar flex w-28 shrink-0 flex-col border-r border-neutral-200 bg-white overflow-y-auto custom-scrollbar">
            <LeftAdmin />
          </aside>

        <main className="main-content flex-1 overflow-hidden p-4 ml-0">
          <div className="flex gap-4 h-full">

            <MenuSidebar
              viewType={viewType}
              setViewType={setViewType}
              selectedDoctorId={selectedDoctorId}
              setSelectedDoctorId={setSelectedDoctorId}
              doctorList={doctorList}
            />

            <div className="content-area flex flex-col flex-1 h-full min-h-0 bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
              
              {/* 캘린더 상단 제목 */}
              <div className="flex justify-between items-end p-6 pb-2 shrink-0">
                <div>
                  <h2 className="text-xl font-bold text-slate-900 mb-1">
                    {viewType === 'COMMON' 
                      ? '병원 공통 일정' 
                      : `${getSelectedDoctorName()} 개인 일정`} {/* 의사 이름 동적 표시 */}
                  </h2>
                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-widest">
                    {viewType === 'COMMON' ? 'HOSPITAL SHARED CALENDAR' : `DOCTOR ID: ${selectedDoctorId}`}
                  </p>
                </div>
                <button
                  onClick={() => { setSelectedEvent(null); setIsModalOpen(true); }}
                  className="px-4 py-2 bg-blue-600 text-white rounded-[6px] text-[13px] font-bold hover:bg-blue-700 transition shadow-sm"
                >
                  + 일정 생성
                </button>
              </div>

              <div className="flex-1 p-6 overflow-hidden">
                <FullCalendar
                  key={`${viewType}-${selectedDoctorId}`}
                  plugins={[dayGridPlugin, timeGridPlugin, interactionPlugin]}
                  initialView="dayGridMonth"
                  headerToolbar={{
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,timeGridDay'
                  }}
                  // 버튼 텍스트 한글 변경 (월, 주, 일)
                  buttonText={{
                    today: '오늘',
                    month: '월',
                    week: '주',
                    day: '일',
                    list: '목록'
                  }}
                  slotMinTime="08:00:00"
                  slotMaxTime="20:00:00"
                  slotEventOverlap={false}
                  locale="ko"
                  height="100%"
                  events={events}
                  editable={true}
                  selectable={true}
                  dayMaxEvents={true}
                  select={handleDateSelect}
                  eventClick={handleEventClick}
                  eventDrop={handleEventDrop}
                />
              </div>
            </div>
            
          </div>
        </main>
      </div>
    </div>
  );
}

export default DoctorCalendarPage;