<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
    .modal-overlay { background: rgba(0, 0, 0, 0.4); backdrop-filter: blur(4px); }
    /* 드롭다운 스타일 보정 */
    #dropdownStart::-webkit-scrollbar { width: 6px; }
    #dropdownStart::-webkit-scrollbar-thumb { background-color: #cbd5e1; border-radius: 4px; }
</style>

<div id="scheduleModal" class="modal-overlay fixed inset-0 hidden items-center justify-center bg-black/50 backdrop-blur-sm font-sans" style="z-index: 110;">
    <div class="modal-content modal-hidden modal modal-lg">
        
        <div class="modal-header">
            <h3 class="modal-title">진료 예약 등록</h3>
            <button type="button" class="btn btn-icon btn-ghost" onclick="closeModal('scheduleModal')">
                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="18" y1="6" x2="6" y2="18"></line>
                    <line x1="6" y1="6" x2="18" y2="18"></line>
                </svg>
            </button>
        </div>

        <div class="modal-body">  

            <div class="form-group">
            	<label class="form-label">예약환자</label>                
                <input type="hidden" id="bookingPatientNo">
                <input type="text" id="bookingFieldName" class="input bg-slate-50" readonly value="">
                
                <input type="hidden" id="bookingEndDate">
                <input type="hidden" id="bookingEndTime">                
            </div>

            <div class="form-group mb-2">
                <label class="form-label">수술명</label>
                <input type="text" id="bookingOperationName" class="input bg-slate-50" readonly value="" placeholder="수술 정보가 없습니다.">
            </div>

            <div class="form-group">
                <label class="form-label mb-2">예약일시</label>
                
                <div class="flex items-center gap-2 mb-2">                    
                    <input type="date" id="bookingStartDate" class="input w-3/5" onchange="calculateEndTime()">                    
                    
                    <div class="relative w-2/5">
                        <input type="text" id="bookingStartTime" 
                               class="input cursor-pointer caret-transparent text-center" 
                               readonly placeholder="09:00" 
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
            <button type="button" class="btn btn-secondary" onclick="closeModal('scheduleModal')">취소</button>
            <button type="button" onclick="submitNewBooking()" class="btn btn-primary">예약 저장</button>
        </div>
    </div>
</div>

