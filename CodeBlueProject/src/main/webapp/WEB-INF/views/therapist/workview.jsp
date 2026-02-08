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
<title>물리치료</title>
</head>
<body data-gnb="gnb-therapist">
	<!-- ===== Header 시작 ===== -->
	<%@ include file="/WEB-INF/views/common/include/header.jsp" %>
	<!-- ===== Header 끝 ===== -->
	
	<div class="main-container">
		<!-- ===== Sidebar 시작 (각 액터에 따라 sidebar jsp 교체)  ===== -->
		<%@ include file="/WEB-INF/views/common/include/left/left_reception.jsp" %>
		<!-- ===== Sidebar 끝 ===== -->
		
		<!-- ===== Main 시작 ===== -->
		<main class="main-content">
			<div class="grid grid-sidebar-lg grid-full-height"> <!-- main이 2분할 이상일 경우 grid 사이즈 클래스 추가 필요 -->
				<!-- 콘텐츠 영역 -->
				<!-- 1번 영역 -->
				<div class="content-area flex flex-col h-full overflow-hidden">
				    <h2 class="page-title">물리치료</h2>
				    <div class="box">
				        <h2 class="box-title text-md">대기 환자 목록</h2>
				        <div class="form-group mb-2">
				            <input type="text" id="patientSearchInput" class="input input-search" placeholder="환자명 또는 환자번호를 입력해주세요.">
				        </div>
				        <div class="tabs tabs-button mb-2" style="width: 100% !important;">
				            <button class="tab active w-full" onclick="switchTab(event, '')" id="allTap">전체 <span class="text-sm" id="usersTotal"></span></button>
				            <button class="tab w-full" onclick="switchTab(event, '치료중')">치료중 <span class="text-sm" id="usersGoing"></span></button>
				            <button class="tab w-full" onclick="switchTab(event, '대기')">대기 <span class="text-sm" id="users"></span></button>
				        </div>
				    </div>
				
				    <!-- 전제 환자 목록 스크롤 적용을 위해 따로 분리 -->
				    <div class="flex-1 overflow-auto my--8"> 
				        <div class="card-group patient-list" id="patientList"><!-- HTML 동적 추가 --></div>
				    </div>
				</div>
				
				<!--right-->
				<!-- 데이터 없음 -->
				<div class="content-area grid grid-1 h-full overflow-hidden justify-center" data-empty="patientChart">
                		<!-- 환자 상세 정보 빈 데이터 UI -->
	                <div class="empty-state">
						<i class="icon icon-king icon-muted icon-user"></i>
						<div class="empty-state-title mt-3">선택된 환자가 없습니다.</div>
						<div class="empty-state-description">
							환자 대기 목록에서 환자를 선택해주세요!
						</div>
					</div>	
                </div>
                <!-- 데이터 있음 -->
				<div class="content-area grid grid-2 h-full overflow-hidden" id="patientChart" data-view="patientChart">
					<!-- <div class="btn-group-right">
            	
		                <button class="btn btn-icon btn-ghost" onclick="closeChart()">
		                	<i class="icon icon-x icon-lg"></i>
		                </button>
		            </div> -->
                    <div class="content-area_left flex flex-col h-full overflow-hidden">                    					
                        <!-- 환자 상세 정보 -->
                        <div class="box" id="patientInfo"><!-- 동적 HTML 적용 --></div>
                        <!-- 환자 기초 문진 정보 -->
                        <div class="box box-padding box-secondary mt-3" id="patientScr"><!-- 동적 HTML 적용 --></div>
                        
                        <hr class="section-divider" />
                        
                        <!-- 오더 -->
                        <div class="box flex items-center gap-md">
			            	<h2 class="box-title">
				            	<i class="icon icon-label icon-md"></i>
				            	오더 목록
				            </h2>
				            <span class="text-sm" style="margin-left: auto;"><i class="icon icon-calendar icon-sm"></i> 오늘날짜 : <b id="todayDate"></b></span>
		            		</div>
                        <div class="flex-1 overflow-auto">
                        	<div class="list" id="orderList"><!-- 동적 HTML 적용 --></div>
                        </div>
                    </div>

                    <!-- right -->
					<div class="content-area_right flex flex-col h-full overflow-hidden" data-empty="orderDetail">
						<!-- 데이터 없을 때 -->
						<div class="empty-state h-full">
						    <i class="icon icon-king icon-muted icon-file"></i>
						    <div class="empty-state-title mt-3">선택된 오더가 없습니다.</div>
						    <div class="empty-state-description">
						        상세 검사항목을 보려면 오더 목록에서 오더를 선택해주세요!
						    </div>
						</div>
					</div>
					<!-- 데이터 있을 때 -->
					<div class="content-area_right flex flex-col h-full overflow-hidden" data-view="orderDetail">	
                        <!--right-top-->
                        <div class="box flex-1 overflow-auto">
                            <div class="box-title-group flex justify-between" id="orderDetailTitle"><!-- 동적 HTML 적용 --></div>
                            <!-- 진료기록 : fix -->
                            <div class="mt-3">
	                            <div class="content-header">
	                                <i class="icon icon-pharmacy icon-md"></i>
	                                <div class="content-header-title">치료 수행</div>
	                            </div>
	                                
	                            <!--진료 기록 내용 : dynamic -->
	                           	<div class="table-wrapper">
								    <table class="table table-center">
								    	<colgroup>
								    		<col width="60px" />
								    		<col width="15%" />
								    		<col width="auto" />
								    		<col width="80px" />
								    		<col width="80px" />
								    		<col width="15%" />
								    	</colgroup>
								        <thead>
								            <tr>
								                <th>No</th>
								                <th>치료코드</th>
								                <th>치료명</th>
								                <th>1회량</th>
								                <th>횟수</th>
								                <th>방법</th>
								            </tr>
								        </thead>
								        <tbody id="orderDetailTbody">
								        	<!-- 동적 HTML 적용 -->
								        </tbody>
								    </table>
								</div>
							</div>
                        </div>
                        <!--right-footer-->
                        <div class="area-right_footer pt-3">
                            <!-- 좌우 배치 -->
                            <div class="btn-group-justified">
                                <div class="btn-group-left">
                                    <p class="description flex items-center">
                                    	<i class="icon icon-info-circle mr-2"></i>
                                    	치료완료 버튼 클릭 시, 주치의에게 실시간 알림이 전송됩니다.
                                    </p>
                                </div>
                                <div class="btn-group-right">
                                    <button class="btn btn-primary" id="submitBtn">치료완료</button>
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
<!-- javascript -->
<script type="text/javascript">
	let allPatients = [];
	let currentPatientNo = null; // 선택된 환자 없음
	let currentPredetailNo = null;
	let currentChartNo = null;
	let patientChart = document.querySelector('#patientChart');
	let empty = document.querySelectorAll('[data-empty]');
	let view = document.querySelectorAll('[data-view]');
	let submitBtn = document.querySelector("#submitBtn");

	//페이지 로드 시 초기화
	document.addEventListener('DOMContentLoaded', () => {
	    init_fn();
	    init_ui();
	    init_data();
	    displayToday();
	});
	
	function init_fn() {
	    //loadPatientList();  // 초기 로드만
	    bindPatientListEvent();  // 환자 목록 클릭 이벤트만 
	    bindTretmentCompleteEvent(); // 검사완료 클릭 이벤트
	    init_search();
	}
	
	function init_ui(){
		init_chartView();
	}

	/*	
	==========================
	비동기 데이터 처리		
	==========================	
	*/
	
	// 초기화면
	async function init_data() {
	    try {
	        await loadPatientList(); // 대기 환자 목록 서버 호출
	    } catch (error) {
	        console.error("초기 데이터 로드 중 오류 발생:", error);
	    }
	}
	   	
	
	// == 대기 환자 조회 목록 ================================================================
	// 대기 환자 검색
	function init_search() {

    	const searchInput = document.querySelector('#patientSearchInput');

	    // 입력이 일어날 때마다 실행 (실시간 검색)
	    searchInput.addEventListener('input', (e) => {
	        const keyword = e.target.value.trim().toLowerCase(); // 검색어 소문자화 및 공백 제거
	
	        // 검색어가 비어있으면 전체 목록 출력
	        if (!keyword) {
	            renderPatientList(allPatients);
	            updateTabCounts(); // 카운트도 유지
	            return;
	        }
	
	        // 이름 또는 환자번호에 키워드가 포함된 환자만 필터링
	        const filtered = allPatients.filter(p => {
	            const nameMatch = p.patientName.toLowerCase().includes(keyword);
	            const noMatch = String(p.patientNo).includes(keyword); // 번호는 문자열로 변환 후 비교
	            
	            return nameMatch || noMatch;
	        });
	
	        // 필터링된 결과로 목록 다시 그리기
	        renderPatientList(filtered);
	    });
	
	    // 엔터키를 눌렀을 때 포커스를 해제하거나 추가 동작을 하고 싶다면 (선택 사항)
	    searchInput.addEventListener('keypress', (e) => {
	        if (e.key === 'Enter') {
	            e.preventDefault(); // 폼 제출 방지
	            searchInput.blur(); // 포커스 해제 (키보드 닫기 효과)
	        }
	    });
	}
		
	// 상태 필터링
	function filterPatients(status) {
	    if (status === "치료중") {
	        return allPatients.filter(p => p.preTreatdetailStatus === "치료중");
	    } else if (status === "대기") {
	        return allPatients.filter(p => p.preTreatdetailStatus !== "치료중");
	    }
	    return allPatients; // 전체
	}
	
	// 대기 환자 목록 - 환자 목록 불러오기
	async function loadPatientList(status = ""){ 
	    try {
	        const response = await axios.get('/therapist/workview/waitingList');
	        allPatients = response.data;
	        
	        const filteredPatients = filterPatients(status);
	        
	        // 렌더링 & 카운트 업데이트
	        renderPatientList(filteredPatients);
	        updateTabCounts(); // status 파라미터 제거, allPatients 사용
	        
	    } catch(error) {
	        console.error(error);
	        alert("목록 조회 실패.")
	    }
	}
	
	// 상태 변경 - POST
	async function updateExamStatus(predetailNo, patientNo) {
	    try {
	        const response = await axios.post('/therapist/workview/waitingStatus', {
	        	predetailNo: predetailNo,
	        	preTreatdetailStatus: '치료중'
	        });
	        if (response.data.success) {
		    	Swal.fire({
		    		title: "상태가 변경되었습니다.",
		    		icon: "success",
		    		customClass: {
		    			confirmButton: "btn btn-primary btn-lg",
		    			title: "text-xl text-primary mb-3"
		    		},
		    		confirmButtonText: "확인"
		    	}).then(async (result)=> {
		            await loadPatientList();  // 목록 새로고침
		            
		            resetToAllTab(); // 탭 초기화
		            setTimeout(() => {
		                selectPatient(patientNo);
		            }, 50);
		            selectPatient(patientNo);
		    	});  
	        }
	        
	    } catch (error) {
	        console.error('상태 변경 실패:', error);
	        alert('상태 변경에 실패했습니다.');
	    }
	}
	
	// 탭 전환
	function switchTab(event, status) {
	    const tabObject = event.target.closest('.tabs');
	    const tabs = tabObject.querySelectorAll('.tab');
	    
	    tabs.forEach(tab => tab.classList.remove('active'));
	    event.target.classList.add('active');
	    
	    // 필터링만 다시 (API 재호출 X)
	    const filteredPatients = filterPatients(status);
	    renderPatientList(filteredPatients);
	}
	
	// 탭 초기화(상태 업데이트 이후 초기화 처리 필요.)
	function resetToAllTab() {
	    const tabs = document.querySelectorAll('.tab');
	    tabs.forEach(tab => tab.classList.remove('active'));
	    
	    const allTab = document.querySelector('#allTap');
	    if (allTab) allTab.classList.add('active')
	}
	
	// 탭 카운트 업데이트 (항상 전체 카운트 표시)
	function updateTabCounts() {
	    //const total = allPatients.length;
	    const total = allPatients.filter(p => p.preTreatdetailStatus !== "완료").length;
	    const going = allPatients.filter(p => p.preTreatdetailStatus === "치료중").length;
	    const waiting = allPatients.filter(p => p.preTreatdetailStatus === "대기").length;
	    
	    document.querySelector('#usersTotal').textContent = total;
	    document.querySelector('#usersGoing').textContent = going;
	    document.querySelector('#users').textContent = waiting;
	}
	
	// 환자 목록 만들기
	function renderPatientList(data) {
	    const patientList = document.querySelector('#patientList');
	
	    const activePatients = data.filter(d => d.preTreatdetailStatus !== '완료');
	    // 대기 환자 목록
	    const html = activePatients.map(d => `
	        <div class="card patient-item" data-patient-no="\${d.patientNo}" data-chart-no="\${d.predetailVO.chartNo}">
	            <div class="card-header py-1 flex justify-between">
	                <h4 class="card-title text-sm"><span>환자번호</span> \${d.patientNo}</h4>
	                <div class="relative">
	                    \${d.preTreatdetailStatus === '치료중' 
	                        ? `<div class="status-going">치료중</div>`
	                        : `<div class="status-default">
	                                대기
	                                <button class="ml-3 btn btn-danger-light btn-icon" onclick="startExam(event, \${d.patientNo}, '\${d.patientName}', \${d.predetailVO.predetailNo})">
	                                    <i class="icon icon-room-service"></i>
	                                </button>
	                            </div>`
	                    }
	                </div>
	            </div>
	            <div class="card-body">
	                <div class="flex items-center mb-1">
	                    <h3 class="text-base font-bold mb-1">\${d.patientName}</h3>
	                    <p class="description text-sm mb-1 ml-3">
	                        \${d.patientGen === 'MALE' ? '남' : '여'} /
	                        \${d.patientAge}세 (\${d.patientRegno1})
	                    </p>
	                </div>
	                <div class="flex justify-between items-center">
		                <div class="flex gap-1 flex-wrap">
		                    \${d.treatmentName.split(',').map(name =>
		                            '<span class="badge badge-default">' + name.trim() + '</span>'
		                    ).join('')}
		                </div>
		                <span class="text-sm text-secondary">\${d.orderDate}</span>
		        	</div>
	            </div>
	        </div>
	    `).join('');
	
	    // 페이지 로딩 시 loadPatientList()가 바로 실행되기 때문에 여기서 정의한당
	    const noDataList = `
	    		<div class="empty-state empty-state-list" data-empty="patientList">
		    		<i class="icon-lg icon icon-danger-circle"></i>
		        <div class="empty-state-title">대기 환자가 없습니다</div>
		    </div>
	    `;
	
	    patientList.innerHTML = html || noDataList;
	}
	
	function startExam(event, patientNo, patientName, predetailNo){
		event.stopPropagation();
	    
		Swal.fire({
			title: patientName + "님의 물리치료를 진행하시겠습니까?",
			icon: "warning",
			showCancelButton: true,
			customClass: {
			    confirmButton: "btn btn-primary btn-lg",
			    cancelButton: "btn btn-secondary  btn-lg",
			    title: "text-xl text-primary mb-3"
			},
			cancelButtonText: "취소",
			confirmButtonText: "치료진행",
			reverseButtons: true
		}).then((result) => {
		  	if (result.isConfirmed) {
		  		updateExamStatus(predetailNo, patientNo);
			}
		});
	}

	// == 환자 상세 조회 ================================================================
	// 대기 환자 목록에서 환자를 선택하면 환자 상세화면 VIEW
	async function loadPatientDetail(patientNo) {
		try {
			const response = await axios.get(`/therapist/workview/patient/\${patientNo}`);
			const patient = response.data;
	        // const { patientVO, registrationVO, employeeVO, screeningVO } = patient;
	        
	        console.log("환자상세조회", patient);
	        
	        renderPatientDetail(patient);
	        
		} catch(error) {
			console.error(error);
			alert("환자 조회가 정상적으로 처리되지 못했습니다.");
		}
	}
	
	// 환자 목록 클릭 이벤트 바인딩
	function bindPatientListEvent() { // tab ui 클릭 이벤트
	    const patientList = document.querySelector('#patientList');
	    patientList.addEventListener('click', handlePatientClick);
	}
	
	// 환자 클릭 핸들러
	function handlePatientClick(e) {
	    const patientItem = e.target.closest('.patient-item'); // 선택한 환자
	    if (!patientItem) return; 
	    
	    selectPatient(patientItem.dataset.patientNo);
	}
	
	function selectPatient(patientNo){
	    if (!patientNo) return; 
	    
	    currentPatientNo = patientNo; // 상태값 업데이트
	    
	    // 선택한 환자 활성화(active) 상태 주기
	    const allItems = document.querySelectorAll('.patient-item');
	    allItems.forEach(item => item.classList.remove('active'));
	    
	    console.log("currentPatientNo", currentPatientNo);
	    
	    const targetItem = document.querySelector(`.patient-item[data-patient-no="\${patientNo}"]`);
	    
	    console.log("targetItem", targetItem);
	    if(targetItem) {

	    	console.log("test");
			targetItem.classList.add('active');
			targetItem.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
	    }

	    resetOrderDetail();
	    loadPatientDetail(patientNo); // 클릭한 환자의 환자번호로 상세조회
	}
	
	// content-area 초기화면 => 환자상세조회는 환자를 선택해야만 데이터를 가져올 수 있음. 
	function init_chartView() {
		empty.forEach(el => el.style.display = 'flex');
		view.forEach(el => el.style.display = 'none');
	}
	
	function renderPatientDetail(data){
		let empty = document.querySelector("[data-empty='patientChart']");
		let view = document.querySelector("[data-view='patientChart']");
		
		if(view) {
			empty.style.display = "none";
			view.style.display = "grid";
		};
		
		const dataFormat = formatNull(data);
		const patientInfo = document.querySelector("#patientInfo");
		const patientScr = document.querySelector("#patientScr");
		// 데이터가공
		const d = dataFormat[0];
		const p = d.patientVO;
		const r = d.registrationVO;
		const s = d.screeningVO;
		
		let patientChartId = "patientDetail_" + p.patientNo;
		
		// 환자 기본 정보
		patientInfo.innerHTML = `
			<div class="box" id="\${patientChartId}">
			    <div class="box-title-group flex justify-between">
			        <h2 class="box-title flex items-center">
			            <i class="icon icon-user-hexagon icon-lg icon-muted"></i>
			            <span class="text-secondary mx-4">\${p.patientNo}</span>
			            <strong>\${p.patientName}</strong>
			        </h2>
			        <div class="doctor-info flex items-center">
			            <i class="icon icon-doctor icon-md icon-muted"></i>
			            <span class="text-sm"><b>\${d.employeeName}</b> 의사</span>
			        </div>
			    </div>
			    <!-- 보험 종류 : 없을 경우 삭제하기 -->
			    <div class="flex gap-xs my-3">
			        <span class="badge badge-default">\${r.registrationVisittype}</span>
			        <span class="badge badge-primary">\${r.registrationInsurance}</span>
			    </div>
			    <!-- 환자정보 -->
			    <div class="list-horizontal list-horizontal-2">
			        <div class="list-horizontal-item">
			            <div class="list-horizontal-label">나이 / 성별</div>
			            <div class="list-horizontal-value">\${d.patientAge}세 / \${p.patientGen === 'MALE' ? '남' : '여'}</div>
			        </div>
			        <div class="list-horizontal-item">
			            <div class="list-horizontal-label">생년월일</div>
			            <div class="list-horizontal-value">\${d.patientBirthdate}</div>
			        </div>
			        <div class="list-horizontal-item">
			            <div class="list-horizontal-label">주민등록번호</div>
			            <div class="list-horizontal-value">\${d.patientRegnoMasked}</div>
			        </div>
			        <div class="list-horizontal-item">
			            <div class="list-horizontal-label">연락처</div>
			            <div class="list-horizontal-value">\${p.patientTel}</div>
			        </div>
			    </div>
			    <div class="list-horizontal list-horizontal-1 mt-1">
			        <div class="list-horizontal-item">
			            <div class="list-horizontal-label">주소</div>
			            <div class="list-horizontal-value">\${p.patientAddr1 || ""} \${p.patientAddr2 || " "}</div>
			        </div>
			    </div>
			</div>
		`;
		
		// 환자 기초 문진 정보
		patientScr.innerHTML = `
			<div class="list-horizontal list-horizontal-2">
				<div class="list-horizontal-item">
			    	<div class="list-horizontal-label">키/체중</div>
			        <div class="list-horizontal-value">\${formatNull(s.screeningHeight)} cm / \${formatNull(s.screeningWeight)} kg</div>
			    </div>
			    <div class="list-horizontal-item">
			        <div class="list-horizontal-label">체온</div>
			        <div class="list-horizontal-value">\${formatNull(s.screeningTemperature)} ℃</div>
			    </div>
		        <div class="list-horizontal-item">
		            <div class="list-horizontal-label">혈압</div>
		            <div class="list-horizontal-value">\${formatNull(s.screeningSystolic)} / \${formatNull(s.screeningDiastolic)} mmHg</div>
		        </div>
		        <div class="list-horizontal-item">
		            <div class="list-horizontal-label">맥박</div>
		            <div class="list-horizontal-value">\${formatNull(s.screeningPulse)} 회/분</div>
		        </div>
		    </div>
		    <div class="form-group mt-3">
		        <label class="form-label"><i class=""></i> 환자메모</label>
		        <textarea class="textarea textarea-sm" id="patientMemo" data-origin-value="\${p.patientMemo}">\${p.patientMemo}</textarea>
		    </div>
		`;
	    
		patientMemoUpdate(p.patientNo);
		
        // 오더 목록 조회 시작
        loadExamOrders(p.patientNo);
	}
	
	// 환자 메모 자동 업데이트
	function patientMemoUpdate(patient){
		const memoArea = document.querySelector("#patientMemo");
		
		memoArea.addEventListener('focus', function(){
			this.dataset.originValue = this.value;
		});
		
		// 포커스를 잃어버렸다..!
		memoArea.addEventListener('blur', async function(){
			const currentValue = this.value;
			const originValue = this.dataset.originValue;
			
			// 변경사항 있을 경우
			if(currentValue !== originValue){
				
				console.log("memo가 변경되는 중..")
				
				try	{
					const response = await axios.post("/therapist/workview/patient/updatePetientMemo", {
						patientNo : patient,
						patientMemo : currentValue
					});
					
					if(response.data.success) {
						this.dataset.originValue = currentValue;
						console.log("자동 저장 완료");
					}
				} catch (error) {
					console.error("저장 실패 :", error);
					sweetAlert("error", "메모 저장 중 오류가 발생했습니다.", "확인");
					this.dataset.originValue = originValue;
				}
				
			} else {
				console.log("변경사항 없음")
			}
		})
		
	}
	
	// == 오더 목록 ================================================================
	// 오더 목록 조회
	async function loadExamOrders(patientNo) {
		try {
			const response = await axios.get(`/therapist/workview/patientOrder/\${patientNo}`);
			const order = response.data;

	        renderPatientOrder(order);		
	        
		} catch(error) {
			console.error(error);
			alert("오더 목록이 정상적으로 생성되지 못했습니다.");
		}
	}
	
	// 오더 목록 생성
	function renderPatientOrder(data){
		
		const orderList = document.querySelector("#orderList");
		
		// 오더 목록 없을 때
		if(!data || data.length === 0) {
			orderList.innerHTML = `
				<div class="empty-state">
				    <i class="icon icon-xl icon-muted icon-file"></i>
				    <div class="empty-state-title mt-3">오더 목록이 없습니다.</div>
				</div>
			`;
			return;
		}
		
		// 오더 목록이 있다면
		let orderHTML = data.map(d => `	
			<div class="list-item" onclick="loadOrderDetail(\${d.predetailNo})">
			    <div class="flex gap-md test">
			        <span class="accordion-header-title">\${d.orderDate}</span>
			        \${d.isCurrentOrder === 'Y' ? 
			            `<span class="badge badge-danger">현재 오더</span>` 
			            : ""
			        }
			        <span class="text-sm text-secondary" style="margin-left: auto;">총 <b>\${d.examCount}</b>건</span>
			    </div>
			</div>
		`).join('');
		
		orderList.innerHTML = orderHTML; 
	}
	
	// 날짜 display
	function displayToday() {
	    const now = new Date();
	    
	    const year = now.getFullYear();
	    const month = String(now.getMonth() + 1).padStart(2, '0');
	    const day = String(now.getDate()).padStart(2, '0');
	    
	    // 요일까지 넣어주면 더 친절한 시스템이 됩니다.
	    const week = ['일', '월', '화', '수', '목', '금', '토'];
	    const dayOfWeek = week[now.getDay()];
	    
	    const dateString = year + "-" + month + "-" + day + " (" + dayOfWeek + ")"
	    
	    // 화면에 반영
	    const dateElement = document.querySelector("#todayDate");
	    if(dateElement) {
	        dateElement.innerText = dateString;
	    }
	}
	
	// == 오더 상세 정보 ================================================================
	// 오더 상세 조회
	async function loadOrderDetail(predetailNo){

		const allItems = document.querySelectorAll("#orderList .list-item");
		allItems.forEach(item => item.classList.remove('active'));
		
		let target = event.currentTarget;
		target.classList.add("active");
		
		try{
			const response = await axios.get(`/therapist/workview/orderDetail/\${predetailNo}`);
			const order = response.data;

			// 현재 작업 중인 오더
			currentPredetailNo = predetailNo;
			
			if(order && order.length > 0){
				currentChartNo = order[0].chartNo;
			}
			
			renderOrderDetail(order);
		} catch(error){
			console.error(error);
			alert("오더 불러오기에 실패했습니다.")
		};
	}
	
	function closeChart(){
		init_chartView();
	}
	
	// 오더 상세 초기화
	function resetOrderDetail() {
	    let emptyOrder = document.querySelector("[data-empty='orderDetail']");
	    let viewOrder = document.querySelector("[data-view='orderDetail']");
	    
	    if (emptyOrder && viewOrder) {
	        emptyOrder.style.display = "flex";  // "선택된 오더가 없습니다" 표시
	        viewOrder.style.display = "none";   // 상세 내용 숨김
	    }
	}
	
	// 오더 상세 생성
	function renderOrderDetail(data){
		resetOrderDetail();
		
		let emptyOrder = document.querySelector("[data-empty='orderDetail']");
	    let viewOrder = document.querySelector("[data-view='orderDetail']");
		
		// data 여부에 따라 보여지는 영역 변경
		if(!data || data.length === 0) { // 데이터 없을 때
			emptyOrder.style.display = "flex";
			viewOrder.style.display = "none";
		} else { // 데이터 있을 때
			emptyOrder.style.display = "none";
			viewOrder.style.display = "flex";
			
			renderDetailArea(data);
		}
	}
	
	// 오더 상세 UI 생성
	function renderDetailArea(data) {
		const orderTitle = document.querySelector("#orderDetailTitle");
		const orderBody = document.querySelector("#orderDetailTbody");
		const orderFoot = document.querySelector(".area-right_footer");
		
		let stt = "";
		data.forEach((d,i) => stt = d.treatmentVO[i].pretreatmentDetailStatus);
		
		if(stt === "대기"){
			submitBtn.disabled = true;
			orderFoot.style.display = "block";
		} else if(stt === "완료") {
			submitBtn.disabled = true;
			orderFoot.style.display = "none";
		} else {
			submitBtn.disabled = false;
			orderFoot.style.display = "block";
		}
		
		submitBtn.dataset.currentNo = data[0].predetailNo;
		
		// data가 배열이라 []로 꺼내야 함.
		let titleHTML = `
			<h2 class="box-title">\${data[0].orderDate}</h2>
		`;
		
		let bodyHTML = data[0].treatmentVO.map((d,i) => `
			<tr>
		        <td>\${i + 1}</td>
		        <td>\${formatNull(d.treatmentCode)}</td>
		        <td style="text-align: left">\${formatNull(d.treatmentName)}</td>
		        <td>\${formatNull(d.pretreatmentDetailDose)}</td>
		        <td>\${formatNull(d.pretreatmentDetailFreq)}</td>
		        <td>\${formatNull(d.pretreatmentDetailMethod)}</td>
		    </tr>	
		`).join('');
		
		orderTitle.innerHTML = titleHTML;
		orderBody.innerHTML = bodyHTML;
		
	}
	
	// == 검사완료 ================================================================
	function bindTretmentCompleteEvent() {
		// const submitBtn = document.querySelector("#formDataSubmit");
		submitBtn.addEventListener('click', handleCompleteClick);
	}
	
	async function handleCompleteClick(e){
		const predetailNo = e.currentTarget.dataset.currentNo;
		
		if(!predetailNo) {
			sweetAlert("warning", "처리할 오더를 선택해주세요.", "확인");
			return;
		}
		
		const cofirmResult = await sweetAlert("question", "치료를 완료하시겠습니까?", "확인", "취소", true);
		
		if(!cofirmResult.isConfirmed){ // 만약 취소버튼 클릭 시 함수 종료
			return;
		}
		
		try {
			const response = await axios.post("/therapist/workview/complete", {
				predetailNo: predetailNo,
				pretreatmentDetailStatus : "001"
			});
			
			if(response.data.success) { // 성공적이면
				sweetAlert("success", "치료가 완료되었습니다.", "확인")
					.then(() => {
						init_chartView(); 		// 상세 영역 숨기기
						resetOrderDetail();	 	// 오더 상세 숨기기
						loadPatientList();		// 목록 새로고침
					});
			}
		} catch (error) {
			console.log(error);
			sweetAlert("error", "전송 중 오류가 발생했습니다.", "확인");
		}
	}
	
	function closeChart() {
		resetOrderDetail();
	}
	
	// 데이터 null 처리
	function formatNull(data, fallback = "-") {
	    if (data === null || data === undefined || data === "") return fallback;
	    if (typeof data !== "object") return data;
	
	    const formatted = Array.isArray(data) ? [] : {}; // 배열 여부에 따른 결과 저장용 빈 배열 또는 빈 객체 생성
	    for (const key in data) { // 객체의 속성(key) 반복문. 내부 데이터 탐색
	        formatted[key] = formatNull(data[key], fallback); // 재귀 호출. 하위 객체 데이터 검증 및 결과 저장
	    }
	    return formatted; // 데이터 반환
	}
</script>
</html>