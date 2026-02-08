import React, { useState, useEffect } from 'react';
import { X, Trash2, Edit2, User } from 'lucide-react';



// --- [Constants] 상수 정의 ---
const HOSPITAL_COMMON_ID = 26020908;
const EVENT_TYPES = ['사내일정', '휴진', '병원행사', '시설점검', '기타'];

// --- [Utils] 날짜 포맷 헬퍼 (UI 표시용) ---
const formatInputDateTime = (dateInput, isAllDay) => {
  if (!dateInput) return '';
  const date = new Date(dateInput);
  if (isNaN(date.getTime())) return '';
  
  // 한국 시간(KST) 보정을 위해 오프셋 적용
  const kstDate = new Date(date.getTime() - (date.getTimezoneOffset() * 60000));
  const isoString = kstDate.toISOString();

  // input type="date"는 YYYY-MM-DD, type="datetime-local"은 YYYY-MM-DDTHH:mm 필요
  if (isAllDay) return isoString.slice(0, 10);
  return isoString.slice(0, 16);
};

// UI에 보여줄 한국어 날짜 포맷
const formatKoDateTime = (isoStr, isAllDay) => {
  if (!isoStr) return '';
  const date = new Date(isoStr);
  
  if (isAllDay) {
    return date.toLocaleString('ko-KR', { 
      year: 'numeric', month: 'long', day: 'numeric', weekday: 'short' 
    }) + " (종일)";
  }

  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');

  return `${year}-${month}-${day} ${hours}:${minutes}`;
};

// --- [Sub-Component] 1. 상세 보기 모드 ---
const ViewMode = ({ formData, eventData, onClose, setMode, onDelete, getEmpName }) => {
  return (
    <div className="fixed inset-0 z-[9999] flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
      <div className="bg-white w-full max-w-[400px] rounded-[24px] shadow-2xl p-6 flex flex-col gap-6">
        <div className="flex justify-between items-start">
           <div className="flex items-center gap-2">
             <span className={`px-2 py-1 rounded text-xs font-bold bg-blue-100 text-blue-600`}>
               {formData.type === '001' ? '사내일정' : formData.type}
             </span>
             {formData.allDay && <span className="px-2 py-1 bg-purple-100 text-purple-600 text-xs font-bold rounded">하루종일</span>}
           </div>
           <div className="flex gap-2 text-slate-400">
             <button onClick={() => setMode('edit')} className="hover:text-blue-600"><Edit2 size={18}/></button>
             <button onClick={() => { if(window.confirm('삭제하시겠습니까?')) onDelete(eventData.id); }} className="hover:text-red-600"><Trash2 size={18}/></button>
             <button onClick={onClose} className="hover:text-slate-600"><X size={20}/></button>
           </div>
        </div>
        <div>
          <h1 className="text-xl font-bold text-slate-800 leading-snug">{formData.title}</h1>
          <p className="text-sm text-slate-500 mt-2 flex items-center gap-1"><User size={14}/> {getEmpName(formData.employeeNo)}</p>
        </div>
        <div className="bg-slate-50 p-4 rounded-xl border border-slate-100 space-y-3">
           <div className="flex justify-between text-sm"><span className="text-slate-400 font-bold">시작</span><span className="text-slate-700 font-bold">{formatKoDateTime(formData.start, formData.allDay)}</span></div>
           <div className="flex justify-between text-sm"><span className="text-slate-400 font-bold">종료</span><span className="text-slate-700 font-bold">{formatKoDateTime(formData.end, formData.allDay)}</span></div>
        </div>
        <div className="text-sm text-slate-600 min-h-[60px] whitespace-pre-wrap">{formData.description || "내용 없음"}</div>
        <button onClick={onClose} className="w-full py-3 bg-white border border-slate-200 rounded-xl font-bold text-slate-600 hover:bg-slate-50">닫기</button>
      </div>
    </div>
  );
};