<script>
    // 1. 버튼 활성화/비활성화 (메인 화면에서 호출됨)
	function updateOPReservation(data) {
		let opBtn = document.getElementById('opReservation');
		let chartListAll = data.chartListAll;
		
		
        let hasOp = false;
		if (chartListAll && Array.isArray(chartListAll)) {
            // 수술처방(005)이 하나라도 있는지 확인
	         hasOp = chartListAll.some(item => item.predetailType === "005");	      
	    } 
		
		if (hasOp) {
	        opBtn.disabled = false;
	        opBtn.classList.remove('btn-secondary'); 
	        opBtn.classList.add('btn-destructive');  
	    } else {
	        opBtn.disabled = true;
	        opBtn.classList.remove('btn-destructive');
	        opBtn.classList.add('btn-secondary');
	    }
	}
	
    // 2. 모달 열기/닫기 유틸리티
	function openModal(id) {
		const modal = document.getElementById(id);
	 	modal.classList.remove('hidden');
	  	modal.classList.add('flex');
	 	document.getElementById(id).classList.add('active');	        
	}

	function closeModal(id) {
		 const modal = document.getElementById(id);
		 modal.classList.remove('flex');
	 	 modal.classList.add('hidden');
	     modal.classList.remove('active');
	     resetBookingForm(); // 폼 초기화         
	}
	 
    // ============================================================
    // 3. 수술 예약 모달 열기 및 데이터 세팅
    // ============================================================
	function openOpReservationModal(data) {
		
	     // (1) 모달 열기
	     openModal('scheduleModal');
         
         // (2) 날짜 및 시간 슬롯 초기화 (오늘 날짜, 09:00 세팅)
         initTimeSlots();

	     // (3) 데이터 분해
	     const detail = data.detail;         // 환자 정보 
	     const chartListAll = data.chartListAll; // 차트 리스트
		
	     // (4) 환자 정보 세팅
	     if (detail) {
	         document.getElementById('bookingPatientNo').value = detail.patientNo || '';
	         document.getElementById('bookingFieldName').value = detail.patientName || '';
	         document.getElementById('bookingInputMemo').value = detail.patientMemo || '';
	         
	     }

	     // (5) 수술 정보(이름) 추출 및 담당 의사 찾기
	     let opNames = [];       
	     let targetDoctorNo = ""; 

	     if (chartListAll && Array.isArray(chartListAll)) {
	         // 모든 차트 순회
	         chartListAll.forEach(chart => {
	             if (chart.operList && Array.isArray(chart.operList)) {
	                 chart.operList.forEach(op => {
	                     // 수술명이 있으면 배열에 추가
	                     if (op.operationName) {
	                         opNames.push(op.operationName);
	                     }
	                     // 첫 번째 발견된 수술의 담당 의사를 타겟으로 설정
	                     if (!targetDoctorNo && op.employeeNo) {
	                         targetDoctorNo = op.employeeNo;
	                     }
	                 });
	             }
	         });
	     }

	     // (6) 수술명 표시 (콤마로 연결)
	     document.getElementById('bookingOperationName').value = opNames.join(', ');

	     // (7) 의사 목록 로드 후 -> 해당 의사 자동 선택 및 시간 계산
	     loadBookingDoctorList().then(() => {
	         if (targetDoctorNo) {
	             const selectEl = document.getElementById('bookingInputDoctor');
	             if (selectEl) {
	                 selectEl.value = targetDoctorNo; // 의사 선택                
	                 
                     // 의사가 선택되었으니 종료시간 계산 및 busy 체크 수행
	                 calculateEndTime(); 
	             }
	         }
	     });
	 }
	 
    // ============================================================
    // 4. 폼 초기화
    // ============================================================
	function resetBookingForm() {
        document.getElementById('bookingPatientNo').value = '';   
        document.getElementById('bookingFieldName').value = '';   
        document.getElementById('bookingOperationName').value = ''; // 수술명 초기화
        document.getElementById('bookingInputMemo').value = '';  
        
        // 날짜/시간 리셋을 위해 initTimeSlots 재호출 가능하나 여기서는 기본 로직 유지
        initTimeSlots(); 

        const selectEl = document.getElementById('bookingInputDoctor');
        if(selectEl) {
            selectEl.value = ""; 
            // 옵션 활성화 복구
            const options = selectEl.querySelectorAll('option');
            options.forEach(opt => {
                opt.disabled = false;
                if (opt.dataset.name) opt.text = opt.dataset.name; 
            });
        }
    }

    // ============================================================
    // 5. 날짜/시간 초기화 및 슬롯 생성
    // ============================================================
	function initTimeSlots() {
        // (1) 09:00 ~ 18:00 (30분 단위) 생성
        const slots = generateTimeSlots(9, 18); 
        
        const startDrop = document.getElementById('dropdownStart');
        if (startDrop) {
            startDrop.innerHTML = slots.map(t => createTimeItem(t, 'Start')).join('');
        }

        // (2) 오늘 날짜 구하기
        const now = new Date();
        const year = now.getFullYear();
        const month = String(now.getMonth() + 1).padStart(2, '0');
        const day = String(now.getDate()).padStart(2, '0');
        const today = `\${year}-\${month}-\${day}`;

        // (3) 날짜 필드 비어있으면 오늘 날짜
        const dateInput = document.getElementById('bookingStartDate');
        if(!dateInput.value) {
            dateInput.value = today;
        }
        
        // (4) 시작 시간 비어있으면 09:00
        const timeInput = document.getElementById('bookingStartTime');
        if(!timeInput.value) {
            timeInput.value = "09:00";
        }

        // (5) 종료 시간 자동 계산 실행
        calculateEndTime(); 
    }

    // 시간 배열 생성기
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

    // 드롭다운 아이템 HTML 생성
    function createTimeItem(timeStr, type) {
        return `<div class="p-2 hover:bg-blue-50 cursor-pointer text-center text-sm border-b border-slate-50 last:border-0" 
                     onclick="selectTimeSlot('\${timeStr}', '\${type}')">
                    \${timeStr}
                </div>`;
    }

    // 드롭다운 토글
    function toggleTimeDropdown(type) {
        const drop = document.getElementById(`dropdown\${type}`);
        if(drop) drop.classList.toggle('hidden');
    }

    // 시간 선택 이벤트
    function selectTimeSlot(timeStr, type) {
        document.getElementById(`booking\${type}Time`).value = timeStr;
        document.getElementById(`dropdown\${type}`).classList.add('hidden');
        
        if (type === 'Start') {
            calculateEndTime(); // 시작 시간 변경 시 종료 시간 재계산
        } 
    }

    // ============================================================
    // 6. 종료 시간 자동 계산 (+30분)
    // ============================================================
    function calculateEndTime() {
        const sDateVal = document.getElementById('bookingStartDate').value; 
        const sTimeVal = document.getElementById('bookingStartTime').value; 

        if (!sDateVal || !sTimeVal) return;

        // Date 객체 생성
        const startDateTime = new Date(`\${sDateVal}T\${sTimeVal}`); 

        // 30분 더하기
        startDateTime.setMinutes(startDateTime.getMinutes() + 30);
        
        const year = startDateTime.getFullYear();
        const month = String(startDateTime.getMonth() + 1).padStart(2, '0'); 
        const day = String(startDateTime.getDate()).padStart(2, '0');
        const hour = String(startDateTime.getHours()).padStart(2, '0');
        const minute = String(startDateTime.getMinutes()).padStart(2, '0');

        const eDateStr = `\${year}-\${month}-\${day}`;
        const eTimeStr = `\${hour}:\${minute}`;

        // Hidden 필드에 값 저장
        document.getElementById('bookingEndDate').value = eDateStr;
        document.getElementById('bookingEndTime').value = eTimeStr;
        
        // 의사 스케줄 체크
        checkDoctor();
    }

    // ============================================================
    // 7. 의사 목록 로드 (Promise 반환)
    // ============================================================
    function loadBookingDoctorList() {
    	return axios.get('/reservation/doctors') // [수정] return 추가됨
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

    // ============================================================
    // 8. 의사 바쁜 시간 체크 (Busy Check)
    // ============================================================
    function checkDoctor(){
        const sDate = document.getElementById('bookingStartDate').value;
        const sTime = document.getElementById('bookingStartTime').value;
        
        if(!sDate || !sTime) return;

        // [T 제거] 서버 전송용 문자열 생성 (공백 사용)
        const startDateTime = sDate + " " + sTime + ":00";
        // 종료 시간은 calculateEndTime에서 계산된 Hidden 값 사용 안하고 여기서 +30분직접 해도 되지만,
        // 편의상 동일 로직(30분) 적용
        const startObj = new Date(`\${sDate}T\${sTime}`);
        startObj.setMinutes(startObj.getMinutes() + 30);
        
        const endYear = startObj.getFullYear();
        const endMonth = String(startObj.getMonth() + 1).padStart(2, '0');
        const endDay = String(startObj.getDate()).padStart(2, '0');
        const endHour = String(startObj.getHours()).padStart(2, '0');
        const endMin = String(startObj.getMinutes()).padStart(2, '0');
        
        const endDateTime = `\${endYear}-\${endMonth}-\${endDay} \${endHour}:\${endMin}:00`;
        
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
                    
                    
                }
            });
        }).catch(err => {
            console.error("의사 일정 조회 실패:", err);
        });
    }

    // ============================================================
    // 9. 예약 저장 (Submit)
    // ============================================================
    function submitNewBooking() {       
        const patientNo = document.getElementById('bookingPatientNo').value;        
        const patientName = document.getElementById('bookingFieldName').value;
        
        // 날짜/시간 가져오기
        const sDate = document.getElementById('bookingStartDate').value;
        const sTime = document.getElementById('bookingStartTime').value;
        const eDate = document.getElementById('bookingEndDate').value;
        const eTime = document.getElementById('bookingEndTime').value;
        
        const doctorSelect = document.getElementById('bookingInputDoctor');
        const doctorVal = document.getElementById('bookingInputDoctor').value;        
       
        const selectedOption = doctorSelect.options[doctorSelect.selectedIndex];

        if(!patientNo) {
            sweetAlert("warning", "환자를 선택해주세요.", "확인");           
            return;
        }
        if(!doctorVal) {
            sweetAlert("warning", "담당 의사를 선택해주세요.", "확인");              
            return;
        }
        
        if(selectedOption && selectedOption.disabled) {//초기 바쁜 의사가 선택되었는지 유효성 검사
            sweetAlert("warning", "현재 선택된 의사는 해당 시간에 예약이 불가합니다.", "확인");
            return;
        }
        
        if(!sDate || !sTime) {
            sweetAlert("warning", "예약 일시를 입력해주세요.", "확인");            
            return;
        }
        
        // 전송용 데이터 포맷팅
        const startDateTime = sDate + " " + sTime + ":00";
        const endDateTime = eDate + " " + eTime + ":00";      
              

        const payload = {
            patientNo: patientNo,
            patientName: patientName,
            scheduleType: '004',
            scheduleStart: startDateTime, 
            scheduleEnd: endDateTime,
            scheduleDoctorNo: doctorVal, 
            memo: document.getElementById('bookingInputMemo').value,
            opSchedules: [
                {
                    opScheduleContent: document.getElementById('bookingOperationName').value,
                    employeeNo: doctorVal
                }
               ]
        };         
        
        
        
        axios.post("/reservation/opreservationinsert", payload)
        .then(res => {
        	
	            sweetAlert("success", "예약이 등록되었습니다.", "확인");
	            resetBookingForm(); 
	            closeModal('scheduleModal'); 	            
        	
        })
        .catch(err => { 
            console.error("Booking Error:", err);
            sweetAlert("warning", "서버 오류로 인해 예약에 실패했습니다.", "확인");
        });
    };
</script>