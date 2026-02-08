import React, { useEffect, useState } from 'react'
import * as API from '../../../api/accountApi';
import Swal from 'sweetalert2';

/**
 * AccountExcelModal.jsx
 * 
 * 작성자 : 김경희
 * 역할 : 엑셀 파일 담당
 * 
 * 종류
 * 1) 엑셀 일괄 등록
 * 2) 엑셀 일괄 다운로드
 */

// 직책 필터 한글 변환
const POSITION_MAP = {
    "": "전체",
    "0": "관리자",
    "1": "의사",
    "2": "외래간호사", 
    "3": "입원간호사",
    "4": "약사",
    "5": "방사선사",
    "6": "물리치료사",
    "7": "원무과"
};

// 정렬 필터 한글 변환
const SORT_MAP = {
    "": "전체 (퇴사자 포함)",
    "active": "재직자만",
    "retired": "퇴사자만",
    "date_desc": "입사일 최신순",
    "date_asc": "입사일 과거순"
};

function AccountExcelModal({ isOpen, onClose, onSuccess, filters, setFilters, mode}) {

    // 엑셀 파일 상태
    const [excelFile, setExcelFile] = useState(null);

    // 엑셀 파일 업로드 상태
    const [isLoading, setIsLoading] = useState(false);

    // 모달 열때마다 초기화 훅
    useEffect(() => {
        if (isOpen) setExcelFile(null);
    }, [isOpen]);
    
    // 모드에 맞는 제목 보여주기
    const title = mode === 'upload' ? "엑셀 일괄 계정 등록" : "엑셀 일괄 다운로드";
    
    // 엑셀 파일 선택
    const handleExcelChange = (e) => {
        const file = e.target.files[0];
        if (file) setExcelFile(file);
    };

    // 드래그 앤 드롭 핸들러
    const handleDragOver = (e) => {
        e.preventDefault();
    };

    // 핸들 드롭..
    const handleDrop = (e) => {
        e.preventDefault();
        const file = e.dataTransfer.files[0];
        
        // 확장자가 엑셀 파일일때만 가능
        if (file && (file.name.endsWith('.xlsx') || file.name.endsWith('.xls'))) {
            setExcelFile(file);
        } else {
            Swal.fire({
            icon: 'warning',
            title: '파일 형식 오류',
            text: '.xlsx 혹은 .xls 파일만 업로드 가능합니다.',
            confirmButtonColor: '#3085d6',
        });
    };
    }

    // ✅ [복구됨] 성공 시 닫기 및 새로고침 헬퍼 함수
    const handleSuccessClose = () => {
        setExcelFile(null);
        onClose?.(); 
        onSuccess?.(); 
    };

    // 엑셀 일괄 등록
    const handleExcelUpload = async () => {
        // 파일 선택 안했으면 alert 띄우기
        if (!excelFile) {
        return Swal.fire({
            icon: 'warning',
            text: '업로드할 엑셀 파일을 선택해주세요.',
            confirmButtonColor: '#3085d6',
            });
        }

        try {
            setIsLoading(true); // 로딩 시작
            
            // FormData 생성
            const formData = new FormData();
            formData.append("file", excelFile);

            const response = await API.uploadExcel(formData);

            const { successCount, failCount, failDetails } = response.data;

            // 결과 처리
            if (failCount === 0) {
                // 100% 성공 시
                await Swal.fire({
                icon: 'success',
                title: '업로드 완료!',
                text: `총 ${successCount}명이 정상적으로 등록되었습니다.`,
                confirmButtonColor: '#10b981'
            });
            handleSuccessClose();
        } else {
            // 부분실패 or 전체실패시
            
            // HTML 문자열 생성
            let htmlMsg = `
                <div style="text-align: left;">
                    <p>✅ <b>성공:</b> ${successCount}건</p>
                    <p style="color: red;">❌ <b>실패:</b> ${failCount}건</p>
                    <hr style="margin: 10px 0;">
                    <b>[실패 사유]</b>
                    <ul style="padding-left: 20px; color: #555;">
            `;

            // 반복문으로 <li> 태그 추가
            failDetails.slice(0, 10).forEach((detail) => {
                htmlMsg += `<li>${detail.row}행: ${detail.reason}</li>`;
            });

            // 실패 상세 건수
            if (failDetails.length > 10) {
                htmlMsg += `<li>...외 ${failDetails.length - 10}건</li>`;
            }
            htmlMsg += `</ul></div>`;

            // SweetAlert 띄우기 (html 속성 사용)
            await Swal.fire({
                icon: 'error',
                title: '처리 결과 확인',
                html: htmlMsg,
                width: '500px',
                confirmButtonText: '확인',
                confirmButtonColor: '#3085d6',
            });

            handleSuccessClose();
        }
    } catch (error) {
        console.error("업로드 에러:", error);
        const errData = error.response?.data;
        const errorMsg = errData?.message || "업로드 중 오류 발생";
        
        Swal.fire({
            icon: 'error',
            title: '업로드 실패',
            text: errorMsg
        });
    } finally {
        setIsLoading(false);
    }
};

    // 엑셀 다운로드 
    const handleExcelDownload = async () => {
        try {
            setIsLoading(true);
            const res = await API.downloadExcel(filters);
            const blob = res.data;
            
            // 서버에서 엑셀 대신 JSON(에러메시지)을 보냈는지 확인
            if (blob.type.includes('application/json')) {
                const text = await blob.text();
                const json = JSON.parse(text);
                throw new Error(json.message || "다운로드 실패");
            }

            // --- 정상 다운로드 로직 시작 ---

            // 파일명 세팅
            let filename = `직원계정목록_${new Date().toISOString().slice(0, 10)}.xlsx`;
            
            // 헤더에서 파일명 추출 시도
            const disposition = res.headers['content-disposition'];

            if (disposition) {
                const decodedFileName = decodeURIComponent(disposition);
                const matches = decodedFileName.match(/filename\*?=['"]?(?:UTF-\d['"]*)?([^;\r\n"']*)['"]?;?/);
                if (matches && matches[1]) {
                    filename = matches[1].replace(/['"]/g, '');
                }
            }

            // 브라우저 다운로드 실행
            const url = window.URL.createObjectURL(blob);
            const link = document.createElement("a");
            link.href = url;
            link.setAttribute("download", filename);
            document.body.appendChild(link);
            link.click();
            link.remove();
            window.URL.revokeObjectURL(url);

            // 모달 닫기
            onClose?.();

        } catch (error) {
            console.error(error);
            const msg = error.message || "다운로드 중 오류가 발생했습니다.";
            Swal.fire({
                icon: 'error',
                title: '다운로드 실패',
                text: msg,
                confirmButtonColor: '#d33', // 빨간색 버튼
            });
        } finally {
            setIsLoading(false);
        }
    };

    // isOpen이 false면 아무것도 렌더링 안 함 (에러 방지용 안전장치)
    if (!isOpen) return null;

    return (
        <>
            <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 backdrop-blur-sm">
                <div className="bg-white w-[600px] max-h-[90vh] rounded-[2rem] shadow-2xl overflow-hidden flex flex-col animate-in fade-in zoom-in duration-200">

                    {/* 모달 창 닫기 버튼 */}
                    <div className="p-6 border-b border-slate-100 flex justify-between items-center bg-white shrink-0">
                        <h3 className="text-lg font-bold text-slate-900">{title}</h3>
                        <button onClick={() => {setExcelFile(null); onClose?.();}} type="button" className="w-8 h-8 flex items-center justify-center rounded-full hover:bg-slate-100 text-slate-400">
                            ✕
                        </button>
                    </div>

                    <div className="flex-1 py-8 px-12 overflow-y-auto custom-scrollbar">
                        {/* 다운로드 모드 */}
                        {mode === 'download' && (
                            <div className="flex flex-col gap-6">
                                <div className="text-center">
                                    <span className="text-5xl mb-4 block">📊</span>
                                    <h4 className="text-lg font-bold text-slate-800 mb-2">검색된 결과를 다운로드할까요?</h4>
                                    <p className="text-xs text-slate-400">현재 적용된 필터 조건은 아래와 같습니다.</p>
                                </div>

                                {/* 현재 설정된 필터 */}
                                <div className="bg-slate-50 rounded-2xl p-5 border border-slate-100 flex flex-col gap-4">
                                
                                {/* 1. 직책 선택 */}
                                <div className="flex flex-col gap-1">
                                    <label className="text-xs font-bold text-slate-500 ml-1">직책 필터</label>
                                    <select value={filters.position} onChange={(e) => setFilters({...filters, position: e.target.value})}
                                        className="w-full p-3 bg-white border border-slate-200 rounded-xl text-sm font-bold text-slate-700 outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all cursor-pointer">
                                        {/* ✅ Map을 돌면서 자동 생성 */}
                                        {Object.entries(POSITION_MAP).map(([key, label]) => (
                                            <option key={key} value={key}>{label}</option>
                                        ))}
                                    </select>
                                </div>

                                {/* 정렬 필터 */}
                                <div className="flex flex-col gap-1">
                                    <label className="text-xs font-bold text-slate-500 ml-1">재직 상태</label>
                                    <select value={filters.sort} onChange={(e) => setFilters({...filters, sort: e.target.value})}
                                            className="w-full p-3 bg-white border border-slate-200 rounded-xl text-sm font-bold text-slate-700 outline-none focus:border-blue-500 focus:ring-2 focus:ring-blue-100 transition-all cursor-pointer">
                                            {Object.entries(SORT_MAP).map(([key, label]) => (<option key={key} value={key}>{label}</option>))}
                                    </select>
                                </div>
                            </div>

                                <button type="button" onClick={handleExcelDownload} disabled={isLoading}
                                        className="w-full py-4 bg-blue-600 text-white rounded-2xl font-bold shadow-lg shadow-blue-200 hover:bg-blue-700 transition-all">
                                    {isLoading ? "다운로드 중..." : "엑셀 파일 다운로드"}
                                </button>
                            </div>
                        )}

                        {/* 업로드 모드 */}
                        {mode === 'upload' && (
                            <div>
                                {/* 드래그 앤 드롭 영역 */}
                                <div onDragOver={handleDragOver} onDrop={handleDrop}
                                    className={`border-2 border-dashed rounded-2xl p-10 flex flex-col items-center justify-center bg-slate-50 mb-6 relative transition-colors
                                    ${excelFile ? 'border-emerald-500 bg-emerald-50' : 'border-slate-200 hover:border-emerald-400' }`}>
                                    <input type="file" accept=".xlsx, .xls" className="absolute inset-0 opacity-0 cursor-pointer" onChange={handleExcelChange} />
                                    <span className="text-4xl mb-4">{excelFile ? '📂' : '📄'}</span>
                                    <p className="text-sm font-bold text-slate-600">
                                        {excelFile ? <span className="text-emerald-600">{excelFile.name}</span> : "엑셀 파일을 드래그하거나 클릭하세요"}
                                    </p>
                                </div>

                                {/* 버튼 영역 */}
                                <div className="flex gap-3">
                                    <button type="button" disabled={isLoading} onClick={() => {setExcelFile(null); onClose?.(); }}
                                            className="flex-1 py-4 rounded-2xl bg-white border border-slate-200 text-sm font-bold text-slate-500 hover:bg-slate-100">
                                        취소
                                    </button>
                                    <button type="button" disabled={isLoading || !excelFile} onClick={handleExcelUpload}
                                            className="flex-[2] py-4 rounded-2xl bg-emerald-600 text-white text-sm font-black shadow-lg shadow-emerald-100 hover:bg-emerald-700 disabled:opacity-60 transition-all">
                                        {isLoading ? "업로드 중..." : "일괄 등록 확정"}
                                    </button>
                                </div>
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </>
    );
}

export default AccountExcelModal;