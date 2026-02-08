<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
    /* ----------------------------------------------------------------
       모달 스타일 정의
       ---------------------------------------------------------------- */
    
    /* 모달 오버레이 (배경) */
    .modal-overlay {
        transition: opacity 0.2s ease-in-out;
        opacity: 0;
        pointer-events: none;
    }
    .modal-overlay.active {
        opacity: 1;
        pointer-events: auto;
    }

    /* 테이블 헤더 고정 */
    .table-fixed-head {
        position: sticky;
        top: 0;
        background-color: #f9fafb; /* bg-gray-50 */
        z-index: 10;
    }
    
    /* 커스텀 스크롤바 */
    .custom-scrollbar::-webkit-scrollbar { 
        width: 6px; 
    }
    .custom-scrollbar::-webkit-scrollbar-track { 
        background: transparent; 
    }
    .custom-scrollbar::-webkit-scrollbar-thumb { 
        background: #cbd5e1; 
        border-radius: 3px; 
    }
    .custom-scrollbar::-webkit-scrollbar-thumb:hover { 
        background: #94a3b8; 
    }


</style>

<div id="modal-container">

    <div id="modal-diagnosis" class="modal-overlay fixed inset-0 flex items-center justify-center bg-black/50 backdrop-blur-sm z-[9000]">
        <div class="modal modal-full h-[80vh] w-[80vw] flex flex-col bg-white rounded-lg shadow-xl">
            
            <div class="modal-header flex justify-between items-center p-4 border-b">
                <div class="flex flex-col">
                    <h3 class="modal-title text-xl font-bold">상병 추가</h3>
                    <span class="text-xs text-gray-500 font-normal">상병 검색 후 선택하여 적용</span>
                </div>
                <button class="btn btn-icon btn-ghost text-2xl" onclick="closeModal('modal-diagnosis')">×</button>
            </div>

            <div class="modal-body flex-1 flex gap-4 p-6 overflow-hidden min-h-0">
                
                <div class="flex-1 flex flex-col border rounded-lg overflow-hidden">
                    <div class="p-4 border-b bg-gray-50 space-y-2">
                        <label class="text-sm font-bold text-gray-700 flex items-center gap-1">
                            <span class="w-1 h-4 bg-blue-500 rounded-full inline-block"></span> 상병 검색
                        </label>
                        <div class="flex gap-2">
                            <select class="border rounded px-2 text-sm"><option value="all">전체</option></select>
                            <div class="relative flex-1">
                                <input type="text" id="diag-search-input" onkeyup="handleSearch(this, 'diagnosis')"
                                       class="w-full border rounded px-3 py-2 text-sm pl-8" placeholder="검색어 입력 (예: 골절)">
                                <svg class="w-4 h-4 absolute left-2.5 top-2.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                            </div>
                            <button onclick="clearInput('diag-search-input'); document.getElementById('diag-left-list').innerHTML='';" class="btn btn-sm border">초기화</button>
                        </div>
                    </div>
                    <div class="relative flex-1 overflow-y-auto custom-scrollbar">
                        <div id="diag-loading" class="hidden absolute inset-0 bg-white/80 z-20 flex items-center justify-center"><div class="animate-spin h-6 w-6 border-2 border-blue-500 rounded-full border-t-transparent"></div></div>
                        <ul id="diag-left-list" class="divide-y divide-gray-100">
                            <li class="py-8 text-center text-gray-400 text-sm">검색어를 입력하세요.</li>
                        </ul>
                    </div>
                </div>

                <div class="w-[40%] flex flex-col border rounded-lg overflow-hidden">
                    <div class="p-4 border-b bg-blue-50/50 flex justify-between items-center">
                        <label class="text-sm font-bold text-gray-700">선택 목록</label>
                        <button onclick="removeAllStagedDiagnosis()" class="text-xs text-red-500 border border-red-200 bg-white px-2 py-1 rounded">전체 삭제</button>
                    </div>
                    <div class="flex-1 overflow-y-auto p-2 space-y-2 bg-gray-50/30" id="diag-right-list">
                        <div id="diag-empty-msg" class="h-full flex items-center justify-center text-gray-400 text-sm">추가된 항목이 없습니다.</div>
                    </div>
                    <div class="p-3 border-t bg-yellow-50/50 text-xs flex justify-between">
                        <span>기본값:</span>
                        <div class="flex gap-2">
                            <label><input type="radio" name="diag-default-type" value="main" checked> 주상병</label>
                            <label><input type="radio" name="diag-default-type" value="sub"> 부상병</label>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer flex justify-end gap-2 p-4 border-t bg-gray-50">
                <button class="btn btn-secondary" onclick="closeModal('modal-diagnosis')">취소</button>
                <button class="btn bg-blue-600 text-white hover:bg-blue-700" onclick="applyStagedDiagnosis()">진료 적용</button>
            </div>
        </div>
    </div>

    <div id="modal-treatment" class="modal-overlay fixed inset-0 flex items-center justify-center bg-black/50 backdrop-blur-sm z-[9000]">
        <div class="modal modal-full h-[80vh] w-[80vw] flex flex-col bg-white rounded-lg shadow-xl">
            
            <div class="modal-header flex justify-between items-center p-4 border-b">
                <div class="flex flex-col">
                    <h3 class="modal-title text-xl font-bold">치료 처방 추가</h3>
                    <span class="text-xs text-gray-500 font-normal">치료 및 주사를 검색하여 적용</span>
                </div>
                <button class="btn btn-icon btn-ghost text-2xl" onclick="closeModal('modal-treatment')">×</button>
            </div>

            <div class="modal-body flex-1 flex gap-4 p-6 overflow-hidden min-h-0">
                
                <div class="flex-1 flex flex-col border rounded-lg overflow-hidden">
                    <div class="p-4 border-b bg-gray-50 space-y-3">
                        <div class="flex justify-between items-center">
                            <label class="text-sm font-bold text-gray-700 flex items-center gap-1">
                                <span class="w-1 h-4 bg-green-500 rounded-full inline-block"></span> 
                                <span id="tx-mode-title">치료 검색</span>
                            </label>
                            
                            <div class="flex bg-white border border-gray-300 rounded-lg overflow-hidden">
                                <label class="cursor-pointer border-r border-gray-200">
                                    <input type="radio" name="txTypeToggle" value="treatment" class="peer sr-only" checked onchange="changeTxMode('treatment')">
                                    <span class="block px-3 py-1.5 text-xs font-bold text-gray-500 bg-gray-50 peer-checked:bg-green-500 peer-checked:text-white transition-all">치료</span>
                                </label>
                                <label class="cursor-pointer">
                                    <input type="radio" name="txTypeToggle" value="injection" class="peer sr-only" onchange="changeTxMode('injection')">
                                    <span class="block px-3 py-1.5 text-xs font-bold text-gray-500 bg-gray-50 peer-checked:bg-green-500 peer-checked:text-white transition-all">주사</span>
                                </label>
                            </div>
                        </div>

                        <div class="flex gap-2">
                            <select class="border rounded px-2 text-sm"><option value="all">전체</option></select>
                            <div class="relative flex-1">
                                <input type="text" id="treat-search-input" onkeyup="handleSearch(this, 'treatment')"
                                       class="w-full border rounded px-3 py-2 text-sm pl-8" placeholder="검색어 입력 (예: 물리치료, 주사제)">
                                <svg class="w-4 h-4 absolute left-2.5 top-2.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                            </div>
                            <button onclick="clearInput('treat-search-input'); document.getElementById('treat-left-list').innerHTML='';" class="btn btn-sm border">초기화</button>
                        </div>
                    </div>
                    <div class="relative flex-1 overflow-y-auto custom-scrollbar">
                        <div id="treat-loading" class="hidden absolute inset-0 bg-white/80 z-20 flex items-center justify-center"><div class="animate-spin h-6 w-6 border-2 border-green-500 rounded-full border-t-transparent"></div></div>
                        <ul id="treat-left-list" class="divide-y divide-gray-100">
                            <li class="py-8 text-center text-gray-400 text-sm">검색어를 입력하세요.</li>
                        </ul>
                    </div>
                </div>

                <div class="w-[40%] flex flex-col border rounded-lg overflow-hidden">
                    <div class="p-4 border-b bg-green-50/50 flex justify-between items-center">
                        <label class="text-sm font-bold text-gray-700">선택 목록</label>
                        <button onclick="removeAllStagedTreatment()" class="text-xs text-red-500 border border-red-200 bg-white px-2 py-1 rounded">전체 삭제</button>
                    </div>
                    <div class="flex-1 overflow-y-auto p-2 space-y-2 bg-gray-50/30" id="treat-right-list">
                        <div id="treat-empty-msg" class="h-full flex items-center justify-center text-gray-400 text-sm">추가된 항목이 없습니다.</div>
                    </div>
                </div>
            </div>

            <div class="modal-footer flex justify-end gap-2 p-4 border-t bg-gray-50">
                <button class="btn btn-secondary" onclick="closeModal('modal-treatment')">취소</button>
                <button class="btn bg-green-600 text-white hover:bg-green-700" onclick="applyStagedTreatment()">치료 적용</button>
            </div>
        </div>
    </div>

    <div id="modal-medication" class="modal-overlay fixed inset-0 flex items-center justify-center bg-black/50 backdrop-blur-sm z-[9000]">
        <div class="modal modal-full h-[80vh] w-[80vw] flex flex-col bg-white rounded-lg shadow-xl">
            
            <div class="modal-header flex justify-between items-center p-4 border-b">
                <div class="flex flex-col">
                    <h3 class="modal-title text-xl font-bold">약제 처방 추가</h3>
                    <span class="text-xs text-gray-500 font-normal">약품 검색 후 선택하여 적용</span>
                </div>
                <button class="btn btn-icon btn-ghost text-2xl" onclick="closeModal('modal-medication')">×</button>
            </div>

            <div class="modal-body flex-1 flex gap-4 p-6 overflow-hidden min-h-0">
                
                <div class="flex-1 flex flex-col border rounded-lg overflow-hidden">
                    <div class="p-4 border-b bg-gray-50 space-y-2">
                        <label class="text-sm font-bold text-gray-700 flex items-center gap-1">
                            <span class="w-1 h-4 bg-orange-500 rounded-full inline-block"></span> 약품 검색
                        </label>
                        <div class="flex gap-2">
                            <select class="border rounded px-2 text-sm"><option value="all">전체</option></select>
                            <div class="relative flex-1">
                                <input type="text" id="med-search-input" onkeyup="handleSearch(this, 'medication')"
                                       class="w-full border rounded px-3 py-2 text-sm pl-8" placeholder="검색어 입력 (예: 타이레놀)">
                                <svg class="w-4 h-4 absolute left-2.5 top-2.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                            </div>
                            <button onclick="clearInput('med-search-input'); document.getElementById('med-left-list').innerHTML='';" class="btn btn-sm border">초기화</button>
                        </div>
                    </div>
                    <div class="relative flex-1 overflow-y-auto custom-scrollbar">
                        <div id="med-loading" class="hidden absolute inset-0 bg-white/80 z-20 flex items-center justify-center"><div class="animate-spin h-6 w-6 border-2 border-orange-500 rounded-full border-t-transparent"></div></div>
                        <ul id="med-left-list" class="divide-y divide-gray-100">
                            <li class="py-8 text-center text-gray-400 text-sm">검색어를 입력하세요.</li>
                        </ul>
                    </div>
                </div>

                <div class="w-[40%] flex flex-col border rounded-lg overflow-hidden">
                    <div class="p-4 border-b bg-orange-50/50 flex justify-between items-center">
                        <label class="text-sm font-bold text-gray-700">선택 목록</label>
                        <button onclick="removeAllStagedMedication()" class="text-xs text-red-500 border border-red-200 bg-white px-2 py-1 rounded">전체 삭제</button>
                    </div>
                    <div class="flex-1 overflow-y-auto p-2 space-y-2 bg-gray-50/30" id="med-right-list">
                        <div id="med-empty-msg" class="h-full flex items-center justify-center text-gray-400 text-sm">추가된 항목이 없습니다.</div>
                    </div>
                </div>
            </div>

            <div class="modal-footer flex justify-end gap-2 p-4 border-t bg-gray-50">
                <button class="btn btn-secondary" onclick="closeModal('modal-medication')">취소</button>
                <button class="btn bg-orange-600 text-white hover:bg-orange-700" onclick="applyStagedMedication()">약제 적용</button>
            </div>
        </div>
    </div>

    <div id="modal-operation" class="modal-overlay fixed inset-0 flex items-center justify-center bg-black/50 backdrop-blur-sm z-[9000]">
        <div class="modal modal-full h-[80vh] w-[80vw] flex flex-col bg-white rounded-lg shadow-xl">
            
            <div class="modal-header flex justify-between items-center p-4 border-b">
                <div class="flex flex-col">
                    <h3 class="modal-title text-xl font-bold text-red-600">수술 처방 추가</h3>
                    <span class="text-xs text-gray-500 font-normal">수술 검색 후 선택하여 적용</span>
                </div>
                <button class="btn btn-icon btn-ghost text-2xl" onclick="closeModal('modal-operation')">×</button>
            </div>

            <div class="modal-body flex-1 flex gap-4 p-6 overflow-hidden min-h-0">
                
                <div class="flex-1 flex flex-col border rounded-lg overflow-hidden">
                    <div class="p-4 border-b bg-gray-50 space-y-2">
                        <label class="text-sm font-bold text-gray-700 flex items-center gap-1">
                            <span class="w-1 h-4 bg-red-500 rounded-full inline-block"></span> 수술 검색
                        </label>
                        <div class="flex gap-2">
                            <select class="border rounded px-2 text-sm"><option value="all">전체</option></select>
                            <div class="relative flex-1">
                                <input type="text" id="op-search-input" onkeyup="handleSearch(this, 'operation')"
                                       class="w-full border rounded px-3 py-2 text-sm pl-8" placeholder="검색어 입력 (예: 맹장수술)">
                                <svg class="w-4 h-4 absolute left-2.5 top-2.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                            </div>
                            <button onclick="clearInput('op-search-input'); document.getElementById('op-left-list').innerHTML='';" class="btn btn-sm border">초기화</button>
                        </div>
                    </div>
                    <div class="relative flex-1 overflow-y-auto custom-scrollbar">
                        <div id="op-loading" class="hidden absolute inset-0 bg-white/80 z-20 flex items-center justify-center"><div class="animate-spin h-6 w-6 border-2 border-red-500 rounded-full border-t-transparent"></div></div>
                        <ul id="op-left-list" class="divide-y divide-gray-100">
                            <li class="py-8 text-center text-gray-400 text-sm">검색어를 입력하세요.</li>
                        </ul>
                    </div>
                </div>

                <div class="w-[40%] flex flex-col border rounded-lg overflow-hidden">
                    <div class="p-4 border-b bg-red-50/50 flex justify-between items-center">
                        <label class="text-sm font-bold text-gray-700">선택 목록</label>
                        <button onclick="removeAllStagedOperation()" class="text-xs text-red-500 border border-red-200 bg-white px-2 py-1 rounded">전체 삭제</button>
                    </div>
                    <div class="flex-1 overflow-y-auto p-2 space-y-2 bg-gray-50/30" id="op-right-list">
                        <div id="op-empty-msg" class="h-full flex items-center justify-center text-gray-400 text-sm">추가된 항목이 없습니다.</div>
                    </div>
                </div>
            </div>

            <div class="modal-footer flex justify-end gap-2 p-4 border-t bg-gray-50">
                <button class="btn btn-secondary" onclick="closeModal('modal-operation')">취소</button>
                <button class="btn bg-red-600 text-white hover:bg-red-700" onclick="applyStagedOperation()">수술 적용</button>
            </div>
        </div>
    </div>

    <div id="modal-examination" class="modal-overlay fixed inset-0 flex items-center justify-center bg-black/50 backdrop-blur-sm z-[9000]">
        <div class="modal h-[85vh] w-[90vw] max-w-[1200px] flex flex-col bg-white rounded-xl shadow-2xl overflow-hidden">
            
            <div class="modal-header flex justify-between items-center px-6 py-3 border-b bg-white z-10">
                <div class="flex flex-col">
                    <h3 class="text-xl font-extrabold text-slate-800">영상 검사 오더</h3>
                    <span class="text-xs text-slate-500 mt-1">환부를 선택하고 검사 종류를 입력하세요.</span>
                </div>
                <button class="btn btn-icon btn-ghost text-2xl text-slate-400 hover:text-slate-600" onclick="closeModal('modal-examination')">×</button>
            </div>

            <div class="modal-body flex-1 flex overflow-hidden bg-slate-50">
                
                <div class="w-[400px] flex flex-col items-center bg-white border-r border-slate-200 p-6 shadow-sm relative">
                    
                    <div class="w-full mb-4">
                        <label class="block text-xs font-bold text-slate-500 mb-1">검사 구분 (Modality)</label>
                        <select id="exam-modality-select" class="w-full border border-slate-300 rounded-lg px-3 py-2 text-sm font-bold text-slate-700 focus:outline-none focus:border-indigo-500 focus:ring-1 focus:ring-indigo-500 bg-white">
                            <option value="X-Ray">X-Ray (일반촬영)</option>
                            <option value="CT">CT (컴퓨터단층촬영)</option>
                            <option value="MRI">MRI (자기공명영상)</option>
                        </select>
                    </div>




                    <div class="flex-1 flex items-center justify-center w-full relative">
                        </div>
                    <div class="flex-1 flex items-center justify-center w-full relative">
                        <span class="absolute top-16 left-12 text-6xl font-black text-red-400 select-none pointer-events-none z-0">R</span>
                        <span class="absolute top-16 right-12 text-6xl font-black text-blue-400 select-none pointer-events-none z-0">L</span>
                        <svg xmlns="http://www.w3.org/2000/svg" width="199" height="525" viewBox="0 0 153 404" fill="none" id="human-body-svg" class="h-full w-auto drop-shadow-xl cursor-pointer">
                            <g id="body-paths">
                                <path d="M138.301 219.803L142.011 216.105C142.649 220.064 143.816 224.067 144.54 228.012C144.751 229.167 145.461 232.095 144.917 233.003C143.772 234.9 142.12 232.749 141.598 231.485C140.113 227.86 139.533 223.588 138.301 219.796V219.803Z"></path>
                                <path d="M145.831 206.842C146.352 207.91 146.867 208.993 147.534 210.017C148.766 211.928 150.374 213.497 151.715 215.291C152.918 216.904 151.143 217.427 149.729 217.231C148.555 217.071 146.504 215.546 145.628 214.717C145.374 214.478 144.83 213.773 144.222 213.061L145.838 206.835L145.831 206.842Z"></path>
                                <path d="M76.057 64.8039V51.8213H65.6141C65.7446 55.5773 65.3677 62.7697 61.9399 64.8039H76.057Z"></path>
                                <path d="M76.0566 0C67.7082 0.01453 59.5119 4.90388 57.7001 13.9488C57.0117 17.3997 57.2653 20.9232 57.4465 24.4177C52.9389 23.2626 54.3303 28.4788 54.9246 31.0434C55.4173 33.1575 56.2363 36.9571 58.8307 37.1533C59.4394 42.4713 61.5845 47.5931 65.5848 51.2183C65.5921 51.4072 65.6066 51.6106 65.6138 51.8286H76.0566V0Z"></path>
                                <path d="M13.8127 219.803L10.1022 216.105C9.46451 220.064 8.29775 224.067 7.57306 228.012C7.3629 229.167 6.6527 232.095 7.19622 233.003C8.34124 234.9 9.99354 232.749 10.5153 231.485C12.0009 227.86 12.5807 223.588 13.8127 219.796V219.803Z"></path>
                                <path d="M6.28306 206.842C5.76128 207.91 5.24675 208.993 4.58003 210.017C3.34805 211.928 1.73923 213.497 0.398546 215.291C-0.804447 216.904 0.971054 217.427 2.38421 217.231C3.55821 217.071 5.6091 215.546 6.48598 214.717C6.73962 214.478 8.89126 212.212 9.5 211.5L6.27582 206.835L6.28306 206.842Z"></path>
                                <path d="M13.2186 226.53C12.8563 228.528 11.7547 231.928 11.7185 233.744C11.6678 236.251 14.2622 237.086 15.3565 234.602L18.5379 220.907L14.2839 220.282C13.8491 222.353 13.5955 224.452 13.2186 226.53Z"></path>
                                <path d="M19.0016 220.973C18.9146 224.605 17.8348 228.753 17.7841 232.335C17.7478 234.98 20.3495 235.597 21.3568 233.112C21.9873 229.4 22.3569 225.615 23.0598 221.917C23.1323 221.539 23.4657 219.491 23.7628 219.352H23.7338L19.0016 220.965V220.973Z"></path>
                                <path d="M24.0598 221.176C23.9584 223.697 23.3062 226.726 23.4511 229.189C23.6323 232.291 26.2629 231.107 26.7919 228.441C27.3862 225.455 27.1325 221.946 27.5529 218.917C27.6253 218.394 27.7413 217.87 27.8717 217.34L25.3136 218.59L23.7917 219.338C24.2048 219.745 24.0816 220.617 24.0598 221.169V221.176Z"></path>
                                <path d="M43.3516 132.245C43.6052 130.189 43.6414 128.031 43.9603 125.954L27.6112 123.215C27.575 123.549 27.546 123.883 27.5097 124.217C26.8793 129.818 24.7776 134.454 23.4442 139.844C23.3282 140.324 23.2195 140.81 23.1108 141.297L41.6485 144.407C42.2863 140.367 42.8515 136.313 43.3516 132.252V132.245Z"></path>
                                <path d="M41.6482 144.392L23.1105 141.283C20.4654 153.045 20.7045 165.729 19.5305 177.753C19.2044 181.139 18.8565 186.035 18.1318 189.944L30.2777 191.978C32.075 185.076 34.4012 178.174 36.1767 171.251C38.4523 162.388 40.2278 153.415 41.6482 144.385V144.392Z"></path>
                                <path d="M17.3928 193.053C16.342 196.402 13.0592 198.611 10.4575 200.965L29.3141 204.125C29.2996 203.762 29.2851 203.398 29.2633 203.035C29.0387 199.003 28.8793 197.536 29.8721 193.533C30.0025 193.017 30.1402 192.501 30.2707 191.985L18.1248 189.951C17.9146 191.084 17.6755 192.145 17.3856 193.053H17.3928Z"></path>
                                <path d="M44.3223 124.145C44.3513 124.021 44.3513 123.847 44.3948 123.73V68.7415C37.6334 70.9356 32.4808 74.5826 30.5748 82.9955C27.6326 96.0071 28.9443 110.043 27.6108 123.207L43.9599 125.946C44.0542 125.336 44.1629 124.733 44.3223 124.145Z"></path>
                                <path d="M10.4647 200.965C9.84145 201.524 9.25445 202.098 8.75441 202.694C7.68911 203.958 6.98616 205.389 6.2832 206.842L9.5 211.5C9.5 211.5 9.79797 210.998 10.298 211.332C10.7328 212.865 10.356 214.536 10.1096 216.083C10.1096 216.09 10.1096 216.098 10.1023 216.105L13.8128 219.796C13.9215 219.461 14.0229 219.135 14.1389 218.808L14.2403 219.81L14.2911 220.261L18.545 220.885L18.5813 220.718L18.661 220.37C18.9726 220.442 19.0088 220.682 19.0016 220.958L23.7918 219.331L25.3137 218.59L27.8718 217.34C28.1472 216.221 28.4951 215.095 28.698 213.962C29.2778 210.693 29.4444 207.409 29.3212 204.118L10.4647 200.957V200.965Z"></path>
                                <path d="M76.0568 152.863H45.9603C45.9095 153.67 45.8588 154.476 45.7936 155.268C45.0616 163.499 43.4456 171.614 42.1411 179.773H76.0641V152.863H76.0568Z"></path>
                                <path d="M44.3877 261.998C44.924 270.331 44.5254 278.497 44.7573 286.895C44.7718 287.505 44.8008 288.108 44.8225 288.711H73.2595C73.2595 288.283 73.2668 287.854 73.2668 287.433C73.2668 278.729 73.1871 270.549 73.5566 261.998H44.3877Z"></path>
                                <path d="M73.7958 257.436C74.4988 246.327 75.0278 235.285 75.4988 224.198H40.6338C41.4527 235.444 42.8514 246.654 44.0471 257.959C44.192 259.31 44.2935 260.654 44.3805 261.991H73.5494C73.6146 260.487 73.6943 258.969 73.7886 257.436H73.7958Z"></path>
                                <path d="M75.7379 218.59C75.7887 217.413 75.8321 216.243 75.8829 215.066C75.8901 214.834 75.8539 214.463 76.0568 214.456V179.765H42.1338C41.4961 183.732 40.9309 187.699 40.5758 191.702C39.5974 202.636 39.8511 213.431 40.641 224.191H75.506C75.5857 222.324 75.6655 220.457 75.7452 218.582L75.7379 218.59Z"></path>
                                <path d="M44.0544 394.824C42.6485 396.117 40.4744 397.185 39.7932 399.096C38.9743 401.414 39.9888 402.053 41.9672 402.838C43.5543 403.47 45.8661 403.862 47.5329 403.971C48.562 404.036 49.6273 403.92 50.6636 403.971L54.2871 403.332C57.6062 402.591 61.3601 400.985 63.7226 398.311L44.1486 394.737C44.1486 394.737 44.0906 394.795 44.0616 394.824H44.0544Z"></path>
                                <path d="M76.0569 123.621H44.5762C44.7936 125.445 45.1052 127.283 45.2719 129.114C45.9676 136.728 46.4386 145.111 45.9603 152.863H76.0569V123.621Z"></path>
                                <path d="M44.1411 394.744L63.7151 398.319C64.4181 397.527 64.9978 396.641 65.4036 395.66C66.9328 391.947 67.0052 391.976 69.4402 388.896C71.6215 386.135 71.4983 383.091 70.9331 379.975H53.5911C51.8736 384.573 47.0326 392.027 44.1411 394.744Z"></path>
                                <path d="M54.0914 378.384C53.9827 378.856 53.8088 379.393 53.5986 379.967H70.9406C70.5927 378.064 70.0854 376.139 69.8245 374.221C69.4984 371.801 69.3173 369.237 69.2375 366.607H54.019C54.5407 370.763 54.8451 375.071 54.0914 378.376V378.384Z"></path>
                                <path d="M52.9031 358.761C53.2075 361.078 53.664 363.81 54.0191 366.614H69.2377C68.9841 358.238 69.7522 349.113 70.1436 341.303C71.0205 323.772 73.1655 306.22 73.2598 288.719H44.8228C45.6562 312.635 49.7652 335.149 52.8958 358.761H52.9031Z"></path>
                                <path d="M44.5762 123.621H76.0569V64.8039H61.9399C61.6862 64.9492 61.4181 65.0727 61.1355 65.1671C58.3309 66.0607 54.1929 66.3659 51.1492 67.0052C48.7722 67.5137 46.5039 68.0586 44.395 68.7415V123.73C44.424 123.658 44.4747 123.607 44.5762 123.621Z"></path>
                                <path d="M76.0566 64.8039V51.8213H86.4995C86.369 55.5773 86.7459 62.7697 90.1737 64.8039H76.0566Z"></path>
                                <path d="M76.0566 0C84.4051 0.01453 92.6014 4.90388 94.4132 13.9488C95.1016 17.3997 94.848 20.9232 94.6668 24.4177C99.1744 23.2626 97.783 28.4788 97.1887 31.0434C96.6959 33.1575 95.877 36.9571 93.2826 37.1533C92.6739 42.4713 90.5288 47.5931 86.5285 51.2183C86.5212 51.4072 86.5067 51.6106 86.4995 51.8286H76.0566V0Z"></path>
                                <path d="M138.895 226.53C139.257 228.528 140.359 231.928 140.395 233.744C140.446 236.251 137.851 237.086 136.757 234.602L133.576 220.907L137.83 220.282C138.264 222.353 138.518 224.452 138.895 226.53Z"></path>
                                <path d="M133.112 220.973C133.199 224.605 134.279 228.753 134.33 232.335C134.366 234.98 131.764 235.597 130.757 233.112C130.127 229.4 129.757 225.615 129.054 221.917C128.982 221.539 128.648 219.491 128.351 219.352H128.38L133.112 220.965V220.973Z"></path>
                                <path d="M128.054 221.176C128.155 223.697 128.807 226.726 128.662 229.189C128.481 232.291 125.851 231.107 125.321 228.441C124.727 225.455 124.981 221.946 124.561 218.917C124.488 218.394 124.372 217.87 124.242 217.34L126.8 218.59L128.322 219.338C127.909 219.745 128.032 220.617 128.054 221.169V221.176Z"></path>
                                <path d="M108.763 132.245C108.509 130.189 108.473 128.031 108.154 125.954L124.503 123.215C124.539 123.549 124.568 123.883 124.604 124.217C125.235 129.818 127.336 134.454 128.67 139.844C128.786 140.324 128.895 140.81 129.003 141.297L110.466 144.407C109.828 140.367 109.263 136.313 108.763 132.252V132.245Z"></path>
                                <path d="M110.465 144.392L129.003 141.283C131.648 153.045 131.409 165.729 132.583 177.753C132.909 181.139 133.257 186.035 133.982 189.944L121.836 191.978C120.039 185.076 117.712 178.174 115.937 171.251C113.661 162.388 111.886 153.415 110.465 144.385V144.392Z"></path>
                                <path d="M134.721 193.053C135.772 196.402 139.055 198.611 141.656 200.965L122.8 204.125C122.814 203.762 122.829 203.398 122.851 203.035C123.075 199.003 123.235 197.536 122.242 193.533C122.111 193.017 121.974 192.501 121.843 191.985L133.989 189.951C134.199 191.084 134.438 192.145 134.728 193.053H134.721Z"></path>
                                <path d="M107.799 124.145C107.77 124.021 107.77 123.847 107.726 123.73V68.7415C114.487 70.9356 119.64 74.5826 121.546 82.9955C124.488 96.0071 123.177 110.043 124.51 123.207L108.161 125.946C108.067 125.336 107.958 124.733 107.799 124.145Z"></path>
                                <path d="M141.649 200.965C142.272 201.524 142.859 202.098 143.359 202.694C144.425 203.958 145.128 205.389 145.831 206.842L144.215 213.061C143.338 212.037 142.316 210.998 141.816 211.332C141.381 212.865 141.758 214.536 142.004 216.083C142.004 216.09 142.004 216.098 142.011 216.105L138.301 219.796C138.192 219.461 138.091 219.135 137.975 218.808L137.873 219.81L137.823 220.261L133.569 220.885L133.533 220.718L133.453 220.37C133.141 220.442 133.105 220.682 133.112 220.958L128.322 219.331L126.8 218.59L124.242 217.34C123.967 216.221 123.619 215.095 123.416 213.962C122.836 210.693 122.669 207.409 122.793 204.118L141.649 200.957V200.965Z"></path>
                                <path d="M76.057 152.863H106.154C106.204 153.67 106.255 154.476 106.32 155.268C107.052 163.499 108.668 171.614 109.973 179.773H76.0498V152.863H76.057Z"></path>
                                <path d="M107.726 261.998C107.19 270.331 107.588 278.497 107.356 286.895C107.342 287.505 107.313 288.108 107.291 288.711H78.8543C78.8543 288.283 78.847 287.854 78.847 287.433C78.847 278.729 78.9267 270.549 78.5571 261.998H107.726Z"></path>
                                <path d="M78.3178 257.436C77.6148 246.327 77.0858 235.285 76.6147 224.198H111.48C110.661 235.444 109.262 246.654 108.066 257.959C107.922 259.31 107.82 260.654 107.733 261.991H78.5642C78.499 260.487 78.4192 258.969 78.325 257.436H78.3178Z"></path>
                                <path d="M76.3755 218.59C76.3248 217.413 76.2813 216.243 76.2306 215.066C76.2233 214.834 76.2596 214.463 76.0566 214.456V179.765H109.98C110.617 183.732 111.183 187.699 111.538 191.702C112.516 202.636 112.262 213.431 111.472 224.191H76.6074C76.5277 222.324 76.448 220.457 76.3683 218.582L76.3755 218.59Z"></path>
                                <path d="M108.059 394.824C109.465 396.117 111.639 397.185 112.321 399.096C113.139 401.414 112.125 402.053 110.146 402.838C108.559 403.47 106.248 403.971 104.581 403.971C103.552 404.036 102.486 403.92 101.45 403.971L97.8266 403.332C94.5075 402.591 90.7536 400.985 88.3911 398.311L107.965 394.737C107.965 394.737 108.023 394.795 108.052 394.824H108.059Z"></path>
                                <path d="M76.0566 123.621H107.537C107.32 125.445 107.008 127.283 106.842 129.114C106.146 136.728 105.675 145.111 106.153 152.863H76.0566V123.621Z"></path>
                                <path d="M107.972 394.744L88.3983 398.319C87.6954 397.527 87.1156 396.641 86.7098 395.66C85.1807 391.947 85.1082 391.976 82.6732 388.896C80.4919 386.135 80.6151 383.091 81.1803 379.975H98.5223C100.24 384.573 105.081 392.027 107.972 394.744Z"></path>
                                <path d="M98.0225 378.384C98.1312 378.856 98.3051 379.393 98.5153 379.967H81.1733C81.5212 378.064 82.0285 376.139 82.2894 374.221C82.6155 371.801 82.7967 369.237 82.8764 366.607H98.095C97.5732 370.763 97.2688 375.071 98.0225 378.376V378.384Z"></path>
                                <path d="M99.218 358.761C98.9136 361.078 98.4571 363.81 98.102 366.614H82.8834C83.137 358.238 82.3689 349.113 81.9775 341.303C81.1006 323.772 78.9555 306.22 78.8613 288.719H107.298C106.465 312.635 102.356 335.149 99.2252 358.761H99.218Z"></path>
                                <path d="M107.537 123.621H76.0566V64.8039H90.1737C90.4273 64.9492 90.6955 65.0727 90.9781 65.1671C93.7827 66.0607 97.9207 66.3659 100.964 67.0052C103.341 67.5137 105.61 68.0586 107.719 68.7415V123.73C107.69 123.658 107.639 123.607 107.537 123.621Z"></path>
                            </g>
                            <defs>
                            <clipPath id="clip0_4726_1938">
                            <rect width="152.113" height="404" fill="white"></rect>
                            </clipPath>
                            </defs>
                        </svg>
                    </div>


                </div>

                <div class="flex-1 flex flex-col p-8 overflow-hidden">
                                        <div class="w-full mb-2 px-2">
                        <div id="anatomy-info-display" class="w-full h-12 rounded-lg bg-slate-100 border border-slate-200 flex items-center justify-center gap-2 transition-all duration-200">
                            <span class="text-xs font-bold text-slate-400 animate-pulse">
                                인체 모형에 마우스를 올려보세요
                            </span>
                        </div>
                    </div>
                    <div class="mt-4 w-full flex flex-col h-[80vh] overflow-y-auto"> <div class="flex justify-between items-end mb-2">
                            <label class="text-xs font-bold text-slate-500">선택된 오더 목록</label>
                            <button type="button" onclick="clearAllSelectedSites()" class="text-[10px] text-slate-400 hover:text-red-500 underline decoration-slate-300 hover:decoration-red-500 transition-colors">
                                전체 초기화
                            </button>
                        </div>
                        
                        <div class="grid grid-cols-12 bg-slate-100 text-xs font-bold text-slate-500 py-1.5 px-2 rounded-t border border-slate-200 text-center">
                            <div class="col-span-3">구분</div>
                            <div class="col-span-6">부위</div>
                            <div class="col-span-2">방향</div>
                            <div class="col-span-1">삭제</div>
                        </div>
                        <div id="selected-site-container" class="flex-1 overflow-y-auto custom-scrollbar border-x border-b border-slate-200 rounded-b bg-white">
                            <div id="site-placeholder" class="h-full flex flex-col items-center justify-center text-slate-300 text-xs">
                                <span>장비를 선택하고<br>환부를 클릭하세요.</span>
                            </div>
                        </div>
                    </div>

                    <div class="mt-6 bg-indigo-50 rounded-lg p-4 text-xs text-indigo-700 leading-relaxed border border-indigo-100">
                        <p class="font-bold mb-1 flex items-center gap-1">ℹ️ 안내사항</p>
                        검사 판부 체크 및 오더 내용을 작성하신 후 '요청' 버튼을 클릭하시면 영상실로 오더가 접수됩니다.<br>
                        원활한 검사를 위해 환자 분께 영상실 이동 안내를 부탁드립니다.
                    </div>

                </div>
            </div>

            <div class="modal-footer flex justify-end gap-3 px-8 py-3 border-t bg-white">
                <button class="px-6 py-2 rounded-lg border border-slate-300 text-slate-600 font-bold hover:bg-slate-50 transition-colors" onclick="closeModal('modal-examination')">취소</button>
                <button class="px-6 py-2 rounded-lg bg-indigo-600 text-white font-bold shadow-lg hover:bg-indigo-700 hover:shadow-xl transition-all" onclick="applyStagedExamination()">영상 검사 요청</button>
            </div>
        </div>
    </div>
