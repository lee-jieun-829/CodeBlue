<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
<div id="modalBookingRegister" class="modal-backdrop hidden" style="z-index: 110;">
    <div class="modal-content modal-hidden modal modal-lg">
        
        <div class="modal-header">
            <h3 class="modal-title">진료 예약 등록</h3>
            <button type="button" class="btn btn-icon btn-ghost" onclick="closeAndResetModal('modalBookingRegister')">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="18" y1="6" x2="6" y2="18"></line>
                    <line x1="6" y1="6" x2="18" y2="18"></line>
                </svg>
            </button>
        </div>

        <div class="modal-body">
            
            <div class="form-group relative" style="margin-top: var(--spacing-md);"> 
                <label class="form-label form-label-required">환자 검색</label>
                <div class="input-group relative">
                    <input type="text" id="bookingSearchInput" class="input input-search" 
                           placeholder="성함 입력 (자동 검색)" 
                           autocomplete="off"
                           onkeyup="searchBookingPatient(this)">
                           
                    <div id="bookingSearchDropdown" 
                         class="search-dropdown hidden absolute w-full bg-white border border-slate-200 rounded-md shadow-lg max-h-48 overflow-y-auto z-50"
                         style="top: 100% !important; bottom: auto !important; margin-top: 4px;">
                    </div>
                </div>
            </div>

            <div class="form-group">
                <label class="form-label">선택된 환자</label>
                <input type="hidden" id="bookingPatientNo">
                <input type="text" id="bookingFieldName" class="input bg-slate-50" readonly placeholder="위에서 환자를 검색하면 자동 입력됩니다.">
            </div>

            <div class="form-group mb-2">
                <label class="form-label">예약 유형</label>
                <div class="flex gap-6 mt-1">
                    <label class="flex items-center gap-2 cursor-pointer">
                        <input type="radio" name="bookingType" value="002" class="radio" checked onchange="toggleBookingType()">
                        <span class="text-sm font-medium">진료 예약</span>
                    </label>
                    <label class="flex items-center gap-2 cursor-pointer">
                        <input type="radio" name="bookingType" value="003" class="radio" onchange="toggleBookingType()">
                        <span class="text-sm font-medium">입원 예약</span>
                    </label>
                </div>
            </div>

            <div class="box bg-slate-50 rounded-lg p-4 mb-4 border border-slate-200">
                <label class="form-label mb-2">예약 일시</label>
                
                <div class="flex items-center gap-2 mb-2">
                    <span class="text-xs font-bold text-slate-500 w-10">시작</span>
                    <input type="date" id="bookingStartDate" class="input w-3/5" onchange="calculateEndTime(); checkDoctor();">
                    
                    <div class="relative w-2/5">
                        <input type="text" id="bookingStartTime" 
                               class="input cursor-pointer caret-transparent text-center" 
                               placeholder="시간" 
                               onclick="toggleTimeDropdown('Start')"
                               autocomplete="off">
                        <div id="dropdownStart" class="hidden absolute left-0 w-full bg-white border border-slate-200 rounded-md shadow-lg z-50 overflow-y-auto max-h-60"
                             style="top: 100% !important; margin-top: 4px;"></div>
                    </div>
                </div>
            </div>

            <div class="form-row form-row-2">
                <div class="form-group">
                    <label class="form-label">담당의사</label>
                    <select id="bookingInputDoctor" class="select">
                        <option value="">담당 의사를 선택하세요</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">환자 메모</label>
                    <textarea id="bookingInputMemo" rows="1" class="textarea h-10 py-2" placeholder="기타 참고사항"></textarea>
                </div>
            </div>
        </div>

        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="closeAndResetModal('modalBookingRegister')">취소</button>
            <button type="button" onclick="submitNewBooking()" class="btn btn-primary">예약 저장</button>
        </div>
    </div>
