<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <%@ include file="/WEB-INF/views/common/include/link.jsp" %>
    <title>SB 정형외과 | 입원 간호사</title>
</head>

<body data-gnb="gnb-inpatientnurse">
	<!-- 공통헤더 -->
    <%@ include file="/WEB-INF/views/common/include/header.jsp"%>
    
    <div class="main-container">
    	<!-- 간호 사이드바 -->
        <%@ include file="/WEB-INF/views/common/include/left/left_nursing.jsp"%> 
        
        <main class="main-content">
            <div class="flex h-full gap-4 overflow-hidden">
                
                <div class="box box-bordered flex flex-col w-96 h-full">
                    <div class="flex justify-between items-center mb-2">
                        <h2 class="page-title text-lg font-bold">입원간호</h2>  
                    </div>  
                    <div class="box mb-4">
                    	<!-- 환자 검색 영역 -->
                        <h2 class="box-title text-md mb-2">입원 환자 검색</h2>
                        <div class="form-group relative">
                            <input type="text" id="patientSearchInput" class="input input-search" placeholder="환자명/환자번호">
                            <ul id="searchResultList" class="hidden absolute top-full left-0 w-full bg-white border border-slate-200 rounded-md shadow-lg z-50 max-h-60 overflow-y-auto mt-1"></ul>
                        </div>
                    </div>
                    
                    <hr class="section-divider mb-4"/>            

                   <div class="flex-1 overflow-y-auto pr-1 space-y-6">
                        <div class="flex justify-between items-center mb-2 px-1">                             
                            
                            <button id="transferBed"class="btn btn-primary btn-sm">전실 관리</button>
                        </div>  
                        <!-- 담당병상 출력 -->
                        <div id="bedMapContainer" class="w-full space-y-6">
                            <div class="text-center py-10 text-gray-400">
                                <i class="fas fa-spinner fa-spin mr-2"></i> 병상 정보 불러오는 중...
                            </div>
                        </div> 
                    </div>
                </div>

               <div class="flex flex-col w-80 h-full overflow-hidden" id="patientInfoArea">
			    <div id="patientInfoEmpty" class="box box-bordered h-full flex items-center justify-center text-slate-400 text-sm">
			        <div class="text-center">
			            <i class="fas fa-bed text-3xl mb-2 opacity-50"></i>
			            <div class="empty-state empty-state-sm">
			                <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
			                    <line x1="8" y1="6" x2="21" y2="6"></line>
			                    <line x1="8" y1="12" x2="21" y2="12"></line>
			                    <line x1="8" y1="18" x2="21" y2="18"></line>
			                    <line x1="3" y1="6" x2="3.01" y2="6"></line>
			                    <line x1="3" y1="12" x2="3.01" y2="12"></line>
			                    <line x1="3" y1="18" x2="3.01" y2="18"></line>
			                </svg>
			                <div class="empty-state-title">목록 없음</div>
			                <div class="empty-state-description">환자를 선택해주세요</div>
			            </div>
			        </div>
			    </div>

			    <div id="patientInfoContent" class="hidden h-full flex flex-col">
			        <div class="box box-bordered h-full flex flex-col" id="patientInfo">
			            <div id="patientDetail" class="flex-1 flex flex-col">
			                <div class="box-title-group flex justify-between shrink-0">
			                    <h2 class="box-title flex items-center text-base">
			                        <span class="text-secondary text-sm mr-2 font-normal" id="pInfoNo"></span>
			                        <strong id="pInfoName"></strong>
			                        
			                    </h2>
			                </div>
			                
			                <div class="btn-group-justified">
			                	<div class="btn-group-left">
				                	<span class="badge badge-default badge-sm" id="pInfoInsurance"></span>
				                    <span class="badge badge-primary badge-sm" id="pInfoStatus"></span>
			                	</div>
			                    
			                    <button class="btn btn-danger-light btn-sm btn-group-right hidden" onclick="" id="changeStatus">퇴원처리</button>
			                    
			                </div>
			
			                <div class="list-horizontal list-horizontal-1 text-sm mt-3 shrink-0">
			                    <div class="list-horizontal-item">                                    	
			                        <div class="list-horizontal-label w-16">성별/나이</div>
			                        <div class="list-horizontal-value" id="pInfoGenAge"></div>
			                    </div>
			                    <div class="list-horizontal-item">
			                        <div class="list-horizontal-label w-16">생년월일</div>
			                        <div class="list-horizontal-value" id="pInfoBirth"></div>
			                    </div>
			                    <div class="list-horizontal-item">
			                        <div class="list-horizontal-label w-16">주치의</div>
			                        <div class="list-horizontal-value" id="pInfoDoctor"></div>
			                    </div>
			                    <div class="list-horizontal-item">
			                        <div class="list-horizontal-label w-16">입원일</div>
			                        <div class="list-horizontal-value" id="pInfoDate"></div>
			                    </div>
			                    <div class="list-horizontal-item btn-group-center">
			                    	 <span id="statusBtnArea" class="ml-3"></span>
			                    </div>
			                </div>
			
			                <div class="mt-4 flex flex-col flex-1 min-h-0 border-t border-slate-100 pt-3">			               
			                    <div class="flex justify-between items-center mb-2">
			                        <div class="font-bold text-sm text-slate-600">특이사항</div> 
			                        <p style="font-size: var(--font-sm); color: var(--color-text-secondary);">작성하시면 자동으로 수정됩니다.</p>		                                         
			                    </div>
			                    
			                    <textarea 
			                        class="textarea textarea-bordered w-full flex-1 resize-none bg-slate-50 text-sm focus:outline-none focus:border-blue-400 focus:bg-white transition-colors" 
			                        id="patientMemo" 
			                        placeholder="특이사항 없음"
			                        readonly></textarea>
			                        
			                </div>
			                 
			            </div>
			        </div>
			    </div>
			</div>

                <div class="flex flex-col flex-1 h-full min-w-0" id="patientChart">                    
                    <div class="box box-bordered flex-1 flex flex-col min-h-0">
                        <div class="tabs tabs-underline" id="chartTabs">
                            <button class="tab active" data-tab="info">간호 정보 조사지</button>
                            <button class="tab" data-tab="note">간호 기록지</button>
                            <button class="tab" data-tab="order">입원 관리</button>                            
                            <button class="tab" data-tab="surgery">수술 관리</button>
                        </div>

                        <div class="flex-1 overflow-y-auto pr-2 mt-4 relative" id="chartTabContent">
                            <!-- 간호정보조사지 -->
                            <div id="tab-info" class="tab-panel">
                                <jsp:include page="nursingInfo.jsp" />
                            </div>
                            <!-- 간호기록지 -->
                            <div id="tab-note" class="tab-panel hidden">
                                <jsp:include page="nursingNote.jsp" />
                            </div>
							<!-- 입원오더 처리 -->
                            <div id="tab-order" class="tab-panel hidden">
                                <jsp:include page="nursingOrder.jsp" />
                            </div>
							
							<!-- 수술 상태 -->
                            <div id="tab-surgery" class="tab-panel hidden">
                                <jsp:include page="nursingSurgery.jsp" />
                            </div>

                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
    <!-- 전실 관리 모달 -->
		 <div id="modal-transfer" class="modal-backdrop hidden z-[60]" onclick="if(event.target === this) closeModal('modal-transfer')">
		    <div class="modal modal-xl h-[90vh] flex flex-col"> <div class="modal-header">
		            <div class="flex items-center gap-3">
		                <h3 class="modal-title">전실 관리 (Bed Transfer)</h3>
		                <span class="badge badge-default">
		                    <i class="fas fa-info-circle mr-1"></i>
		                    담당 병동의 환자를 드래그하여 빈 병상으로 이동시키세요.
		                </span>
		                <span class="badge badge-primary">
		                    사용중 병상 <span id="usageCount" class="ml-1 mr-1">0</span>/20
		                </span>
		            </div>
		            <button onclick="closeModal('modal-transfer')" class="btn btn-icon btn-ghost">
		                <i class="fas fa-times text-xl"></i>
		            </button>
		        </div>
		
		        <div class="modal-body">
		            <div id="transferChanges" class="callout callout-info hidden mb-4 flex justify-between items-center">
		                <div class="flex items-center gap-2">
		                    <div class="callout-title mb-0">
		                        <i class="fas fa-exchange-alt mr-2"></i>
		                        <span id="changeText">변경사항: 0건</span>
		                    </div>
		                </div>
		                <button onclick="resetTransfer()" class="text-sm text-blue-600 underline hover:text-blue-800">초기화</button>
		            </div>
		
		            <div id="transferMapContainer" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-2 gap-6">
		                </div>
		        </div>
		
		        <div class="modal-footer">
		            <button onclick="closeModal('modal-transfer')" class="btn btn-secondary">취소</button>
		            <button onclick="saveTransfer()" class="btn btn-primary">변경사항 저장</button>
		        </div>
		    </div>
		</div>