</div>

<script>
    /* ==================================================================================
       1. 전역 변수 설정
       ================================================================================== */
    let debounceTimer;

    let stagedDiagnosisList = [];   // 상병
    let stagedTreatmentList = [];   // 치료
    let stagedMedicationList = [];  // 약제
    let stagedOperationList = [];   // 수술
    let stagedExaminationList = []; // 영상 검사 (신규 로직)

    let currentTxMode = 'treatment';

    /* ==================================================================================
       2. 초기화 및 이벤트 리스너 (DOMContentLoaded)
       ================================================================================== */
    document.addEventListener('DOMContentLoaded', async function() {

        // 1. DB 데이터 가져오기 (부위 정보)
        const svgData = await selectAnatomy();

        // 2. 엘리먼트 가져오기
        const svgContainer = document.querySelector('#human-body-svg');
        const modalitySelect = document.getElementById('exam-modality-select');
        const infoDisplay = document.getElementById('anatomy-info-display');

        if (svgContainer) {
            const allPaths = svgContainer.querySelectorAll('path');

            // SVG 초기화
            allPaths.forEach((path, index) => {
                let dbInfo = (svgData && svgData[index]) ? svgData[index] : {};

                // 스타일 초기화
                path.style.fill = '#D4D4D8';
                path.style.stroke = '#adb5bd';
                path.classList.add('cursor-pointer', 'transition-colors', 'duration-200', 'ease-in-out', 'hover:!fill-sky-200');

                // 데이터 속성 주입
                if (!path.id) path.id = 'body-part-' + index;
                path.setAttribute('data-name', dbInfo.anatomyName || '부위');
                path.setAttribute('data-side', dbInfo.anatomyDirection || 'None');

                // [이벤트] 마우스 오버 효과
                path.addEventListener('mouseenter', (e) => {
                    const target = e.target;
                    const isRight = target.getAttribute('data-side') === '우' || target.getAttribute('data-side') === 'Right';
                    const badgeColor = isRight ? 'bg-orange-100 text-orange-700 border-orange-200' : 'bg-indigo-100 text-indigo-700 border-indigo-200';
                    const dirText = isRight ? '우(R)' : '좌(L)';

                    if (infoDisplay) {
                        infoDisplay.className = `w-full h-12 rounded-lg border-2 flex items-center justify-center gap-3 transition-all duration-200 bg-white shadow-sm \${isRight ? 'border-orange-500' : 'border-indigo-500'}`;
                        infoDisplay.innerHTML = `
                            <span class="px-3 py-1 rounded text-[10px] font-black border \${badgeColor}">\${dirText}</span>
                            <span class="text-lg font-extrabold text-slate-700 tracking-tight">\${target.getAttribute('data-name')}</span>
                        `;
                    }
                });

                // [이벤트] 마우스 아웃 효과
                path.addEventListener('mouseleave', () => {
                    if (infoDisplay) {
                        infoDisplay.className = "w-full h-12 rounded-lg bg-slate-100 border border-slate-200 flex items-center justify-center gap-2 transition-all duration-200";
                        infoDisplay.innerHTML = `<span class="text-xs font-bold text-slate-400 animate-pulse">인체 모형에 마우스를 올려보세요</span>`;
                    }
                });
            });

            // ★★★ SVG 클릭 이벤트 (바로 리스트 추가) ★★★
            svgContainer.addEventListener('click', function(e) {
                if (e.target.tagName !== 'path') return;

                const target = e.target;
                const partId = target.id;
                const partName = target.getAttribute('data-name');
                const partSide = target.getAttribute('data-side');
                const modality = modalitySelect ? modalitySelect.value : 'X-Ray';

                // 바로 리스트에 추가하는 함수 호출
                // addDirectExamination(modality, partName, partSide, partId);

                // 클릭 색상 변경 (주황색)
                toggleDirectExamination(modality, partName, partSide, partId);
                // target.style.fill = '#E76E50';
            });
        }
    });

    /* ==================================================================================
       3. [영상 검사] 리스트 관리 로직 (신규)
       ================================================================================== */

    // (A) 리스트에 추가
    // (A) [수정됨] 리스트 추가/삭제 토글 함수 (검증 로직 포함)
    function toggleDirectExamination(modality, partName, partSide, originId) {
        // 고유 ID 생성
        const tempId = `\${modality}-\${originId}`;

        // 1. 이미 리스트에 있는지 확인
        const existingIndex = stagedExaminationList.findIndex(item => item.uniqueId === tempId);

        if (existingIndex !== -1) {
            // [이미 있음] -> 다시 눌렀으니 삭제 (Toggle Off)
            removeStagedExamination(tempId);
        } else {
            // [없음] -> 신규 추가 (Toggle On)
            
            // 방향 변환
            let lat = 'None';
            if (partSide === '좌' || partSide === 'Left') lat = '좌';
            else if (partSide === '우' || partSide === 'Right') lat = '우';

            stagedExaminationList.push({
                uniqueId: tempId,
                modality: modality,
                site: partName,
                laterality: lat,
                originId: originId
            });

            // ★ 추가됐으니 해당 부위 색상을 주황색으로 변경
            const path = document.getElementById(originId);
            if(path) {
                path.style.fill = '#E76E50';
            }

            renderStagedExaminationList();
        }
    }

    // (B) 화면 그리기
    function renderStagedExaminationList() {
        const container = document.getElementById('selected-site-container');
        const placeholder = document.getElementById('site-placeholder');

        if (!container) return;

        // 기존 리스트만 지우기
        const existingRows = container.querySelectorAll('div[id^="row-"]');
        existingRows.forEach(el => el.remove());

        // 데이터 없으면 placeholder 보이기
        if (stagedExaminationList.length === 0) {
            if (placeholder) placeholder.classList.remove('hidden');
            return;
        }

        // 데이터 있으면 placeholder 숨기기
        if (placeholder) placeholder.classList.add('hidden');

        // 리스트 아이템 생성
        stagedExaminationList.forEach((item) => {
            const div = document.createElement('div');
            div.id = 'row-' + item.uniqueId;
            div.className = "grid grid-cols-12 items-center py-2 px-2 border-b border-slate-50 text-xs hover:bg-slate-50 transition-colors animate-fade-in";

            // 방향 뱃지 스타일
            let latDisplay = '-';
            let badgeColor = 'bg-gray-100 text-gray-600';
            if (item.laterality === '좌') { latDisplay = '좌(L)'; badgeColor = 'bg-blue-50 text-blue-600 border-blue-100'; } 
            else if (item.laterality === '우') { latDisplay = '우(R)'; badgeColor = 'bg-red-50 text-red-600 border-red-100'; } 

            div.innerHTML = `
                <div class="col-span-3 flex items-center font-medium text-slate-600 pl-2">\${item.modality}</div>
                <div class="col-span-6 flex items-center truncate px-2 text-slate-700 font-extrabold" title="\${item.site}">\${item.site}</div>
                <div class="col-span-2 flex items-center justify-center">
                    <span class="px-2.5 py-1 rounded-md border \${badgeColor} text-xs font-bold shadow-sm tracking-wide">\${latDisplay}</span>
                </div>
                <div class="col-span-1 flex items-center justify-center">
                    <button onclick="removeStagedExamination('\${item.uniqueId}')" class="p-1 text-slate-400 hover:text-red-500 hover:bg-red-50 rounded-full transition-all">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                    </button>
                </div>
            `;
            container.appendChild(div);
        });
    }

    // (C) 삭제 함수
    // (C) [수정됨] 삭제 함수 (색상 유지 검증 로직 추가)
    function removeStagedExamination(id) {
        // 1. 지울 아이템 임시 저장 (어떤 부위였는지 알기 위해)
        const itemToRemove = stagedExaminationList.find(i => i.uniqueId === id);
        if (!itemToRemove) return;

        // 2. 리스트에서 삭제
        stagedExaminationList = stagedExaminationList.filter(i => i.uniqueId !== id);

        // 3. ★ 핵심 검증: 방금 지운 부위(originId)를 사용하는 다른 오더가 남았나?
        const isStillUsed = stagedExaminationList.some(item => item.originId === itemToRemove.originId);

        // 4. 아무도 안 쓰면 -> 회색으로 복구
        if (!isStillUsed) {
            const path = document.getElementById(itemToRemove.originId);
            if (path) {
                path.style.fill = '#D4D4D8';
                path.style.stroke = '#adb5bd';
            }
        }
        // (만약 X-Ray는 지웠는데 CT가 남아있다면? -> isStillUsed가 true이므로 색상 변경 안 함)

        renderStagedExaminationList();
    }

    // (D) 전체 초기화
    function clearAllSelectedSites() {
        stagedExaminationList = [];
        renderStagedExaminationList();

        const svgContainer = document.querySelector('#human-body-svg');
        if (svgContainer) {
            svgContainer.querySelectorAll('path').forEach(p => {
                p.style.fill = '#D4D4D8';
                p.style.stroke = '#adb5bd';
            });
        }
    }

    // (E) ★★★ [최종] 메인 화면 테이블로 전송 ★★★
    // [수정됨] 모달 -> 메인 화면 데이터 적용
    function applyStagedExamination() {
        // 1. 선택된 항목이 없으면 경고 (선택사항)
        /* if (stagedExaminationList.length === 0) {
            alert("선택된 검사가 없습니다.");
            return;
        }
        */

        const tbody = document.getElementById('exTableBody'); // 메인 테이블 ID
        if (!tbody) return;

        // ★ 핵심: 기존 내용을 비워줍니다. (갱신 기능)
        tbody.innerHTML = ''; 
        
        // 인덱스 초기화
        let exIdx = 1; 

        stagedExaminationList.forEach((item) => {
            // 좌우 텍스트 및 색상 결정
            let latVal = item.laterality;
            let latText = '-';
            let latClass = 'bg-gray-50 text-slate-600 border-slate-200';

            if (latVal === '좌' || latVal === 'L') {
                latText = '좌(L)';
                latClass = 'bg-blue-50 text-blue-600 border-blue-100';
            } else if (latVal === '우' || latVal === 'R') {
                latText = '우(R)';
                latClass = 'bg-red-50 text-red-600 border-red-100';
            }

            let no = '';
            if(item.modality == "X-Ray"){ no = '1' }
            if(item.modality == "MRI"){ no = '3' }
            if(item.modality == "CT"){ no = '4' }

            // HTML 생성 (메인 화면 스타일)
            tbody.innerHTML += `
                <tr class="border-b border-slate-100 hover:bg-slate-50 transition-colors"
                    data-modality="\${no}" 
                    data-site="\${item.site}" 
                    data-laterality="\${item.laterality}">
                    
                    <td class="text-center py-3">\${exIdx++}</td>

                    <td class="text-left py-3 pl-4">\${item.modality}</td>

                    <td class="text-left py-3 pl-4">\${item.site}</td>

                    <td class="text-left py-3">
                        <span class="inline-block px-2 py-0.5 rounded border \${latClass}">
                            \${latText}
                        </span>
                    </td>

                    <td class="text-center py-3">
                        <button onclick="removeList(this)" class="p-1 hover:text-red-500 rounded transition-colors">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                        </button>
                    </td>
                </tr>
            `;
        });

        // 모달 닫기
        closeModal('modal-examination');
    }


    /* ==================================================================================
       4. 공통 함수들 (상병, 약제, 수술 등) - 들여쓰기 정리 완료
       ================================================================================== */

    function openModal(id) {
        if (id === 'modal-diagnosis') {
            syncDiagnosisFromTable();
            selectDiagnosis('', 'diagnosis');
            setTimeout(() => document.getElementById('diag-search-input').focus(), 100);
        }
        if (id === 'modal-treatment') {
            syncTreatmentFromTable();
            selectTreatment('', 'treatment');
            setTimeout(() => document.getElementById('treat-search-input').focus(), 100);
        }
        if (id === 'modal-medication') {
            syncMedicationFromTable();
            selectDrug('', 'medication');
            setTimeout(() => document.getElementById('med-search-input').focus(), 100);
        }
        if (id === 'modal-operation') {
            syncOperationFromTable();
            selectOperation('', 'operation');
            setTimeout(() => document.getElementById('op-search-input').focus(), 100);
        }

        if(id === 'modal-examination') {
            syncExaminationFromTable();
            const modalitySelect = document.getElementById('exam-modality-select');
            if (modalitySelect) modalitySelect.value = 'X-Ray';
        }
        
        const modal = document.getElementById(id);
        if (modal) modal.classList.add('active');
    }

    function closeModal(id) {
        document.getElementById(id).classList.remove('active');
        document.querySelectorAll('.result-list').forEach(el => el.classList.add('hidden'));
    }

    function resetForm(modalId) {
        const inputs = document.getElementById(modalId).querySelectorAll('input:not([type="radio"]):not([type="hidden"])');
        inputs.forEach(input => input.value = '');
        
        if (modalId === 'modal-diagnosis') document.getElementById('diag-left-list').innerHTML = '<li class="py-8 text-center text-gray-400 text-sm">검색어를 입력하세요.</li>';
        if (modalId === 'modal-treatment') document.getElementById('treat-left-list').innerHTML = '<li class="py-8 text-center text-gray-400 text-sm">검색어를 입력하세요.</li>';
        if (modalId === 'modal-medication') document.getElementById('med-left-list').innerHTML = '<li class="py-8 text-center text-gray-400 text-sm">검색어를 입력하세요.</li>';
        if (modalId === 'modal-operation') document.getElementById('op-left-list').innerHTML = '<li class="py-8 text-center text-gray-400 text-sm">검색어를 입력하세요.</li>';
    }

    function clearInput(inputId) {
        const el = document.getElementById(inputId);
        if (el) {
            el.value = '';
            el.focus();
        }
    }

    function changeTxMode(mode) {
        currentTxMode = mode;
        const titleEl = document.getElementById('tx-mode-title');
        const inputEl = document.getElementById('treat-search-input');
        const listEl = document.getElementById('treat-left-list');
        
        if (mode === 'treatment') {
            titleEl.innerHTML = '<span class="w-1 h-4 bg-green-500 rounded-full inline-block"></span> 치료 검색';
            inputEl.placeholder = "검색어 입력 (예: 물리치료)";
        } else {
            titleEl.innerHTML = '<span class="w-1 h-4 bg-blue-500 rounded-full inline-block"></span> 주사 검색';
            inputEl.placeholder = "검색어 입력 (예: 인슐린, 아스피린)";
        }
        clearInput('treat-search-input');
        listEl.innerHTML = '<li class="py-8 text-center text-gray-400 text-sm">검색어를 입력하세요.</li>';
    }

    function handleSearch(input, type) {
        const keyword = input.value.trim().toUpperCase();
        let loadingId = 'med-loading';
        if (type === 'diagnosis') loadingId = 'diag-loading';
        else if (type === 'treatment') loadingId = 'treat-loading';
        else if (type === 'operation') loadingId = 'op-loading';

        const loadingEl = document.getElementById(loadingId);
        if (loadingEl) loadingEl.classList.remove('hidden');

        if (debounceTimer) clearTimeout(debounceTimer);
        debounceTimer = setTimeout(function() {
            if (type === 'diagnosis') selectDiagnosis(keyword, type);
            if (type === 'medication') selectDrug(keyword, type);
            if (type === 'operation') selectOperation(keyword, type);
            if (type === 'treatment') {
                if (currentTxMode === 'treatment') selectTreatment(keyword, type);
                else selectInjection(keyword, type);
            }
        }, 300);
    }

    /* ==================================================================================
       5. API 호출 함수들
       ================================================================================== */
    async function selectAnatomy() {
        try {
            const res = await axios.post("/doctor/api/selectAnatomy", {}, { headers: getApiHeaders() });
            return res.data;
        } catch (e) {
            console.error(e);
            return [];
        }
    }

    function selectDiagnosis(searchWord, type) {
        axios.post("/doctor/api/getDiagnosis", { "searchWord": searchWord }, { headers: getApiHeaders() })
            .then(res => renderResults(res.data, null, type))
            .finally(() => document.getElementById('diag-loading').classList.add('hidden'));
    }

    function selectTreatment(searchWord, type) {
        axios.post("/doctor/api/getTreatment", { "searchWord": searchWord }, { headers: getApiHeaders() })
            .then(res => renderResults(res.data, null, type))
            .finally(() => document.getElementById('treat-loading').classList.add('hidden'));
    }

    function selectDrug(searchWord, type) {
        axios.post("/doctor/api/getDrug", { "searchWord": searchWord }, { headers: getApiHeaders() })
            .then(res => renderResults(res.data, null, type))
            .finally(() => document.getElementById('med-loading').classList.add('hidden'));
    }

    function selectInjection(searchWord, type) {
        axios.post("/doctor/api/getInject", { "searchWord": searchWord }, { headers: getApiHeaders() })
            .then(res => {
                const converted = res.data.map(item => ({
                    treatmentNo: item.drugNo,
                    treatmentCode: item.drugCode,
                    treatmentName: item.drugName,
                    originalType: 'injection'
                }));
                renderResults(converted, null, type);
            })
            .finally(() => document.getElementById('treat-loading').classList.add('hidden'));
    }

    function selectOperation(searchWord, type) {
        axios.post("/doctor/api/getOperation", { "searchWord": searchWord }, { headers: getApiHeaders() })
            .then(res => renderResults(res.data, null, type))
            .finally(() => document.getElementById('op-loading').classList.add('hidden'));
    }

    /* ==================================================================================
       6. 검색 결과 렌더링 (공통)
       ================================================================================== */
    function renderResults(data, listEl, type) {
        let containerId = '';
        if (type === 'diagnosis') containerId = 'diag-left-list';
        else if (type === 'treatment') containerId = 'treat-left-list';
        else if (type === 'medication') containerId = 'med-left-list';
        else if (type === 'operation') containerId = 'op-left-list';

        const container = document.getElementById(containerId);
        if (!container) return;
        container.innerHTML = '';

        if (!data || data.length === 0) {
            container.innerHTML = '<li class="py-8 text-center text-gray-500 text-sm">검색 결과가 없습니다.</li>';
            return;
        }

        data.forEach(function(item) {
            let isAdded = false;
            let code = '', name = '', company = '', clickAction = '';

            if (type === 'diagnosis') {
                isAdded = stagedDiagnosisList.some(s => s.diagnosisCode === item.diagnosisCode);
                code = item.diagnosisCode;
                name = item.diagnosisName;
                clickAction = `stageDiagnosis(\${JSON.stringify(item)})`;
            } else if (type === 'treatment') {
                isAdded = stagedTreatmentList.some(s => s.treatmentCode === item.treatmentCode);
                code = item.treatmentCode;
                name = item.treatmentName;
                clickAction = `stageTreatment(\${JSON.stringify(item)})`;
            } else if (type === 'medication') {
                isAdded = stagedMedicationList.some(s => s.drugCode === item.drugCode);
                code = item.drugCode;
                name = item.drugName;
                company = item.drugCompany || '-';
                clickAction = `stageMedication(\${JSON.stringify(item)})`;
            } else if (type === 'operation') {
                isAdded = stagedOperationList.some(s => s.operationCode === item.operationCode);
                code = item.operationCode;
                name = item.operationName;
                clickAction = `stageOperation(\${JSON.stringify(item)})`;
            }

            let color = (type === 'treatment') ? 'green' : (type === 'medication' ? 'orange' : (type === 'operation' ? 'red' : 'blue'));
            const btnClass = isAdded ? "bg-gray-100 text-gray-400 cursor-not-allowed border-gray-200" : `bg-white border-\${color}-200 text-\${color}-600 hover:bg-\${color}-50 cursor-pointer`;
            const btnText = isAdded ? "추가됨" : "추가";
            let btnPrefix = (type === 'treatment') ? 'btn-treat-' : (type === 'medication' ? 'btn-med-' : (type === 'operation' ? 'btn-op-' : 'btn-'));

            const li = document.createElement('li');
            li.className = "grid grid-cols-12 items-center py-2 px-4 hover:bg-gray-50 transition-colors group border-b border-gray-50 last:border-0";
            li.innerHTML = `
                <div class="col-span-3 text-left pl-2 font-mono text-xs font-bold text-gray-600">\${code}</div>
                <div class="col-span-\${type === 'medication' ? 4 : 7} text-left text-sm text-gray-900 truncate pr-2" title="\${name}">\${name}</div>
                \${type === 'medication' ? `<div class="col-span-3 text-left text-xs text-gray-500 truncate">\${company}</div>` : ''}
                <div class="col-span-2 text-center">
                    <button type="button" id="\${btnPrefix}\${code}" onclick='\${clickAction}' class="px-2 py-1 text-xs border rounded shadow-sm transition-colors \${btnClass}">\${btnText}</button>
                </div>
            `;
            container.appendChild(li);
        });
    }

    /* ==================================================================================
       7. 동기화 및 Staging 함수들 (Diagnosis, Treatment, Medication, Operation)
       ================================================================================== */

    // 1. Treatment (치료)
    function syncTreatmentFromTable() {
        stagedTreatmentList = [];
        document.querySelectorAll('#txTableBody tr').forEach(row => {
            const inputs = row.querySelectorAll('input');
            stagedTreatmentList.push({
                treatmentNo: row.dataset.no,
                treatmentCode: row.dataset.code,
                treatmentName: row.dataset.name,
                groupType: row.dataset.group || 'treatment',
                typeDisplay: row.children[1].innerText,
                dose: inputs[0].value || 0,
                freq: inputs[1].value,
                days: inputs[2].value
            });
        });
        renderStagedTreatmentList();
    }

    function stageTreatment(item) {
        if (stagedTreatmentList.some(s => s.treatmentCode === item.treatmentCode)) return;
        let group = (currentTxMode === 'injection' || item.originalType === 'injection') ? 'injection' : 'treatment';
        stagedTreatmentList.push({
            treatmentNo: item.treatmentNo,
            treatmentCode: item.treatmentCode,
            treatmentName: item.treatmentName,
            groupType: group,
            typeDisplay: (group === 'injection') ? '주사' : '치료',
            dose: (group === 'treatment') ? 0 : 1,
            freq: (group === 'treatment') ? '1' : 1,
            days: 1
        });
        renderStagedTreatmentList();
        updateBtnState('btn-treat-' + item.treatmentCode, true, 'treat');
    }

    function removeStagedTreatment(code) {
        stagedTreatmentList = stagedTreatmentList.filter(item => item.treatmentCode !== code);
        renderStagedTreatmentList();
        updateBtnState('btn-treat-' + code, false, 'treat');
    }

    function removeAllStagedTreatment() {
        stagedTreatmentList.forEach(item => updateBtnState('btn-treat-' + item.treatmentCode, false, 'treat'));
        stagedTreatmentList = [];
        renderStagedTreatmentList();
    }

    function renderStagedTreatmentList() {
        const container = document.getElementById('treat-right-list');
        const emptyMsg = document.getElementById('treat-empty-msg');
        if (stagedTreatmentList.length === 0) {
            container.innerHTML = '';
            container.appendChild(emptyMsg);
            emptyMsg.classList.remove('hidden');
            return;
        }
        emptyMsg.classList.add('hidden');
        container.innerHTML = '';
        container.appendChild(emptyMsg);
        stagedTreatmentList.forEach(item => {
            let isInj = (item.groupType === 'injection');
            const div = document.createElement('div');
            div.className = "flex justify-between items-center bg-white p-3 rounded border border-gray-200 shadow-sm mb-2";
            div.innerHTML = `
                <div class="flex flex-col w-full overflow-hidden">
                    <div class="flex items-center gap-2 mb-1">
                        <span class="text-[10px] font-bold px-1.5 py-0.5 rounded border \${isInj ? "bg-blue-100 text-blue-700" : "bg-green-100 text-green-700"}">\${item.typeDisplay}</span>
                        <span class="text-xs font-bold text-gray-400 bg-gray-50 px-1.5 rounded">\${item.treatmentCode}</span>
                    </div>
                    <span class="text-sm text-gray-800 font-medium truncate">\${item.treatmentName}</span>
                </div>
                <button onclick="removeStagedTreatment('\${item.treatmentCode}')" class="text-gray-300 hover:text-red-500 ml-2">×</button>
            `;
            container.appendChild(div);
        });
    }

    function applyStagedTreatment() {
        if (stagedTreatmentList.length === 0) {
            sweetAlert("warning", "선택된 항목이 없습니다.", "확인");
            return;
        }
        let tbody = document.getElementById('txTableBody');
        tbody.innerHTML = '';
        stagedTreatmentList.forEach((item, i) => {
            let doseDisabled = (item.groupType === 'treatment') ? 'disabled style="background-color: #f3f4f6;"' : '';
            tbody.innerHTML += `
                <tr class="border-b border-slate-100 hover:bg-slate-50 transition-colors" 
                    data-no="\${item.treatmentNo}" 
                    data-code="\${item.treatmentCode}" 
                    data-name="\${item.treatmentName}" 
                    data-group="\${item.groupType}">
                    
                    <td class="text-center py-3">\${i+1}</td>
                    
                    <td class="text-center py-3">
                        <span class="inline-block px-2 py-0.5 rounded border \${item.groupType === 'injection' ? 'bg-blue-50 text-blue-600 border-blue-100' : 'bg-green-50 text-green-600 border-green-100'}">
                            \${item.typeDisplay}
                        </span>
                    </td>
                    
                    <td class="text-center py-3">\${item.treatmentCode}</td>
                    
                    <td class="text-left py-3 pl-4">\${item.treatmentName}</td>
                    
                    <td class="text-center py-3">
                        <input min="0" type="number" class="w-full border rounded px-1 py-1 text-center focus:outline-none focus:border-blue-500 bg-transparent transition-colors" 
                               value="\${item.dose}" \${doseDisabled} />
                    </td>
                    
                    <td class="text-center py-3">
                        <input type="text" class="w-full border rounded px-1 py-1 text-center focus:outline-none focus:border-blue-500 bg-transparent transition-colors" 
                               value="\${item.freq}" />
                    </td>
                    
                    <td class="text-center py-3">
                        <input min="0" type="number" class="w-full border rounded px-1 py-1 text-center focus:outline-none focus:border-blue-500 bg-transparent transition-colors" 
                               value="\${item.days}" />
                    </td>
                    
                    <td class="text-center py-3">
                        <button onclick="removeList(this)" class="p-1 hover:text-red-500 rounded transition-colors">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                        </button>
                    </td>
                </tr>
            `;
        });
        stagedTreatmentList = [];
        renderStagedTreatmentList();
        resetForm('modal-treatment');
        closeModal('modal-treatment');
    }

    // 2. Diagnosis (상병)
    function syncDiagnosisFromTable() {
        stagedDiagnosisList = [];
        document.querySelectorAll('#dxTableBody tr').forEach(row => {
            if (row.dataset.code) {
                stagedDiagnosisList.push({
                    diagnosisNo: row.dataset.no,
                    diagnosisCode: row.dataset.code,
                    diagnosisName: row.dataset.name
                });
            }
        });
        renderStagedList();
    }

    // [수정됨] 메인 화면 -> 모달 데이터 동기화
    // [최종 완성] 메인 화면 데이터 -> 모달 동기화 (SVG 색칠 포함)