// --- [Sub-Component] 2. 수정/등록 모드 ---
const EditMode = ({ formData, eventData, handleChange, handleSubmit, onClose, setMode, doctorList, getEmpName }) => {
  return (
    <div className="fixed inset-0 z-[9999] flex items-center justify-center bg-black/50 backdrop-blur-sm p-4">
      <div className="bg-white w-full max-w-[480px] rounded-[24px] shadow-2xl overflow-hidden flex flex-col max-h-[90vh]">
        <div className="flex justify-between items-center px-8 py-6 border-b border-slate-50 bg-white sticky top-0 z-10">
          <h2 className="text-xl font-bold text-slate-800 flex items-center gap-2">{eventData ? '일정 수정' : '새 일정 등록'}</h2>
          <button onClick={onClose} className="text-slate-300 hover:text-slate-600"><X size={24} /></button>
        </div>

        <div className="px-8 py-6 space-y-6 overflow-y-auto custom-scrollbar">
          {/* 구분 및 제목 */}
          <div className="grid grid-cols-3 gap-4">
             <div className="col-span-1">
               <label className="text-xs font-bold text-slate-500 mb-2 block">구분</label>
               <select name="type" value={formData.type} onChange={handleChange} className="w-full p-3 text-sm border border-slate-200 rounded-xl font-bold text-slate-700 bg-slate-50 outline-none">
                 {EVENT_TYPES.map(type => (
                   <option key={type} value={type}>{type}</option>
                 ))}
               </select>
             </div>
             <div className="col-span-2">
                 <label className="text-xs font-bold text-slate-500 mb-2 block">제목</label>
                 <input type="text" name="title" value={formData.title} onChange={handleChange} className="w-full p-3 text-sm border border-slate-200 rounded-xl outline-none focus:border-blue-500 font-medium" placeholder="일정 제목"/>
             </div>
          </div>

          {/* 배정 대상 */}
          {formData.type === '기타' ? null : 
           formData.type === '휴진' ? (
              <div className="p-3 bg-slate-50 rounded-xl border border-slate-100 flex flex-col gap-2">
                 <div className="flex justify-between items-center"><span className="text-xs font-bold text-slate-500">배정 대상 (의사 선택)</span></div>
                 <select name="employeeNo" value={formData.employeeNo} onChange={handleChange} className="w-full p-2.5 text-sm border border-slate-200 rounded-lg font-bold text-slate-700 bg-white focus:border-blue-500 outline-none transition">
                    <option value="0">담당 의사 선택</option>
                    {doctorList.map((doc) => (
                        <option key={doc.employeeNo} value={doc.employeeNo}>{doc.empName}</option>
                    ))}
                 </select>
              </div>
          ) : (
              <div className="p-3 bg-slate-50 rounded-xl border border-slate-100 flex justify-between items-center">
                 <span className="text-xs font-bold text-slate-500">배정 대상</span>
                 <span className={`text-sm font-bold ${formData.employeeNo === 0 ? 'text-blue-600' : 'text-slate-700'}`}>{getEmpName(formData.employeeNo)}</span>
              </div>
          )}

          {/* 일시 설정 */}
          <div className="space-y-3">
             <div className="flex justify-between items-center">
                <label className="text-xs font-bold text-slate-500">일시 설정</label>
                <label className="flex items-center gap-2 cursor-pointer group">
                  <input type="checkbox" name="allDay" checked={formData.allDay} onChange={handleChange} className="w-4 h-4 text-blue-600 rounded focus:ring-blue-500 border-gray-300"/>
                  <span className="text-sm font-bold text-slate-600 group-hover:text-blue-600">하루종일</span>
                </label>
             </div>
             <div className="flex gap-4">
                <div className="flex-1"><input type={formData.allDay ? "date" : "datetime-local"} name="start" value={formData.start} onChange={handleChange} className="w-full p-3 text-sm font-bold text-slate-600 border border-slate-200 rounded-xl focus:border-blue-500 outline-none"/></div>
                <div className="flex-1"><input type={formData.allDay ? "date" : "datetime-local"} name="end" value={formData.end} onChange={handleChange} className="w-full p-3 text-sm font-bold text-slate-600 border border-slate-200 rounded-xl focus:border-blue-500 outline-none"/></div>
             </div>
          </div>

          {/* 메모 */}
          <div>
            <label className="text-xs font-bold text-slate-500 mb-2 block">상세 내용</label>
            <textarea name="description" value={formData.description} onChange={handleChange} className="w-full h-24 p-3 text-sm border border-slate-200 rounded-xl resize-none outline-none focus:border-blue-500" placeholder="내용을 입력하세요"/>
          </div>
        </div>

        <div className="px-8 py-5 border-t border-slate-50 flex gap-3 bg-white">
          <button onClick={() => { if(eventData) setMode('view'); else onClose(); }} className="flex-1 py-3 bg-slate-50 border border-slate-200 rounded-xl font-bold text-slate-600 hover:bg-slate-100">취소</button>
          <button onClick={handleSubmit} className="flex-[2] py-3 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 shadow-lg shadow-blue-200">저장</button>
        </div>
      </div>
    </div>
  );
};