</div>

	<div id="viewModal" class="modal-overlay fixed inset-0 z-50 hidden flex items-center justify-center">
	    <div class="bg-white rounded-lg shadow-xl w-96 overflow-hidden">
	        <div class="p-4 flex justify-between items-center text-white" id="viewColor">
	            <h3 class="text-lg font-bold" id="viewTitle"></h3>
	            <button onclick="closeModal('viewModal')" class="text-white hover:text-gray-200">✕</button>
	        </div>
	        <div class="p-6 space-y-4">
	            <div>
	                <label class="text-xs text-gray-500 font-bold block mb-1">일시</label>
	                <div class="text-sm">
	                    <span id="viewStart"></span>
	                </div>
	            </div>
	            <div>
	                <label class="text-xs text-gray-500 font-bold block mb-1">메모</label>
	                <p id="viewMemo" class="text-sm text-gray-700 bg-gray-50 p-2 rounded"></p>
	            </div>
	        </div>
	        <div class="p-4 bg-gray-50 text-right">
	            <button onclick="closeModal('viewModal')" class="btn btn-sm bg-white border border-gray-300">닫기</button>
	        </div>
	    </div>
	</div>

<script>    
    // ============================================================
    // 0. 모달 초기화 및 닫기 로직 (Reset)
    // ============================================================
    function resetBookingForm() {
        // 1. 입력 필드 비우기
        document.getElementById('bookingSearchInput').value = ''; 
        document.getElementById('bookingPatientNo').value = '';   
        document.getElementById('bookingFieldName').value = '';   
        document.getElementById('bookingInputMemo').value = '';   
        
        // 2. 검색 드롭다운 숨기기
        const searchDrop = document.getElementById('bookingSearchDropdown');
        searchDrop.classList.add('hidden');
        searchDrop.style.display = 'none';

        // 3. 라디오 버튼 초기화 (진료예약 '002'로 복귀)
        const radios = document.getElementsByName('bookingType');
        radios.forEach(r => {
            if (r.value === '002') r.checked = true;
            else r.checked = false;
        });

        // 4. 날짜/시간 리셋 (오늘 날짜, 09:00)
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        const today = `\${year}-\${month}-\${day}`;

        document.getElementById('bookingStartDate').value = today;       
        document.getElementById('bookingStartTime').value = "09:00";        

        // 5. 의사 목록 초기화
        const selectEl = document.getElementById('bookingInputDoctor');
        selectEl.value = ""; 
        
        // 비활성 옵션 복구
        const options = selectEl.querySelectorAll('option');
        options.forEach(opt => {
            opt.disabled = false;
            if (opt.dataset.name) opt.text = opt.dataset.name; 
        });
        
        // 진료예약이 기본값이므로 busyDoctor 체크 수행
        checkDoctor();
    }

    function closeAndResetModal(modalId) {
        resetBookingForm(); // 폼 초기화
        closeModal(modalId); // 모달 닫기
    }

    // ============================================================
    // 1. 시간 슬롯 생성 및 드롭다운 제어
    // ============================================================
    function initTimeSlots() {
        const slots = generateTimeSlots(9, 18); // 09:00 ~ 18:00
        
        const startDrop = document.getElementById('dropdownStart');
        if (startDrop && startDrop.children.length === 0) {
            startDrop.innerHTML = slots.map(t => createTimeItem(t, 'Start')).join('');
        }
        
        if(!document.getElementById('bookingStartTime').value) {
            document.getElementById('bookingStartTime').value = "09:00";       
        }
    }

    function generateTimeSlots(start, end) {
        let times = [];
        for (let h = start; h < end; h++) {
            const hour = h.toString().padStart(2, '0');
            times.push(`\${hour}:00`);
            times.push(`\${hour}:30`);
        }
        times.push(`\${end}:00`);
        return times;
    }

    function createTimeItem(timeStr, type) {
        return `<div class="p-2 hover:bg-blue-50 cursor-pointer text-center text-sm border-b border-slate-50 last:border-0" 
                     onclick="selectTimeSlot('\${timeStr}', '\${type}')">
                    \${timeStr}
                </div>`;
    }

    function toggleTimeDropdown(type) {
        const drop = document.getElementById(`dropdown\${type}`);
        if(drop) drop.classList.remove('hidden');
    }

    function selectTimeSlot(timeStr, type) {
        document.getElementById(`booking\${type}Time`).value = timeStr;
        document.getElementById(`dropdown\${type}`).classList.add('hidden');
        
        // 시작 시간이 변경되면 의사 스케줄 다시 체크
        if (type === 'Start') {
            checkDoctor();
        }
    }

    // ============================================================
    // 2. [유틸리티] 날짜 포맷터 및 30분 더하기 계산 함수
    // ============================================================
    function getCalculatedEndDateTime(sDate, sTime) {
        if (!sDate || !sTime) return null;

        const startObj = new Date(`\${sDate}T\${sTime}`);
        // 30분 더하기
        startObj.setMinutes(startObj.getMinutes() + 30);

        const year = startObj.getFullYear();
        const month = String(startObj.getMonth() + 1).padStart(2, '0');
        const day = String(startObj.getDate()).padStart(2, '0');
        const hour = String(startObj.getHours()).padStart(2, '0');
        const minute = String(startObj.getMinutes()).padStart(2, '0');

        // YYYY-MM-DD HH:mm:00 형식 반환
        return `\${year}-\${month}-\${day} \${hour}:\${minute}:00`;
    }

    // ============================================================
    // 3. 의사 목록 로드 및 Busy Check 
    // ============================================================
    function loadBookingDoctorList() {
        axios.get('/reservation/doctors')
            .then(res => {
                const doctors = res.data;
                const selectEl = document.getElementById('bookingInputDoctor');
                if(!selectEl) return;                
                
                let html = '<option value="">담당 의사를 선택하세요</option>';                
                doctors.forEach(doc => { 
                    html += `<option value="\${doc.employeeNo}" data-name="\${doc.empName}">\${doc.empName}</option>`;
                });
                selectEl.innerHTML = html;
            })
            .catch(err => console.error("예약 모달 의사 목록 로드 실패:", err));
    }
    
    // 예약 유형 토글
    function toggleBookingType() {
        const type = document.querySelector('input[name="bookingType"]:checked').value;
        const selectEl = document.getElementById('bookingInputDoctor');
        const options = selectEl.querySelectorAll('option');

        // 일단 모두 활성화
        options.forEach(opt => {
            opt.disabled = false;
            if(opt.dataset.name) opt.text = opt.dataset.name; 
        });
        
        // '진료 예약(002)'일 때만 바쁜 의사 체크
        if (type === '002') {
            checkDoctor();
        } 
    }

    // 바쁜 의사 체크
    function checkDoctor(){
        const type = document.querySelector('input[name="bookingType"]:checked').value;
        
        // 입원 예약(003)이면 검사 안함
        if(type === '003') return;
        
        const sDate = document.getElementById('bookingStartDate').value;
        const sTime = document.getElementById('bookingStartTime').value;
        
        if(!sDate || !sTime) return;

        // 시작 시간 포맷팅
        const startDateTime = sDate + " " + sTime + ":00";
        // 종료 시간 계산 (시작 + 30분)
        const endDateTime = getCalculatedEndDateTime(sDate, sTime);
        
        const selectEl = document.getElementById('bookingInputDoctor');
        const options = selectEl.querySelectorAll('option');
        
        // 요청 전 일단 초기화
        options.forEach(opt => {
            opt.disabled = false;
            if(opt.dataset.name) opt.text = opt.dataset.name; 
        });
        
        const payload = {
            scheduleStart: startDateTime,
            scheduleEnd: endDateTime
        };        
        
        axios.post('/reservation/selectBusyDoctor', payload)
        .then(res => {
            const busyDoctorIds = res.data; 
            
            options.forEach(opt => {                
                if (busyDoctorIds.includes(parseInt(opt.value)) || busyDoctorIds.includes(opt.value)) {
                    opt.disabled = true;
                    opt.text = `\${opt.dataset.name} (예약 불가)`;                   
                    
                    if(selectEl.value == opt.value) {
                        selectEl.value = ""; // 선택된 의사가 바쁘면 선택 해제
                    }
                }
            });
        }).catch(err => {
            console.error("의사 일정 조회 실패:", err);
        });
    }

    // ============================================================
    // 4. 예약 저장 (Submit)
    // ============================================================
    function submitNewBooking() {       
        const patientNo = document.getElementById('bookingPatientNo').value;        
        const patientName = document.getElementById('bookingFieldName').value;
        
        const sDate = document.getElementById('bookingStartDate').value;
        const sTime = document.getElementById('bookingStartTime').value;      
        
        const doctorVal = document.getElementById('bookingInputDoctor').value;

        if(!patientNo) {
            sweetAlert("warning", "환자를 선택해주세요.", "확인");           
            return;
        }
        if(!doctorVal) {
            sweetAlert("warning", "담당 의사를 선택해주세요.", "확인");              
            return;
        }
        if(!sDate || !sTime ) {
            sweetAlert("warning", "예약 일자와 시간을 모두 입력해주세요.", "확인");            
            return;
        }
        
        // [서버 전송용 데이터 생성]
        const startDateTime = sDate + " " + sTime + ":00";
        // 종료 시간은 무조건 시작 시간 + 30분
        const endDateTime = getCalculatedEndDateTime(sDate, sTime);
        
        const scheduleType = document.querySelector('input[name="bookingType"]:checked').value;

        const payload = {
            patientNo: patientNo,
            patientName: patientName,
            scheduleType: scheduleType,
            scheduleStart: startDateTime, 
            scheduleEnd: endDateTime, // 30분 더해진 값 전송
            scheduleDoctorNo: doctorVal, 
            memo: document.getElementById('bookingInputMemo').value
        };         
        
        console.log("== Payload:", payload);

        axios.post("/reservation/reservationinsert", payload)
        .then(res => {
            sweetAlert("success", "예약이 등록되었습니다.", "확인");
            resetBookingForm(); // 성공 시 폼 초기화
            closeModal('modalBookingRegister');
            if(typeof initCalendar === 'function') initCalendar(); 
        })
        .catch(err => { 
            console.error("Booking Error:", err);
            sweetAlert("warning", "서버 오류로 인해 예약에 실패했습니다.", "확인");
        });
    };
    
    // ============================================================
    // 5. 환자 검색 기능
    // ============================================================
    function searchBookingPatient(input) {
        const keyword = input.value.trim();
        const dropdown = document.getElementById('bookingSearchDropdown');         

        if (keyword.length < 1) {
            dropdown.classList.add('hidden');
            dropdown.style.display = 'none';
            return;
        }
       
        axios.get('/reception/searchPatient', { params: { keyword: keyword } })
            .then(res => {
                const list = res.data;
                if (list.length === 0) {
                    dropdown.innerHTML = '<div class="p-3 text-slate-400 text-xs text-center">검색 결과가 없습니다.</div>';
                } else {
                    let html = '';
                    list.forEach((p, index) => {
                        const gender = (p.patientGen === 'MALE' || p.patientGen === 'M' || p.PATIENT_GEN === 'MALE') ? 'M' : 'F';
                        const pJson = JSON.stringify(p).replace(/"/g, '&quot;');
                        html += `<div class="p-2 hover:bg-slate-50 cursor-pointer border-b border-slate-100 last:border-0" 
                                      onclick="selectBookingPatient(` + pJson + `)">
                                     <div class="font-bold text-sm text-slate-800">\${p.patientName}</div>
                                     <div class="text-xs text-slate-500">\${p.patientRegno1} | \${p.patientNo} | \${gender}</div>
                                 </div>`;
                    });
                    dropdown.innerHTML = html;
                }
                dropdown.classList.remove('hidden');
                dropdown.style.display = 'block';
            })
            .catch(err => console.error("Booking Search Error:", err));
    }

    function selectBookingPatient(patient) {
        const gender = (patient.patientGen === 'MALE' || patient.patientGen === 'M') ? 'M' : 'F';
        
        document.getElementById('bookingFieldName').value = `\${patient.patientName} (\${gender} / \${patient.patientRegno1})`;       
        document.getElementById('bookingPatientNo').value = patient.patientNo; 
        document.getElementById('bookingSearchInput').value = '';
        document.getElementById('bookingSearchDropdown').classList.add('hidden');
        if(patient.patientMemo) document.getElementById('bookingInputMemo').value = patient.patientMemo;
    }

    // ============================================================
    // 6. 환자예약 풀캘린더 출력 기능
    // ============================================================
    function initCalendar() {
	    const calendarEl = document.getElementById('calendar');
	    if (!calendarEl) return;
	
	    if (!window.reservationCalendar) {
	        window.reservationCalendar = new FullCalendar.Calendar(calendarEl, {
	            initialView: 'timeGridWeek',
	            locale: 'ko',
	            height: '100%',
	            headerToolbar: {
	                left: 'prev,next today',
	                center: 'title',
	                right: 'dayGridMonth,timeGridWeek,timeGridDay'
	            },
	            slotEventOverlap: false,
	            allDaySlot: false,
	            slotMinTime: '09:00:00',
	            slotMaxTime: '18:00:00',
	            eventClick: function(info) {
                    openViewModal(info.event);
                }
	        });
	        window.reservationCalendar.render();	        
	        scheduleSelect();
	    } else {
	        window.reservationCalendar.updateSize(); 
	        scheduleSelect();
	    }
	}

    function scheduleSelect(){ 
    	axios.get('/reservation/schedulelist')
        .then(function (response) {
        	const scList = response.data;
        	const calendarEvents = scList.map(function(item) {
                return {
                    id: item.scheduleNo,           
                    title: item.scheduleTitle,     
                    start: item.scheduleStart, 
                    end: item.scheduleEnd,     
                    backgroundColor: item.backgroundColor, 
                    extendedProps: {
                        memo: item.scheduleContent 
                    }
                };
            });
        	if (window.reservationCalendar) {
                window.reservationCalendar.removeAllEvents(); 
                window.reservationCalendar.addEventSource(calendarEvents); 
            }
        })
        .catch(function (error) {
            console.error(error);
            sweetAlert("error", "일정을 불러오는데 실패했습니다.", "확인");
        });
    }

    function openViewModal(event) {
        document.getElementById('viewTitle').innerText = event.title;
        document.getElementById('viewColor').style.backgroundColor = event.backgroundColor;
        
        const options = { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' };
        
        document.getElementById('viewStart').innerText = event.start.toLocaleString('ko-KR', options);
        // viewEnd HTML이 삭제된 상태이므로 값 할당 제거 (오류 방지)
        
        document.getElementById('viewMemo').innerText = event.extendedProps.memo || "내용 없음";
        
        const modal = document.getElementById('viewModal');
        if(modal) modal.classList.remove('hidden');
    }

    function closeModal(id) {
    	const modalId = id
        const modal = document.getElementById(modalId);
        if(modal) modal.classList.add('hidden');
    }

    // ============================================================
    // 이벤트 리스너 및 초기 실행
    // ============================================================
    
    // 드롭다운 닫기 이벤트 (End 타입 제거)
    document.addEventListener('click', function(e) {
        const input = document.getElementById('bookingStartTime');
        const drop = document.getElementById('dropdownStart');
        
        if (input && drop && !drop.classList.contains('hidden')) {
            if (e.target !== input && !drop.contains(e.target)) {
                drop.classList.add('hidden');
            }
        }
        
        const searchDrop = document.getElementById('bookingSearchDropdown');
        const searchInput = document.getElementById('bookingSearchInput');
        if (searchDrop && !searchDrop.classList.contains('hidden')) {
            if (e.target !== searchInput && !searchDrop.contains(e.target)) {
                searchDrop.classList.add('hidden');
            }
        }
    });

    // DOM 로드 완료 후 실행
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            initTimeSlots();
            loadBookingDoctorList();     
            initCalendar();
        });
    } else {
        initTimeSlots();
        loadBookingDoctorList();       
        initCalendar();
    }
</script>