function syncExaminationFromTable() {
    // 1. 초기화
    stagedExaminationList = []; 
    clearAllSelectedSites(); 

    const tbody = document.getElementById('exTableBody'); 
    if (!tbody) return;

    const rows = tbody.querySelectorAll('tr');

    // [1] SVG 정보 수집 (이름, ID, 방향)
    // SVG에는 data-name="흉부", data-side="좌" 이렇게 되어있다고 가정
    const svgPaths = document.querySelectorAll('#human-body-svg path');
    const siteToInfoMap = new Map();
    
    svgPaths.forEach(path => {
        const name = path.getAttribute('data-name');
        const side = path.getAttribute('data-side'); // SVG의 방향 (좌, 우)
        const id = path.id;
        
        if (name && id) {
            if (!siteToInfoMap.has(name)) {
                siteToInfoMap.set(name, []);
            }
            // 매칭을 위해 ID와 방향 정보를 같이 저장
            siteToInfoMap.get(name).push({ id: id, side: side });
        }
    });

    // [2] 테이블 읽어서 매칭
    rows.forEach(row => {
        // ★ 핵심 변경: innerText 파싱 대신 data 속성 직접 사용
        // 화면 표시는 텍스트(X-Ray)를 쓰되, 로직은 data 속성을 씁니다.
        
        let modality = row.children[1].innerText.trim(); // 표시는 "X-Ray" 사용
        
        // tr 태그에 있는 data-site="흉부", data-laterality="좌" 가져오기
        let site = row.getAttribute('data-site');         
        let laterality = row.getAttribute('data-laterality'); 

        // 데이터가 없으면 스킵
        if (!site) return;

        // [3] 매칭 로직
        const candidates = siteToInfoMap.get(site) || [];
        let targetIdsToPaint = [];

        if (candidates.length > 0) {
            if (laterality === '양측' || laterality === 'Both') {
                // 양측: 해당 부위의 모든 조각 선택
                targetIdsToPaint = candidates.map(c => c.id);
            } else if (laterality) {
                // 좌/우: SVG의 data-side와 테이블의 data-laterality가 정확히 일치하는 것 찾기
                // 예: SVG(좌) === TABLE(좌)
                targetIdsToPaint = candidates
                    .filter(c => c.side === laterality)
                    .map(c => c.id);
            } else {
                // 방향 정보가 아예 없으면(None) 그냥 다 칠하거나 첫번째꺼
                targetIdsToPaint = candidates.map(c => c.id);
            }
        }

        // 4. 데이터 저장 (대표 ID 하나만 originId로 사용)
        let representativeId = targetIdsToPaint.length > 0 ? targetIdsToPaint[0] : null;
        let uniqueId = representativeId ? `\${modality}-\${representativeId}` : ('sync_' + Date.now() + Math.random().toString(36).substr(2,5));

        // 리스트에 추가 (이미 테이블에 있으므로 중복 체크는 로직에 따라 결정)
        stagedExaminationList.push({
            uniqueId: uniqueId,
            modality: modality,
            site: site,
            laterality: laterality,
            originId: representativeId 
        });

        // ★ 5. 찾은 ID들 색칠하기
        targetIdsToPaint.forEach(tid => {
            const targetPath = document.getElementById(tid);
            if (targetPath) {
                targetPath.style.fill = '#E76E50'; // 주황색
            }
        });
    });

    // 우측 리스트 갱신 (필요하다면)
    renderStagedExaminationList();
}

    function stageDiagnosis(item) {
        if (!stagedDiagnosisList.some(s => s.diagnosisCode === item.diagnosisCode)) {
            stagedDiagnosisList.push(item);
            renderStagedList();
            updateBtnState('btn-' + item.diagnosisCode, true, 'diag');
        }
    }

    function removeStagedDiagnosis(code) {
        stagedDiagnosisList = stagedDiagnosisList.filter(i => i.diagnosisCode !== code);
        renderStagedList();
        updateBtnState('btn-' + code, false, 'diag');
    }

    function removeAllStagedDiagnosis() {
        stagedDiagnosisList.forEach(i => updateBtnState('btn-' + i.diagnosisCode, false, 'diag'));
        stagedDiagnosisList = [];
        renderStagedList();
    }

    function renderStagedList() {
        const container = document.getElementById('diag-right-list');
        const emptyMsg = document.getElementById('diag-empty-msg');
        if (stagedDiagnosisList.length === 0) {
            container.innerHTML = '';
            container.appendChild(emptyMsg);
            emptyMsg.classList.remove('hidden');
            return;
        }
        emptyMsg.classList.add('hidden');
        container.innerHTML = '';
        container.appendChild(emptyMsg);
        stagedDiagnosisList.forEach(item => {
            const div = document.createElement('div');
            div.className = "flex justify-between items-center bg-white p-3 rounded border border-gray-200 shadow-sm mb-2";
            div.innerHTML = `
                <div class="flex flex-col w-full overflow-hidden">
                    <div class="flex items-center gap-2 mb-1">
                        <span class="text-xs font-bold text-blue-600 bg-blue-50 px-1.5 rounded">\${item.diagnosisCode}</span>
                    </div>
                    <span class="text-sm text-gray-800 font-medium truncate">\${item.diagnosisName}</span>
                </div>
                <button onclick="removeStagedDiagnosis('\${item.diagnosisCode}')" class="text-gray-300 hover:text-red-500 ml-2">×</button>
            `;
            container.appendChild(div);
        });
    }

    function applyStagedDiagnosis() {
        if (stagedDiagnosisList.length === 0) {
            sweetAlert("warning", "선택된 상병 없음", "확인");
            return;
        }
        let tbody = document.getElementById('dxTableBody');
        tbody.innerHTML = '';
        let defType = document.querySelector("input[name='diag-default-type']:checked").value;
        stagedDiagnosisList.forEach((item, i) => {
            tbody.innerHTML += `
                <tr class="border-b border-slate-100 hover:bg-slate-50 transition-colors" 
                    data-no="\${item.diagnosisNo}" 
                    data-code="\${item.diagnosisCode}" 
                    data-name="\${item.diagnosisName}">
                    <td class="text-center py-3">\${i+1}</td>
                    <td class="text-center py-3">
                        <div class="flex items-center justify-center">
                            <input \${defType === 'main' && i === 0 ? 'checked' : ''} name="diagcheck\${i+1}" value="Y" type="radio" class="h-4 w-4 accent-blue-600 cursor-pointer"/>
                        </div>
                    </td>
                    <td class="text-center py-3">
                        <div class="flex items-center justify-center">
                            <input \${defType !== 'main' || i > 0 ? 'checked' : ''} name="diagcheck\${i+1}" value="N" type="radio" class="h-4 w-4 accent-blue-600 cursor-pointer"/>
                        </div>
                    </td>
                    <td class="text-center py-3">\${item.diagnosisCode}</td>
                    <td class="text-left py-3 pl-4">\${item.diagnosisName}</td>
                    <td class="text-center py-3">
                        <button onclick="removeList(this)" class="p-1 hover:text-red-500 rounded transition-colors">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                        </button>
                    </td>
                </tr>
            `;
        });
        stagedDiagnosisList = [];
        renderStagedList();
        resetForm('modal-diagnosis');
        closeModal('modal-diagnosis');
    }

    // 3. Medication (약제)
    function syncMedicationFromTable() {
        stagedMedicationList = [];
        document.querySelectorAll('#rxTableBody tr').forEach(row => {
            const inputs = row.querySelectorAll('input');
            const select = row.querySelector('select');
            stagedMedicationList.push({
                drugCode: row.dataset.code,
                drugName: row.dataset.name,
                drugCompany: row.dataset.company,
                dose: inputs[0].value,
                freq: inputs[1].value,
                days: inputs[2].value,
                method: select ? select.value : ''
            });
        });
        renderStagedMedicationList();
    }

    function stageMedication(item) {
        if (!stagedMedicationList.some(s => s.drugCode === item.drugCode)) {
            item.dose = 1;
            item.freq = 3;
            item.days = 3;
            item.method = '식후 30분';
            stagedMedicationList.push(item);
            renderStagedMedicationList();
            updateBtnState('btn-med-' + item.drugCode, true, 'med');
        }
    }

    function removeStagedMedication(code) {
        stagedMedicationList = stagedMedicationList.filter(i => i.drugCode !== code);
        renderStagedMedicationList();
        updateBtnState('btn-med-' + code, false, 'med');
    }

    function removeAllStagedMedication() {
        stagedMedicationList.forEach(i => updateBtnState('btn-med-' + i.drugCode, false, 'med'));
        stagedMedicationList = [];
        renderStagedMedicationList();
    }

    function renderStagedMedicationList() {
        const container = document.getElementById('med-right-list');
        const emptyMsg = document.getElementById('med-empty-msg');
        if (stagedMedicationList.length === 0) {
            container.innerHTML = '';
            container.appendChild(emptyMsg);
            emptyMsg.classList.remove('hidden');
            return;
        }
        emptyMsg.classList.add('hidden');
        container.innerHTML = '';
        container.appendChild(emptyMsg);
        stagedMedicationList.forEach(item => {
            const div = document.createElement('div');
            div.className = "flex justify-between items-center bg-white p-3 rounded border border-gray-200 shadow-sm mb-2";
            div.innerHTML = `
                <div class="flex flex-col w-full overflow-hidden">
                    <div class="flex items-center gap-2 mb-1">
                        <span class="text-xs font-bold text-orange-600 bg-orange-50 px-1.5 rounded">\${item.drugCode}</span>
                        <span class="text-[10px] text-gray-400">\${item.drugCompany || ''}</span>
                    </div>
                    <span class="text-sm text-gray-800 font-medium truncate">\${item.drugName}</span>
                </div>
                <button onclick="removeStagedMedication('\${item.drugCode}')" class="text-gray-300 hover:text-red-500 ml-2">×</button>
            `;
            container.appendChild(div);
        });
    }

    function applyStagedMedication() {
        if (stagedMedicationList.length === 0) {
            sweetAlert("warning", "선택된 약제 없음", "확인");
            return;
        }
        let tbody = document.getElementById('rxTableBody');
        tbody.innerHTML = '';
        stagedMedicationList.forEach((item, i) => {
            let opts = ['식후 30분', '식전 30분', '취침 전'].map(m => `<option \${item.method === m ? 'selected' : ''}>\${m}</option>`).join('');
            tbody.innerHTML += `
                <tr class="border-b border-slate-100 hover:bg-slate-50 transition-colors" 
                    data-no="\${item.drugNo}" 
                    data-code="\${item.drugCode}" 
                    data-name="\${item.drugName}" 
                    data-company="\${item.drugCompany}">
                    
                    <td class="text-center py-3">\${i+1}</td>
                    
                    <td class="text-left py-3 pl-4" title="\${item.drugName}">
                        \${item.drugName.split('(')[0]}
                    </td>
                    
                    <td class="text-center py-3">
                        <input min="0" type="number" class="w-full border rounded px-1 py-1 text-center focus:outline-none focus:border-blue-500 bg-transparent transition-colors" 
                               value="\${item.dose}"/>
                    </td>
                    
                    <td class="text-center py-3">
                        <input min="0" type="number" class="w-full border rounded px-1 py-1 text-center focus:outline-none focus:border-blue-500 bg-transparent transition-colors" 
                               value="\${item.freq}"/>
                    </td>
                    
                    <td class="text-center py-3">
                        <input min="0" type="number" class="w-full border rounded px-1 py-1 text-center focus:outline-none focus:border-blue-500 bg-transparent transition-colors" 
                               value="\${item.days}"/>
                    </td>
                    
                    <td class="text-center py-3">
                        <select class="w-full border rounded px-1 py-1 text-center focus:outline-none focus:border-blue-500 bg-transparent transition-colors cursor-pointer">
                            \${opts}
                        </select>
                    </td>
                    
                    <td class="text-center py-3">
                        <button onclick="removeList(this)" class="p-1 hover:text-red-500 rounded transition-colors">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                        </button>
                    </td>
                </tr>
            `;
        });
        stagedMedicationList = [];
        renderStagedMedicationList();
        resetForm('modal-medication');
        closeModal('modal-medication');
    }

    // 4. Operation (수술)
    function syncOperationFromTable() {
        stagedOperationList = [];
        document.querySelectorAll('#opTableBody tr').forEach(row => {
            stagedOperationList.push({
                operationNo: row.dataset.no,
                operationCode: row.dataset.code,
                operationName: row.dataset.name,
                operationPrice: row.dataset.price
            });
        });
        renderStagedOperationList();
    }

    function stageOperation(item) {
        if (!stagedOperationList.some(s => s.operationCode === item.operationCode)) {
            stagedOperationList.push(item);
            renderStagedOperationList();
            updateBtnState('btn-op-' + item.operationCode, true, 'op');
        }
    }

    function removeStagedOperation(code) {
        stagedOperationList = stagedOperationList.filter(i => i.operationCode !== code);
        renderStagedOperationList();
        updateBtnState('btn-op-' + code, false, 'op');
    }

    function removeAllStagedOperation() {
        stagedOperationList.forEach(i => updateBtnState('btn-op-' + i.operationCode, false, 'op'));
        stagedOperationList = [];
        renderStagedOperationList();
    }

    function renderStagedOperationList() {
        const container = document.getElementById('op-right-list');
        const emptyMsg = document.getElementById('op-empty-msg');
        if (stagedOperationList.length === 0) {
            container.innerHTML = '';
            container.appendChild(emptyMsg);
            emptyMsg.classList.remove('hidden');
            return;
        }
        emptyMsg.classList.add('hidden');
        container.innerHTML = '';
        container.appendChild(emptyMsg);
        stagedOperationList.forEach(item => {
            const div = document.createElement('div');
            div.className = "flex justify-between items-center bg-white p-3 rounded border border-gray-200 shadow-sm mb-2";
            div.innerHTML = `
                <div class="flex flex-col w-full overflow-hidden">
                    <div class="flex items-center gap-2 mb-1">
                        <span class="text-xs font-bold text-red-600 bg-red-50 px-1.5 rounded">\${item.operationCode}</span>
                    </div>
                    <span class="text-sm text-gray-800 font-medium truncate">\${item.operationName}</span>
                </div>
                <button onclick="removeStagedOperation('\${item.operationCode}')" class="text-gray-300 hover:text-red-500 ml-2">×</button>
            `;
            container.appendChild(div);
        });
    }

    function applyStagedOperation() {
        if (stagedOperationList.length === 0) {
            sweetAlert("warning", "선택된 수술 없음", "확인");
            return;
        }
        let tbody = document.getElementById('opTableBody');
        tbody.innerHTML = '';
        stagedOperationList.forEach((item, i) => {
            tbody.innerHTML += `
                <tr class="border-b border-slate-100 hover:bg-slate-50 transition-colors" 
                    data-no="\${item.operationNo}" 
                    data-code="\${item.operationCode}" 
                    data-name="\${item.operationName}" 
                    data-price="\${item.operationPrice}">
                    
                    <td class="text-center py-3">\${i+1}</td>
                    
                    <td class="text-left py-3">\${item.operationCode}</td>
                    
                    <td class="text-left py-3 pl-4">\${item.operationName}</td>
                    
                    <td class="text-center py-3">
                        <button onclick="removeList(this)" class="p-1 hover:text-red-500 rounded transition-colors">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                        </button>
                    </td>
                </tr>
            `;
        });
        stagedOperationList = [];
        renderStagedOperationList();
        resetForm('modal-operation');
        closeModal('modal-operation');
    }

    // 5. 공통 유틸리티
    function updateBtnState(id, added, type) {
        const btn = document.getElementById(id);
        if (!btn) return;
        let color = (type === 'treat') ? 'green' : (type === 'med' ? 'orange' : (type === 'op' ? 'red' : 'blue'));
        if (added) {
            btn.innerText = "추가됨";
            btn.className = `px-2 py-1 text-xs border rounded shadow-sm bg-gray-100 text-gray-400 cursor-not-allowed`;
        } else {
            btn.innerText = "추가";
            btn.className = `px-2 py-1 text-xs border rounded shadow-sm bg-white border-\${color}-200 text-\${color}-600 hover:bg-\${color}-50 cursor-pointer`;
        }
    }

    function removeList(ele) {
        ele.closest('tr').remove();
    }

    document.addEventListener('click', function(e) {
        if (!e.target.closest('.relative')) {
            document.querySelectorAll('.result-list').forEach(function(el) {
                el.classList.add('hidden');
            });
            const examResults = document.getElementById('exam-search-results');
            if (examResults) examResults.classList.add('hidden');
        }
    });
</script>