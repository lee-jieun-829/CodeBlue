import React, { useEffect, useRef, useState } from 'react'
import * as API from '../../../api/accountApi';

function AccountCreateModal({isOpen, onClose, onSuccess}) {
  const fileInputRef = useRef(null);
  
  const initialCreateForm = {
    employeeName: '',
    employeeCode: '',
    employeeBirth: '',
    employeeGen: '',
    employeeRegno1: '',
    employeeRegno2: '',
    employeeRegdate: '',
    employeeDetailLicence: '',
    noLicense: false,
  };
  
  const [createForm, setCreateForm] = useState({
    employeeName: '',
    employeeCode: '',
    // employeeTel:'',
    // employeeEmail:'',
    employeeBirth: '',
    employeeGen: '',
    employeeRegno1: '',
    employeeRegno2: '',
    employeeRegdate: '',
    employeeDetailLicence: '',
    noLicense: false
  });
  
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
  
  // 파일 관련
  const [profileFile, setProfileFile] = useState(null);
  const [profilePreview, setProfilePreview] = useState('');
  
  const resetForm = () => {
    if (profilePreview) URL.revokeObjectURL(profilePreview);
    
    setProfileFile(null);
    setProfilePreview('');
    setCreateForm(initialCreateForm);
    setTelParts({ part1: '010', part2: '', part3: '' });
    setEmailParts({ id: '', domain: '' });
    setIsDirectDomain(false);
    
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };
  
  // 모달 끌때 상태 초기화
  useEffect(() => {
    if (!isOpen) {
      resetForm();
    }
  }, [isOpen]);

  if (!isOpen) return null;
  
  // 입력값 변경 핸들러
  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setCreateForm(prev => ({ ...prev, [name]: value }));
  };
  
  // 전화번호 입력 핸들러
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
  
  // 면허 번호 없음 (체크박스)
  const handleLicenseCheck = (e) => {
    const isChecked = e.target.checked;
      setCreateForm(prev => ({
        ...prev,
        noLicense: isChecked,
        employeeDetailLicence: isChecked ? '해당 없음' : ''
      }));
    };
    
    // 프로필 사진 선택 & 미리보기
    const handleProfileChange = (e) => {
      const file = e.target.files[0];
      if (!file) return;
      
      // 이전 preview URL 정리
      if (profilePreview) URL.revokeObjectURL(profilePreview);
      
      setProfileFile(file);
      setProfilePreview(URL.createObjectURL(file));
    };
    
    // 메인 이벤트 - 1) 계정 생성
    const handleCreateSave = async () => {
      
      // 유효성
      if (!createForm.employeeCode) return alert("직책을 선택해주세요.");
      if (!createForm.employeeName) return alert("이름을 입력해주세요.");
      if (!createForm.employeeGen) return alert("성별을 선택해주세요.");
      
      if (!profileFile) return alert("프로필 사진은 필수입니다.");
      if (!telParts.part2 || !telParts.part3) return alert("전화번호를 끝까지 입력해주세요.");
      
      if (!emailParts.id || !emailParts.domain) return alert("이메일를 입력해주세요.");
      
      if (createForm.employeeRegno1 && createForm.employeeRegno1.length !== 6) return alert("주민번호 앞 6자리를 확인해주세요.");
      if (createForm.employeeRegno2 && createForm.employeeRegno2.length !== 7) return alert("주민번호 뒤 7자리를 확인해주세요.");
      
      
      // 저장전에 하이픈으로 합치기
      const finalTel = `${telParts.part1}-${telParts.part2}-${telParts.part3}`;
      const finalEmail = `${emailParts.id}@${emailParts.domain}`;
      
      try {
        const formData = new FormData();
        
        formData.append("employeeName", createForm.employeeName);
        formData.append("employeeCode", createForm.employeeCode);
        formData.append("employeeTel", finalTel);
        formData.append("employeeEmail", finalEmail);
        formData.append("employeeBirth", createForm.employeeRegno1);
        formData.append("employeeGen", createForm.employeeGen);
        formData.append("employeeRegno1", createForm.employeeRegno1);
        formData.append("employeeRegno2", createForm.employeeRegno2);
        formData.append("employeeDetailLicence", createForm.employeeDetailLicence);
        formData.append("employeeRegdate", createForm.employeeRegdate || new Date().toISOString().split("T")[0]);
        formData.append("file", profileFile);
        
        const res = await API.createEmployee(formData);
        
        // 계정 생성 
        if (res.status === 200) {
          alert("계정이 성공적으로 생성되었습니다.");
          // 목록 갱신
          onSuccess?.();
          onClose?.();
          }
        } catch (err) {
          alert("생성 실패: " + (err.response?.data?.msg || "서버 오류"));
        }
      };
      
      return (
        <div className="fixed inset-0 modal-overlay z-50 flex items-center justify-center">
          <div className="bg-white w-[650px] max-h-[90vh] rounded-[2rem] shadow-2xl overflow-hidden flex flex-col animate-in fade-in zoom-in duration-200 text-zinc-950">
            <div className="p-6 border-b border-slate-100 bg-white shrink-0 flex justify-between items-center text-zinc-950">
              <div>
                <h3 className="text-lg font-bold text-slate-900"> 신규 계정 등록 </h3>
                <p className="text-[10px] text-slate-400 font-medium"> 직원의 인적사항 및 면허 정보를 등록합니다. </p>
              </div>
              <button onClick={() => onClose?.()} className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-slate-100 text-slate-400"> ✕ </button>
            </div>
            <div className="flex-1 overflow-y-auto custom-scrollbar py-8 px-12 text-zinc-950">
              {/* 프로필 사진 업로드 */}
              <div className="flex flex-col items-center mb-10">
                <div className="relative group cursor-pointer">
                  <div className="w-20 h-20 rounded-[1.5rem] bg-white border-2 border-dashed border-slate-200 flex items-center justify-center overflow-hidden transition-all group-hover:border-blue-400 shadow-sm">
                    {profilePreview ? (
                      <img src={profilePreview} className="w-full h-full object-cover" alt="preview"/>
                    ) : (
                      <span className="text-xl text-slate-300">📷</span>
                    )}
                  </div>
                  <input
                    type="file"
                    ref={fileInputRef}
                    className="absolute inset-0 opacity-0 cursor-pointer"
                    accept="image/*"
                    onChange={handleProfileChange}
                  />
                  <div className="absolute -bottom-1 -right-1 w-6 h-6 bg-blue-600 rounded-full border-2 border-white flex items-center justify-center text-white text-[10px] shadow-lg">
                    ＋
                  </div>
                </div>
              </div>
              <form className="grid grid-cols-2 gap-x-6 gap-y-5 text-zinc-950">
                {/* 직책 */}
                <div className="col-span-2 space-y-1.5">
                  <label className="text-[11px] font-black text-slate-500 uppercase">직책</label>

                  <div className="relative">
                    <select name="employeeCode" onChange={handleInputChange} className="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold text-slate-700 outline-none appearance-none shadow-sm cursor-pointer">
                      <option value="">직책을 선택해 주세요</option>
                      <option value="1">의사</option>
                      <option value="2">외래 간호사</option>
                      <option value="3">입원 간호사</option>
                      <option value="4">약사</option>
                      <option value="5">방사선사</option>
                      <option value="6">물리치료사</option>
                      <option value="7">원무과</option>
                      <option value="0">관리자</option>
                    </select>

                    {/* 화살표 아이콘 */}
                    <div className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400 text-xs">
                      ▼
                    </div>
                  </div>
                </div>

                <div className="col-span-2 flex gap-6 items-end">
                  {/* 이름 */}
                  <div className="space-y-1.5 w-1/3">
                    <div className="flex items-center px-1">
                      <label className="text-[11px] font-black text-slate-500 uppercase"> 이름 </label>
                    </div>
                    <input
                      type="text"
                      name="employeeName"
                      onChange={handleInputChange}
                      className="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold text-slate-700 outline-none shadow-sm"
                      placeholder="성함 입력"
                    />
                  </div>

                  {/* 면허번호 */}
                  <div className="space-y-1.5 flex-1">
                    <div className="flex justify-between items-center px-1">
                      <label className="text-[11px] font-black text-blue-600 uppercase">
                        면허번호
                      </label>
                      <label className="flex items-center gap-1.5 cursor-pointer group">
                        <input
                          type="checkbox"
                          className="custom-checkbox"
                          onChange={handleLicenseCheck}
                        />
                        <span className="text-[10px] font-bold text-slate-400">
                          없음
                        </span>
                      </label>
                    </div>
                    <input
                      type="text"
                      name="employeeDetailLicence"
                      value={createForm.employeeDetailLicence}
                      disabled={createForm.noLicense}
                      onChange={handleInputChange}
                      className={`w-full border rounded-xl px-4 py-3 text-sm font-bold outline-none shadow-sm ${
                        createForm.noLicense
                          ? "bg-slate-50 text-slate-400"
                          : "bg-white border-blue-100 text-slate-700"
                      }`}
                      placeholder="면허번호 입력"
                    />
                  </div>
                </div>

                {/* 연락처 */}
                <div className="space-y-1.5">
                  <label className="text-[11px] font-black text-slate-500 uppercase">
                    연락처
                  </label>
                  <div className="flex items-center gap-2">
                    <input
                      type="text"
                      name="part1"
                      maxLength="3"
                      value={telParts.part1}
                      onChange={handleTelChange}
                      placeholder="010"
                      className="w-[28%] bg-white border border-slate-200 rounded-xl px-3 py-3 text-sm font-bold text-slate-700 outline-none shadow-sm text-center"
                    />
                    <span className="text-slate-400 font-bold">-</span>
                    <input
                      type="text"
                      name="part2"
                      maxLength="4"
                      value={telParts.part2}
                      onChange={handleTelChange}
                      className="w-[36%] bg-white border border-slate-200 rounded-xl px-3 py-3 text-sm font-bold text-slate-700 outline-none shadow-sm text-center"
                    />
                    <span className="text-slate-400 font-bold">-</span>
                    <input
                      type="text"
                      name="part3"
                      maxLength="4"
                      value={telParts.part3}
                      onChange={handleTelChange}
                      className="w-[36%] bg-white border border-slate-200 rounded-xl px-3 py-3 text-sm font-bold text-slate-700 outline-none shadow-sm text-center"
                    />
                  </div>
                </div>

                {/* 입사일 */}
                <div className="space-y-1.5">
                  <label className="text-[11px] font-black text-slate-500 uppercase">
                    입사일
                  </label>
                  <input type="date" name="employeeRegdate" onChange={handleInputChange} defaultValue={new Date().toISOString().split("T")[0]}
                    className="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm font-black text-slate-700 outline-none shadow-sm"/>
                </div>

                {/* 이메일 */}
                <div className="space-y-1.5 col-span-2">
                  <label className="text-[11px] font-black text-slate-500 uppercase">
                    이메일
                  </label>
                  <div className="flex items-center gap-2 w-full">
                    {/* 아이디  */}
                    <input type="text" name="id" value={emailParts.id} onChange={handleEmailChange}
                      placeholder="아이디"
                      className="flex-1 bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold text-slate-700 outline-none shadow-sm min-w-0"
                    />
                    <span className="text-slate-400 font-bold">@</span>

                    {/* 도메인 */}
                    {isDirectDomain ? (
                      <div className="flex-1 relative">
                        <input type="text" name="domain" value={emailParts.domain} onChange={handleEmailChange} placeholder="직접 입력해주세용"
                          className="w-full bg-white border border-slate-200 rounded-xl pl-4 pr-10 py-3 text-sm font-bold text-slate-700 outline-none shadow-sm"
                        />
                        <button
                          type="button"
                          onClick={() => {
                            setIsDirectDomain(false);
                            setEmailParts((prev) => ({
                              ...prev,
                              domain: "naver.com",
                            }));
                          }}
                          className="absolute right-4 top-1/2 -translate-y-1/2 text-slate-400 text-xs"
                        >
                          ▼
                        </button>
                      </div>
                    ) : (
                      <div className="flex-1 relative">
                        <select
                          name="domain"
                          onChange={handleDomainSelect}
                          value={emailParts.domain}
                          className="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold text-slate-700 outline-none appearance-none shadow-sm cursor-pointer"
                        >
                          <option value="">직접 입력</option>
                          <option value="naver.com">naver.com</option>
                          <option value="gmail.com">gmail.com</option>
                          <option value="daum.net">daum.net</option>
                          <option value="nate.com">nate.com</option>
                        </select>
                        <div className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400 text-xs">
                          {" "}
                          ▼{" "}
                        </div>
                      </div>
                    )}
                  </div>
                </div>

                {/* 주민등록번호 & 성별 */}
                <div className="col-span-2 flex gap-4 items-end">
                  {/* 주민등록번호 */}
                  <div className="space-y-1.5 flex-grow">
                    <label className="text-[11px] font-black text-slate-500 uppercase">
                      주민등록번호
                    </label>
                    <div className="flex items-center gap-2 text-zinc-950">
                      <input
                        type="text"
                        name="employeeRegno1"
                        maxLength="6"
                        onChange={handleInputChange}
                        className="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold text-slate-700 outline-none shadow-sm text-center"
                        placeholder="앞 6자리"
                      />
                      <span className="text-slate-300 font-bold">-</span>
                      <input
                        type="password"
                        name="employeeRegno2"
                        maxLength="7"
                        onChange={handleInputChange}
                        className="w-full bg-white border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold text-slate-700 outline-none shadow-sm text-center"
                        placeholder="뒤 7자리"
                      />
                    </div>
                  </div>

                  {/* 성별 */}
                  <div className="space-y-1.5 shrink-0">
                    <label className="text-[11px] font-black text-slate-500 uppercase">
                      성별
                    </label>
                    <div className="flex gap-2">
                      {/* 남성 버튼 */}
                      <label className="w-24 cursor-pointer">
                        <input
                          type="radio"
                          name="employeeGen"
                          value="M"
                          checked={createForm.employeeGen === "M"}
                          onChange={handleInputChange}
                          className="hidden peer"
                        />
                        <div className="w-full py-3 text-center border border-slate-200 rounded-xl text-sm font-bold bg-white text-slate-400 peer-checked:bg-blue-600 peer-checked:text-white peer-checked:border-blue-600 transition-all shadow-sm">
                          남성
                        </div>
                      </label>

                      {/* 여성 버튼 */}
                      <label className="w-24 cursor-pointer">
                        <input
                          type="radio"
                          name="employeeGen"
                          value="F"
                          checked={createForm.employeeGen === "F"}
                          onChange={handleInputChange}
                          className="hidden peer"
                        />
                        <div className="w-full py-3 text-center border border-slate-200 rounded-xl text-sm font-bold bg-white text-slate-400 peer-checked:bg-pink-500 peer-checked:text-white peer-checked:border-pink-500 transition-all shadow-sm">
                          여성
                        </div>
                      </label>
                    </div>
                  </div>
                </div>
              </form>
            </div>

            <div className="p-6 bg-slate-50 border-t border-slate-100 flex gap-3 shrink-0">
              <button onClick={onClose} className="flex-1 py-4 rounded-2xl bg-white border border-slate-200 text-sm font-bold hover:bg-slate-100 transition-all text-zinc-950">
                취소
              </button>
              <button onClick={handleCreateSave} className="flex-[2] py-4 rounded-2xl bg-blue-600 text-white text-sm font-black shadow-lg shadow-blue-100 hover:bg-blue-700 transition-all">
                계정 등록 완료
              </button>
            </div>
          </div>
        </div>
  )
}

export default AccountCreateModal