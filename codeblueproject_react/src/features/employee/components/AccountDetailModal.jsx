import React, { useEffect, useState } from 'react'
import * as API from '../../../api/accountApi';

 /**
 * AccountDetailModal.jsx
 * 
 * 작성자 : 김경희
 * 역할 : 계정 관리 - 상세 조회모달 + 수정 기능
 * 
 * 상세보기 모달
 * 1) 계정 프로필 사진, 사번, 이름, 한글명-직원코드, 입사일, 이메일, 전화번호
 * 2) 수정가능한 영역 - 
 */

function AccountDetailModal({isOpen, onClose, onChanged, employeeNo}) {

  // 전화번호 3단 분리 state
    const [telParts, setTelParts] = useState({
      part1:'010',
      part2:'',
      part3:''
    })
    
    // 이메일 2단 분리 state
    const [emailParts, setEmailParts] = useState({
      id:'',
      domain:''
    });
    
    // 이메일 - 도메인 직접 입력 mode 체크 state
    const [isDirectDomain, setIsDirectDomain] = useState(false);

  // 상세보기에서 수정으로 접근가능
  const [isEditMode, setIsEditMode] = useState(false);

  const [fetching, setFetching] = useState(false);
  const [saving, setSaving] = useState(false);

  const [detail, setDetail] = useState(null);
  const [form, setForm] = useState(null);

  const [errorMsg, setErrorMsg] = useState(null);

  // 모달열때마다 초기화 훅
  useEffect(()=>{
    if(isOpen && employeeNo){
      loadData();
    }else{
      resetState();
    }
  }, [isOpen, employeeNo]);

  // 리셋 상태
  const resetState=()=>{
    setIsEditMode(false);
    setDetail(null);
    setForm(null);
    setErrorMsg(null);
    setFetching(false);
    setSaving(false);
  }

  // 닫기
  const handleClose = () => {
    resetState();
    onClose();
  };

  // 클릭시
  const loadData = async () => {

    setFetching(true);
    setErrorMsg(null);

    try{
      const res = await API.getEmployeeDetail(employeeNo);
      const data = res.data;

      setDetail(data);
      setForm(toEditableForm(data));

      // 전화번호 분리
      if (data.employeeTel) {
        const parts = data.employeeTel.split('-');
        setTelParts({
          part1: parts[0] || '',
          part2: parts[1] || '',
          part3: parts[2] || ''
        });
      }

      // 이메일 분리
      if (data.employeeEmail) {
        const parts = data.employeeEmail.split('@');
        setEmailParts({
          id: parts[0] || '',
          domain: parts[1] || ''
        });
      }

    }catch(error){
      console.error("상세 조회 실패:", error);
      const status = error?.response?.status;
      const url = error?.config?.url;
      const method = error?.config?.method;
      
      setErrorMsg(`조회 실패: ${method?.toUpperCase()} ${url} (status: ${status ?? "?"})`);

    }finally{
      setFetching(false);
    }
  };

  // 전화번호 핸들러
  const handleTelChange=(e)=>{
    const { name, value } = e.target;
    
    // 정규식 체크
    if(value && !/^[0-9]*$/.test(value)) return;
    
    // 글자수 제한
    if(name === 'part1' && value.length > 3) return;
    if(name === 'part2' && value.length > 4) return;
    if(name === 'part3' && value.length > 4) return;
    
    setTelParts(prev => ({...prev, [name]:value}));
  }

  // 이메일 입력 핸들러
  const handleEmailChange=(e)=>{
    const{name, value}=e.target;
    setEmailParts(prev => ({ ...prev, [name]: value }));
  }
  
  // 이메일 - 도메인 직접입력 핸들러
  const handleDomainSelect=(e)=>{
    const value = e.target.value;
    if(value === 'type'){
      // 직접 입력 선택할시
      setIsDirectDomain(true);
      setEmailParts(prev => ({...prev, domain:''}));
    }else{
      // 옵션중 선택하면
      setIsDirectDomain(false);
      setEmailParts(prev => ({...prev, domain:value}));
    }
  };

  // 수정폼에 대한 함수
  const toEditableForm = (data) => ({
    employeeName: data?.employeeName ?? "",
    employeeTel: data?.employeeTel ?? "",
    employeeEmail: data?.employeeEmail ?? "",
  });

  // 값 넣을때
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  // 수정 버튼 클릭시
  const startEdit = () => {
    if (!detail) return;
    setErrorMsg(null);
    setForm(toEditableForm(detail));
    setIsEditMode(true);
  };

  // 취소 버튼 클릭하면 원상복귀
  const handleCancel = () => {
    setIsEditMode(false);
    setErrorMsg(null);
    setForm(toEditableForm(detail));
  };

  // 유효성 체크
  const validate = () => {
    if (!form) return "입력값이 없습니다.";
    if (!form.employeeName.trim()) return "이름은 필수 입력 항목입니다.";

    if (form.employeeEmail.trim()) {
      const ok = /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.employeeEmail.trim());
      if (!ok) return "이메일 형식이 올바르지 않습니다.";
    }

    if (form.employeeTel.trim()) {
      const ok = /^[0-9]{2,3}-[0-9]{3,4}-[0-9]{4}$/.test(form.employeeTel.trim());
      if (!ok) return "전화번호 형식이 올바르지 않습니다. 예: 010-1234-5678";
    }

    return null;
  };

  const handleSave = async () => {
    const msg = validate();
    if (msg) {
      setErrorMsg(msg);
      return;
    }

    if (!window.confirm("변경된 정보를 저장하시겠습니까?")) return;

    setSaving(true);
    setErrorMsg(null);

    // 저장전에 하이픈으로 합치기
    const finalTel = `${telParts.part1}-${telParts.part2}-${telParts.part3}`;
    const finalEmail = `${emailParts.id}@${emailParts.domain}`;

    try {
      const fd = new FormData();
      // 허용된 필드만 수정 가능함...
      fd.append("employeeName", form.employeeName);
      fd.append("employeeTel", finalTel);
      fd.append("employeeEmail", finalEmail);

      await API.updateEmployee(employeeNo, fd);

      // 최신 데이터 갱신
      await loadData();
      setIsEditMode(false);

      if (onChanged) onChanged();

    } catch (err) {
      console.error(err);
      setErrorMsg("저장 중 오류 발생");
    } finally {
      setSaving(false);
    }
  };

  // isOpen이 false면 아무것도 렌더링 안 함 (에러 방지용 안전장치)
  if (!isOpen) return null;

  return (
    <div onClick={handleClose} className="fixed inset-0 z-50 flex items-center justify-center bg-black/50">
      <div onClick={(e) => e.stopPropagation()} className="w-[700px] max-w-[95%] bg-white rounded-2xl shadow-xl overflow-hidden flex flex-col max-h-[90vh]">
        <div className="px-6 py-4 border-b flex justify-between items-center bg-slate-50">
          <h2 className="text-lg font-bold text-slate-800">
            직원 상세 정보 {isEditMode && (<span className="ml-2 text-xs bg-blue-100 text-blue-700 px-2 py-0.5 rounded">수정중</span>)}
          </h2>
          <button onClick={handleClose} aria-label="닫기" className="text-slate-400 hover:text-slate-600 text-2xl leading-none">
            &times;
          </button>
        </div>

        {/* Body */}
        <div className="p-6 overflow-y-auto">
          {/* Error Banner */}
          {errorMsg && (
            <div className="mb-4 p-3 bg-red-50 border border-red-200 text-red-700 text-sm rounded">
              {errorMsg}
            </div>
          )}

          {fetching ? (
            <div className="py-10 text-center text-slate-500">데이터를 불러오는 중입니다...</div>
          ) : (
            detail &&
            form && (
              <div className="grid grid-cols-2 gap-6">
                {/* ReadOnly 영역 */}
                <InfoItem label="사번" value={detail.employeeNo} />
                <InfoItem label="입사일" value={formatDate(detail.employeeRegdate)} />
                <InfoItem label="직급" value={detail.employeePositionName ?? detail.employeePosition} />
                <InfoItem label="상태" value={detail.employeeStatus === "N" ? "재직중" : "퇴사 처리됨"} />

                {/* Editable 영역 */}
                <Field
                  label="이름"
                  isEditMode={isEditMode}
                  viewValue={detail.employeeName}
                >
                  <input
                    type="text"
                    name="employeeName"
                    value={form.employeeName}
                    onChange={handleInputChange}
                    className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                  />
                </Field>

                <Field
                  label="전화번호"
                  isEditMode={isEditMode}
                  viewValue={detail.employeeTel}
                >
                  <input type="text" name="employeeTel" value={form.employeeTel}
                    onChange={handleInputChange} placeholder="010-0000-0000"
                    className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                  />
                </Field>

                <div className="col-span-2">
                  <Field
                    label="이메일"
                    isEditMode={isEditMode}
                    viewValue={detail.employeeEmail}
                    fullWidth
                  >
                    <input
                      type="text"
                      name="employeeEmail"
                      value={form.employeeEmail}
                      onChange={handleInputChange}
                      className="w-full border rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 outline-none"
                    />
                  </Field>
                </div>

                {/* 퇴사일 (조회만) */}
                {detail.employeeRetdate && (
                  <InfoItem label="퇴사일자" value={formatDate(detail.employeeRetdate)} fullWidth />
                )}
              </div>
            )
          )}
        </div>

        {/* Footer */}
        <div className="px-6 py-4 bg-slate-50 border-t flex justify-end gap-2">
          {!isEditMode ? (
            <>
              <button
                onClick={handleClose}
                className="px-4 py-2 text-sm font-medium text-slate-700 bg-white border border-slate-300 rounded-lg hover:bg-slate-50"
              >
                닫기
              </button>
              <button
                onClick={startEdit}
                disabled={fetching || !detail}
                className="px-4 py-2 text-sm font-bold text-white bg-blue-600 rounded-lg hover:bg-blue-700 disabled:opacity-50"
              >
                수정
              </button>
            </>
          ) : (
            <>
              <button
                onClick={handleCancel}
                disabled={saving}
                className="px-4 py-2 text-sm font-medium text-slate-700 bg-white border border-slate-300 rounded-lg hover:bg-slate-50 disabled:opacity-50"
              >
                취소
              </button>
              <button
                onClick={handleSave}
                disabled={saving}
                className="px-4 py-2 text-sm font-bold text-white bg-blue-600 rounded-lg hover:bg-blue-700 flex items-center gap-2 disabled:bg-blue-400"
              >
                {saving && <span className="animate-spin">⌛</span>}
                {saving ? "저장 중..." : "저장"}
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}

/** ReadOnly 반복 UI */
function InfoItem({ label, value, fullWidth = false }) {
  return (
    <div className={fullWidth ? "col-span-2" : "col-span-1"}>
      <label className="block text-xs font-semibold text-slate-500 mb-1">{label}</label>
      <div className="text-sm text-slate-800 py-2 border-b border-dotted border-slate-300">
        {value || "-"}
      </div>
    </div>
  );
}

/** View/Edit 전환되는 필드 래퍼 */
function Field({ label, isEditMode, viewValue, children }) {
  return (
    <div className="col-span-1">
      <label className="block text-xs font-semibold text-slate-500 mb-1">{label}</label>
      {isEditMode ? (
        children
      ) : (
        <div className="text-sm text-slate-800 py-2 font-medium">{viewValue || "-"}</div>
      )}
    </div>
  );
}

/** 날짜 포맷 */
function formatDate(dateStr) {
  if (!dateStr) return "-";
  return String(dateStr).substring(0, 10);
}

export default AccountDetailModal