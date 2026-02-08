<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!DOCTYPE html>
<html>
<head>
<!-- ===== Head 시작 ===== -->
<%@ include file="/WEB-INF/views/common/include/link.jsp" %>
<link rel="stylesheet" href="${pageContext.request.contextPath }/resources/assets/css/pages/execution.css">
<!-- ===== Head 끝 ===== -->
<title>입원 조제</title>
<style>
	.status-default-card .card-body{padding-top: var(--spacing-md)}
</style>
</head>
<body data-gnb="gnb-pharmacist">
	<!-- ===== Header 시작 ===== -->
	<%@ include file="/WEB-INF/views/common/include/header.jsp" %>
	<!-- ===== Header 끝 ===== -->
	
	<div class="main-container">
		<!-- ===== Sidebar 시작 (각 액터에 따라 sidebar jsp 교체)  ===== -->
		<%@ include file="/WEB-INF/views/common/include/left/left_reception.jsp" %>
		<!-- ===== Sidebar 끝 ===== -->
		
		<!-- ===== Main 시작 ===== -->
		<main class="main-content">
			<div class="grid grid-1-3 grid-full-height"> <!-- main이 2분할 이상일 경우 grid 사이즈 클래스 추가 필요 -->
				<!-- 콘텐츠 영역 -->
				<!-- 1번 영역 -->
				<div class="content-area flex flex-col h-full overflow-hidden">
				    <h2 class="page-title">입원 조제</h2>
				    <div class="box">
				        <h2 class="box-title text-md">대기 환자 목록</h2>
				        <div class="form-group mb-2">
				            <input type="text" id="patientSearchInput" class="input input-search" placeholder="환자명 또는 환자번호를 입력해주세요.">
				        </div>
				        <div class="tabs tabs-button mb-2" style="width: 100% !important;">
						    <button class="tab active w-full" onclick="switchTab(event, '')" id="allTap">전체 <span class="text-sm" id="usersTotal"></span></button>
						    <button class="tab w-full" onclick="switchTab(event, '조제중')">조제 중 <span class="text-sm" id="usersGoing"></span></button>
						    <button class="tab w-full" onclick="switchTab(event, '대기')">대기 <span class="text-sm" id="users"></span></button>
						    <button class="tab w-full" onclick="switchTab(event, '완료')">완료 <span class="text-sm" id="usersComplete"></span></button>
						</div>
				    </div>
				
				    <!-- 전제 환자 목록 스크롤 적용을 위해 따로 분리 -->
				    <div class="flex-1 overflow-auto mx--16"> 
						<div class="card-group patient-list px-4" id="patientList"><!-- 환자목록 동적추가 --></div>
				    </div>
				</div>
				
				<!--right-->
				<div class="content-area h-full overflow-hidden">
					<!-- 데이터 없음 -->
					<div class="empty-state h-full" data-empty="patientChart">
						<i class="icon icon-king icon-muted icon-user"></i>
						<div class="empty-state-title mt-3">선택된 환자가 없습니다.</div>
						<div class="empty-state-description">
							환자 대기 목록에서 환자를 선택해주세요!
						</div>
					</div>	
					<!-- 데이터 있음 -->  
					<div class="box flex flex-col h-full" id="patientChart" data-view="patientChart" >
						<div class="box-section">
							<div class="box-title-group flex items-center mb-2" id="patientInfo">
								<!-- <div class="flex items-center">
							        <h2 class="box-title mb-0">
							            <strong class="text-blue">홍길동</strong>
								        <span> 님의 조제 처방</span>
							        </h2>
							        <div class="item ml-2">
							        	(
							    		<span class="value">35세</span>
							    		&nbsp;/&nbsp;
							    		<span class="value">M</span>
							    		)
							    	</div>
							    </div>
						        <div class="doctor-info flex items-center ml-auto">
						            <i class="icon icon-doctor icon-md icon-muted"></i>
						            <span class="text-sm"><b>차은우</b> 의사</span>
						        </div> -->
						    </div>
						    <div class="flex justify-between items-center"> 
							    <div class="patient-info dot-divide flex" id="predetailInfo">
							    	<div class="item ">
							    		<span class="label">환자번호 : </span>&nbsp;<span class="value">3</span>
							    	</div>
							    	<div class="item">
							    		<span class="label">처방일 : </span>&nbsp;<span class="value">2026-01-13 10:20</span>
							    	</div>
							    </div>
							</div>
							<div class="callout callout-info mt-3">
							    <div class="callout-content flex" id="patientMemo">환자메모</div>
							</div>
						</div>
						
						<div class="box-section overflow-auto h-full flex-1 flex flex-col">
	                        <div class="content-header">
	                            <i class="icon icon-drug icon-md"></i>
	                            <div class="content-header-title">조제 약품 목록</div>
	                        </div>
	                        
	                        <!--진료 기록 내용 : dynamic -->
                        	<div class="table-wrapper flex-1">
							    <table class="table table-center">
							    	<colgroup>
							    		<col width="60px"/>
							    		<col width="auto"/>
							    		<col width="10%"/>
							    		<col width="10%"/>
							    		<col width="10%"/>
							    		<col width="10%"/>
							    		<col width="10%"/>
							    	</colgroup>
							        <thead>
							            <tr>
							                <th>No</th>
							                <th>약품명/약품코드</th>
							                <th>1회량</th>
							                <th>횟수</th>
							                <th>일수</th>
							                <th>총 용량</th>
							                <th>용법</th>
							            </tr>
							        </thead>
							        <tbody id="medicineTbody">
							        	<tr>
							        	<!-- HTML 동적 추가 -->
							        	</tr>
							        </tbody>
							    </table>
							</div>
							
						</div>
						<div class="callout callout-danger" id="shortageAlert" style="display:none;">
							<div class="callout-title">
								<i class="icon icon-danger-triangle icon-lg mr-2"></i> 
								<p class="font-bold" id="shortageMedicine">대웅제약 이부프로벤 파마브롬의 재고가 부족하여 조제가 불가능합니다.</p>
							</div>
							<div class="callout-content ml-9">
								<div class="info-list" id="shortageInfoList">
							    	<div class="item">
							    		<span class="label font-semibold">대웅제약 이부프로벤 파마브롬</span>
							    	</div>
							    	<div class="item">
							    		<span class="label">부족 재고 : </span>&nbsp;<span class="value font-semibold">3</span>
							    	</div>
							    	<div class="item">
							    		<span class="label">현재 재고 : </span>&nbsp;<span class="value font-semibold">20</span>
							    	</div>
							    </div>
							</div>
						</div>
						<hr class="section-divider" style="margin: 0; margin-top: var(--spacing-lg)"/>
						<!--right-footer-->
                        <div class="box-section" style="padding-bottom: var(--spacing-sm) !important;">
                        	<div class="flex justify-between">
	                        	<div class="group">
							        <h3 class="title-h3">조제 처리</h3>
							        <p id="pharmInfo">담당자 : ${not empty employee ? employee.employeeName : '이철희'}</p>
							    </div>
	                            <div class="btn-group">
	                            	<p class="description flex items-center mr-4">
	                                	<i class="icon icon-info-circle mr-2"></i>
	                                    <b>'조제 완료'</b>시 처방된 수량만큼 재고가 자동으로 차감됩니다.
	                                </p>
	                                <button class="btn btn-primary btn-lg btn-icon-left" id="submitBtn">
	                                	<i class="icon icon-check-circle-one icon-md text-white mr-2"></i>
	                                	조제 완료
	                                </button>
	                            </div>
	                    	</div>
                        </div>			
					</div>
                </div>
			</div>
		</main>
		<!-- ===== Main 끝 ===== -->
	</div>
	
