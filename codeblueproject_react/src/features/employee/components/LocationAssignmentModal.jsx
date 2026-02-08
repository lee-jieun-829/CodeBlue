import React, { useEffect, useState } from 'react'
import * as API from '../../../api/accountApi';

function LocationAssignmentModal({isOpen, onClose}) {
  
  const [activeTab, setActiveTab] = useState('nurse');
  const [locations, setLocations] = useState([]);
  const [loading, setLoading] = useState(false);

  const [candidates, setCandidates] = useState([]); 

  const [editLocation, setEditLocation] = useState(null);
  const [inputEmployeeNo, setInputEmployeeNo] = useState('');

  // 초기화 훅
  useEffect(() => {
    if(isOpen){
      loadData();
      loadCandidates(activeTab);
    }else{
      setEditLocation(null);
      setInputEmployeeNo('');
      setActiveTab('nurse');
      setCandidates([]);
    }
  }, [isOpen]);

  // 초기화 훅 
  useEffect(() => {
    if(isOpen) {
        loadCandidates(activeTab);
    }
  }, [activeTab]);

  // 데이터 로딩
  const loadData = async ()=>{
    
    setLoading(true);

    try{
      const res = await API.getLocationList();
      setLocations(res.data);
    }catch(error){
      alert("조회 실패");
    }finally{
      setLoading(false);
    }
  };

  const loadCandidates = async (tab) => {
  try {
    // 1) 목록 조회
    let params = { size: 1000, sort: "active" };
    if (tab === "doctor") params.position = "1";

    const res = await API.getEmployee(params);
    let list = res?.data?.content || [];

    // 2) authList 보강(목록에 없을 수 있음)
    const needEnrich = list.some((e) => e?.authList == null);
    if (needEnrich) {
      const details = await Promise.all(
        list.map(async (emp) => {
          try {
            const d = await API.getEmployeeDetail(emp.employeeNo);
            const detail = d?.data || {};
            return {
              ...emp,
              authList:
                detail.authList ||
                detail.employeeAuthList ||
                detail.authorities ||
                detail.auths ||
                emp.authList ||
                [],
            };
          } catch {
            return { ...emp, authList: emp.authList || [] };
          }
        })
      );
      list = details;
    }

    // 3) role 판별 (필드명 다양하게 대응)
    const hasRole = (emp, roleName) => {
      const raw =
        emp?.authList ||
        emp?.employeeAuthList ||
        emp?.authorities ||
        emp?.auths ||
        [];

      const arr = Array.isArray(raw) ? raw : [raw];

      return arr.some((item) => {
        if (typeof item === "string") return item === roleName || item.includes(roleName);
        const v = String(
          item?.auth ||
            item?.authority ||
            item?.roleCode ||
            item?.role ||
            item?.employeeAuth ||
            item?.employeeAuthCode ||
            ""
        );
        return v === roleName || v.includes(roleName);
      });
    };

    // 4) nurse 탭일 때만: "3은 기본 포함 + ROLE_NURSE_IN 포함"
    if (tab === "nurse") {
      const total = list.length;
      const cntCode3 = list.filter((e) => String(e?.employeeCode ?? "").includes("3")).length;
      const cntRole = list.filter((e) => hasRole(e, "ROLE_NURSE_IN")).length;

      console.log("[candidates][nurse] total:", total);
      console.log("[candidates][nurse] code has 3:", cntCode3);
      console.log("[candidates][nurse] has ROLE_NURSE_IN:", cntRole);
      console.log("[sample0]", list[0]);
      console.log(
        "[sample0 auth raw]",
        list[0]?.authList || list[0]?.employeeAuthList || list[0]?.authorities || list[0]?.auths
      );

      list = list.filter((emp) => {
        const code = String(emp?.employeeCode ?? "");
        return code.includes("3") || hasRole(emp, "ROLE_NURSE_IN");
      });

      console.log("[candidates][nurse] after filter:", list.length);
      
    }

    // ✅ setCandidates는 맨 마지막에 딱 1번만
    setCandidates(list);
  } catch (error) {
    console.error("로딩 실패", error);
  }
};



  const filterList = locations.filter(loc=>{
    if(!loc.locationCode) return false;
    if(activeTab === 'nurse') return loc.locationCode.startsWith('WARD');
    if(activeTab === 'doctor') return loc.locationCode.startsWith('DOC');

    return true;
  });

  // 저장하기
  const handleSave = async(targetLoc)=>{
    if (!inputEmployeeNo) return alert("사번을 입력해주세요.");

    // 바꾸기전에 확인사살
    if (targetLoc.employeeNo && String(targetLoc.employeeNo) !== inputEmployeeNo) {
      // 선택된 사람 이름 찾기
      const selectedEmp = candidates.find(c => String(c.employeeNo) === inputEmployeeNo);
      const newName = selectedEmp ? selectedEmp.employeeName : inputEmployeeNo;

      const confirmMsg = `현재 담당자: ${targetLoc.employeeName || '오류 발생'}(${targetLoc.employeeNo})\n변경 대상자: ${newName}\n\n정말로 담당자를 변경하시겠습니까?`;
      if (!window.confirm(confirmMsg)) {
          return; // 취소 누르면 중단
      }
    }

  try {
      const data = {
        locationNo: targetLoc.locationNo,
        employeeNo: parseInt(inputEmployeeNo)
      };

      await API.saveEmployeeLocation(data);
      
      // 성공 시
      alert("배정이 완료되었습니다.");
      await loadData();
      setEditLocation(null);
      setInputEmployeeNo('');
      
    } catch (error) {
      console.error(error);
      alert("저장 실패");
    }
  };

  // 수정하기
  const startEdit = (loc) => {
    setEditLocation(loc.locationNo);
    setInputEmployeeNo(loc.employeeNo ? String(loc.employeeNo) : '');
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 modal-overlay z-50 flex items-center justify-center">
      
      <div className="bg-white w-[1000px] max-h-[90vh] rounded-[2rem] shadow-2xl overflow-hidden flex flex-col animate-in fade-in zoom-in duration-200 text-zinc-950">
        
        {/* 헤더 */}
        <div className="p-6 border-b border-slate-100 bg-white shrink-0 flex justify-between items-center">
          <div>
            <h3 className="text-lg font-bold text-slate-900">시설 및 담당자 배정 관리</h3>
            <p className="text-[10px] text-slate-400 font-medium">진료실 및 병동의 담당자를 선택하여 배정합니다.</p>
          </div>
          <button onClick={onClose} className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-slate-100 text-slate-400 transition-colors">
            ✕
          </button>
        </div>

        {/* 탭 */}
        <div className="px-6 border-b border-slate-100 bg-slate-50/50 shrink-0">
          <div className="flex gap-6">
            <button
              onClick={() => { setActiveTab('nurse'); setEditLocation(null); }}
              className={`py-4 text-sm font-bold border-b-[3px] transition-all flex items-center gap-2 ${
                activeTab === 'nurse' 
                  ? 'border-purple-600 text-purple-600' 
                  : 'border-transparent text-slate-400 hover:text-slate-600'
              }`}
            >
              🏥 입원 병동
            </button>
            <button
              onClick={() => { setActiveTab('doctor'); setEditLocation(null); }}
              className={`py-4 text-sm font-bold border-b-[3px] transition-all flex items-center gap-2 ${
                activeTab === 'doctor' 
                  ? 'border-blue-600 text-blue-600' 
                  : 'border-transparent text-slate-400 hover:text-slate-600'
              }`}
            >
              🩺 진료실
            </button>
          </div>
        </div>

        {/* 메인 컨텐츠 */}
        <div className="flex-1 overflow-y-auto custom-scrollbar p-8 bg-white">
          {loading ? (
             <div className="h-full flex flex-col items-center justify-center text-slate-400 font-bold min-h-[300px]">
               데이터를 불러오는 중입니다...
             </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
              {filterList.map((loc) => {
                const isEditing = editLocation === loc.locationNo; // 변수명 유지
                const isAssigned = !!loc.employeeNo;
                
                const themeColor = activeTab === 'nurse' ? 'purple' : 'blue';
                const borderColor = isEditing 
                   ? (activeTab === 'doctor' ? 'border-blue-500 ring-2 ring-blue-100' : 'border-purple-500 ring-2 ring-purple-100')
                   : 'border-slate-200';

                return (
                  <div key={loc.locationNo} className={`rounded-2xl border ${borderColor} p-5 flex flex-col gap-4 shadow-sm hover:shadow-md transition-all group bg-white`}>
                     {/* 카드 헤더 */}
                    <div className="mb-1">
                        <h4 className="text-lg font-bold text-slate-800">{loc.locationName}</h4>
                    </div>

                    {/* 카드 바디 */}
                    <div className="flex-1 flex flex-col justify-center min-h-[70px]">
                      {isEditing ? (
                        <div className="animate-in fade-in duration-200 w-full">
                          <label className="text-[10px] font-bold text-slate-400 mb-1.5 block">담당자 선택</label>
                          <div className="flex gap-2">
                             <select 
                               value={inputEmployeeNo} 
                               onChange={(e) => setInputEmployeeNo(e.target.value)}
                               className={`w-full h-10 px-3 rounded-xl border border-slate-200 text-sm font-bold focus:outline-none transition-all cursor-pointer ${
                                   activeTab==='doctor' ? 'focus:border-blue-500' : 'focus:border-purple-500'
                               }`}
                             >
                                <option value="">선택하세요</option>
                                {candidates.map((emp) => (
                                    <option key={emp.employeeNo} value={emp.employeeNo}>
                                        {emp.employeeName} ({emp.employeeNo})
                                    </option>
                                ))}
                             </select>
                          </div>
                          <div className="flex gap-2 mt-3">
                            <button 
                              onClick={() => handleSave(loc)}
                              className={`flex-1 py-2 rounded-xl text-xs font-bold text-white shadow-sm transition-colors ${
                                  activeTab === 'doctor' ? 'bg-blue-600 hover:bg-blue-700' : 'bg-purple-600 hover:bg-purple-700'
                              }`}
                            >
                              저장
                            </button>
                            <button 
                              onClick={() => setEditLocation(null)}
                              className="flex-1 py-2 rounded-xl text-xs font-bold bg-white border border-slate-200 text-slate-500 hover:bg-slate-50 transition-colors"
                            >
                              취소
                            </button>
                          </div>
                        </div>
                      ) : (
                        // [조회 모드]
                        <div className="flex items-center gap-4">
                           <div className={`w-12 h-12 rounded-2xl flex items-center justify-center shrink-0 transition-colors ${
                               isAssigned 
                               ? (activeTab==='doctor'?'bg-blue-50 text-blue-500':'bg-purple-50 text-purple-500') 
                               : 'bg-slate-100 text-slate-300'
                           }`}>
                              <span className="text-xl">👤</span>
                           </div>
                           
                           <div className="flex-1 min-w-0">
                              {isAssigned ? (
                                <>
                                  <p className="text-[10px] text-slate-400 font-bold uppercase tracking-wider mb-0.5">담당 직원</p>
                                  <p className="text-md font-bold text-slate-800 truncate">
                                    {loc.employeeName || '이름 없음'}
                                    <span className="ml-1 text-slate-400 font-medium text-xs">({loc.employeeNo})</span>
                                  </p>
                                </>
                              ) : (
                                <p className="text-sm text-slate-400 font-bold">담당자가 없습니다.</p>
                              )}
                           </div>
                        </div>
                      )}
                    </div>

                    {/* 담당자 변경 */}
                     {!isEditing && (
                      <button onClick={() => startEdit(loc)}
                        className="w-full py-2.5 rounded-xl border border-dashed border-slate-300 bg-white text-xs font-bold text-slate-400 hover:text-slate-600 hover:border-slate-400 hover:bg-slate-50 transition-all"
                      >
                        담당자 변경
                      </button>
                    )}
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>
    </div>
  )
}

export default LocationAssignmentModal