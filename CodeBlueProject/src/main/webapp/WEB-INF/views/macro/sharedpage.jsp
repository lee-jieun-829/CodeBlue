<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal" var="pinfo"/>
    <c:set var="loginUserNo" value="${pinfo.employee.employeeNo}" /> 
    <c:set var="loginJob" value="ETC" /> 
    <c:forEach items="${pinfo.employee.authList}" var="authVO">
        <c:choose>
            <c:when test="${authVO.auth eq 'ROLE_DOCTOR'}"><c:set var="loginJob" value="DOC" /></c:when>
            <c:when test="${authVO.auth eq 'ROLE_NURSE_OUT' or authVO.auth eq 'ROLE_NURSE_IN'}"><c:set var="loginJob" value="NUR" /></c:when>
            <c:when test="${authVO.auth eq 'ROLE_ADMIN'}"><c:set var="loginJob" value="ADM" /></c:when>
        </c:choose>
    </c:forEach>
</sec:authorize>
<sec:authorize access="isAnonymous()">
    <c:set var="loginUserNo" value="0" />
    <c:set var="loginJob" value="" />
</sec:authorize>

<!DOCTYPE html>
<html lang="ko">
<head>
    <title>SB 병원 - 나의오더</title>
    <%@ include file="/WEB-INF/views/common/include/link.jsp" %>
    
    <script src="https://cdn.tailwindcss.com"></script>
    <script> tailwind.config = { corePlugins: { preflight: false } } </script>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    
    <style>
        input, textarea, select { font-family: inherit; border: 1px solid #e2e8f0; }
        .hidden { display: none !important; }
        .macro-page-wrapper { display: flex; width: 100%; height: 100%; overflow: hidden; }
        select:disabled { background-color: #f1f5f9; color: #64748b; cursor: not-allowed; }
    </style>
</head>

<body data-gnb="gnb-folder">

    <%@ include file="/WEB-INF/views/common/include/header.jsp" %>

    <div class="main-container">
        <%@ include file="/WEB-INF/views/common/include/left/left_default.jsp" %>

        <div class="main-content macro-page-wrapper" style="padding: 0; background-color: #f8fafc;">
            
            <aside class="w-[240px] bg-white border border-slate-200 mx-4 my-6 flex flex-col py-6 px-4 shrink-0 overflow-y-auto rounded-2xl shadow-sm">
                <div class="mb-6 pl-2 border-l-4 border-blue-600 h-4 flex items-center justify-between shrink-0">
                    <h2 class="text-sm font-bold text-slate-900 leading-none m-0">나의 오더 관리</h2>
                     <span id="userRoleBadge" class="text-[10px] px-1.5 py-0.5 rounded font-bold text-blue-600 bg-blue-50">LOADING</span>
                </div>
                <div class="flex flex-col gap-1" id="categoryList"></div>
            </aside>

            <section class="w-[320px] bg-white border border-slate-200 mx-4 my-6 flex flex-col shrink-0 rounded-2xl shadow-sm">
                <div class="p-6 border-b border-slate-100 bg-white shrink-0 rounded-t-2xl">
                    <div class="flex justify-between items-center mb-4">
                        <h2 class="text-lg font-bold text-slate-900 m-0">나의 오더 목록</h2>
                        <button id="btnNewMacro" onclick="initNewMacro()" class="text-blue-600 text-[11px] font-bold hover:underline flex items-center bg-transparent p-0">
                             <i data-lucide="plus" class="w-3 h-3 mr-0.5"></i> 새 나의 오더
                        </button>
                    </div>
                    <div class="relative">
                        <input type="text" id="searchInput" onkeyup="filterMacros()" placeholder="나의 오더 검색..." class="w-full pl-9 pr-3 py-2.5 bg-slate-50 border border-slate-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-100 transition-all placeholder:text-slate-400">
                        <i data-lucide="search" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400"></i>
                    </div>
                </div>
               <div id="macroListContainer" class="flex-1 overflow-y-auto p-4 space-y-3 bg-white rounded-b-2xl"></div>
            </section>

            <main id="mainEditorPanel" class="flex-1 h-full flex flex-col min-w-[600px] overflow-hidden relative">
                
                <div id="formContainer" class="flex flex-col h-[calc(100%-3rem)] mx-4 my-6 bg-white rounded-2xl shadow-sm border border-slate-200 overflow-hidden">
                    <div class="h-[72px] px-8 border-b border-slate-100 flex items-center justify-between shrink-0 bg-white">
                        <div>
                            <h2 id="formTitle" class="text-xl font-bold text-slate-900 mb-1 m-0">새 나의 오더 생성</h2>
                            <p class="text-[10px] text-slate-400 font-bold tracking-widest uppercase m-0">MACRO CONTENT CONFIGURATION</p>
                        </div>
                        <button onclick="saveMacro()" class="px-6 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-bold shadow-md shadow-blue-200/50 transition-all flex items-center gap-1.5 cursor-pointer">
                            <i data-lucide="save" class="w-4 h-4"></i> 저장 및 등록
                        </button>
                    </div>

                    <div class="flex-1 overflow-y-auto p-8 bg-white relative">
                        <input type="hidden" id="macroNo" value="0">
                        <div class="grid grid-cols-12 gap-x-8 gap-y-8">
                            <div class="col-span-4">
                                <label class="block text-xs font-bold text-slate-500 mb-2.5">사용자 그룹 선택</label>
                                <div class="relative">
                                    <select id="macroType" onchange="toggleEditorLayout()" class="w-full p-3 pl-4 bg-white border border-slate-200 rounded-lg text-sm font-bold text-slate-700 focus:ring-2 focus:ring-blue-500 outline-none appearance-none cursor-pointer shadow-sm">
                                        <option value="001">의사 전용 세트</option>
                                        <option value="002">간호사 전용 세트</option>
                                    </select>
                                    <div class="absolute right-3 top-1/2 -translate-y-1/2 pointer-events-none text-slate-400"><i data-lucide="settings" class="w-3.5 h-3.5"></i></div>
                                </div>
                            </div>
                            <div class="col-span-8">
                                <label class="block text-xs font-bold text-slate-500 mb-2.5">나의 오더 명칭</label>
                                <input type="text" id="macroName" class="w-full p-3 bg-slate-50 border border-slate-200 rounded-lg text-sm font-medium focus:bg-white focus:ring-2 focus:ring-blue-500 outline-none transition-all placeholder:text-slate-400" placeholder="나의 오더 이름을 입력하세요">
                            </div>

                            <div id="contentArea" class="col-span-12 flex flex-col h-full transition-all duration-300">
                                <label id="contentLabel" class="block text-xs font-bold text-slate-500 mb-2.5">상세 내용</label>
                                <textarea id="macroContent" class="w-full min-h-[500px] flex-1 p-6 bg-white border border-slate-200 rounded-2xl text-sm leading-7 text-slate-700 resize-none focus:ring-2 focus:ring-blue-500 outline-none shadow-sm" placeholder="내용을 입력하세요..."></textarea>
                            </div>
                            <div id="medicalPanel" class="col-span-5 flex flex-col gap-5 doctor-panel hidden">
                                <div class="border border-slate-200 rounded-2xl p-5 bg-white shadow-sm">
                                    <div class="flex justify-between items-center mb-4">
                                        <span class="text-xs font-bold text-slate-700 flex items-center gap-1.5"><i data-lucide="activity" class="text-blue-500 w-3.5 h-3.5"></i> 상병(진단) 코드</span>
                                        <button onclick="openModal('DIAGNOSIS')" class="text-[11px] text-blue-600 font-bold hover:underline bg-blue-50 px-2 py-1 rounded-md transition-colors">+ 검색</button>
                                    </div>
                                    <div id="diagnosisList" class="min-h-[80px] bg-slate-50 rounded-xl border border-slate-100 p-2 space-y-2"></div>
                                </div>
                                <div class="border border-slate-200 rounded-2xl p-5 bg-white shadow-sm">
                                    <div class="flex justify-between items-center mb-4">
                                        <span class="text-xs font-bold text-slate-700 flex items-center gap-1.5"><i data-lucide="pill" class="text-orange-500 w-3.5 h-3.5"></i> 약제 처방</span>
                                        <button onclick="openModal('DRUG')" class="text-[11px] text-blue-600 font-bold hover:underline bg-blue-50 px-2 py-1 rounded-md transition-colors">+ 추가</button>
                                    </div>
                                    <div id="drugList" class="min-h-[100px] bg-slate-50 rounded-xl border border-slate-100 p-2 space-y-2"></div>
                                </div>
                                <div class="border border-slate-200 rounded-2xl p-4 bg-white shadow-sm min-h-[160px] flex flex-col">
                                    <div class="flex justify-between items-center mb-3">
                                        <span class="text-xs font-bold text-slate-600 flex items-center gap-1.5"><i data-lucide="syringe" class="text-green-500 w-3.5 h-3.5"></i> 치료</span>
                                        <button onclick="openModal('TREATMENT')" class="text-[10px] bg-slate-100 px-1.5 py-0.5 rounded font-bold text-slate-500 hover:text-blue-600">+ 추가</button>
                                    </div>
                                    <div id="treatmentList" class="flex-1 bg-slate-50 rounded-lg p-2 space-y-1.5 overflow-y-auto max-h-[120px]"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div id="infoMessage" class="hidden flex-col items-center justify-center h-full w-full bg-slate-50 text-center p-8">
                    <div class="w-16 h-16 bg-slate-200 rounded-full flex items-center justify-center mb-4 text-slate-400">
                        <i data-lucide="lock" class="w-8 h-8"></i>
                    </div>
                    <h3 class="text-lg font-bold text-slate-700 mb-2">나의 오더 생성 한도 초과</h3>
                    <p class="text-sm text-slate-500 mb-6">
                        개인 오더는 최대 3개까지만 생성할 수 있습니다.<br>
                        기존 오더를 수정하거나 삭제 후 이용해주세요.
                    </p>
                    <div class="text-xs text-slate-400 bg-white px-4 py-2 rounded border border-slate-200">
                        Tip. 좌측 목록에서 오더를 클릭하면 수정할 수 있습니다.
                    </div>
                </div>

            </main>
        </div>
    </div>

    <div id="searchModal" class="hidden fixed inset-0 z-[9999] flex items-center justify-center bg-slate-900/50 backdrop-blur-sm">
        <div class="bg-white w-[600px] h-[750px] rounded-2xl shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in duration-200">
            <div class="px-6 py-4 border-b border-slate-100 flex justify-between items-center bg-white" style="border-bottom-width: 1px;">
                <h3 id="modalTitle" class="text-lg font-bold text-slate-800" style="margin:0;">검색</h3>
                <button onclick="closeModal()" class="p-2 hover:bg-slate-100 rounded-full transition-colors text-slate-500"><i data-lucide="x" class="w-5 h-5"></i></button>
            </div>
            <div class="p-5 bg-slate-50 border-b border-slate-100" style="border-bottom-width: 1px;">
                <div class="relative">
                    <input type="text" id="modalSearchInput" onkeydown="if(event.key==='Enter') searchApi()" class="w-full pl-10 pr-20 py-3 border border-slate-200 rounded-xl text-sm focus:ring-2 focus:ring-blue-500 outline-none shadow-sm" placeholder="코드 또는 명칭 검색..." autofocus>
                    <i data-lucide="search" class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400"></i>
                    <button onclick="searchApi()" class="absolute right-2 top-1/2 -translate-y-1/2 px-4 py-1.5 bg-blue-600 text-white text-xs font-bold rounded-lg hover:bg-blue-700">검색</button>
                </div>
            </div>
            <div id="modalResultList" class="flex-1 overflow-y-auto p-4 space-y-2 bg-white"></div>
            <div class="p-4 border-t border-slate-100 bg-white" style="border-top-width: 1px;">
                <button onclick="addSelectedItems()" id="btnAddSelected" disabled class="w-full py-3 bg-blue-600 hover:bg-blue-700 disabled:bg-slate-200 disabled:text-slate-400 disabled:cursor-not-allowed text-white rounded-xl text-sm font-bold shadow-md transition-all flex items-center justify-center gap-2">
                    <i data-lucide="plus-circle" class="w-4 h-4"></i>
                    <span id="btnAddText">선택한 항목 추가하기</span>
                </button>
            </div>
        </div>
    </div>

    <script>
        document.addEventListener("DOMContentLoaded", () => { lucide.createIcons(); });

        const API_BASE = '${pageContext.request.contextPath}/api/macro';
        const USER_ID = Number("${loginUserNo}") || 0;
        const USER_JOB = "${loginJob}";
        
        let allMacros = [];
        let selectedCategory = 'ALL';
        let currentData = { diagnosisList: [], drugList: [], treatmentList: [] };
        let currentModalType = '';
        let modalSelectedItems = [];
        
        let CATEGORIES = [ { id: 'ALL', label: '전체 오더 조회', icon: 'layout-grid' } ];

        window.onload = function() {
            if (USER_ID === 0 || (USER_JOB !==''  && USER_JOB !== 'DOC' && USER_JOB !== 'NUR')) {
                Swal.fire({ 
                    title: "접근 권한 없음", 
                    text: "의료진(의사/간호사)만 접근 가능한 페이지입니다.", 
                    icon: "error", 
                    confirmButtonText: "나가기",
                    allowOutsideClick: false
                }).then(() => { window.location.href = '/'; });
                return;
            }
            identifyUserRole(); 
            initCategories(); 
            loadMacroList(); 
            lucide.createIcons();
        };

        function initCategories() {
            if (USER_JOB === 'DOC') CATEGORIES.push({ id: '001', label: '의사 전용 세트', icon: 'stethoscope' });
            else if (USER_JOB === 'NUR') CATEGORIES.push({ id: '002', label: '간호사 전용 세트', icon: 'users' });
        }

        function identifyUserRole() {
            const badge = document.getElementById('userRoleBadge');
            let roleName = "일반 직원", colorClass = "text-slate-500 bg-slate-100";
            if (USER_JOB === 'DOC') { roleName = "의사"; colorClass = "text-blue-600 bg-blue-50"; }
            else if (USER_JOB === 'NUR') { roleName = "간호사"; colorClass = "text-green-600 bg-green-50"; }
            badge.innerText = roleName; badge.className = `text-[10px] px-1.5 py-0.5 rounded font-bold \${colorClass}`;
        }

        async function loadMacroList() {
            try {
                // [수정 포인트] 백엔드에서 employeeNo를 보냈을 때 '내 것 + 공용(관리자)'을 모두 반환한다고 가정합니다.
                const res = await axios.get(`\${API_BASE}/list`, { params: { employeeNo: USER_ID } });
                allMacros = res.data || []; 
                renderCategoryMenu(); 
                filterMacros();
                initNewMacro(); 
            } catch (err) { Swal.fire("오류", "목록 로드 실패", "error"); }
        }

        // [수정] 새 매크로 초기화 및 개수 제한 체크 (내 것만 카운트)
        function initNewMacro() {
            let targetType = USER_JOB === 'NUR' ? '002' : '001';
            
            // 변경됨: 전체 리스트가 아니라 '내가 작성한 것'만 필터링하여 카운트
            const myMacros = allMacros.filter(m => m.macroType === targetType && m.employeeNo === USER_ID);
            const count = myMacros.length;

            const btn = document.getElementById('btnNewMacro');
            const formContainer = document.getElementById('formContainer');
            const infoMessage = document.getElementById('infoMessage');
            const saveBtn = document.querySelector('button[onclick="saveMacro()"]');

            // 버튼 표시 여부 (3개 이상이면 숨김)
            if (btn) btn.style.display = (count >= 3) ? 'none' : 'flex';

            // 폼 초기화
            document.getElementById('macroNo').value = 0;
            document.getElementById('macroName').value = '';
            const typeSelect = document.getElementById('macroType');
            typeSelect.value = targetType;
            typeSelect.disabled = true; 
            document.getElementById('macroContent').value = '';
            
            // [중요] 새 글 작성 모드이므로 입력 활성화
            document.getElementById('macroName').readOnly = false;
            document.getElementById('macroContent').readOnly = false;
            if(saveBtn) saveBtn.style.display = 'flex'; // 저장 버튼 보이기

            document.getElementById('formTitle').innerText = "새 나의 오더 생성";
            currentData = { diagnosisList: [], drugList: [], treatmentList: [] };
            toggleEditorLayout(); 
            renderMedicalItems(true); // 편집 가능

            // 3개 이상이고, 현재 보고 있는 글이 신규 작성이면 안내 메시지 표시
            if (count >= 3 && document.getElementById('macroNo').value == 0) {
                formContainer.style.setProperty('display', 'none', 'important'); 
                infoMessage.style.setProperty('display', 'flex', 'important');   
            } else {
                formContainer.style.setProperty('display', 'flex', 'important'); 
                infoMessage.style.setProperty('display', 'none', 'important');   
            }
            // 목록 하이라이트 제거 등을 위해 호출
            filterMacros(); 
        }

        // [수정] 상세 조회 (관리자 글인지 확인하여 UI 제어)
        async function loadDetail(macroNo) {
            try {
                const res = await axios.get(`\${API_BASE}/detail/\${macroNo}`);
                const data = res.data;
                
                // 내 글인지 확인
                const isMine = (data.employeeNo === USER_ID);

                document.getElementById('formContainer').style.setProperty('display', 'flex', 'important');
                document.getElementById('infoMessage').style.setProperty('display', 'none', 'important');

                document.getElementById('macroNo').value = data.macroNo;
                document.getElementById('macroName').value = data.macroName;
                document.getElementById('macroType').value = data.macroType;
                document.getElementById('macroType').disabled = true; 
                document.getElementById('macroContent').value = data.macroContent || '';
                
                // [변경] 내 글이 아니면 읽기 전용으로 설정
                document.getElementById('macroName').readOnly = !isMine;
                document.getElementById('macroContent').readOnly = !isMine;
                
                // [변경] 저장 버튼 제어
                const saveBtn = document.querySelector('button[onclick="saveMacro()"]');
                if(saveBtn) saveBtn.style.display = isMine ? 'flex' : 'none';

                // 타이틀 변경
                document.getElementById('formTitle').innerText = isMine ? "나의 오더 수정" : "공통 오더 조회 (수정 불가)";
                
                currentData = { diagnosisList: [], drugList: [], treatmentList: [] };
                if (data.macroDetails) {
                    data.macroDetails.forEach(d => {
                        if(d.macroDetailType === 'DIAGNOSIS') currentData.diagnosisList.push({ diagnosisCode: d.macroDetailPrename, diagnosisName: d.macroDetailPrename });
                        else if(d.macroDetailType === 'DRUG') currentData.drugList.push({ drugCode: d.macroDetailPrename, drugName: d.macroDetailPrename });
                        else if(d.macroDetailType === 'TREATMENT') currentData.treatmentList.push({ treatmentCode: d.macroDetailPrename, treatmentName: d.macroDetailPrename });
                    });
                }
                toggleEditorLayout(); 
                renderMedicalItems(isMine); // isMine 여부에 따라 삭제 버튼 렌더링
                filterMacros();
            } catch (err) { console.error(err); }
        }

        function renderCategoryMenu() {
            const countDoc = allMacros.filter(m => m.macroType === '001').length;
            const countNurse = allMacros.filter(m => m.macroType === '002').length;
            const countAll = allMacros.length;
            const container = document.getElementById('categoryList');
            container.innerHTML = CATEGORIES.map(cat => {
                const isActive = selectedCategory === cat.id;
                let count = (cat.id === 'ALL') ? countAll : (cat.id === '001' ? countDoc : countNurse);
                return `<button onclick="setCategory('\${cat.id}')" class="w-full text-left px-4 py-3.5 rounded-lg text-[13px] flex items-center justify-between transition-all \${isActive ? 'bg-blue-50 text-blue-600 font-bold shadow-sm active-menu' : 'text-slate-500 font-medium hover:bg-slate-50'}" style="border:none;"><div class="flex items-center gap-2 flex-1"><i data-lucide="\${cat.icon}" class="w-4 h-4"></i><span>\${cat.label}</span></div><span class="menu-badge">\${count}</span></button>`;
            }).join('');
            lucide.createIcons();
        }

        function setCategory(id) { 
            selectedCategory = id; 
            renderCategoryMenu(); 
            filterMacros(); 
            initNewMacro(); // 카테고리 바꾸면 입력폼 리셋
        }

        // [수정] 목록 렌더링 시 내 글/관리자 글 UI 구분
        function filterMacros() {
            const term = document.getElementById('searchInput').value.toLowerCase();
            const filtered = allMacros.filter(item => {
                return item.macroName.toLowerCase().includes(term) && (selectedCategory === 'ALL' || item.macroType === selectedCategory);
            });
            const container = document.getElementById('macroListContainer');
            container.innerHTML = '';
            if (filtered.length === 0) { container.innerHTML = '<div class="text-center py-10 text-slate-400 text-xs">등록된 오더가 없습니다.</div>'; return; }
            
            const currentNo = Number(document.getElementById('macroNo').value);
            
            filtered.forEach(item => {
                const isActive = currentNo === item.macroNo;
                const isMine = (item.employeeNo === USER_ID); // 내 글인지 확인

                // 스타일 분기
                let typeLabel, icon, badgeColor;
                let actionButtons;

                if (isMine) {
                    // 내 매크로
                    typeLabel = item.macroType === '001' ? '나의 세트' : '나의 세트';
                    icon = item.macroType === '001' ? 'stethoscope' : 'users';
                    badgeColor = item.macroType === '001' ? 'text-blue-600 bg-blue-50' : 'text-green-600 bg-green-50';
                    actionButtons = `<div class="flex gap-3 text-[11px] font-medium"><span class="text-blue-600 hover:underline">수정</span><button onclick="event.stopPropagation(); deleteMacro(\${item.macroNo})" class="text-red-500 hover:underline" style="border:none;">삭제</button></div>`;
                } else {
                    // 관리자(공통) 매크로
                    typeLabel = '공통/관리자';
                    icon = 'shield'; 
                    badgeColor = 'text-purple-600 bg-purple-50';
                    actionButtons = `<div class="flex gap-3 text-[11px] font-medium text-slate-400"><i data-lucide="lock" class="w-3 h-3"></i> 수정 불가</div>`;
                }

                const div = document.createElement('div');
                div.className = `p-5 rounded-xl border transition-all cursor-pointer group hover:shadow-md mb-3 \${isActive ? 'bg-white border-blue-500 ring-1 ring-blue-500 shadow-sm' : 'bg-white border-slate-200 hover:border-blue-200'}`;
                div.style.borderWidth = '1px';
                div.onclick = () => loadDetail(item.macroNo);
                
                div.innerHTML = `
                    <div class="flex items-center gap-1.5 mb-2">
                        <span class="text-[10px] font-bold px-1.5 py-0.5 rounded \${badgeColor} flex items-center gap-1">
                            <i data-lucide="\${icon}" class="w-3 h-3"></i> \${typeLabel}
                        </span>
                    </div>
                    <h3 class="font-bold text-slate-800 text-sm mb-4 leading-tight" style="margin:0 0 16px 0;">\${item.macroName}</h3>
                    \${actionButtons}
                `;
                container.appendChild(div);
            });
            lucide.createIcons();
        }

        function toggleEditorLayout() {
            const type = document.getElementById('macroType').value;
            const contentArea = document.getElementById('contentArea');
            const medicalPanel = document.getElementById('medicalPanel');
            const contentLabel = document.getElementById('contentLabel');
            if (type === '001') { 
                contentArea.classList.remove('col-span-12'); contentArea.classList.add('col-span-7'); contentArea.style.gridColumn = "span 7 / span 7";
                medicalPanel.classList.remove('hidden'); medicalPanel.style.display = 'flex';
                contentLabel.innerText = "기본 오더 멘트 (진료 기록용)";
            } else { 
                contentArea.classList.remove('col-span-7'); contentArea.classList.add('col-span-12'); contentArea.style.gridColumn = "span 12 / span 12";
                medicalPanel.classList.add('hidden'); medicalPanel.style.display = 'none';
                contentLabel.innerText = type === '002' ? "간호 기록 양식" : "상세 내용";
            }
        }

        async function saveMacro() {
            if (USER_ID === 0) return Swal.fire("오류", "로그인 세션이 만료되었습니다.", "error");
            
            // 저장 전 내 글인지 한 번 더 체크 (보안)
            const macroNo = Number(document.getElementById('macroNo').value);
            // 만약 수정(macroNo > 0)인데 리스트에서 내 것이 아니면 리턴
            if (macroNo > 0) {
                const target = allMacros.find(m => m.macroNo === macroNo);
                if (target && target.employeeNo !== USER_ID) {
                    return Swal.fire("경고", "관리자 매크로는 수정할 수 없습니다.", "warning");
                }
            }

            const name = document.getElementById('macroName').value;
            let type = document.getElementById('macroType').value;
            if (!type) type = (USER_JOB === 'NUR' ? '002' : '001'); 
            const content = document.getElementById('macroContent').value;
            if (!name.trim()) return Swal.fire("알림", "오더 명칭을 입력해주세요.", "warning");
            
            const payload = { macroNo, macroName: name, macroType: type, macroContent: content, employeeNo: USER_ID, diagnosisList: currentData.diagnosisList, drugList: currentData.drugList, treatmentList: currentData.treatmentList };
            try {
                const url = macroNo === 0 ? `\${API_BASE}/add` : `\${API_BASE}/update`;
                await axios.post(url, payload);
                Swal.fire("성공", "저장되었습니다.", "success");
                loadMacroList(); 
            } catch (err) {
                let errorMsg = "저장 실패";
                if (err.response && typeof err.response.data === 'string') errorMsg = err.response.data;
                else if (err.response && err.response.data && err.response.data.message) errorMsg = err.response.data.message;
                Swal.fire("실패", errorMsg, "error");
            }
        }

        async function deleteMacro(macroNo) {
            if ((await Swal.fire({ title: '삭제하시겠습니까?', icon: 'warning', showCancelButton: true, confirmButtonText: '삭제', cancelButtonText: '취소' })).isConfirmed) {
                try { await axios.post(`\${API_BASE}/delete/\${macroNo}`); Swal.fire("삭제됨", "삭제되었습니다.", "success"); loadMacroList(); } 
                catch (err) { Swal.fire("실패", "삭제 중 오류가 발생했습니다.", "error"); }
            }
        }

        function openModal(type) {
            // [수정] 수정 불가 상태(관리자 글)일 때 모달 오픈 방지
            const saveBtn = document.querySelector('button[onclick="saveMacro()"]');
            if (saveBtn.style.display === 'none') {
                 Swal.fire("알림", "공통 오더는 내용을 수정할 수 없습니다.", "info");
                 return;
            }

            currentModalType = type; modalSelectedItems = []; updateModalUI();
            document.getElementById('modalTitle').innerText = (type==='DIAGNOSIS'?'상병':type==='DRUG'?'약제':'치료') + ' 검색';
            document.getElementById('modalSearchInput').value = '';
            document.getElementById('searchModal').classList.remove('hidden'); document.getElementById('searchModal').style.display = 'flex';
            searchApi();
        }
        function closeModal() { document.getElementById('searchModal').classList.add('hidden'); document.getElementById('searchModal').style.display = 'none'; }

        async function searchApi() {
            const keyword = document.getElementById('modalSearchInput').value;
            let endpoint = currentModalType === 'DIAGNOSIS' ? '/diagnosis/search' : currentModalType === 'DRUG' ? '/drug/search' : '/treatment/search';
            const listEl = document.getElementById('modalResultList'); listEl.innerHTML = '<div class="text-center py-10 text-slate-400">검색중...</div>';
            try { const res = await axios.get(API_BASE + endpoint, { params: { keyword: keyword } }); renderModalList(res.data || []); } 
            catch(err) { listEl.innerHTML = '<div class="text-center py-10 text-red-400">검색 오류가 발생했습니다.</div>'; }
        }

        function renderModalList(list) {
            const listEl = document.getElementById('modalResultList'); listEl.innerHTML = '';
            if(list.length === 0) { listEl.innerHTML = '<div class="h-full flex flex-col items-center justify-center text-slate-400 py-10">검색 결과가 없습니다.</div>'; return; }
            list.forEach(item => {
                let codeKey = currentModalType === 'DIAGNOSIS' ? 'diagnosisCode' : currentModalType === 'DRUG' ? 'drugCode' : 'treatmentCode';
                let isChecked = modalSelectedItems.some(i => i[codeKey] === item[codeKey]);
                let code, name, subInfo = '';
                if(currentModalType === 'DIAGNOSIS') { code = item.diagnosisCode; name = item.diagnosisName; }
                else if(currentModalType === 'DRUG') { code = item.drugCode; name = item.drugName; subInfo = item.drugCompany; }
                else { code = item.treatmentCode; name = item.treatmentName; subInfo = (item.treatmentPrice || 0).toLocaleString() + '원'; }

                const row = document.createElement('div');
                row.className = `flex items-center justify-between p-4 border rounded-xl cursor-pointer transition-all mb-2 \${isChecked ? 'border-blue-500 bg-blue-50 ring-1 ring-blue-500' : 'border-slate-100 hover:bg-slate-50'}`;
                row.style.borderWidth = '1px';
                row.onclick = () => toggleModalItem(item, codeKey);
                row.innerHTML = `<div class="flex items-center gap-3 w-full"><div class="shrink-0 \${isChecked ? 'text-blue-600' : 'text-slate-300'}"><i data-lucide="\${isChecked ? 'check-square' : 'square'}" class="w-5 h-5"></i></div><div class="flex flex-col"><div class="flex items-center gap-2"><span class="text-xs font-bold text-slate-700">\${code}</span><span class="text-sm font-medium text-slate-700">\${name}</span></div>\${subInfo ? `<span class="text-[10px] text-slate-400 mt-0.5">\${subInfo}</span>` : ''}</div></div>`;
                listEl.appendChild(row);
            });
            lucide.createIcons();
        }

        function toggleModalItem(item, key) {
            const exists = modalSelectedItems.some(i => i[key] === item[key]);
            if(exists) modalSelectedItems = modalSelectedItems.filter(i => i[key] !== item[key]); else modalSelectedItems.push(item);
            searchApi(); updateModalUI();
        }

        function updateModalUI() {
            const btn = document.getElementById('btnAddSelected');
            btn.disabled = modalSelectedItems.length === 0;
            document.getElementById('btnAddText').innerText = modalSelectedItems.length > 0 ? `선택한 \${modalSelectedItems.length}개 항목 추가하기` : '항목을 선택해주세요';
        }

        function addSelectedItems() {
            if(currentModalType === 'DIAGNOSIS') currentData.diagnosisList.push(...modalSelectedItems.filter(n => !currentData.diagnosisList.some(e => e.diagnosisCode === n.diagnosisCode)));
            else if(currentModalType === 'DRUG') currentData.drugList.push(...modalSelectedItems.filter(n => !currentData.drugList.some(e => e.drugCode === n.drugCode)));
            else currentData.treatmentList.push(...modalSelectedItems.filter(n => !currentData.treatmentList.some(e => e.treatmentCode === n.treatmentCode)));
            
            // 내 글인지 확인 (신규 등록중이면 true)
            // 작성 중인 글이 내 글인지 확인하고 넘겨줌
            const macroNo = Number(document.getElementById('macroNo').value);
            const isMine = (macroNo === 0) || (allMacros.find(m => m.macroNo === macroNo)?.employeeNo === USER_ID);
            
            renderMedicalItems(isMine); 
            closeModal();
        }

        // [수정] isEditable 파라미터 추가하여 항목 삭제 버튼(휴지통) 제어
        function renderMedicalItems(isEditable = true) {
            const render = (list, type, emptyMsg) => {
                if (!list || list.length === 0) {
                    return `<div class="h-full flex items-center justify-center text-slate-400 text-[11px] py-4">\${emptyMsg}</div>`;
                }
                
                return list.map((item, idx) => {
                    let name = type==='diagnosis' ? item.diagnosisName : type==='drug' ? item.drugName : item.treatmentName;
                    
                    // 수정 불가 상태면 trash 버튼 숨김
                    const deleteBtn = isEditable ? 
                        `<button onclick="removeItem('\${type}', \${idx})" class="text-slate-300 hover:text-red-500"><i data-lucide="trash-2" class="w-3.5 h-3.5"></i></button>` 
                        : '';
                    
                    return `<div class="flex justify-between items-center bg-slate-50 px-3 py-2 rounded-lg border border-slate-100 mb-1" style="border-width:1px;">
                                <span class="text-xs text-slate-700 truncate">\${name}</span>
                                \${deleteBtn}
                            </div>`;
                }).join('');
            };

            document.getElementById('diagnosisList').innerHTML = render(currentData.diagnosisList, 'diagnosis', '등록된 상병이 없습니다.');
            document.getElementById('drugList').innerHTML = render(currentData.drugList, 'drug', '등록된 약제가 없습니다.');
            document.getElementById('treatmentList').innerHTML = render(currentData.treatmentList, 'treatment', '내역 없음');
            
            lucide.createIcons();
        }

        function removeItem(type, idx) {
            if(type === 'diagnosis') currentData.diagnosisList.splice(idx, 1);
            else if(type === 'drug') currentData.drugList.splice(idx, 1);
            else currentData.treatmentList.splice(idx, 1);
            
            // 삭제 후 다시 렌더링 (삭제는 내 글에서만 가능하므로 true)
            renderMedicalItems(true);
        }
    </script>
</body>
</html>