</body>
<script type="text/javascript">
	let allPatients = [];
	let currentFilterStatus = '';
	let currentPatientNo = null;
	let currentPredetailNo = null;
	
	// 전역 변수 중복 선언 방지를 위해 함수 내부에서 찾거나 유지
	const emptyStates = document.querySelectorAll('[data-empty]');
	const viewStates = document.querySelectorAll('[data-view]');
	
	let submitBtn = document.querySelector("#submitBtn");
	
	document.addEventListener('DOMContentLoaded', () => {
		init_fn();
		init_ui();
		init_data();
	});
	
	function init_fn() {
		bindPatientListEvent();
		bindPharmCompleteEvent();
		init_search();
	}
	
	function init_ui(){
		init_chartView();
	}

	async function init_data() {
	    try {
	        await loadPatientList();
	    } catch (error) {
	        console.error("초기 데이터 로드 중 오류 발생:", error);
	    }
	}
	
	// 검색
	function applySearchAndRender() {
	    const searchInput = document.querySelector('#patientSearchInput');
	    const keyword = searchInput ? searchInput.value.trim().toLowerCase() : "";
	
	    // 1. 검색어가 없으면 전체 목록 출력
	    if (!keyword) {
	        renderPatientList(allPatients); // 대기환자목록 - 환자 전체 출력
	        updateTabCounts(); 
	        return;
	    }
	
	    // 2. 검색어가 있으면 필터링
	    const filtered = allPatients.filter(p => {
	        const nameMatch = p.patientName.toLowerCase().includes(keyword);
	        const noMatch = String(p.patientNo).includes(keyword);
	        return nameMatch || noMatch;
	    });
	
	    renderPatientList(filtered);  // 대기환자목록 - 검색된 환자만 출력
	}
	
	// 초기화 함수
	function init_search() {
	    const searchInput = document.querySelector('#patientSearchInput');

	    // 입력이 일어날 때마다 실행
	    searchInput.addEventListener('input', () => {
	        applySearchAndRender(); // 통합 함수 호출
	    });

	    searchInput.addEventListener('keypress', (e) => {
	        if (e.key === 'Enter') {
	            e.preventDefault();
	            searchInput.blur();
	        }
	    });
	}
	
	function updatePatientData(newData) {
	    allPatients = newData;   // 1. 원본 데이터 교체
	    applySearchAndRender();  // 2. 현재 검색어 상태에 맞춰 다시 그리기
	}
	
	// 탭 객체
	const TAB_CONFIG = {
	    all: { label: '전체', status: '', selector: '#usersTotal' },
	    going: { label: '조제중', status: '조제중', selector: '#usersGoing' },
	    waiting: { label: '대기', status: '대기', selector: '#users' },
	    complete: { label: '완료', status: '완료', selector: '#usersComplete' }
	};

	// 탭 작동!!
	function switchTab(event, status) {
		const tabs = document.querySelectorAll('.tab');
	    tabs.forEach(tab => tab.classList.remove('active'));
	    event.currentTarget.classList.add('active');
	    
	    currentFilterStatus = status;
	    const filteredPatients = filterPatients(status);
	    renderPatientList(filteredPatients);
	}
	
	// 탭 초기화!!
	function resetToAllTab() {
		currentFilterStatus = '';
	    const tabs = document.querySelectorAll('.tab');
	    tabs.forEach(tab => tab.classList.remove('active'));
	    const allTab = document.querySelector('#allTap');
	    if (allTab) allTab.classList.add('active');
	}
	
	// 탭 카운트 업데이트
	function updateTabCounts() {
	    Object.values(TAB_CONFIG).forEach(({ status, selector }) => {
	    	const element = document.querySelector(selector);
	        if (!element) return; // 요소가 없으면 스킵
	    	
	        let count = 0;
	        if (status === '') {
	            count = allPatients.length;
	        } else if (status === '대기') {
	            count = allPatients.filter(p => p.predrugDetailStatus === '대기').length;
	        } else {
	            count = allPatients.filter(p => p.predrugDetailStatus === status).length;
	        }
	        element.textContent = count;
	    });
	}
	
	// 상태에 따라 필터링
	function filterPatients(status) {
		if (!status) return allPatients;
	    return allPatients.filter(p => p.predrugDetailStatus === status);
	}
	
	// 환자 대기 목록 불러오기
	async function loadPatientList(){
		try {
	        const response = await axios.get('/pharmacist/patient/waitingList');
	        allPatients = response.data;
	        updateTabCounts();
	        renderPatientList(filterPatients(currentFilterStatus));
	    } catch (error) {
	        console.error("데이터 로드 중 오류 발생:", error);
	        sweetAlert("error", "목록 조회를 실패했습니다.", "확인");
	    }
	}
	
	// 환자 대기 목록 그리기
	function renderPatientList(data){
		const patientList = document.querySelector('#patientList');
		if(!data || data.length === 0) {
			patientList.innerHTML = `
				<div class="empty-state empty-state-list">
	    			<i class="icon-lg icon icon-danger-circle"></i>
	        		<div class="empty-state-title">대기 환자가 없습니다</div>
				</div>`;
			return;
		}
		
		console.log("환자데이터", data)
		
		
		let html = '';
		data.forEach(d => {
			let cardClass = "status-default-card";
			let statusBadge = "";
			let startExamBtn = `<button class="ml-3 btn btn-danger-light btn-icon" onclick="startExam(event, \${d.predetailNo}, '\${d.patientName}', '\${d.stockOutFlag}')"><i class="icon icon-play"></i></button>`;
			
			// 상태값 정의에 따른 UI 분기
	        if(d.predrugDetailStatus === '완료'){
	            statusBadge = `<div class="status-success ml-auto"><i class="icon icon-check-circle-one mr-2"></i> 완료</div>`;
	        } else if(d.predrugDetailStatus === '조제중'){
	            cardClass = "status-going-card";
	            statusBadge = `<span class="status-going ml-auto">조제 중</span>`;
	        } else if(d.predrugDetailStatus === '대기' && d.stockOutFlag === 'Y'){
	            // '주의' 상태 UI
	            cardClass = "status-danger-card";
	            statusBadge = `<span class="status-danger ml-auto">주의 (재고부족) \${startExamBtn}</span>`;
	        } else if(d.predrugDetailStatus === '대기'){
	            statusBadge = `<div class="status-default ml-auto">대기 \${startExamBtn}</div>`;
	        }
			
			let drugArray = d.drugNames ? d.drugNames.split(', ') : [];
			let displayDrug = drugArray.length > 1 ? `\${drugArray[0]} 외 \${drugArray.length - 1}종` : (drugArray[0] || "처방없음");

			html += `
				<div class="card \${cardClass} patient-item" data-predetail-no="\${d.predetailNo}">
					<div class="card-body">
						<div class="flex items-center">
	            			<h3 class="title-h3"><b>\${d.patientName}</b> 님</h3>
	            			\${statusBadge}
						</div>
						<!--\${(d.predrugDetailStatus === '대기' && d.stockOutFlag === 'Y') ? 
							`<div class="callout callout-sm callout-danger mt-2"><div class="callout-body flex items-center justify-center"><i class="icon icon-danger-triangle icon-md mr-2"></i>재고 부족 품목 포함</div></div>`
							: `<div class="drug-list mt-1"><span class="text-base text-secondary">\${displayDrug}</span></div>`
						}-->
						<div class="drug-list mt-1"><span class="text-base text-secondary">\${displayDrug}</span></div>
						<hr class="section-divider my-3" />
		        		<div class="flex justify-between">
		        			<div class="date-info flex items-center"><i class="icon icon-bed icon-md icon-muted"></i><span class="text-sm text-secondary">\${d.roomNo}호</span></div>
				    		<div class="flex gap-sm">
			            		<div class="doctor-info flex items-center"><i class="icon icon-doctor icon-md icon-muted"></i><span class="text-sm text-secondary">처방의 <b>\${d.employeeName}</b></span></div>
					    		<div class="time-info flex items-center"><span class="text-sm text-secondary">\${d.predetailRegdate}</span></div>
					    	</div>
						</div>
			    	</div>
				</div>`;
		});
		patientList.innerHTML = html;
	}
	
	// 환자 대기 상태 변경
	function startExam(event, predetailNo, patientName, flag){
		event.stopPropagation();
		
		console.log("flag", flag)
		
		let alertConfig = {
			icon: "warning",
			title: `\${patientName}님 약품 조제를 시작하시겠습니까?`,
			confirm: "조제시작", 
			cancel: "취소",
			showCancel: true
		}
		
		if(flag === 'Y'){
			alertConfig.title = `안전 재고가 부족한 품목이 있습니다.<br>그래도 \${patientName}님 약품 조제를 시작하시겠습니까?`
		}
		
		sweetAlertC(alertConfig)
			.then((result) => { if (result.isConfirmed) updateExamStatus(predetailNo); });
	}
	
	// 환자 대기 상태 변경 업데이트
	async function updateExamStatus(predetailNo){
		try{
			const response = await axios.post("/pharmacist/patient/waitingStatus", { predetailNo : predetailNo, predrugDetailStatus : '조제중' });
			if(response.data.success){
				sweetAlert("success", "상태가 변경되었습니다.", "확인").then(async () => {
					await loadPatientList();
					resetToAllTab();
					setTimeout(()=> selectPatient(predetailNo), 100);
				});
			}
		} catch(error){
			sweetAlert("error", "상태 업데이트를 실패했습니다.", "확인");
		}
	}
	
	// 환자 클릭 이벤트
	function bindPatientListEvent() { 
	    document.querySelector('#patientList').addEventListener('click', handlePatientClick);
	}
	
	// 환자 클릭 이벤트 실행
	function handlePatientClick(event){
		const patientItem = event.target.closest('.patient-item');
		if(patientItem) selectPatient(patientItem.dataset.predetailNo);
	}
	
	// 환자 상세 조회 활성화
	function selectPatient(predetailNo){
		if(!predetailNo) return;
		
		currentPredetailNo = predetailNo;
		
	    document.querySelectorAll('.patient-item').forEach(item => item.classList.remove('active'));
	    
	    const targetItem = document.querySelector(`.patient-item[data-predetail-no="\${predetailNo}"]`);
	    if(targetItem) {
			targetItem.classList.add('active');
			targetItem.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
	    }
	    
	    submitBtn.dataset.currentNo = predetailNo;
	    loadPatientDetail(predetailNo);
	}
	
	// 환자 상세 조회 불러오기
	async function loadPatientDetail(predetailNo) {
		try{
			const response = await axios.get(`/pharmacist/\${predetailNo}`);
	        renderPatientDetail(response.data);
		} catch(error) {
			sweetAlert("error", "환자 상세 조회를 실패했습니다.", "확인");
		}
	}

	// 상세 조회 화면 초기화
	function init_chartView() {
		emptyStates.forEach(el => el.style.display = 'flex');
		viewStates.forEach(el => el.style.display = 'none');
	}
	
	// 상세 조회 화면 그리기
	function renderPatientDetail(data){		
		let empty = document.querySelector("[data-empty='patientChart']");
		let view = document.querySelector("[data-view='patientChart']");
		if(!data) {
			empty.style.display = "flex";
			view.style.display = "none";
			return;
		}
		empty.style.display = "none";
		view.style.display = "flex";
		
		const d = formatNull(data);
		document.querySelector("#patientInfo").innerHTML = `
			<div class="flex items-center">
		        <h2 class="box-title mb-0"><strong class="text-blue">\${d.patientName}</strong><span> 님의 조제 처방</span></h2>
		        <div class="item ml-2">(<span class="value">\${d.patientAge}세</span>&nbsp;/&nbsp;<span class="value">\${d.patientGen}</span>)</div>
		    </div>
	        <div class="doctor-info flex items-center ml-auto"><i class="icon icon-doctor icon-md icon-muted"></i><span class="text-sm"><b>\${d.employeeName}</b> 의사</span></div>`;
		
		document.querySelector("#predetailInfo").innerHTML = `
			<div class="item"><span class="label">환자번호 : </span>&nbsp;<span class="value">\${d.patientNo}</span></div>
			<div class="item"><span class="label">처방일 : </span>&nbsp;<span class="value">\${d.predetailRegdate}</span></div>`;
		
		document.querySelector("#patientMemo").innerHTML = "<i class='icon icon-clipboard icon-primary icon-md mr-3'></i>" + d.patientMemo;
        loadDrugOrders(d.predetailNo);
	}
	
	// 약 처방 목록 불러오기
	async function loadDrugOrders(predetailNo) {
		try {
			const response = await axios.get(`/pharmacist/patientOrder/\${predetailNo}`);
			rendarPatientOrder(response.data);
		} catch(error) {
			sweetAlert("error", "조제 약품 목록을 조회하는데 실패했습니다.", "확인");
		}
	}
	
	// 약 처방 목록 그리기
	function rendarPatientOrder(data){
		const medicineTbody = document.querySelector("#medicineTbody");
		// data는 List<DrugVO> 배열임
		if (!data || data.length === 0) {
	        medicineTbody.innerHTML = `<tr><td colspan="8" class="text-center">처방 내역이 없습니다.</td></tr>`;
	        return;
	    }

	    medicineTbody.innerHTML = data.map((d, i) => `
	        <tr>
	            <td>\${i + 1}</td>
	            <td style="text-align: left;">
	                <p class="font-semibold \${(d.stockStatus !== 'NORMAL') ? 'text-danger' : ''}">\${d.drugName}</p>
	                <span class="text-sm text-secondary">\${d.drugCode}</span>
	            </td>
	            <td>\${d.predrugDetailDose}</td>
	            <td>\${d.predrugDetailFreq}</td>
	            <td>\${d.predrugDetailDay}</td>
	            <td class="font-bold" style="\${(d.stockStatus !== 'NORMAL') ? 'color: var(--color-danger)' : ''}">\${d.drugTotal}</td> 
	            <td>\${d.predrugDetailMethod || '-'}</td>
	        </tr>
	    `).join('');
	    
		const shortageAlert = document.querySelector("#shortageAlert");
		const shortageMedicine = document.querySelector("#shortageMedicine");
		const shortageInfoList = document.querySelector("#shortageInfoList");
		
		// 서비스에서 처리한 stockStatus를 기반으로 필터링
		const shortages = data.filter(d => d.stockStatus === 'SHORTAGE' || d.stockStatus === 'IMPOSSIBLE');
		
		if(shortages.length > 0){
			shortageAlert.style.display = "block";
			
			//IMPOSSIBLE이 하나라도 포함되어 있는지 확인하기 위함
			const isImpossible = shortages.some(d => d.stockStatus === 'IMPOSSIBLE');
			submitBtn.dataset.isImpossible = '';
			let drugNameMap = shortages.map(s => s.drugName).join(", ");
			
			if(isImpossible){
				shortageAlert.classList.remove("callout-warning");
				shortageAlert.classList.add("callout-danger");
				shortageMedicine.innerText = drugNameMap + "이 재고가 부족하여 조제가 불가능합니다.";
				// 조제 완료 버튼 비활성화
				submitBtn.dataset.isImpossible = isImpossible;
				submitBtn.disabled = true;
			} else {
				shortageAlert.classList.remove("callout-danger");
				shortageAlert.classList.add("callout-warning");
				shortageMedicine.innerText = drugNameMap + "의 재고를 확인해주세요.";
				submitBtn.disabled = false;
				submitBtn.dataset.isImpossible = isImpossible;
			}
			
			shortageInfoList.innerHTML = shortages.map(d => {
					
				// 잔여 재고 계산 (현재고 - 이번 소요량)
	            const remainingStock = d.drugAmount - d.drugTotal;
	            // 부족분 계산 (잔여고 - 안전재고)
	            //const shortageValue = remainingStock - d.drugSaftyStoke;
	            const shortageValue = Math.max(0, d.drugSaftyStoke - remainingStock);
				
				return `
				<div class="item-group flex mb-2 border-bottom">
					<div class="item mr-10"><span class="label font-semibold">\${d.drugName}</span></div>
			    	<div class="item flex gap-lg">
			    		<span>현재 재고 : <b>\${d.drugAmount}</b> (<span>안전 재고 : \${d.drugSaftyStoke}</span>)</span>
			    		<span>조제 후 잔여 : <b>\${remainingStock}</b></span>
			    		<span>안전 재고 부족 수량 : <b class="text-danger">\${shortageValue}</b></span>
			    	</div>
				</div>`;
			}).join('');
		} else if(shortages.length === 0 ||  data[0].predrugDetailStatus === "완료") {
			shortageAlert.style.display = "none";	
		}
		
		// 버튼 상태
	    if(data[0].predrugDetailStatus === "대기") {
			submitBtn.disabled = true;
	    } else if (data[0].predrugDetailStatus === "조제중") {
	    	submitBtn.disabled = false;
	    } else if (data[0].predrugDetailStatus === '완료') {
	    	submitBtn.disabled = true;
	    }
	}

	// 조제 완료 버튼 이벤트
	function bindPharmCompleteEvent(){
		submitBtn.addEventListener('click', handleCompleteClick);
	}
	
	// 조제 상태 업데이트
	async function handleCompleteClick(e){
		const predetailNo = e.currentTarget.dataset.currentNo;
		
		if(!predetailNo || predetailNo == "null") {
			sweetAlert("warning", "처리할 오더가 없습니다.", "확인");
			return;
		}
		
		let isImpossible = submitBtn.dataset.isImpossible === 'true';
		
		// 방어
		if(isImpossible) {
			sweetAlert(
				"error", 
				"재고가 없는 약품이 포함되어 있어 조제를 진행할 수 없습니다. 처방의에게 문의가 필요합니다.", 
				"확인"
			);
			return;
		}
		
		let alertConfig = {
			icon: "warning",
			title: "조제를 완료하시겠습니까?",
			confirm: "조제완료", 
			cancel: "취소",
			showCancel: true,
		}
		
		if(submitBtn.dataset.isImpossible === 'false'){
			alertConfig.html = `부족한 재고가 있으니<br/>반드시 확인하여 재고를 추가하시길 바랍니다.`;
		}
		
		sweetAlertC(alertConfig).then(async (result) => {
	        if (result.isConfirmed) {
	            try {
	                const response = await axios.post("/pharmacist/workview/complete", {
	                    predetailNo: predetailNo
	                });
	                
	                if(response.data.success) {
	                    sweetAlert("success", "조제가 완료되었습니다.", "확인")
	                    .then(() => {
	                        init_chartView(); 
	                        loadPatientList(); // 목록 새로고침
	                    });
	                } else {
	                    sweetAlert("error", response.data.message || "처리에 실패했습니다.", "확인");
	                }
	            } catch (error) {
	                console.error(error);
	                sweetAlert("error", "전송 중 오류가 발생했습니다.", "확인");
	            }
	        }
	    });
	}
	
	function resetOrderDetail(){
		let empty = document.querySelector("[data-empty='patientChart']");
		let view = document.querySelector("[data-view='patientChart']");
		
		if (empty && view) {
			empty.style.display = "flex";  // "선택된 오더가 없습니다" 표시
			view.style.display = "none";   // 상세 내용 숨김
	    }
	}
	
	// null 값 등 체크해서 변경하기
	function formatNull(data, fallback = "-") {
	    if (data === null || data === undefined || data === "") return fallback;
	    if (typeof data !== "object") return data;
	    const formatted = Array.isArray(data) ? [] : {};
	    for (const key in data) formatted[key] = formatNull(data[key], fallback);
	    return formatted;
	}
</script>
</html>