import React, { useState, useEffect } from 'react';
import api from '../../api/axios';

const ForcePwModal = ({ springUrl }) => {
  const [newPw, setNewPw] = useState('');
  const [confirmPw, setConfirmPw] = useState('');
  const [errorMsg, setErrorMsg] = useState('');
  const [loading, setLoading] = useState(false);

  // 1. 로그아웃 (접근 차단)
  const handleLogout = () => {
    // springUrl이 없으면 기본값 처리 (혹시 모를 에러 방지)
    const baseUrl = springUrl || "http://localhost:8060";
    window.location.href = `${baseUrl}/logout`;
  };

  // 2. 취소 버튼 클릭 시
  const handleDeny = () => {
    if (window.confirm("비밀번호를 변경하지 않으면 서비스를 이용할 수 없습니다.\n로그아웃 하시겠습니까?")) {
      handleLogout();
    }
  };

  // 3. ESC 키 감지
  useEffect(() => {
    const handleEsc = (e) => {
      if (e.key === 'Escape') {
        handleLogout();
      }
    };
    window.addEventListener('keydown', handleEsc);
    return () => window.removeEventListener('keydown', handleEsc);
  }, []); // 빈 배열: 마운트될 때 한 번만 실행 (부모가 unmount 시키면 이벤트도 사라짐 -> 안전함)

  // 4. 변경 요청
  const handleSubmit = async () => {
    if (loading) return; 

    if (!newPw) return setErrorMsg("새 비밀번호를 입력해주세요.");
    if (newPw !== confirmPw) return setErrorMsg("비밀번호가 일치하지 않습니다.");
    
    // 비밀번호 8자 이상
    //if (newPw.length < 8) return setErrorMsg("비밀번호는 최소 8자 이상이어야 합니다.");

    try {
      setLoading(true);
      const res = await api.post('/auth/updatepw', { newPw });
      if (res.status === 200) {
        alert("비밀번호가 변경되었습니다. 다시 로그인해주세요.");
        handleLogout();
      }
    } catch (error) {
      setErrorMsg(error.response?.data?.msg || "변경 중 오류 발생");
    } finally {
      setLoading(false);
    }
  };

  // 5. 엔터키 핸들러
  const handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      handleSubmit();
    }
  };

  return (
    <div className="fixed inset-0 z-[9999] flex items-center justify-center">
      
      {/* 어두운 배경 + 블러 처리 */}
      <div className="absolute inset-0 bg-gray-900 bg-opacity-70 backdrop-blur-sm"></div>

      <div className="bg-white rounded-xl shadow-2xl z-10 w-full max-w-md p-8 relative animate-fade-in-up">
        
        <div className="text-center mb-6">
          <h2 className="text-2xl font-bold text-red-600">⚠ 보안 안내</h2>
          <p className="text-gray-600 mt-2 text-sm">
            현재 <span className="font-bold text-gray-800">임시 비밀번호</span>를 사용 중입니다.<br/>
            비밀번호를 변경해야 서비스를 이용할 수 있습니다.
          </p>
        </div>

        <div className="space-y-4">
          <input 
            type="password" 
            placeholder="새로운 비밀번호 (8자 이상)" 
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"
            value={newPw}
            onChange={(e) => setNewPw(e.target.value)}
            onKeyDown={handleKeyDown}
            autoFocus 
            disabled={loading} // 로딩 중 입력 방지
          />
          <input 
            type="password" 
            placeholder="비밀번호 확인" 
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 outline-none transition"
            value={confirmPw}
            onChange={(e) => setConfirmPw(e.target.value)}
            onKeyDown={handleKeyDown}
            disabled={loading}
          />
          {errorMsg && <p className="text-red-500 text-xs font-bold pl-1">{errorMsg}</p>}
        </div>

        <div className="flex gap-3 mt-8">
          <button 
            onClick={handleDeny}
            disabled={loading}
            className="w-1/3 bg-gray-100 hover:bg-gray-200 text-gray-600 font-bold py-3 rounded-lg transition"
          >
            취소<span className="text-[10px] block font-normal text-gray-400">(로그아웃)</span>
          </button>
          
          <button 
            onClick={handleSubmit}
            disabled={loading}
            className={`w-2/3 text-white font-bold py-3 rounded-lg transition shadow-md flex justify-center items-center
              ${loading ? 'bg-blue-400 cursor-not-allowed' : 'bg-blue-600 hover:bg-blue-700'}`}
          >
            {loading ? (
              // 로딩 스피너 (심플)
              <svg className="animate-spin h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
            ) : "변경하고 시작하기"}
          </button>
        </div>
      </div>
    </div>
  );
};

export default ForcePwModal;