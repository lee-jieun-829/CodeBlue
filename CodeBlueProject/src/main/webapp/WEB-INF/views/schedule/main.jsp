<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<!-- ===== Head 시작 ===== -->
<%@ include file="/WEB-INF/views/common/include/link.jsp" %>
<!-- ===== Head 끝 ===== -->
<title>통합 일정 관리</title>
 <style>     
<style>     
    /* 캘린더 스타일 커스텀 */
    .fc { 
        /* 테두리 및 배경 변수 */
        --fc-border-color: #f1f5f9; 
        --fc-today-bg-color: #eff6ff; 
        
        /* 텍스트 색상 전역 변수: 검정 */
        --fc-page-text-color: #000000;
        --fc-neutral-text-color: #000000;
        --fc-list-event-text-color: #000000;
        
        font-size: 13px; 
        height: 100% !important; 
        color: #000000 !important; /* 기본 글자색 강제 검정 */
    }

    /* 날짜(숫자), 요일(헤더) 링크 스타일 제거 및 검정색 적용 */
    .fc .fc-col-header-cell-cushion,
    .fc .fc-daygrid-day-number {
        color: #000000 !important;
        text-decoration: none !important;
    }

    /* 툴바 타이틀 */
    .fc .fc-toolbar-title { font-size: 18px; font-weight: 800; color: #000000; }

    /* 버튼 스타일 */
    .fc .fc-button { 
        background: #fff !important; 
        border: 1px solid #e2e8f0 !important; 
        color: #000000 !important; /* [수정] 버튼 글씨 검정 */
        font-size: 12px !important; 
        font-weight: 700 !important;
        border-radius: 8px !important; 
        text-transform: capitalize !important;
    }
    
    /* 활성화된 버튼 */
    .fc .fc-button-active { 
        background: #3b82f6 !important; 
        border-color: #3b82f6 !important; 
        color: #fff !important; /* [예외] 활성화 버튼은 가독성을 위해 흰색 유지 (검정으로 원하시면 변경 가능) */
    }

    /* 이벤트(일정 막대) 스타일 */
    .fc .fc-event { 
        cursor: pointer; 
        border: none; 
        padding: 2px 4px; 
        border-radius: 4px; 
        transition: transform 0.1s; 
        
        /* [수정] 이벤트 내부 글씨 검정 */
        color: #000000 !important; 
        font-weight: 600; /* 검정 글씨 가독성 확보 */
    }
    
    /* 이벤트 내부 시간/제목 요소 강제 검정 */
    .fc .fc-event-main, .fc .fc-event-title, .fc .fc-event-time {
        color: #000000 !important;
    }

    .fc .fc-event:hover { transform: scale(1.02); }
    
    .modal-overlay { background: rgba(0, 0, 0, 0.4); backdrop-filter: blur(4px); }
</style>

<body class="bg-neutral-100 text-zinc-950" data-gnb="gnb-schedule">
	<div class="app h-screen w-full flex flex-col">
     <!-- ===== Header 시작 ===== -->
	<%@ include file="/WEB-INF/views/common/include/header.jsp" %>
	<!-- ===== Header 끝 ===== -->
	<div class="main-container">
	<!-- ===== Sidebar 시작 (각 액터에 따라 sidebar jsp 교체)  ===== -->
		<sec:authorize access="hasRole('ROLE_ADMIN')">
			<%@ include file="/WEB-INF/views/common/include/left/left_admin.jsp" %>
		</sec:authorize>
		<sec:authorize access="hasRole('ROLE_DOCTOR')">
			<%@ include file="/WEB-INF/views/common/include/left/left_doctor.jsp" %>
		</sec:authorize>
		<sec:authorize access="hasRole('ROLE_NURSE_IN') or hasRole('ROLE_NURSE_OUT')">
			<%@ include file="/WEB-INF/views/common/include/left/left_nursing.jsp" %>
		</sec:authorize>
		<sec:authorize access="hasRole('ROLE_PHARMACIST')">
			<%@ include file="/WEB-INF/views/common/include/left/left_pharmacist.jsp" %>
		</sec:authorize>
		<sec:authorize access="hasRole('ROLE_RADIOLOGIST')">
			<%@ include file="/WEB-INF/views/common/include/left/left_radiologist.jsp" %>
		</sec:authorize>
		<sec:authorize access="hasRole('ROLE_THERAPIST')">
			<%@ include file="/WEB-INF/views/common/include/left/left_therapist.jsp" %>
		</sec:authorize>
		<sec:authorize access="hasRole('ROLE_OFFICE')">
			<%@ include file="/WEB-INF/views/common/include/left/left_reception.jsp" %>
		</sec:authorize>		
	<!-- ===== Sidebar 끝 ===== -->
	<!-- ===== Main 시작 ===== -->
			<main class="main-content overflow-hidden">
				<div class="grid grid-full-height">
					<!-- main이 2분할 이상일 경우 grid 사이즈 클래스 추가 필요 -->
					<!-- 콘텐츠 영역 -->
					<div class="content-area grid grid-1 h-full ">
						<div
							class="box  flex flex-col p-0 min-h-0 overflow-hidden justify-center">
							<div
								class="card  flex-1 overflow-y-auto min-h-0 my-2 pr-2 scrollbar">
								<div class="h-[10%] card-header flex-none"
									style="font-size: var(--font-base); font-weight: var(--font-semibold);">
									<span>통합 일정 관리</span>
									<div class="btn-group-right">
										<div class="form-group btn-sm">
											<select class="select " style="font-size: var(--font-base);"id="selectBox" onchange="scheduleSelect()">
												<option value="0">전체일정</option>
											</select>
										</div>
									</div>
								</div>
								<div class="h-[90%] card-body  flex-1 overflow-y-auto">
									<div class="flex-1 p-6 h-full">
										<div id="calendar"></div>
									</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</main>
		</div>
	</div>
	<div id="viewModal" class="modal-overlay fixed inset-0 z-50 hidden flex items-center justify-center">
	    <div class="bg-white rounded-lg shadow-xl w-96 overflow-hidden">
	        <div class="p-4 flex justify-between items-center text-white" id="viewColor">
	            <h3 class="text-lg font-bold" id="viewTitle"></h3>
	            <button onclick="closeModal()" class="text-white hover:text-gray-200">✕</button>
	        </div>
	        <div class="p-6 space-y-4">
	            <div>
	                <label class="text-xs text-gray-500 font-bold block mb-1">일시</label>
	                <div class="text-sm">
	                    <span id="viewStart"></span> ~ <br><span id="viewEnd"></span>
	                </div>
	            </div>
	            <div>
	                <label class="text-xs text-gray-500 font-bold block mb-1">메모</label>
	                <p id="viewMemo" class="text-sm text-gray-700 bg-gray-50 p-2 rounded"></p>
	            </div>
	        </div>
	        <div class="p-4 bg-gray-50 text-right">
	            <button onclick="closeModal()" class="btn btn-sm bg-white border border-gray-300">닫기</button>
	        </div>
	    </div>
	</div>
</body>
    <script>
        let calendar; //풀캘린더 실행을 위해 변수 선언
        // 일정 데이터
        const allEvents = [];
        
        document.addEventListener('DOMContentLoaded', function() {
            const calendarEl = document.getElementById('calendar');
            
            calendar = new FullCalendar.Calendar(calendarEl, {
                locale: 'ko',
                initialView: 'dayGridMonth',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,timeGridDay'
                },
                buttonText: { month: '월', week: '주', day: '일' },
                height: '100%',
                dayMaxEvents: 5,                
                slotEventOverlap: false,
                allDaySlot: false,
	            slotMinTime: '09:00:00',
	            slotMaxTime: '18:00:00',
                eventClick: function(info) {
                    openViewModal(info.event);
                }
            });
            
            calendar.render();
            
            selectdoctor();
            
            scheduleSelect();
        });
        
        function scheduleSelect(){
        	let empNo = document.getElementById('selectBox').value;
            if(!empNo) empNo = 0;
            axios.get('/schedule/list', {
                params: {
                    employeeNo: empNo 
                }
            })
            .then(function (response) {
            	const scList = response.data;
            	const calendarEvents = scList.map(function(item) {
                    return {
                        id: item.scheduleNo,           // PK
                        title: item.title,     // 제목
                        start: item.start, // 시작일시 (ISO8601 문자열 추천)
                        end: item.end,     // 종료일시
                        backgroundColor: item.backgroundColor || '#3b82f6', // 색상 (없으면 기본값)
                        extendedProps: {
                            memo: item.description // 상세 내용
                        }
                    };
                });            	
            })
            .catch(function (error) {
                console.error(error);
                sweetAlert("error", "일정을 불러오는데 실패했습니다.", "확인");
            });
        }
        
        function selectdoctor(){
        	axios.get('/schedule/selectdoctor')
        	.then(function (response) {
        		let selectElement =document.getElementById('selectBox')
        		
        		let doctorList = response.data;
        		console.log(doctorList);
        		 if(doctorList && doctorList.length > 0) {
        			 let optionsHtml = "";
        			 doctorList.forEach(function(doctor) {
        				 let name = doctor.empName
        				 let id = doctor.employeeNo
        				 optionsHtml += `<option value="\${id}">\${name}</option>`;
        			 })
        			 selectElement.innerHTML += optionsHtml; 
        		 }
        	})
        	.catch(function (error) {	            
	        	sweetAlert("warning", "서버오류, 의사목록을 가져올 수 없습니다.", "확인");
	        });
        }
       

        function openViewModal(event) {
            document.getElementById('viewTitle').innerText = event.title;
            document.getElementById('viewColor').style.backgroundColor = event.backgroundColor;
            
            const options = { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' };
            
            // start는 필수, end는 없을 수 있음
            document.getElementById('viewStart').innerText = event.start.toLocaleString('ko-KR', options);
            document.getElementById('viewEnd').innerText = event.end ? event.end.toLocaleString('ko-KR', options) : event.start.toLocaleString('ko-KR', options);
            
            // extendedProps에서 memo 꺼내기
            document.getElementById('viewMemo').innerText = event.extendedProps.memo || "내용 없음";
            
            const modal = document.getElementById('viewModal');
            if(modal) modal.classList.remove('hidden');
        }

        function closeModal() {
            const modal = document.getElementById('viewModal');
            if(modal) modal.classList.add('hidden');
        }
    </script>
</body>
</html>