// --- [Main Component] EventModal ---
const EventModal = ({ isOpen, onClose, onSave, onDelete, initialDate, eventData, currentViewType, currentDoctorId, doctorList = [] }) => {
  const [mode, setMode] = useState('edit');
  
  const [formData, setFormData] = useState({
    id: '', type: '사내일정', employeeNo: 0, title: '', start: '', end: '', description: '', allDay: false
  });

  // 초기화 및 매핑
  useEffect(() => {
    if (isOpen) {
      if (eventData) {
        setMode('view');
        const props = eventData.extendedProps || {};
        
        let displayType = props.type;
        if (displayType === '001') displayType = '사내일정'; 

        setFormData({
          id: eventData.id,
          type: displayType, 
          employeeNo: Number(props.employeeNo),
          title: eventData.title,
          allDay: eventData.allDay, 
          start: formatInputDateTime(eventData.start, eventData.allDay),
          end: eventData.end ? formatInputDateTime(eventData.end, eventData.allDay) : formatInputDateTime(eventData.start, eventData.allDay),
          description: props.description || ''
        });
      } else {
        setMode('edit');
        const isPersonal = currentViewType === 'PERSONAL';
        const isAllDayInit = initialDate ? initialDate.allDay : false;

        setFormData({
          id: '',
          type: isPersonal ? '휴진' : '사내일정', 
          employeeNo: isPersonal ? Number(currentDoctorId) : HOSPITAL_COMMON_ID, 
          title: '',
          allDay: isAllDayInit,
          start: initialDate ? formatInputDateTime(initialDate.startStr, isAllDayInit) : '',
          end: initialDate ? formatInputDateTime(initialDate.endStr, isAllDayInit) : '',
          description: ''
        });
      }
    }
  }, [isOpen, eventData, initialDate, currentViewType, currentDoctorId]);

  // 입력 핸들러
  const handleChange = (e) => {
    const { name, value, checked } = e.target;
    
    if (name === 'allDay') {
      const isChecked = checked;
      setFormData(prev => {
        let newStart = prev.start;
        let newEnd = prev.end;
        if (isChecked) {
          // Time -> Date (T 이후 제거)
          if (newStart.includes('T')) newStart = newStart.split('T')[0];
          if (newEnd.includes('T')) newEnd = newEnd.split('T')[0];
        } else {
          // Date -> Time (T09:00, T10:00 추가)
          if (!newStart.includes('T')) newStart = `${newStart}T09:00`;
          if (!newEnd.includes('T')) newEnd = `${newEnd}T10:00`;
        }
        return { ...prev, allDay: isChecked, start: newStart, end: newEnd };
      });
    } else if (name === 'type') {
      let nextEmpNo = formData.employeeNo;
      if (value === '휴진') {
        if (currentDoctorId) nextEmpNo = Number(currentDoctorId);
        else nextEmpNo = 0; 
      } else if (['병원행사', '시설점검', '기타', '진료일정', '사내일정'].includes(value)) {
        nextEmpNo = HOSPITAL_COMMON_ID;
      } 
      setFormData(prev => ({ ...prev, type: value, employeeNo: nextEmpNo }));
    } else {
      setFormData(prev => ({ ...prev, [name]: value }));
    }
  };

  // ★★★ [저장 핸들러 수정 완료] ★★★
  const handleSubmit = () => {
    if (!formData.title.trim()) return alert('일정 제목을 입력해주세요.');
    if (!formData.start) return alert('시작 일시를 입력해주세요.');

    if (formData.type === '휴진') {
        const docNo = Number(formData.employeeNo);
        if (docNo === 0 || docNo === HOSPITAL_COMMON_ID) {
            return alert('휴진 처리할 의사를 선택해주세요.');
        }
    }

    // DB 오라클 TO_DATE('YYYY-MM-DD"T"HH24:MI') 형식에 맞추기 위한 포맷팅
    let cleanStart = formData.start;
    let cleanEnd = formData.end;

    // 만약 T가 없다면 (AllDay 체크된 상태로 날짜만 있을 때) 기본 시간 추가
    if (cleanStart && !cleanStart.includes('T')) {
        cleanStart += 'T09:00'; 
    }
    if (cleanEnd && !cleanEnd.includes('T')) {
        cleanEnd += 'T18:00';
    }

    // 문자열 길이 정리 (YYYY-MM-DDTHH:mm -> 16자리)
    // 예: 2024-05-20T09:00:00.000Z -> 2024-05-20T09:00
    if (cleanStart && cleanStart.length > 16) cleanStart = cleanStart.substring(0, 16);
    if (cleanEnd && cleanEnd.length > 16) cleanEnd = cleanEnd.substring(0, 16);

    // 타입 코드 변환
    let finalType = formData.type;
    if (formData.type === '사내일정') finalType = '001';

    // 부모 컴포넌트(DoctorCalendarPage)로 데이터 전달
    onSave({
      ...formData,
      start: cleanStart, // 16자리 포맷된 문자열
      end: cleanEnd,     // 16자리 포맷된 문자열
      type: finalType, 
      employeeNo: Number(formData.employeeNo)
    });
    onClose();
  };

  const getEmpName = (empNo) => {
    const n = Number(empNo);
    if (n === 0 || n === HOSPITAL_COMMON_ID) return '전체(공통)';
    const doctor = doctorList.find(doc => doc.employeeNo === n);
    return doctor ? `${doctor.empName} 의사` : '미지정';
  };

  if (!isOpen) return null;
  return mode === 'view' ? (
    <ViewMode formData={formData} eventData={eventData} onClose={onClose} setMode={setMode} onDelete={onDelete} getEmpName={getEmpName} />
  ) : (
    <EditMode formData={formData} eventData={eventData} handleChange={handleChange} handleSubmit={handleSubmit} onClose={onClose} setMode={setMode} doctorList={doctorList} getEmpName={getEmpName} />
  );
};

export default EventModal;