<script>
    // [설정] 로그인한 직원 사번
    const loginEmpNo = parseInt("<sec:authentication property='principal.employee.employeeNo'/>");
    
    // 보험 종류 매핑
    const insuranceMap = {
        "012": "일반100", "011": "일반", "001": "건강보험",
        "002": "차상위1종", "003": "차상위2종", "004": "급여1종",
        "005": "급여2종", "010": "자보100", "006": "산재",
        "007": "산재100", "008": "후유장해", "009": "자보"
    };
    
    // [전역 변수]
    let globalPatientList = []; // 입원 환자 리스트
    let globalLocationList = []; // 병동 정보
    let transferChanges = {};   // 전실 변경 내역
    
    //  현재 선택된 환자의 차트 번호 (nursingInfo.jsp에서 값 주입됨)
    let currentChartNo = null; 
    
    // 간호정보조사지 저장 여부 (탭 잠금용)
    let isAssessmentSaved = false;
    
    // 처방(수술, 오더 등) 통합 데이터 저장소
    let globalPrescriptionList = []; 

    document.addEventListener('DOMContentLoaded', () => {
        // 초기 데이터 로드
        patientInfo();
        
        // 전실 버튼 이벤트
        const transferBtn =document.getElementById('transferBed'); 
        if(transferBtn) {
            transferBtn.addEventListener('click', openTransferModal);
        }
        
        // 환자 검색 이벤트
        const searchInput = document.getElementById('patientSearchInput');
        if(searchInput) {
            searchInput.addEventListener('input', function() {
                filterPatients(this.value);
            });
        }
        
        // [Tab] 탭 전환 및 데이터 로드 트리거 로직
        const chartContainer = document.getElementById('patientChart');
        if (chartContainer) {
            const tabs = chartContainer.querySelectorAll('.tab[data-tab]');
            const tabPanels = chartContainer.querySelectorAll('.tab-panel');

            tabs.forEach(tab => {
                tab.addEventListener('click', () => {
                    const tabType = tab.dataset.tab;

                    // 1. 간호정보조사지 미작성 시 타 탭 접근 차단 (info 탭 제외)
                    if (tabType !== 'info' && !isAssessmentSaved) {
                        sweetAlert("warning", "간호정보조사지가 등록되지 않았습니다.<br>조사지를 먼저 작성 및 저장해주세요.", "알림");
                        return; 
                    }

                    // 2. UI 전환
                    tabs.forEach(t => t.classList.remove('active'));
                    tabPanels.forEach(panel => panel.classList.add('hidden'));

                    tab.classList.add('active');
                    const targetId = `tab-\${tabType}`;
                    const targetPanel = document.getElementById(targetId);
                    
                    if (targetPanel) {
                        targetPanel.classList.remove('hidden');
                    }

                    // 3. 탭 별 데이터 로드 함수 호출
                    // (각 탭의 JSP 파일에 정의된 함수를 호출함)
                    if (tabType === 'surgery') {
                        if (typeof loadSurgeryList === 'function') loadSurgeryList(); 
                    } 
                    else if (tabType === 'order') {
                        if (typeof loadOrderList === 'function') loadOrderList(); 
                    }                   
                    else if (tabType === 'note') {
                        // 간호 기록지 로드 호출
                        if(typeof loadNursingNoteList === 'function') {
                            console.log("간호기록지 탭 로드 요청 (ChartNo: " + window.currentChartNo + ")");
                            loadNursingNoteList(); // 인자 없이 호출 (함수 내부에서 전역변수 사용)
                        }
                    }
                });
            });
        }

        // 아코디언 로직
        window.toggleAccordion = function(button) {
            const item = button.closest('.accordion-item');
            if (item.classList.contains('active')) {
                item.classList.remove('active');
            } else {
                item.classList.add('active');
            }
        }
    });
    
    //====================================================
    // [통합 데이터 로드] 처방/수술/검사 데이터 가져오기
    // nursingInfo.jsp에서 차트번호가 확인되면 호출됨
    //====================================================
    function fetchPrescriptionData(chartNo) {
        if(!chartNo) {
            globalPrescriptionList = [];
            return;
        }
        
        console.log("통합 처방 데이터 요청 (ChartNo):", chartNo);

        axios.get("/nurse/prescriptionselect", {
            params: { chartNo: chartNo }
        })
        .then(res => {
            // 전역 변수에 저장
            globalPrescriptionList = res.data || [];
            console.log("통합 데이터 로드 완료:", globalPrescriptionList);

            // 현재 보고 있는 탭이 수술이나 오더라면 즉시 화면 갱신
            const activeTab = document.querySelector('#chartTabs .tab.active');
            if (activeTab) {
                const tabType = activeTab.dataset.tab;
                if (tabType === 'surgery' && typeof loadSurgeryList === 'function') loadSurgeryList();
                if (tabType === 'order' && typeof loadOrderList === 'function') loadOrderList();
            }
        })
        .catch(err => {
            console.error("처방 데이터 로드 실패:", err);
            globalPrescriptionList = [];
        });
    }

    //====================================================
    // 병동 정보 & 환자 정보 동시 요청
    //====================================================
    function patientInfo() {
        const getLocation = axios.get("/nurse/locationSelect"); 
        const getPatients = axios.get("/nurse/inPatientSelect");

        Promise.all([getLocation, getPatients])
            .then(axios.spread((locationRes, patientRes) => {
                globalLocationList = locationRes.data; 
                globalPatientList = patientRes.data;   
                renderBedMap(globalLocationList, globalPatientList);
            }))
            .catch(err => { 
                console.error("데이터 로드 실패:", err);
            });
    }

    //====================================================
    // 병동 및 병상 그리기
    //====================================================
    function renderBedMap(locationList, patientList) {
        const container = document.getElementById('bedMapContainer');
        const bedMap = {};
        let usageCount = 0;

        patientList.forEach(p => {
            if(p.bedNo && (p.admissionStatus == '001' || p.admissionStatus == '002')) {
                bedMap[p.bedNo] = p;
                usageCount++;
            }
        });
        
        const usageCountEl = document.getElementById('usageCount');
        if(usageCountEl) usageCountEl.textContent = usageCount;

        let html = '';
        let hasWard = false;

        locationList.forEach(location => {
            if (!location.locationCode || !location.locationCode.includes("WARD")) return; 
            if (location.employeeNo !== loginEmpNo) return; 
            
            hasWard = true;
            const config = getWardConfig(location.locationName); 
            
            html += `<div class="w-full">
                        <h4 class="text-sm font-bold text-\${config.color}-700 mb-2 border-l-4 border-\${config.color}-500 pl-2">
                            \${location.locationName}
                        </h4>
                        <div class="grid grid-cols-1 gap-3">`;

            config.rooms.forEach(roomNo => {
                let gridCols = 'grid-cols-1';
                if (config.capacity === 2 || config.capacity === 4) gridCols = 'grid-cols-2';
                if (config.capacity === 6) gridCols = 'grid-cols-3';

                html += `<div class="w-full flex flex-col p-4 bg-white border border-slate-200 rounded-xl shadow-sm">
                            <h5 class="font-bold text-slate-700 mb-2 text-xs">\${roomNo}호</h5>
                            <div class="grid \${gridCols} gap-2">`;

                for (let i = 1; i <= config.capacity; i++) {
                    const bedIdxStr = i.toString().padStart(2, '0');
                    const currentBedNo = parseInt(`\${roomNo}\${bedIdxStr}`);
                    const patient = bedMap[currentBedNo];

                    if (patient) {
                        let btnColorClass = "border-blue-200 bg-white text-blue-800 hover:bg-blue-50 hover:border-blue-500"; 
                        let statusText = "입원중";
                        
                        if (patient.admissionStatus === '002') {
                            btnColorClass = "border-orange-200 bg-orange-50 text-orange-700 hover:bg-orange-100 hover:border-orange-500";
                            statusText = "퇴원대기";
                        } else if (patient.admissionStatus === '003') {
                            btnColorClass = "border-purple-200 bg-purple-50 text-purple-700 hover:bg-purple-100 hover:border-purple-500";
                            statusText = "수납대기";
                        }

                        html += `<button type="button" 
                                    onclick="loadPatientInfo('\${roomNo}', '\${bedIdxStr}', '\${patient.patientNo}', '\${patient.patientName}', '\${statusText}')"
                                    class="bed-btn flex flex-col items-center justify-center w-full h-[60px] rounded-md border cursor-pointer transition-all hover:shadow-md \${btnColorClass}"
                                    data-name="\${patient.patientName}" 
                                    data-no="\${patient.patientNo}">
                                    <span class="text-[10px] font-semibold mb-0.5 opacity-80">\${bedIdxStr}</span>
                                    <div class="flex flex-col items-center leading-tight">
                                        <span class="text-[12px] font-bold">\${patient.patientName}</span>
                                        <span class="text-[10px] font-medium opacity-90">(\${statusText})</span>
                                    </div>
                                </button>`;
                    } else {
                        html += `<button type="button" disabled
                                    class="flex flex-col items-center justify-center w-full h-[60px] rounded-md border border-slate-100 bg-slate-50 text-slate-300 cursor-not-allowed">
                                    <span class="text-[10px] font-semibold mb-0.5">\${bedIdxStr}</span>
                                    <span class="text-[11px] font-medium">빈 병상</span>
                                </button>`;
                    }
                }
                html += `</div></div>`;
            });
            html += `</div></div>`;
        });

        if (!hasWard) {
            html = `<div class="text-center py-10 text-gray-400">
                        <i class="fas fa-exclamation-circle mb-2 text-2xl"></i><br>
                        담당하는 병동이 없습니다.<br>
                        <span class="text-xs">(로그인 사번: \${loginEmpNo})</span>
                    </div>`;
        }

        container.innerHTML = html;
    }

    // 병동 설정
    function getWardConfig(locationName) {
        let config = { color: 'gray', rooms: [], capacity: 0 };
        if (locationName.includes("1층") || locationName.includes("VIP")) {
            config = { color: "purple", rooms: [101, 102, 103], capacity: 1 };
        } else if (locationName.includes("2층") || locationName.includes("집중")) {
            config = { color: "blue", rooms: [201, 202, 203], capacity: 2 };
        } else if (locationName.includes("4층")) {
            config = { color: "emerald", rooms: [401, 402, 403], capacity: 4 };
        } else if (locationName.includes("6층")) {
            config = { color: "amber", rooms: [601, 602, 603], capacity: 6 };
        }
        return config;
    }

    // 검색 필터링
    function filterPatients(keyword) {
        const resultList = document.getElementById('searchResultList');
        resultList.innerHTML = '';
        
        if (!keyword || keyword.trim() === '') {
            resultList.classList.add('hidden');
            return;
        }
        
        const matches = globalPatientList.filter(p => {
            if (p.admissionStatus != '001' && p.admissionStatus != '002') return false;
            const strVal = keyword.trim();
            return (p.patientName && p.patientName.includes(strVal)) || 
                   (p.patientNo && p.patientNo.toString().includes(strVal)) ||
                   (p.patientRegno1 && p.patientRegno1.includes(strVal));
        });
        
        if (matches.length === 0) {
            const li = document.createElement('li');
            li.className = "px-4 py-3 text-sm text-gray-400 text-center";
            li.textContent = "검색 결과가 없습니다.";
            resultList.appendChild(li);
        } else {
            matches.forEach(p => {
                const genderStr = p.patientGen === 'MALE' ? '남' : (p.patientGen === 'FEMALE' ? '여' : '-');
                const displayText = `\${p.patientNo}.\${p.patientName} \${p.patientRegno1} | \${genderStr} | \${p.patientAge}`;
                
                const li = document.createElement('li');
                li.className = "px-3 py-2 text-sm text-slate-700 border-b border-slate-100 last:border-0 hover:bg-blue-50 cursor-pointer transition-colors flex items-center justify-between";
                li.innerHTML = `<span>\${displayText}</span>`;
                li.addEventListener('click', () => {
                    selectSearchedPatient(p);
                    loadNursingChartInfo(p.admissionNo);
                });
                resultList.appendChild(li);
            });
        }
        resultList.classList.remove('hidden');
    }
    
    // 검색된 환자 선택
    function selectSearchedPatient(patient) {
        const searchInput = document.getElementById('patientSearchInput');
        const resultList = document.getElementById('searchResultList');
        searchInput.value = ''; 
        resultList.classList.add('hidden');

        if (!patient.bedNo) {
        	sweetAlert("warning", "배정된 병상이 없는 환자입니다.", "알림");           
            return;
        }

        const bedNoStr = patient.bedNo.toString();
        const roomNo = bedNoStr.substring(0, 3);
        const bedIdx = bedNoStr.substring(3, 5);
        
        let statusText = "입원중";
        if (patient.admissionStatus === '002') statusText = "퇴원대기";
        else if (patient.admissionStatus === '003') statusText = "수납대기";

        loadPatientInfo(roomNo, bedIdx, patient.patientNo, patient.patientName, statusText);        
    }

    document.addEventListener('click', function(e) {
        const searchArea = document.querySelector('.form-group.relative');
        const resultList = document.getElementById('searchResultList');
        if (searchArea && !searchArea.contains(e.target)) {
            resultList.classList.add('hidden');
        }
    });

    // 내 환자 여부 확인
    function checkMyPatient(bedNo) {
        if (!bedNo) return false;
        const roomNo = Math.floor(bedNo / 100); 
        for (let loc of globalLocationList) {
            if (loc.employeeNo === loginEmpNo) {
                const config = getWardConfig(loc.locationName);
                if (config.rooms.includes(roomNo)) return true;
            }
        }
        return false;
    }
    
   
 

    // 환자 상세 정보 로드 (클릭 시 실행)
    function loadPatientInfo(roomNo, bedIdx, patientId, name, statusText) {
        // 탭 및 상태 초기화
        resetTabsToDefault();
        isAssessmentSaved = false; // 기본값 false로 설정 (조사지 로드 시 갱신됨)
        window.currentChartNo = null; // 차트 번호 초기화

        const patient = globalPatientList.find(p => p.patientNo == patientId);     
        if (!patient) {
            console.error("환자 정보 없음");
            loadNursingChartInfo(null);
            return;
        }

        document.getElementById('patientInfoEmpty').classList.add('hidden');
        document.getElementById('patientInfoContent').classList.remove('hidden');
        document.getElementById('pInfoName').textContent = patient.patientName;
        
        // 수납 대기로 상태 변경 버튼 노출     
    	const changeStatusBtn =  document.getElementById('changeStatus')
    	changeStatusBtn.style.display = 'none';
        
        if (patient.admissionStatus == '002') {           
        	changeStatusBtn.style.display = 'inline-block';    
            changeStatusBtn.onclick = function() {
                admissionStatusUpdate(patient.admissionNo); 
            };
        }
        
        const pNoEl = document.getElementById('pInfoNo');
        pNoEl.textContent = patient.patientNo;
        pNoEl.setAttribute('data-no', patient.patientNo); 

        const genderStr = patient.patientGen === 'MALE' ? '남' : (patient.patientGen === 'FEMALE' ? '여' : '-');
        document.getElementById('pInfoGenAge').textContent = `\${genderStr} / \${patient.patientAge}세`;
        document.getElementById('pInfoBirth').textContent = patient.patientRegno1 || '-';
        document.getElementById('pInfoDoctor').textContent = patient.employeeName || '미지정';
        document.getElementById('pInfoDate').textContent = patient.admissionDate ? patient.admissionDate.substring(0, 10) : '-';
        
        const insCode = patient.admissionInsurance;
        document.getElementById('pInfoInsurance').textContent = insuranceMap[insCode] || "기타";

        const statusBadge = document.getElementById('pInfoStatus');
        let displayStatus = "입원중";
        let badgeClass = "badge badge-primary badge-sm";
        let badgeStyle = "";
        if (patient.admissionStatus === '002') { displayStatus = "퇴원대기"; badgeClass = "badge badge-warning badge-sm"; }
        else if (patient.admissionStatus === '003') { displayStatus = "수납대기"; badgeClass = "badge badge-primary badge-sm"; badgeStyle = "background-color: #9333ea;"; }
        statusBadge.textContent = displayStatus;
        statusBadge.className = badgeClass;
        statusBadge.style = badgeStyle;

        const memoArea = document.getElementById('patientMemo');
        const saveBtn = document.getElementById('btnSaveMemo');
        memoArea.value = patient.patientMemo || ''; 
		
        //해당 환자 내 담당 병동 환자인지 확인
        const isMine = checkMyPatient(patient.bedNo); 
        if (isMine) {//내 담당일때
            memoArea.removeAttribute('readonly');
            memoArea.classList.remove('bg-slate-50', 'text-slate-500'); 
            memoArea.classList.add('bg-white', 'text-slate-800');      
           
            
            memoArea.onfocus = function() {
                this.dataset.originValue = this.value;
            };
            
            memoArea.onblur = function() {
                const currentValue = this.value;
                const originValue = this.dataset.originValue;
                // 현재 선택된 환자 번호를 다시 가져옴 
                const currentPatientNo = document.getElementById('pInfoNo').getAttribute('data-no');

                // 변경사항이 있을 때만 저장
                if(currentValue !== originValue) {
                    console.log("메모 변경 감지 -> 자동 저장 시도");
                    
                    axios.post("/nurse/updatememo", {
                        patientNo: parseInt(currentPatientNo),
                        patientMemo: currentValue 
                    })
                    .then(res => {
                    	// 전역 데이터도 갱신
                        const target = globalPatientList.find(p => p.patientNo == currentPatientNo);
                        if(target) target.patientMemo = currentValue;
                    })
                    .catch(err => {
                        console.error("메모 저장 실패:", err);
                        // 실패 시 원래대로 돌리거나 경고
                    });
                }
            };
        } else {//내 담당 아닐때
            memoArea.setAttribute('readonly', true);
            memoArea.classList.add('bg-slate-50', 'text-slate-500');   
            memoArea.classList.remove('bg-white', 'text-slate-800');    
            saveBtn.classList.add('hidden');      
            
            memoArea.onfocus = null;
            memoArea.onblur = null;
        }

        // 간호정보조사지 로드 호출 (여기서 chartNo를 찾아 window.currentChartNo에 넣음)
        if (typeof loadNursingChartInfo === 'function') {
            loadNursingChartInfo(patient.admissionNo, patient.patientName);
        }
    }
    
    // 환자 퇴원(수납대기로 상태 변경)
    function admissionStatusUpdate(admissionNo){
		
		// 1. 미수행 오더 여부 확인
		        if (checkPendingOrders()) {
		            sweetAlert("warning", "미수행된 오더(대기/진행중)가 남아있습니다.<br>모든 오더가 완료되었는지 확인 후 진행해주세요.", "확인");
		            
		            // 오더 탭으로 강제 이동하여 사용자가 확인하도록 유도
		            const orderTab = document.querySelector('.tab[data-tab="order"]');
		            if(orderTab) orderTab.click();
		            
		            return; // 함수 종료
		        }
				
        Swal.fire({
            title: '',
            text: "환자 상태를 변경하시겠습니까?",
            icon: 'warning',
            showCancelButton: true,
            confirmButtonText: '확인',
            cancelButtonText: '취소'
        }).then((result) => {
            if(result.isConfirmed){
                axios.post("/nurse/admissionstatusupdate",{ admissionNo: admissionNo })
                 .then(res => {
                	 sendManyNotifications('7', '부서 공지', '새로운 수납 대기 환자가 있습니다.', '002', '#', 'N');
                     sweetAlert("success", "환자 상태가 변경되었습니다.", "확인");             
                     patientInfo();
                     document.getElementById('patientInfoContent').classList.add('hidden');
                     document.getElementById('patientInfoEmpty').classList.remove('hidden');
                     resetTabsToDefault();
                 })
                 .catch(err => {
                     console.error(err);
                     sweetAlert("error", "상태변경에 실패했습니다.", "확인");
                 });
            }
        });
    }
    
    // 차트 초기화
    function resetTabsToDefault() {
        const tabs = document.querySelectorAll('#chartTabs .tab');
        const panels = document.querySelectorAll('.tab-panel');

        tabs.forEach(t => t.classList.remove('active'));
        panels.forEach(p => p.classList.add('hidden'));

        // '간호 정보 조사지'(info) 탭 활성화
        const defaultTab = document.querySelector('.tab[data-tab="info"]');
        const defaultPanel = document.getElementById('tab-info');

        if (defaultTab) defaultTab.classList.add('active');
        if (defaultPanel) defaultPanel.classList.remove('hidden');
    }
    
    // 전실 모달 로직
    function openTransferModal() {
        const modal = document.getElementById('modal-transfer');
        modal.classList.remove('hidden');
        modal.classList.add('flex');
        transferChanges = {};
        updateChangeUI();
        renderTransferMap(globalLocationList, globalPatientList);
    }

    function closeModal(id) {
        const modal = document.getElementById(id);
        modal.classList.add('hidden');
        modal.classList.remove('flex');
        if(id === 'modal-transfer' && Object.keys(transferChanges).length > 0) {
            patientInfo();
        }
    }

    function renderTransferMap(locationList, patientList) {
        const container = document.getElementById('transferMapContainer');
        const bedMap = {};
        patientList.forEach(p => {
            if(p.bedNo && (p.admissionStatus == '001' || p.admissionStatus == '002')) {
                bedMap[p.bedNo] = p;
            }
        });

        let html = '';
        locationList.forEach(location => {
            if (!location.locationCode || !location.locationCode.includes("WARD")) return; 
            const isMyWard = (location.employeeNo === loginEmpNo);
            const config = getWardConfig(location.locationName);
            const headerClass = isMyWard 
                ? `bg-\${config.color}-50 border-\${config.color}-200 text-\${config.color}-700` 
                : "bg-slate-50 border-slate-200 text-slate-600";
            const managerBadge = isMyWard 
                ? `<span class="ml-2 text-[10px] bg-\${config.color}-600 text-white px-1.5 py-0.5 rounded">My</span>` 
                : "";

            html += `<div class="box p-0 overflow-hidden border border-slate-200 rounded-lg shadow-sm">
                        <div class="px-4 py-2 border-b font-bold text-sm flex items-center \${headerClass}">
                            \${location.locationName} \${managerBadge}
                        </div>
                        <div class="p-4 grid grid-cols-1 gap-3">`;

            config.rooms.forEach(roomNo => {
                let gridCols = 'grid-cols-2';
                if (config.capacity === 6) gridCols = 'grid-cols-3';
                if (config.capacity === 1) gridCols = 'grid-cols-1';

                html += `<div class="border border-slate-100 rounded p-2">
                            <div class="text-xs font-bold text-slate-500 mb-2">\${roomNo}호</div>
                            <div class="grid \${gridCols} gap-2">`;

                for (let i = 1; i <= config.capacity; i++) {
                    const bedIdxStr = i.toString().padStart(2, '0');
                    const currentBedNo = parseInt(`\${roomNo}\${bedIdxStr}`);
                    const patient = bedMap[currentBedNo];

                    if (patient) {
                        const draggable = isMyWard ? 'true' : 'false';
                        const cursorClass = isMyWard ? 'cursor-grab active:cursor-grabbing' : 'cursor-not-allowed';
                        const bgClass = isMyWard ? 'bg-blue-100 border-blue-300' : 'bg-slate-100 border-slate-200 text-slate-400';

                        html += `<div id="bed-\${currentBedNo}"
                                     class="transfer-bed relative flex flex-col items-center justify-center h-16 rounded border \${bgClass} \${cursorClass} transition-all"
                                     draggable="\${draggable}"
                                     ondragstart="handleDragStart(event, \${currentBedNo}, '\${patient.patientNo}', '\${patient.patientName}', \${isMyWard})"
                                     data-bed="\${currentBedNo}">
                                    <span class="text-[10px] font-bold">\${bedIdxStr}</span>
                                    <span class="text-xs font-bold">\${patient.patientName}</span>
                                    \${isMyWard ? '' : '<i class="fas fa-lock absolute top-1 right-1 text-[8px] opacity-50"></i>'}
                                </div>`;
                    } else {
                        html += `<div id="bed-\${currentBedNo}"
                                     class="transfer-bed relative flex flex-col items-center justify-center h-16 rounded border border-dashed border-slate-300 bg-white hover:bg-green-50 hover:border-green-400 cursor-pointer transition-all"
                                     ondragover="handleDragOver(event)"
                                     ondrop="handleDrop(event, \${currentBedNo})"
                                     ondragleave="handleDragLeave(event)"
                                     data-bed="\${currentBedNo}">
                                    <span class="text-[10px] text-slate-400">\${bedIdxStr}</span>
                                    <span class="text-xs text-slate-400">빈 병상</span>
                                </div>`;
                    }
                }
                html += `</div></div>`;
            });
            html += `</div></div>`;
        });
        container.innerHTML = html;
    }

    function handleDragStart(e, bedNo, patientId, patientName, isMyWard) {
        if (!isMyWard) { e.preventDefault(); return; }
        e.dataTransfer.setData("text/plain", JSON.stringify({ bedNo, patientId, patientName }));
        e.dataTransfer.effectAllowed = "move";
        e.target.classList.add("opacity-50");
    }

    function handleDragOver(e) {
        e.preventDefault();
        e.dataTransfer.dropEffect = "move";
        e.currentTarget.classList.add("bg-green-100", "border-green-500", "scale-105");
    }

    function handleDragLeave(e) {
        e.currentTarget.classList.remove("bg-green-100", "border-green-500", "scale-105");
    }

    function handleDrop(e, targetBedNo) {
        e.preventDefault();
        const target = e.currentTarget;
        target.classList.remove("bg-green-100", "border-green-500", "scale-105");
        const data = JSON.parse(e.dataTransfer.getData("text/plain"));
        const { bedNo: sourceBedNo, patientId, patientName } = data;
        if (sourceBedNo === targetBedNo) return; 
        movePatientUI(sourceBedNo, targetBedNo, patientName, patientId);
        transferChanges[patientId] = targetBedNo;
        updateChangeUI();
    }

    function movePatientUI(sourceBedNo, targetBedNo, patientName, patientId) {
        const sourceEl = document.getElementById(`bed-\${sourceBedNo}`);
        const targetEl = document.getElementById(`bed-\${targetBedNo}`);
        const emptyTemplate = `<span class="text-[10px] text-slate-400">\${sourceBedNo.toString().slice(-2)}</span><span class="text-xs text-slate-400">빈 병상</span>`;

        targetEl.className = "transfer-bed relative flex flex-col items-center justify-center h-16 rounded border bg-blue-100 border-blue-300 cursor-grab active:cursor-grabbing transition-all";
        targetEl.draggable = true;
        targetEl.setAttribute("ondragstart", `handleDragStart(event, \${targetBedNo}, '\${patientId}', '\${patientName}', true)`);
        targetEl.removeAttribute("ondragover");
        targetEl.removeAttribute("ondrop");
        targetEl.innerHTML = `<span class="text-[10px] font-bold">\${targetBedNo.toString().slice(-2)}</span><span class="text-xs font-bold text-blue-900">\${patientName}</span><span class="absolute top-0 right-1 text-[8px] text-red-500 font-bold">이동</span>`;

        sourceEl.className = "transfer-bed relative flex flex-col items-center justify-center h-16 rounded border border-dashed border-slate-300 bg-white hover:bg-green-50 hover:border-green-400 cursor-pointer transition-all";
        sourceEl.draggable = false;
        sourceEl.setAttribute("ondragover", "handleDragOver(event)");
        sourceEl.setAttribute("ondrop", `handleDrop(event, \${sourceBedNo})`);
        sourceEl.setAttribute("ondragleave", "handleDragLeave(event)");
        sourceEl.innerHTML = emptyTemplate;
    }

    function updateChangeUI() {
        const count = Object.keys(transferChanges).length;
        const container = document.getElementById('transferChanges');
        const text = document.getElementById('changeText');
        if (count > 0) {
            container.classList.remove('hidden');
            text.textContent = `변경사항: \${count}건`;
        } else {
            container.classList.add('hidden');
        }
    }

    function resetTransfer() {
        renderTransferMap(globalLocationList, globalPatientList);
        transferChanges = {};
        updateChangeUI();
    }

    function saveTransfer() {
    	
        		
        if (Object.keys(transferChanges).length === 0) {
            sweetAlert("success", "변경 사항이 없습니다.", "확인");
            return;
        }
        
        const payload = Object.entries(transferChanges).map(([pId, newBed]) => {
            // 1. 전역 환자 리스트에서 해당 환자를 찾아 기존 병상 번호를 가져옴
            const targetPatient = globalPatientList.find(p => p.patientNo == pId);
            const currentOldBed = targetPatient.bedNo;

            return {
                patientNo: parseInt(pId),
                bedNo: newBed,         // 새로 이동할 병상
                oldBedNo: currentOldBed // 기존 병상 (VO의 필드명과 일치해야 함)
            };
        });

        Swal.fire({
            title: '',
            text: "현재 상태로 병상 상태를 수정하시겠습니까?",
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: '확인',
            cancelButtonText: '취소'
        }).then((result) => {
            if (result.isConfirmed) {
                axios.post("/nurse/bedupdate", payload)
                    .then(res => {
                        sweetAlert("success", "전실 처리가 완료되었습니다.", "확인");
                        closeModal('modal-transfer');
                        patientInfo();
                    })
                    .catch(err => {
                        console.error("전실 저장 실패:", err);
                        sweetAlert("warning", "서버오류, 전실 내용을 저장 실패하였습니다.", "확인");
                    });
            } 
        }); 
    }
	
	//=======================================================
	// [유효성 검사] 미수행(대기/진행중) 오더 확인 함수
	//=======================================================
	    function checkPendingOrders() {
	        if (!globalPrescriptionList || globalPrescriptionList.length === 0) {
	            return false; // 오더가 없으면 통과
	        }

	        // 상태 코드 체크: 002(대기), 003(진행중)이 있으면 차단
	        // (001: 완료, 004: 중단은 퇴원 가능으로 간주)
	        for (const item of globalPrescriptionList) {
	            
	            // 1. 약품/주사 체크
	            if (item.drugList && item.drugList.length > 0) {
	                for (const d of item.drugList) {
	                    if (d.predrugDetailStatus === '002' || d.predrugDetailStatus === '003') {
	                        return true; // 미수행 존재
	                    }
	                }
	            }

	            // 2. 치료 체크
	            if (item.treatList && item.treatList.length > 0) {
	                for (const t of item.treatList) {
	                    if (t.pretreatmentDetailStatus === '002' || t.pretreatmentDetailStatus === '003') {
	                        return true;
	                    }
	                }
	            }

	            // 3. 검사 체크
	            if (item.examList && item.examList.length > 0) {
	                for (const e of item.examList) {
	                    if (e.preexaminationDetailStatus === '002' || e.preexaminationDetailStatus === '003') {
	                        return true;
	                    }
	                }
	            }

	            // 4. 식이 체크
	            if (item.dietList && item.dietList.length > 0) {
	                for (const d of item.dietList) {
	                    if (d.predietStatus === '002' || d.predietStatus === '003') {
	                        return true;
	                    }
	                }
	            }
	        }

	        return false; // 모든 오더가 완료(001)되거나 중단(004)됨
	    }
</script>
</body>
</html>
