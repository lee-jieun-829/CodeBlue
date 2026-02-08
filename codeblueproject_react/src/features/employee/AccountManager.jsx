import React, { useEffect, useRef, useState } from 'react'
import * as API from '../../api/accountApi';
import AccountCreateModal from './components/AccountCreateModal';
import AccountDetailModal from './components/AccountDetailModal';
import AccountExcelModal from './components/AccountExcelModal';
import LocationAssignmentModal from './components/LocationAssignmentModal';


/**
 * AccountManager.jsx
 * 
 * 작성자 : 김경희
 * 역할 : 계정 관리 - 목록 조회 & 퇴사처리 & 각 기능(모달)들 조립
 * 
 * 모달 종류
 * 1) 계정 생성
 * 2) 계정 상세조회 & 수정
 * 3) 엑셀 관련 모달
 */
function AccountManager() {

  // 조회 목록 상태
  const [employees, setEmployees] = useState([]);

  // 로딩 상태
  const [isLoading, setIsLoading] = useState(false);

  // 페이징 처리
  const [paging, setPaging] = useState({
    page: 1,
    size: 10,
    totalElements: 0,
    totalPages: 0
  });

  // 검색 필터
  const [filters, setFilters] = useState({
    position: "",
    sort: "",
    keyword: "",
  });

  // 마지막 요청만 반영해줌
  const lastReqIdRef = useRef(0);

  // 모달 상태 - 열기, 닫기
  const [modals, setModals] = useState({
    create: false,
    excel: false,
    detail: false,
    location: false
  });

  // 엑셀 모달의 모드 : 등록/다운로드
  const [excelMode, setExcelMode] = useState("upload");

  // 엑셀 모달을 원하는 모드로 바꾸기
  const openExcelModal = (mode) => {
    setExcelMode(mode);
    toggleModal("excel", true);
  }

  // 선택된 사원 번호 (직원계정 클릭시 보여줄 상세보기 모달용)
  const [selectedEmNo, setSelectedEmNo] = useState(null);

  // 직원 구분 코드
  const POSITION_MAP = {
    "0": "관리자",
    "1": "의사",
    "2": "외래간호사",
    "3": "입원간호사",
    "4": "약사",
    "5": "방사선사",
    "6": "물리치료사",
    "7": "원무과"
  };

  // 초기화 훅
  useEffect(() => {
    loadEmployees();
  }, [filters.position, filters.sort, paging.page]);

  // 목록 로딩
  const loadEmployees = async () => {
    const reqId = ++lastReqIdRef.current;
    setIsLoading(true);

    try {
      const params = {...filters, page: paging.page - 1, size: paging.size };
      console.log("[REQ params]", params);
      const res = await API.getEmployee(params);

      // 페이징 했으니까 배열이 아닌 객체 리턴!!
      if (reqId === lastReqIdRef.current) {
        
        setEmployees(res.data.content);

        setPaging(prev => ({...prev,
          totalPages: res.data.totalPages,
          totalElements: res.data.totalElements
        }));
      }
    } catch (error) {
      console.error("로딩 실패ㅠ", error);
    } finally {
      // 로딩 끝
      if (reqId === lastReqIdRef.current) setIsLoading(false);
    }
  };

  // 페이지 변경 핸들러 함수
  const handlePageChange = (newPage) => {
    if (newPage >= 1 && newPage <= paging.totalPages) {
      setPaging(prev => ({ ...prev, page: newPage }));
    }
  };

  // 검색 버튼 클릭 시
  const handleSearch = () => {
    if (paging.page === 1) {
      loadEmployees();
    } else {
      setPaging(prev => ({ ...prev, page: 1 }));
    }
  };

  // 모달 토글
  const toggleModal = (type, isOpen) => {
    setModals(prev => ({ ...prev, [type]: isOpen }));
  };

  // 엑셀 다운로드 함수
  const handleExcelDownload = async () => {
    try {
      await API.downloadExcel(filters);
    } catch (error) {
      alert("다운로드 실패");
    }
  };

  // 테이블의 행 클릭하면 계정에 대한 상세보기 모달 열리게 하기
  const openDetailModal = (employeeNo)=>{
    setSelectedEmNo(employeeNo);
    toggleModal('detail', true);
  }

  // 계정 생성/엑셀/수정 성공 후 처리
  const handleSuccess = () => {
    loadEmployees();
  };

  // 계정 퇴사 처리 핸들러
  const handleRetireClick = async(e, employeeNo)=>{
    // 행 누를때 상세 모달 뜨는 로직 막아줌
    e.stopPropagation();

    if(!window.confirm("퇴사 처리하시겠습니까?\n")) return;

    try{
      await API.retireEmployee(employeeNo);
      alert("퇴사 처리가 완료되었습니당");
      loadEmployees();

    }catch(error){
      alert("퇴사 처리 실패" + error.message);
    }
  };

  return (
    <>
      <style>{`.custom-scrollbar::-webkit-scrollbar { width: 4px; height: 4px; }
               .custom-scrollbar::-webkit-scrollbar-thumb { background-color: #e2e8f0; border-radius: 10px; }
                      input:focus, select:focus, textarea:focus { border-color: #3b82f6 !important; box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.1); }
                      .modal-overlay { background: rgba(0, 0, 0, 0.5); backdrop-filter: blur(4px); }
                      .custom-checkbox { width: 16px; height: 16px; accent-color: #3b82f6; cursor: pointer; }
                      .no-data { color: #ef4444 !important; font-weight: 800 !important; }`}
      </style>

      <section className="flex flex-col h-full rounded-2xl bg-white shadow-sm ring-1 ring-black/5 overflow-hidden text-zinc-950">
              {/* 검색 및 필터 영역 (상단 고정) */}
              <div className="p-5 border-b border-slate-100 bg-white shrink-0 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
                <div>
                  <h2 className="text-xl font-bold text-slate-900">직원 계정 전체 리스트</h2>
                  <p className="text-xs text-slate-400 mt-0.5 font-medium uppercase">Staff Directory</p>
                </div>

                {/* 직책 필터 */}
                <div className="flex flex-wrap gap-2 items-center">
                  {/* 배정 관리*/}
                  <button onClick={() => toggleModal("location", true)}
                          className="px-3 py-2 bg-white border border-slate-200 text-slate-600 rounded-xl text-xs font-bold hover:bg-slate-50 transition-all shadow-sm flex items-center gap-1">
                      시설 배정
                  </button>
                  <div className="flex items-center bg-slate-50 rounded-xl px-3 border border-slate-200 shadow-sm">
                    <span className="text-[10px] font-black text-blue-500 mr-1">직책</span>
                    <select value={filters.position}  className="bg-transparent py-2 text-xs font-bold text-slate-700 outline-none cursor-pointer"
                            onChange={(e) => {const v = e.target.value; console.log("[UI] position changed ->", v); setFilters({ ...filters, position: e.target.value}); setPaging(prev => ({ ...prev, page: 1 })); }}>
                      <option value="">전체</option>
                      <option value="1">의사</option>
                      <option value="2">외래간호사</option>
                      <option value="3">입원간호사</option>
                      <option value="4">약사</option>
                      <option value="5">방사선사</option>
                      <option value="6">물리치료사</option>
                      <option value="7">원무과</option>
                      <option value="0">관리자</option>
                    </select>
                  </div>

                  {/* 정렬 필터 */}
                  <div className="flex items-center bg-slate-50 rounded-xl px-3 border border-slate-200 shadow-sm">
                    <span className="text-[10px] font-black text-slate-400 mr-1">정렬</span>
                    <select value={filters.sort} className="bg-transparent py-2 text-xs font-bold text-slate-700 outline-none cursor-pointer"
                            onChange={(e) => {const v = e.target.value; console.log("[UI] sort changed ->", v); setFilters({ ...filters, sort: e.target.value}); setPaging(prev => ({ ...prev, page: 1 })); }}>
                      <option value="">전체 (퇴사자 포함)</option>
                      <option value="active">재직자</option>
                      <option value="retired">퇴사자</option>
                      <option value="date_desc">입사일 최신순</option>
                      <option value="date_asc">입사일 과거순</option>
                    </select>
                  </div>

                  {/* 검색창 */}
                  <div className="flex gap-1 ml-1 items-center">
                    <input type="text" placeholder="이름 혹은 사번" value={filters.keyword}
                      className="ml-2 px-4 py-2 bg-slate-50 border border-slate-200 rounded-xl text-xs font-bold outline-none focus:bg-white w-32 transition-all shadow-sm"
                      onChange={(e) => setFilters({ ...filters, keyword: e.target.value })}
                      onKeyDown={(e) => e.key === "Enter" && handleSearch()}/>
                    <button onClick={handleSearch} className="ml-1 mr-1 px-3 py-2 bg-slate-800 text-white rounded-xl text-xs font-bold hover:bg-black transition-colors">
                      검색
                    </button>
                    <div className="h-6 w-[1px] bg-slate-200 mx-1"></div>
                    {/* 계정 생성 버튼 */}
                    <button onClick={() => toggleModal("create", true)}
                      className="mr-1 ml-1 px-3 py-2 bg-blue-600 text-white rounded-xl text-xs font-bold hover:bg-blue-700 transition-all shadow-md shadow-blue-100">
                      + 계정 생성
                    </button>
                    <div className="h-6 w-[1px] bg-slate-200 mx-1"></div>
                    {/* 엑셀로 생성 버튼 */}
                    <button onClick={() => openExcelModal("upload")}
                      className="ml-2 px-3 py-2 bg-emerald-600 text-white rounded-xl text-xs font-bold hover:bg-emerald-700 transition-all shadow-md shadow-emerald-100"
                      >
                      일괄 생성하기
                    </button>
                      {/* 엑셀로 다운로드 버튼 */}
                    <button onClick={() => openExcelModal("download")}
                      className="px-3 py-2 bg-white border border-slate-200 text-slate-600 rounded-xl text-xs font-bold hover:bg-slate-50 transition-all shadow-sm">
                      일괄 다운로드
                    </button>
                  </div>
                </div>
              </div>

              {/* ====== 테이블 영역 ====== */}
              <div className="flex-1 overflow-auto custom-scrollbar bg-slate-50/30 text-zinc-950 relative">
                <table className="w-full text-left border-collapse table-fixed">
                  {/* 헤더 영역 */}
                  <thead className="bg-white border-b border-slate-100 z-10 shadow-sm text-slate-400 font-bold text-[12px] uppercase tracking-wider">
                    <tr>
                      <th className="px-4 py-4 w-[5%] text-center">번호</th>
                      <th className="px-4 py-4 w-[10%] text-center">사번</th>
                      <th className="px-4 py-4 w-[15%] text-center">이름</th>
                      <th className="px-4 py-4 w-[10%] text-center">직책</th>
                      <th className="px-4 py-4 w-[10%] text-center">성별</th>
                      <th className="px-4 py-4 w-[15%] text-center">이메일</th>
                      <th className="px-4 py-4 w-[15%] text-center">전화번호</th>
                      <th className="px-4 py-4 w-[10%] text-center">입사일</th>
                      <th className="px-4 py-4 w-[15%] text-center">퇴사 관리</th>
                    </tr>
                  </thead>

                  {/* 본문 영역 */}
                  <tbody className="divide-y divide-slate-100 bg-white">
                    {employees.length === 0 ? (
                      <tr>
                        <td colSpan="9" className="text-center py-20 text-slate-400 font-bold h-[500px]">데이터가 없습니다.</td>
                      </tr>
                    ) : (
                      employees.map((emp, index) => (
                        <tr key={emp.employeeNo} onClick={() => openDetailModal(emp.employeeNo)} className="hover:bg-blue-50/30 transition-colors cursor-pointer group">
                          
                          {/* 1 - 순번 */}
                          <td className="px-4 py-4 text-xs font-bold text-slate-500 text-center">
                            {(paging.page - 1) * paging.size + index + 1}
                          </td>

                          {/* 2 - 사번 */}
                          <td className="px-4 py-4 text-xs font-bold text-slate-700 text-center">
                            {emp.employeeNo} 
                          </td>
                          
                          {/* 3 - 이름 */}
                          <td className="px-4 py-4">
                            <div className="flex items-center justify-center gap-3">
                              {emp.fileNo ? ( <img src={`/api/employee/profile/${emp.fileNo}`} alt="profile" className="w-8 h-8 rounded-full object-cover border border-slate-200"
                                  onError={(e) => {e.target.style.display = 'none'; e.target.nextSibling.style.display = 'flex';}}/>
                              ) : (
                                <div className="w-8 h-8 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center text-xs font-bold shrink-0">
                                  {(POSITION_MAP[emp.employeeCode] || "?").charAt(0)}
                                </div>
                              )}
                              {/* 이미지 깨졌을 때 대체 텍스트 */}
                              <div className="hidden w-8 h-8 rounded-full bg-slate-100 text-slate-500 items-center justify-center text-xs font-bold shrink-0 border border-slate-200">
                                {(POSITION_MAP[emp.employeeCode] || "?").charAt(0)}
                              </div>

                              <div className="text-sm font-bold text-zinc-950">
                                {emp.employeeName}
                              </div>
                            </div>
                          </td>

                          {/* 4 - 직책 */}
                          <td className="px-4 py-4 text-center">
                            <span className="inline-block px-2 py-1 rounded bg-slate-100 text-slate-600 text-[11px] font-bold">
                              {POSITION_MAP[emp.employeeCode] || "오류 발생"}
                            </span>
                          </td>

                          {/* 5 - 성별 */}
                          <td className="px-4 py-4 text-xs text-slate-600 text-center">
                            {emp.employeeGen === 'M' ? '남성' : (emp.employeeGen === 'F' ? '여성' : emp.employeeGen)}
                          </td>


                          {/* 6 - 이메일 */}
                          <td className="px-4 py-4 text-xs text-slate-600 text-center">
                            {emp.employeeEmail || "안 넣음"}
                          </td>

                          {/* 7 - 전화번호 */}
                          <td className="px-4 py-4 text-xs font-bold text-slate-600 text-center">
                            {emp.employeeTel || "오류 발생"}
                          </td>

                          {/* 8 - 입사일 */}
                          <td className="px-4 py-4 text-xs font-bold text-slate-600 text-center">
                            {emp.employeeRegdate ? emp.employeeRegdate.substring(0, 10) : "-"}
                          </td>

                          {/* 9. 퇴사 관리 버튼 */}
                          <td className="px-4 py-4 text-center">
                            <div className="flex justify-center">
                              {emp.employeeStatus !== '002' ? (
                                <button onClick={(e) => handleRetireClick(e, emp.employeeNo)}
                                 className="px-3 py-1.5 rounded-lg border border-red-100 text-[11px] font-bold text-red-500 bg-red-50/50 hover:bg-red-100 hover:text-red-600 transition-colors z-20 relative">
                                  퇴사
                                </button>
                              ) : (
                              <span className="px-3 py-1.5 rounded-lg border border-slate-200 bg-slate-100 text-slate-400 text-[11px] font-bold select-none">
                                {emp.employeeRetdate ? emp.employeeRetdate.substring(0, 10) : "-"}
                              </span>)}
                            </div>
                          </td>
                        </tr>
                      ))
                    )}
                  </tbody>
                </table>
              </div>


              {/* 페이지네이션 영역 */}
              <div className="p-4 border-t border-slate-100 bg-white flex items-center justify-between shrink-0 z-20 relative">
                <span className="text-xs text-slate-500 font-bold">
                  총{" "}
                  <span className="text-blue-600">{paging.totalElements}</span>
                  명
                </span>

                <div className="flex items-center gap-1">
                  <button onClick={() => handlePageChange(paging.page - 1)} disabled={paging.page === 1}
                    className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed">
                    &lt;
                  </button>

                  {Array.from({ length: paging.totalPages }, (_, i) => i + 1)
                    .filter((num) => Math.abs(paging.page - num) < 3)
                    .map((num) => (
                      <button
                        key={num}
                        onClick={() => handlePageChange(num)}
                        disabled={isLoading} // 로딩 중엔 클릭 못하게 막기
                        className={`w-8 h-8 flex items-center justify-center rounded-lg text-xs font-bold transition-all ${
                          paging.page === num
                            ? "bg-blue-600 text-white shadow-md shadow-blue-200"
                            : "bg-white border border-slate-200 text-slate-600 hover:bg-slate-50"
                        }${isLoading ? "cursor-wait" : ""}`}
                      >
                        {num}
                      </button>
                    ))}
                    <button
                    onClick={() => handlePageChange(paging.page + 1)}
                    disabled={paging.page === paging.totalPages}
                    className="w-8 h-8 flex items-center justify-center rounded-lg border border-slate-200 text-slate-500 hover:bg-slate-50 disabled:opacity-50 disabled:cursor-not-allowed">
                  </button>
                </div>
              </div>
            </section>

          {/* 계정 생성 모달 */}
          <AccountCreateModal
            isOpen={modals.create}
            onClose={() => toggleModal('create', false)}
            onSuccess={handleSuccess}
          />

          {/* 엑셀 일괄 생성 */}
          <AccountExcelModal
            isOpen={modals.excel}
            onClose={() => toggleModal('excel', false)}
            filters={filters}         // 다운로드
            setFilters={setFilters}   // 다운로드의 필터 설정 바꾸기
            mode={excelMode}
            onSuccess={handleSuccess}
            />

          {/* 상세 조회 & 수정 모달 */}
          <AccountDetailModal
            isOpen={modals.detail}
            employeeNo={selectedEmNo}
            onClose={() => toggleModal('detail', false)}
            onChanged={() => loadEmployees()}
            onSuccess={handleSuccess}
          />

          {/* 배정 관리의 조회 & 수정 (입원간호사-병동, 의사-진료실) 모달 */}
          <LocationAssignmentModal
            isOpen={modals.location}
            onClose={() => toggleModal('location', false)}
            onSuccess={handleSuccess}
          />
    </>
  )
}

export default AccountManager