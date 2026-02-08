import React, { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import Swal from 'sweetalert2';

/**
 * MacroPage.jsx
 * 
 * 작성자 : 윤여범
 * 역할 : 관리자 매크로 - 목록 조회 & 각 기능(모달)들 조립
 * 
 * 모달 종류
 * 1) 매크로 등록
 * 2) 매크로 조회 & 수정
 * 3) 처방 코드, 약제처방, 치료 모달
 */

// --- [외부 컴포넌트 임포트] ---
import Header from "../../components/layout/Header.jsx";
import LeftAdmin from "../../components/layout/LeftAdmin.jsx";

// --- [아이콘 임포트] ---
import { 
  BarChart2, User, Monitor, FileText, Package, Megaphone, Calendar as CalendarIcon, 
  Search, Home, Bell, 
  Settings, LayoutGrid, Stethoscope, Pill, Activity, Users, 
  Plus, X, ChevronRight, Trash2, CheckSquare, Square // 체크박스 아이콘 추가
} from 'lucide-react';

// --- [설정] ---
const API_BASE_URL = 'http://localhost:8060/api/macro';
const CURRENT_USER_ID = 26020908; 

// --- [상수 데이터] ---
const MACRO_CATEGORIES = [
  { id: 'ALL', label: '전체 나의 오더 조회', icon: <LayoutGrid size={16} /> },
  { id: '001', label: '의사 전용 세트', icon: <Stethoscope size={16} /> }, 
  { id: '002', label: '입원간호사 세트', icon: <Users size={16} /> },
];

/**
 * [내부 컴포넌트] 의료 정보 검색 모달 (다중 선택 기능 적용)
 */
const MedicalSearchModal = ({ isOpen, onClose, type, onSelectBatch }) => {
  const [keyword, setKeyword] = useState('');
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(false);
  
  // 다중 선택을 관리할 상태 추가
  const [selectedItems, setSelectedItems] = useState([]);

  // [수정] 모달 열릴 때 초기화 및 리스트 즉시 조회
  useEffect(() => {
    if (isOpen) {
      setKeyword('');
      setResults([]);
      setSelectedItems([]); // 선택 목록 초기화
      searchData(''); // 검색어 없이 바로 조회 호출
    }
  }, [isOpen]);

  const handleKeyDown = (e) => {
    if (e.key === 'Enter') searchData(keyword);
  };

  const searchData = async (searchKeyword = keyword) => {
    // 빈 키워드 체크 로직 제거 (전체 조회)
    setLoading(true);
    
    let endpoint = '';
    switch(type) {
      case 'DIAGNOSIS': endpoint = '/diagnosis/search'; break;
      case 'DRUG': endpoint = '/drug/search'; break;
      case 'TREATMENT': endpoint = '/treatment/search'; break;
      default: setLoading(false); return;
    }

    try {
      const response = await axios.get(`${API_BASE_URL}${endpoint}`, {
        params: { keyword: searchKeyword }
      });
      setResults(response.data || []);
    } catch (error) {
      console.error("검색 실패:", error);
      // 필요 시 에러 알림
    } finally {
      setLoading(false);
    }
  };

  // 아이템 선택/해제 토글 함수
  const toggleSelection = (item) => {
    const codeKey = type === 'DIAGNOSIS' ? 'diagnosisCode' : 
                    type === 'DRUG' ? 'drugCode' : 'treatmentCode';

    setSelectedItems(prev => {
      const exists = prev.some(i => i[codeKey] === item[codeKey]);
      if (exists) {
        return prev.filter(i => i[codeKey] !== item[codeKey]); // 이미 있으면 제거
      } else {
        return [...prev, item]; // 없으면 추가
      }
    });
  };

  // 선택 여부 확인 함수
  const isSelected = (item) => {
    const codeKey = type === 'DIAGNOSIS' ? 'diagnosisCode' : 
                    type === 'DRUG' ? 'drugCode' : 'treatmentCode';
    return selectedItems.some(i => i[codeKey] === item[codeKey]);
  };

  // 선택 완료 버튼 핸들러
  const handleComplete = () => {
    if (selectedItems.length === 0) {
      Swal.fire("알림", "선택된 항목이 없습니다.", "warning");
      return;
    }
    onSelectBatch(selectedItems, type); // 부모 컴포넌트에 리스트 전달
    onClose();
  };

  if (!isOpen) return null;

  // 상병(진단)코드, 약제 처방, 치료 검색
  const getTitle = () => {
    switch(type) {
      case 'DIAGNOSIS': return '상병(진단) 코드 검색';
      case 'DRUG': return '약제 검색';
      case 'TREATMENT': return '치료 항목 검색';
      default: return '검색';
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-900/50 backdrop-blur-sm">
      <div className="bg-white w-[600px] h-[750px] rounded-2xl shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in duration-200">
        {/* 모달 헤더 */}
        <div className="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white">
          <h3 className="text-lg font-bold text-slate-800">{getTitle()}</h3>
          <button onClick={onClose} className="p-2 hover:bg-slate-100 rounded-full transition-colors">
            <X size={20} className="text-slate-500" />
          </button>
        </div>

        {/* 검색 입력창 */}
        <div className="p-6 bg-slate-50 border-b border-slate-100">
          <div className="relative">
            <input 
              type="text" 
              value={keyword}
              onChange={(e) => setKeyword(e.target.value)}
              onKeyDown={handleKeyDown}
              placeholder="코드 또는 명칭을 입력하세요..." 
              className="w-full pl-10 pr-20 py-3 border border-slate-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none shadow-sm"
              autoFocus
            />
            <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 text-slate-400" size={18} />
            <button 
              onClick={() => searchData(keyword)}
              className="absolute right-2 top-1/2 -translate-y-1/2 px-4 py-1.5 bg-blue-600 text-white text-xs font-bold rounded-lg hover:bg-blue-700 transition-colors"
            >
              검색
            </button>
          </div>
        </div>

        {/* 검색 결과 리스트 */}
        <div className="flex-1 overflow-y-auto p-4 bg-white">
          {loading ? (
            <div className="h-full flex flex-col items-center justify-center text-slate-400 gap-2">
               <div className="w-6 h-6 border-2 border-slate-200 border-t-blue-600 rounded-full animate-spin"></div>
               <span className="text-xs">데이터를 불러오는 중...</span>
            </div>
          ) : results.length === 0 ? (
            <div className="h-full flex flex-col items-center justify-center text-slate-400">
              <Search size={48} className="mb-4 text-slate-200" />
              <p className="text-sm font-medium">검색 결과가 없습니다.</p>
            </div>
          ) : (
            <div className="space-y-2">
              {results.map((item, index) => {
                const checked = isSelected(item);
                return (
                  <div 
                    key={index} 
                    className={`flex items-center justify-between p-4 border rounded-xl cursor-pointer transition-all ${
                        checked 
                        ? 'border-blue-500 bg-blue-50 ring-1 ring-blue-500' 
                        : 'border-slate-100 hover:bg-slate-50'
                    }`}
                    onClick={() => toggleSelection(item)}
                  >
                    <div className="flex items-center gap-3 w-full">
                      {/* 체크박스 UI */}
                      <div className={`shrink-0 ${checked ? 'text-blue-600' : 'text-slate-300'}`}>
                        {checked ? <CheckSquare size={20} /> : <Square size={20} />}
                      </div>

                      <div className="flex flex-col flex-1">
                        {type === 'DIAGNOSIS' && (
                          <>
                            <span className="text-xs font-bold text-blue-600 mb-0.5">{item.diagnosisCode}</span>
                            <span className="text-sm font-medium text-slate-700">{item.diagnosisName}</span>
                          </>
                        )}
                        {type === 'DRUG' && (
                          <>
                            <span className="text-xs font-bold text-orange-500 mb-0.5">{item.drugCode}</span>
                            <span className="text-sm font-medium text-slate-700">{item.drugName}</span>
                            <span className="text-[10px] text-slate-400 mt-1">{item.drugCompany} | {item.drugUnit}</span>
                          </>
                        )}
                        {type === 'TREATMENT' && (
                          <>
                            <span className="text-xs font-bold text-green-600 mb-0.5">{item.treatmentCode}</span>
                            <span className="text-sm font-medium text-slate-700">{item.treatmentName}</span>
                            <span className="text-[10px] text-slate-400 mt-1">
                              수가: {item.treatmentPrice?.toLocaleString()}원
                            </span>
                          </>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {/* [수정] 하단 선택 완료 버튼 영역 */}
        <div className="p-4 border-t border-slate-100 bg-white">
          <button 
            onClick={handleComplete}
            disabled={selectedItems.length === 0}
            className="w-full py-3 bg-blue-600 hover:bg-blue-700 disabled:bg-slate-200 disabled:text-slate-400 disabled:cursor-not-allowed text-white rounded-xl text-sm font-bold shadow-md transition-all flex items-center justify-center gap-2"
          >
            <Plus size={18} />
            <span>선택한 {selectedItems.length}개 항목 추가하기</span>
          </button>
        </div>
      </div>
    </div>
  );
};

// --- [메인 페이지 컴포넌트] ---
export default function MacroPage() {
  const [macroList, setMacroList] = useState([]); 
  const [selectedCategory, setSelectedCategory] = useState('ALL'); 
  const [searchTerm, setSearchTerm] = useState(''); 
  
  // 폼 데이터
  const [formData, setFormData] = useState({
    macroNo: 0,
    macroName: '',
    macroType: '001', 
    macroContent: '',
    employeeNo: CURRENT_USER_ID
  });

  // 선택된 의료 항목들 (의사 전용)
  const [selectedMedicalItems, setSelectedMedicalItems] = useState({
    diagnosis: [],
    drug: [],
    treatment: []
  });

  // 모달 설정
  const [modalConfig, setModalConfig] = useState({
    isOpen: false,
    type: null 
  });

  // 1. 매크로 목록 조회
  const fetchMacros = useCallback(async () => {
    try {
      const response = await axios.get(`${API_BASE_URL}/list`, {
        params: { employeeNo: CURRENT_USER_ID }
      });
      setMacroList(response.data || []);
    } catch (error) {
      console.error("로드 실패:", error);
    }
  }, []);

  useEffect(() => {
    fetchMacros();
  }, [fetchMacros]);

  // 2. 저장 로직 (Swal 사용)
  const handleSave = async () => {
    if (!formData.macroName.trim()) return Swal.fire("알림", "오더 명칭을 입력해주세요.", "warning");
    
    try {
      const url = formData.macroNo === 0 ? `${API_BASE_URL}/add` : `${API_BASE_URL}/update`;
      
      const payload = {
        macroNo: formData.macroNo,
        macroName: formData.macroName,
        macroType: formData.macroType,
        macroContent: formData.macroContent,
        employeeNo: Number(formData.employeeNo), 
        
        diagnosisList: selectedMedicalItems.diagnosis,    
        drugList: selectedMedicalItems.drug,              
        treatmentList: selectedMedicalItems.treatment     
      };
      
      await axios.post(url, payload);
      
      Swal.fire("성공", formData.macroNo === 0 ? "등록되었습니다." : "수정되었습니다.", "success");
      fetchMacros();
      
      if (formData.macroNo === 0) handleNewMacro();

    } catch (error) {
      console.error("저장 오류:", error);
      Swal.fire("오류", "저장 중 문제가 발생했습니다.", "error");
    }
  };

  // 3. 상세 조회 (수정 모드 진입)
  const handleSelectMacro = async (macro) => {
    setFormData({ 
        macroNo: macro.macroNo,
        macroName: macro.macroName,
        macroType: macro.macroType,
        macroContent: macro.macroContent || '',
        employeeNo: macro.employeeNo
    });

    try {
      const response = await axios.get(`${API_BASE_URL}/detail/${macro.macroNo}`);
      const detailData = response.data; 

      if (detailData.macroDetails && Array.isArray(detailData.macroDetails)) {
        const newSelected = { diagnosis: [], drug: [], treatment: [] };

        detailData.macroDetails.forEach(detail => {
            const type = detail.macroDetailType;
            const nameValue = detail.macroDetailPrename;

            if (type === 'DIAGNOSIS') {
                newSelected.diagnosis.push({ 
                    diagnosisName: nameValue, 
                    diagnosisCode: nameValue 
                });
            } else if (type === 'DRUG') {
                newSelected.drug.push({ 
                    drugName: nameValue, 
                    drugCode: nameValue, 
                    drugCompany: '', drugUnit: '' 
                });
            } else if (type === 'TREATMENT') {
                newSelected.treatment.push({ 
                    treatmentName: nameValue, 
                    treatmentCode: nameValue, 
                    treatmentPrice: 0 
                });
            }
        });

        setSelectedMedicalItems(newSelected);

      } else {
        // 기존 구조 호환
        setSelectedMedicalItems({
          diagnosis: detailData.diagnosisList || [],
          drug: detailData.drugList || detailData.searchDrugList || [], 
          treatment: detailData.treatmentList || detailData.searchTreatmentList || []
        });
      }

    } catch (error) {
      console.error("상세 정보 로드 실패:", error);
      setSelectedMedicalItems({ diagnosis: [], drug: [], treatment: [] });
    }
  };

  // 4. 삭제 로직
  const handleDelete = async (macroNo, e) => {
    e.stopPropagation();
    
    const result = await Swal.fire({
      title: '삭제하시겠습니까?',
      text: "삭제된 오더는 복구할 수 없습니다.",
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: '삭제',
      cancelButtonText: '취소'
    });

    if (result.isConfirmed) {
      try {
        await axios.post(`${API_BASE_URL}/delete/${macroNo}`); 
        Swal.fire("삭제됨", "오더가 삭제되었습니다.", "success");
        fetchMacros();
        if (formData.macroNo === macroNo) handleNewMacro();
      } catch (error) {
        Swal.fire("실패", "삭제 중 오류가 발생했습니다.", "error");
      }
    }
  };

  // 초기화 (새 매크로)
  const handleNewMacro = () => {
    setFormData({
      macroNo: 0, 
      macroName: '', 
      macroType: '001', 
      macroContent: '',
      employeeNo: CURRENT_USER_ID
    });
    setSelectedMedicalItems({ diagnosis: [], drug: [], treatment: [] });
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const openSearchModal = (type) => {
    setModalConfig({ isOpen: true, type: type });
  };

  const closeSearchModal = () => {
    setModalConfig({ isOpen: false, type: null });
  };

  // [수정] 다중 항목 처리 핸들러
  const handleBatchSelect = (items, type) => {
    const categoryKey = type.toLowerCase(); 
    
    setSelectedMedicalItems(prev => {
        const codeKey = type === 'DIAGNOSIS' ? 'diagnosisCode' : 
                        type === 'DRUG' ? 'drugCode' : 'treatmentCode';
        
        // 중복 제거 후 병합
        const currentList = prev[categoryKey];
        const newItems = items.filter(newItem => 
            !currentList.some(existingItem => existingItem[codeKey] === newItem[codeKey])
        );
        
        return {
            ...prev,
            [categoryKey]: [...currentList, ...newItems]
        };
    });

    // Swal.fire("추가됨", `${items.length}개 항목이 추가되었습니다.`, "success"); // 필요시 주석 해제
  };

  const removeMedicalItem = (category, index) => {
    setSelectedMedicalItems(prev => ({
        ...prev,
        [category]: prev[category].filter((_, i) => i !== index)
    }));
  };

  const getContentLabel = (type) => {
    switch(type) {
      case '001': return '기본 오더 멘트 (진료 기록용)'; 
      case '002': return '간호 기록 양식'; 
      default: return '나의 오더 상세 내용';
    }
  };

  const filteredList = macroList.filter(item => {
    if (!item || !item.macroName) return false;
    const matchSearch = item.macroName.toLowerCase().includes(searchTerm.toLowerCase());
    const matchCategory = selectedCategory === 'ALL' || item.macroType === selectedCategory;
    return matchSearch && matchCategory;
  });


  return (
    <div className="flex flex-col h-screen bg-slate-50 font-sans text-slate-800">
      
      {/* 모달 */}
      <MedicalSearchModal 
        isOpen={modalConfig.isOpen}
        onClose={closeSearchModal}
        type={modalConfig.type}
        onSelectBatch={handleBatchSelect} // [수정] 다중 선택 핸들러 전달
      />

      {/* 1. Header (임포트한 컴포넌트 사용) */}
       <header className='h-16 w-full bg-white border-b border-neutral-200 shrink-0'>
          <Header />
        </header>
        
        <div className="main-container body flex flex-1 w-full overflow-hidden">
          {/* --- 사이드바 --- */}
         <aside className="side-bar flex w-28 shrink-0 flex-col border-r border-neutral-200 bg-white overflow-y-auto custom-scrollbar">
            <LeftAdmin />
          </aside>

        {/* 3. Category Menu (매크로 전용 사이드바) */}
        <aside className="w-[240px] bg-white border-r border-slate-200 mx-4 my-6 flex flex-col py-6 px-4 shrink-0 overflow-y-auto">
          <div className="mb-6 pl-2 border-l-4 border-blue-600 h-4 flex items-center">
            <h2 className="text-sm font-bold text-slate-900 leading-none">나의 오더 관리 메뉴</h2>
          </div>
          <div className="flex flex-col gap-1">
            {MACRO_CATEGORIES.map((cat) => (
              <button key={cat.id} onClick={() => setSelectedCategory(cat.id)} 
                  className={`w-full text-left px-4 py-3.5 rounded-lg text-[13px] flex items-center
                            justify-between transition-all ${selectedCategory === cat.id ? 
                              'bg-blue-50 text-blue-600 font-bold shadow-sm' :
                                'text-slate-500 font-medium hover:bg-slate-50'}`}>
                <div className="flex items-center gap-2">
                   {cat.icon}
                   <span>{cat.label}</span>
                </div>
                {selectedCategory === cat.id && <ChevronRight size={14} className="text-blue-600"/>}
              </button>
            ))}
          </div>
        </aside>

        {/* 4. List Section (목록) */}
        <section className="w-[320px] bg-white border-r border-slate-200 my-6 flex flex-col shrink-0">
          <div className="p-6 border-b border-slate-100 bg-white">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-lg font-bold text-slate-900">나의 오더 목록</h2>
              <button onClick={handleNewMacro} className="text-blue-600 text-[11px] font-bold hover:underline flex items-center">
                <Plus size={12} className="mr-0.5" /> 새 나의 오더
              </button>
            </div>
            <div className="relative">
              <input type="text" placeholder="오더 검색..." value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} className="w-full pl-9 pr-3 py-2.5 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-100 transition-all placeholder:text-slate-400" />
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={16} />
            </div>
          </div>
          <div className="flex-1 overflow-y-auto p-4 space-y-3 bg-white">
            {filteredList.length === 0 ? (
              <div className="text-center py-10 text-slate-400 text-xs">등록된 오더가 없습니다.</div>
            ) : (
              filteredList.map((macro) => (
                <div key={macro.macroNo} onClick={() => handleSelectMacro(macro)} className={`p-5 rounded-xl border transition-all cursor-pointer group hover:shadow-md ${formData.macroNo === macro.macroNo ? 'bg-white border-blue-500 ring-1 ring-blue-500 shadow-sm' : 'bg-white border-slate-200 hover:border-blue-200'}`}>
                  <div className="flex items-center gap-1.5 mb-2">
                    {macro.macroType === '001' ? <Stethoscope size={12} className="text-slate-500" /> : <Monitor size={12} className="text-slate-500" />}
                    <span className="text-[11px] font-bold text-slate-500">{MACRO_CATEGORIES.find(c => c.id === macro.macroType)?.label.replace(' 세트', '') || macro.macroType}</span>
                  </div>
                  <h3 className="font-bold text-slate-800 text-sm mb-4 leading-tight">{macro.macroName}</h3>
                  <div className="flex gap-3 text-[11px] font-medium">
                    <button onClick={(e) => {e.stopPropagation(); handleSelectMacro(macro);}} className="text-blue-600 hover:underline">수정</button>
                    <button onClick={(e) => handleDelete(macro.macroNo, e)} className="text-red-500 hover:underline">삭제</button>
                  </div>
                </div>
              ))
            )}
          </div>
        </section>

        {/* 5. Main Form Section (에디터) */}
        <main className="flex-1 bg-white mx-4 my-6 flex flex-col min-w-[600px] overflow-hidden">
          <div className="h-[72px] px-8 border-b border-slate-100 flex items-center justify-between shrink-0">
            <div>
              <h2 className="text-xl font-bold text-slate-900 mb-1">{formData.macroNo === 0 ? "새 나의 오더 생성" : "나의 오더 수정"}</h2>
              <p className="text-[10px] text-slate-400 font-bold tracking-widest uppercase">MACRO CONTENT CONFIGURATION</p>
            </div>
            <button onClick={handleSave} className="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-bold shadow-md shadow-blue-200/50 transition-all flex items-center gap-1.5">
              저장 및 등록
            </button>
          </div>

          <div className="flex-1 overflow-y-auto p-8 bg-white relative">
            <div className="grid grid-cols-12 gap-x-8 gap-y-8">
              
              {/* 공통 입력: 사용자 그룹, 매크로 명칭 */}
              <div className="col-span-4">
                <label className="block text-xs font-bold text-slate-500 mb-2.5">사용자 그룹 선택</label>
                <div className="relative">
                  <select name="macroType" value={formData.macroType} onChange={handleInputChange} className="w-full p-3 pl-4 bg-white border border-slate-200 rounded-lg text-sm font-bold text-slate-700 focus:ring-2 focus:ring-blue-500 outline-none appearance-none cursor-pointer shadow-sm">
                    {MACRO_CATEGORIES.filter(c => c.id !== 'ALL').map(cat => (
                      <option key={cat.id} value={cat.id}>{cat.label}</option>
                    ))}
                  </select>
                  <div className="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400"><Settings size={14} /></div>
                </div>
              </div>

              <div className="col-span-8">
                <label className="block text-xs font-bold text-slate-500 mb-2.5">나의 오더 명칭</label>
                <input type="text" name="macroName" value={formData.macroName} onChange={handleInputChange} placeholder="나의 오더입력하세요" className="w-full p-3 bg-slate-50 border border-slate-200 rounded-lg text-sm font-medium focus:bg-white focus:ring-2 focus:ring-blue-500 outline-none transition-all placeholder:text-slate-400" />
              </div>

              {formData.macroType === '001' ? (
                // --- 의사(001) 레이아웃: 에디터 + 우측 박스 ---
                <>
                  <div className="col-span-7 flex flex-col h-full">
                    <label className="block text-xs font-bold text-slate-500 mb-2.5">기본 오더 멘트 (진료 기록용)</label>
                    <textarea name="macroContent" value={formData.macroContent} onChange={handleInputChange} className="w-full min-h-[500px] flex-1 p-6 bg-white border border-slate-200 rounded-2xl text-sm leading-7 text-slate-700 resize-none focus:ring-2 focus:ring-blue-500 outline-none shadow-sm" placeholder="자주 사용하는 진료 기록 내용을 입력하세요..."></textarea>
                  </div>
                  <div className="col-span-5 flex flex-col gap-5">
                    {/* 상병코드 섹션 */}
                    <div className="border border-slate-200 rounded-2xl p-5 bg-white shadow-[0_2px_8px_rgba(0,0,0,0.02)]">
                      <div className="flex justify-between items-center mb-4">
                        <span className="text-xs font-bold text-slate-700 flex items-center gap-1.5">
                            <Activity size={14} className="text-blue-500"/> 상병 코드
                        </span>
                        <button onClick={() => openSearchModal('DIAGNOSIS')} className="text-[11px] text-blue-600 font-bold hover:underline bg-blue-50 px-2 py-1 rounded-md transition-colors">+ 검색</button>
                      </div>
                      <div className="min-h-[80px] bg-slate-50 rounded-xl border border-slate-100 p-2 space-y-2">
                        {selectedMedicalItems.diagnosis.length === 0 ? (
                            <div className="h-full flex items-center justify-center text-[11px] font-medium text-slate-400 py-4">등록된 상병이 없습니다.</div>
                        ) : (
                            selectedMedicalItems.diagnosis.map((item, idx) => (
                                <div key={idx} className="flex justify-between items-center bg-white p-2.5 rounded-lg border border-slate-200 shadow-sm">
                                    <div className="flex flex-col">
                                        <span className="text-[10px] font-bold text-blue-600">{item.diagnosisCode}</span>
                                        <span className="text-xs font-medium text-slate-700">{item.diagnosisName}</span>
                                    </div>
                                    <button onClick={() => removeMedicalItem('diagnosis', idx)} className="text-slate-300 hover:text-red-500"><Trash2 size={14}/></button>
                                </div>
                            ))
                        )}
                      </div>
                    </div>

                    {/* 약제 처방 섹션 */}
                    <div className="border border-slate-200 rounded-2xl p-5 bg-white shadow-[0_2px_8px_rgba(0,0,0,0.02)]">
                      <div className="flex justify-between items-center mb-4">
                        <span className="text-xs font-bold text-slate-700 flex items-center gap-1.5">
                            <Pill size={14} className="text-orange-500"/> 약제 처방
                        </span>
                        <button onClick={() => openSearchModal('DRUG')} className="text-[11px] text-blue-600 font-bold hover:underline bg-blue-50 px-2 py-1 rounded-md transition-colors">+ 추가</button>
                      </div>
                      <div className="min-h-[100px] bg-slate-50 rounded-xl border border-slate-100 p-2 space-y-2">
                        {selectedMedicalItems.drug.length === 0 ? (
                            <div className="h-full flex items-center justify-center text-[11px] font-medium text-slate-400 py-6">등록된 약제가 없습니다.</div>
                        ) : (
                             selectedMedicalItems.drug.map((item, idx) => (
                                <div key={idx} className="flex justify-between items-center bg-white p-2.5 rounded-lg border border-slate-200 shadow-sm">
                                    <div className="flex flex-col">
                                        <span className="text-[10px] font-bold text-orange-500">{item.drugCode}</span>
                                        <span className="text-xs font-medium text-slate-700">{item.drugName}</span>
                                    </div>
                                    <button onClick={() => removeMedicalItem('drug', idx)} className="text-slate-300 hover:text-red-500"><Trash2 size={14}/></button>
                                </div>
                            ))
                        )}
                      </div>
                    </div>

                    {/* 치료 섹션 */}
                    <div className="border border-slate-200 rounded-2xl p-4 bg-white shadow-[0_2px_8px_rgba(0,0,0,0.02)] min-h-[160px] flex flex-col">
                      <div className="flex justify-between items-center mb-3">
                        <span className="text-xs font-bold text-slate-600 flex items-center gap-1.5">
                          {/* [수정] 요청하신 아이콘 추가 */}
                          <i className="icon icon-tag-plus"></i> 
                          치료
                        </span>
                        <button onClick={() => openSearchModal('TREATMENT')} className="text-[10px] bg-slate-100 px-1.5 py-0.5 rounded font-bold text-slate-500 hover:text-blue-600">+ 추가</button>
                      </div>
                      <div className="flex-1 bg-slate-50 rounded-lg p-2 space-y-1.5 overflow-y-auto max-h-[120px]">
                          {selectedMedicalItems.treatment.length === 0 ? (
                              <div className="h-full flex items-center justify-center text-[10px] text-slate-400">내역 없음</div>
                          ) : (
                              selectedMedicalItems.treatment.map((item, idx) => (
                                  <div key={idx} className="bg-white p-2 rounded border border-slate-200 text-xs flex justify-between items-start">
                                      <span>{item.treatmentName}</span>
                                      <button onClick={() => removeMedicalItem('treatment', idx)}><Trash2 size={12} className="text-slate-300 hover:text-red-500"/></button>
                                  </div>
                              ))
                          )}
                      </div>
                    </div>
                    
                  </div>
                </>
              ) : (
                // --- 간호사(002) 등 기본 레이아웃: 전체 에디터 ---
                <div className="col-span-12 flex flex-col h-full">
                  <label className="block text-xs font-bold text-slate-500 mb-2.5">
                    {getContentLabel(formData.macroType)}
                  </label>
                  <textarea 
                    name="macroContent" 
                    value={formData.macroContent} 
                    onChange={handleInputChange} 
                    className="w-full min-h-[600px] flex-1 p-6 bg-white border border-slate-200 rounded-2xl text-sm leading-7 text-slate-700 resize-none focus:ring-2 focus:ring-blue-500 outline-none shadow-sm" 
                    placeholder="작성할 오더를 입력하세요..."
                  ></textarea>
                </div>  
              )}

            </div>
          </div>
        </main>
      </div>
    </div>
  );
}