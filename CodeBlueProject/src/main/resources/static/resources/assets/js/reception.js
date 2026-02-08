
	// 공통 모달 제어 함수
	window.openModal = function(id) {
	    const modal = document.getElementById(id);
	    if (!modal) return;
	    modal.classList.remove("hidden");
	    const content = modal.querySelector(".modal-content");
	    setTimeout(() => {
	        content.classList.remove("modal-hidden");
	        content.classList.add("modal-visible");
	    }, 10);
	    if (id === 'modal-booking-register') setTimeout(() => { if(calendar) calendar.updateSize(); else initCalendar(); }, 200);
	};

	window.closeModal = function(id) {
	    const modal = document.getElementById(id);
	    if (!modal) return;
	    const content = modal.querySelector(".modal-content");
	    content.classList.add("modal-hidden");
	    setTimeout(() => { modal.classList.add("hidden"); }, 10);
	};
	
	// 유효성 검사 
	function validateField(id, regex, errorId) {
	    const field = document.getElementById(id);
	    const errorMsg = document.getElementById(errorId);
	    if (!field || !errorMsg) return true;
	
	    // 중간 공백을 포함한 모든 공백 실시간 제거
	    if(field.value.includes(' ')){
	    	field.value = field.value.replace(/\s/g, '');
	    }
	    
	    // 공백 제거된 최종 값 정규식 검사
	    const value = field.value;
	    const isValid = regex.test(value);

	    console.log(`값: ${value}, 유효성: ${isValid}`);
	    
	 	// 값이 있는데 규격에 안 맞을 때만 에러 표시
    	if (!isValid && value.length > 0) { 
	        field.classList.add('input-error');
	        errorMsg.classList.add('show'); 
	        errorMsg.style.setProperty('display', 'block', 'important');
	        return false;
	    }else if (isValid || value.length === 0) {
	        // 유효하거나 값이 없을 때 제거
	        field.classList.remove('input-error');
	        errorMsg.classList.remove('show');
	        errorMsg.style.display = 'none';
	        return true;
	    }
    	return isValid;
	}
	
	// 신규 환자 등록
	function newPatientRegistration() {
		
		// 유효성 검사
	    const nameRegex = /^[가-힣]{2,5}$|^[a-zA-Z]{2,20}$/;
	    const telRegex = /^01[0-9]-\d{3,4}-\d{4}$/;
	    const r1Regex = /^\d{6}$/;
	    const r2Regex = /^\d{7}$/;
	    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
	    const addr2Regex = /^[가-힣a-zA-Z0-9\s]{2,20}$/;
	    
	    // 최종 검증
	    let isValid = true;
	    if (!validateField('patientName', nameRegex, 'err-patientName')) isValid = false;
	    if (!validateField('patientTel', telRegex, 'err-patientTel')) isValid = false;
	    if (!validateField('patientRegno1', r1Regex, 'err-patientRegno')) isValid = false;
	    if (!validateField('patientRegno2', r2Regex, 'err-patientRegno')) isValid = false;
	    if (!validateField('patientAddr2', addr2Regex, 'err-patientAddr2')) isValid = false;
	    
	    combineEmail(); // 이메일 값 최종 갱신
	    const currentEmail = document.getElementById('patientEmail').value;
	    if (currentEmail && !emailRegex.test(currentEmail)) isValid = false;

	    if (!isValid) {
	        Swal.fire({
	            title: '입력 오류',
	            text: '규격에 맞지 않는 값이 있습니다. 안내 문구를 확인해주세요.',
	            icon: 'warning',
	            confirmButtonColor: '#2563eb'
	        });
	        return;
	    }
	    
	 	// 필수값 및 진료실/담당의 선택 정보 가져오기
		const patientName = document.getElementById('patientName').value.trim();
		const patientAddr1 = document.getElementById('patientAddr1').value.trim();
	    const locationSelect = document.getElementById('locationNo'); 
	    const employeeNo = locationSelect.value; 
	    const selectedOption = locationSelect.options[locationSelect.selectedIndex]; 
	    const locationNo = selectedOption ? selectedOption.getAttribute('data-location') : null; 

	    // 성명 체크
	    if (!patientName) { 
	        Swal.fire('알림', '환자 성명은 필수 입력 항목입니다.', 'warning'); 
	        return; 
	    }
		
		// 주소1(기본 주소) 체크 		
		if (!patientAddr1) {
		    Swal.fire('알림', '주소 검색을 통해 기본 주소를 입력해주세요.', 'warning');
		    return;
		}
		
	    // 담당의 체크
	    if (!employeeNo || employeeNo === "") { 
	        Swal.fire('알림', '진료를 담당할 의사를 선택해주세요.', 'warning'); 
	        return; 
	    }
	    // 진료실 체크 
	    if (!locationNo || locationNo === "0") { 
	        Swal.fire('알림', '선택한 의사의 진료실 정보가 없습니다.', 'warning'); 
	        return; 
	    }
		
	    // 데이터 수집
	    const sendData = {
	        patientName: patientName,
	        patientRegno1: document.getElementById('patientRegno1').value,
	        patientRegno2: document.getElementById('patientRegno2').value,
	        patientTel: document.getElementById('patientTel').value,
	        patientGen: document.getElementById('patientGen').value,
	        patientEmail: document.getElementById('patientEmail').value,
	        patientMemo: document.getElementById('newPatientMemo')?.value.trim() || "",
	        patientPostcode: document.getElementById('patientPostcode').value,
	        patientAddr1: document.getElementById('patientAddr1').value,
	        patientAddr2: document.getElementById('patientAddr2').value, 
	        
	        // 접수 정보 (중첩 객체)
	        registrationVO: {
	            registrationVisittype: document.getElementById('newPatientVisittype').value,
	            registrationInsurance: document.getElementById('registrationInsurance').value,	            
				locationNo: parseInt(locationNo), 
	            employeeNo: parseInt(employeeNo)
	        }
	    }; 

	    console.log("전송 데이터:", sendData);
	    
	    // 신규환자 등록 외래 접수 비동기 처리(신규환자 등록하면서 접수까지 완료하도록 구현함)
	    axios.post('/reception/insertpatient', sendData)
	        .then(response => {
	        	const chartData = response.data;
	        	
	        	// 중복 환자 확인
	        	if(chartData.status === "duplicate") {
	                Swal.fire({
	                    title: '등록 실패',
	                    text: '이미 등록된 환자 정보(성명 및 주민번호)가 존재합니다.',
	                    icon: 'error',
	                    confirmButtonColor: '#ef4444'
	                });
	                return; 
	            }
	        	
	        	Swal.fire({
                    title: '접수 및 차트 생성 완료',
                    html: `
                        <div style="text-align: left; padding: 10px; background: #f8fafc; border-radius: 8px;">
                            <p><b>차트번호:</b> <span style="color: #2563eb;">${chartData.chartNo}</span></p>
                            <p><b>환자성명:</b> ${chartData.patientName}</p>
                            <p><b>담당의:</b> ${selectedOption.text}</p>
                        </div>
                    `,
                    icon: 'success',
                    confirmButtonText: '확인',
                    confirmButtonColor: '#2563eb' 
                }).then(() => {
                    closeModal('modal-new-patient');
                    //location.reload(); 
					loadWaitingList(); // 대기 환자 목록 갱신
					loadInpatientWaitingList(); // 수납 목록 갱신
                });
	        })
	        .catch(error => {
	            console.error("등록 중 발생한 오류:", error);
	            Swal.fire({
	                title: '오류 발생',
	                text: '시스템 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.',
	                icon: 'error',
	                confirmButtonText: '확인',
	                confirmButtonColor: '#ef4444'
	            });
	        });
	}
	
	// 신규환자 등록 이메일 도메인 입력창 제어
	window.handleEmailSelect = function() {
	    const emailSelect = document.getElementById("email_select");
	    const emailDomain = document.getElementById("email_domain");
	    
	    if (!emailSelect || !emailDomain) return;
	
	    if (emailSelect.value === "") {
	        emailDomain.value = "";
	        emailDomain.readOnly = false;
	        emailDomain.focus();
	    } else {
	        emailDomain.value = emailSelect.value;
	        emailDomain.readOnly = true;
	    }
	    
	    combineEmail(); // 내부에서 호출
	};
	
	// 이메일 합치기(아이디, 도메인 값)
	window.combineEmail = function() {
		const idField = document.getElementById("email_id");
	    const domField = document.getElementById("email_domain");
	    
	    // 실시간 공백 제거
	    const id = (idField?.value || "").replace(/\s/g, '');
	    const domain = (domField?.value || "").replace(/\s/g, '');
	    if(idField) idField.value = id;
	    if(domField) domField.value = domain;

	    const combinedField = document.getElementById("patientEmail");
	    const errorMsg = document.getElementById("err-patientEmail");
	    const emailRegex = /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/;
	    
	    if (combinedField) {
            const fullEmail = id + "@" + domain;
            combinedField.value = (id && domain) ? fullEmail : "";
            
         	// 이메일 유효성 검사	
	        if ((id || domain) && !emailRegex.test(fullEmail)) {
	            errorMsg.classList.add('show');
	            idField.classList.add('input-error');
	            domField.classList.add('input-error');
	        } else {
	            errorMsg.classList.remove('show');
	            idField.classList.remove('input-error');
	            domField.classList.remove('input-error');
	        }
	    
	    }
	};
	
//카카오 주소 API
function DaumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
           
            var addr = ''; // 주소 변수

            // 사용자가 선택한 주소 타입에 따라 해당 주소 값을 가져온다.
            if (data.userSelectedType === 'R') { // 도로명 주소
                addr = data.roadAddress;
            } else { // 지번 주소
                addr = data.jibunAddress;
            }

			// 우편번호와 주소 정보를 해당 필드에 넣는다.
            document.getElementById('patientPostcode').value = data.zonecode;
            document.getElementById("patientAddr1").value = addr;
            
            // 커서를 상세주소 필드로 이동
            document.getElementById("patientAddr2").focus();
        }
    }).open();
}

// 신규환자 등록 입력폼 자동완성
function autoFillPatientForm() {
    // 자동 입력할 샘플 데이터
    const sampleData = {
        patientName: '김우빈',
        patientGen: 'MALE',
        patientRegno1: '951001',
        patientRegno2: '1234567',
        email_id: 'hong',
        patientTel: '010-1234-5678',
        patientAddr2: '2층',
        newPatientMemo: '견과류 알러지'
    };

    // 각 필드에 값 대입 
    Object.keys(sampleData).forEach(id => {
        const input = document.getElementById(id);
        if (input) {
            input.value = sampleData[id];
            
            // 유효성 검사 스크립트가 실행되도록 'input' 이벤트 강제 발생
            input.dispatchEvent(new Event('input'));
            // 셀렉트 박스
            if(input.tagName === 'SELECT') {
                input.dispatchEvent(new Event('change'));
            }
        }
    });

    // 이메일 도메인 같은 select 박스는 별도로 처리 
    const emailDomain = document.getElementById('email_select');
    if(emailDomain) {
        emailDomain.value = 'naver.com';
        emailDomain.dispatchEvent(new Event('change'));
    }
	
	// 담당의 '박정민'로 자동 선택
    const doctorSelect = document.getElementById('locationNo');
    if (doctorSelect) {
        for (let i = 0; i < doctorSelect.options.length; i++) {
            if (doctorSelect.options[i].text.includes('박정민')) {
                doctorSelect.selectedIndex = i;
                doctorSelect.dispatchEvent(new Event('change')); // 변경 이벤트 발생
                break;
            }
        }
    }

}

// 접수 환자 대기 리스트 검색
function filterWaitingList() {
    // 데이터가 아직 로드되지 않았으면 중단
    if (!allWaitingData || allWaitingData.length === 0) return;

	// 검색어 앞뒤 공백 제거 및 소문자 변환
	    const keyword = document.getElementById('waitingListSearch').value.trim().toLowerCase();
    
    // 현재 활성화된 탭 찾기
    const activeTab = document.querySelector('.tabs-button .tab.active');
    if (!activeTab) return;

    // 텍스트 전체가 아닌, switchTab에서 사용하는 상태값 구분을 위해 
    // onclick 속성이나 innerText의 첫 단어만 추출
    const tabText = activeTab.innerText.trim();
    
    const filteredData = allWaitingData.filter(patient => {
        const pName = (patient.patientName || patient.PATIENT_NAME || patient.patient_name || "").toLowerCase();
        const pNo = String(patient.patientNo || patient.PATIENT_NO || patient.patient_no || "");
        
		// 키워드 매칭
		const keywordMatch = pName.includes(keyword) || pNo.includes(keyword);
		
		// 탭 상태 매칭
		let statusMatch = false;
        const regVO = patient.registrationVO || patient.REGISTRATIONVO;
        const status = regVO ? 
            (regVO.registrationStatus || regVO.REGISTRATIONSTATUS) : 
            (patient.registrationStatus || patient.REGISTRATION_STATUS || '001');

        // 탭 필터링 조건
        if (tabText.includes('전체')) {
            statusMatch = true;
        } else {
            const statusMap = { '대기': '001', '진료대기': '002', '진료중': '003' };
            // 탭 텍스트에서 숫자 제외하고 매칭 (예: "진료중 2" -> "진료중")
            const pureTabText = tabText.split(/\s/)[0]; 
            statusMatch = (status === statusMap[pureTabText]);
        }

     
        return statusMatch && keywordMatch;
    });

    renderWaitingList(filteredData);
}

//전역 변수로 보관하여 대기 리스트 조회 탭 전환 시 재사용
let allWaitingData = []; 			// 접수 대기 환자 목록 

// 접수 환자 대기 리스트 조회 탭
function loadWaitingList() {
    axios.get('/reception/waitingList')
        .then(response => {
        	
			// 안내 문구 출력
			/*const noticeArea = document.getElementById('waiting-list-notice');
			if(noticeArea){
				noticeArea.innerText = "새로운 환자가 접수되어 목록이 갱신되었습니다.";
				noticeArea.classList.remove("hidden");
				setTimeout(() => noticeArea.classList.add('hidden'), 3000);
			}*/
			
        	allWaitingData = response.data; // 데이터 보관
        	
        	//탭 상단의 숫자는 전체 데이터를 기준으로 한번 업데이트
            calculateTabCounts(allWaitingData);
            
            // 데이터 로드 후, 혹시 검색창에 글자가 있다면 그에 맞춰 필터링
            const keyword = document.getElementById('waitingListSearch').value.trim();
            if(keyword) {
                filterWaitingList();
            } else {
            	//초기 화면은 '전체' 탭이므로 전체 데이터 출력
                renderWaitingList(allWaitingData);   
            }           
			
        })
        .catch(err => console.error("데이터 로드 실패:", err));
}

//탭 클릭 시 호출되는 함수
function switchTab(event, status){
	// 탭 스타일 활성화 처리
    const tabs = document.querySelectorAll('.tab');
    tabs.forEach(tab => tab.classList.remove('active'));
    event.currentTarget.classList.add('active');

 	// 탭 이동 시 검색어 초기화
    const searchInput = document.getElementById('waitingListSearch');
    if(searchInput) searchInput.value = "";
    
    // 데이터 필터링
    let filteredData;
    if (status === '전체') {
        filteredData = allWaitingData;
    } else {
        filteredData = allWaitingData.filter(patient => {
        	const regVO = patient.registrationVO || patient.REGISTRATIONVO;
            const regStatus = regVO ? 
                (regVO.registrationStatus || regVO.REGISTRATIONSTATUS) : 
                (patient.registrationStatus || patient.REGISTRATION_STATUS);
            return regStatus === status;
        });
    }

    // 필터링된 결과 화면만 다시 출력
    renderWaitingList(filteredData);
}

//보험 유형 상수로 선언
const INSURANCE_NAMES = {
    '001': '건강보험', '002': '차상위1종', '003': '차상위2종', '004': '급여1종',
    '005': '급여2종', '006': '산재', '007': '산재100', '008': '후유장해',
    '009': '자보', '010': '자보100', '011': '일반', '012': '일반100'
};

// 접수 환자 대기 리스트 조회
function renderWaitingList(data) {
	console.log("전체 데이터 확인:", data);
	const listBody = document.getElementById('waiting-list-body');
	let html = "";
	
	// 데이터가 없는 경우 처리
    if (!data || data.length === 0) {
        listBody.innerHTML = '<div class="p-4 text-center text-slate-400 text-sm">대기 환자가 없습니다.</div>';
        return;
    }
	
    data.forEach((patient, index) => {
    	const regVO = patient.registrationVO || patient.REGISTRATIONVO;
        const status = regVO ? (regVO.registrationStatus || regVO.REGISTRATIONSTATUS) : 
            (patient.registrationStatus || patient.REGISTRATION_STATUS || '001');
        const insurance = regVO ? (regVO.registrationInsurance || regVO.REGISTRATION_INSURANCE || regVO.REGISTRATIONINSURANCE) : '011'; // 기본값 일반으로 설정
        
		// 예약 정보 추출
        const isReservation = (regVO.reservationYn || regVO.RESERVATION_YN || patient.reservationYn || patient.RESERVATION_YN || 'N');
        const resTime = (regVO.reservationTime || regVO.RESERVATION_TIME || patient.reservation_time || patient.RESERVATION_TIME || "");
		const regDate = (regVO.registrationRegdate || regVO.REGISTRATION_REGDATE || patient.registration_regdate || "");
		
		// 시간 포맷팅 (HH:mm)
        const formattedRegTime = regDate ? regDate.substring(11, 16) : '--:--';
		
		
        const gender = (patient.patientGen === 'MALE' || patient.patientGen === 'M') ? '남' : '여';
        const age = patient.patientAge || '0';
        const regNo1 = patient.patientRegno1 || '000000';
        const patientInfo = `${gender}/${age}세 (${regNo1})`; 
        
     	//대기 리스트 상태별 개수 카운트
     	let statusClass = "text-slate-500";
     	let statusText = "대기";
     	if(status === '003') { 
			statusClass = " text-emerald-700"; 
			statusText = "진료중"; 
		}
        else if(status === '002') { 
			statusClass = "text-blue-700"; 
			statusText = "진료대기"; 
		}
        else if(status === '001') { statusText = "대기"; }
  
     	// 보험 유형 상수 객체에서 바로 꺼내기
        const insuranceText = INSURANCE_NAMES[insurance] || '일반';
		
		// 예약 배지 및 시간 표시 로직
        let resBadge = '';
        let timeHtml = `<span class="text-[11px] text-slate-400 font-medium">접수 ${formattedRegTime}</span>`;
        
        if (isReservation === 'Y') {
            resBadge = `<span class="badge bg-indigo-100 text-indigo-600 border-indigo-200 ml-1 text-[10px]">예약</span>`;
            // 예약 환자는 예약시간과 접수시간 둘 다 표시
			timeHtml = `
		        <div class="flex flex-col items-end">
		            <span class="text-[11px] text-indigo-500 font-bold">예약 ${resTime}</span>
		            <span class="text-[10px] text-slate-400">접수 ${formattedRegTime}</span>
		        </div>
		    `;
        }
     	
		html += `
	        <div class="card border border-slate-200 hover:border-blue-500 hover:shadow-lg transition-all mb-3 shadow-sm bg-white group">
	            <div class="card-header py-1 flex justify-between items-center border-b border-slate-50">
	                <div class="flex items-center">
	                    <h4 class="card-title text-sm">환자번호 ${patient.patientNo}</h4>
	                    ${resBadge}
	                </div>
	                <div class="${statusClass} text-[10px] font-bold px-2 py-0.5 rounded-full">${statusText}</div>
	            </div>
	            <div class="card-body py-4">
	                <div class="flex items-center justify-between mb-2">
	                    <div class="flex items-center gap-2">
	                        <h3 class="text-base font-bold mb-1">${patient.patientName}</h3>
	                        <p class="description text-sm mb-1 ml-1">${patientInfo}</p>
	                    </div>
	                    ${timeHtml}
	                </div>
	                <div class="flex flex-wrap gap-1">
	                    <span class="badge badge-default">${insuranceText}</span>
	                </div>
	            </div>
	        </div>
	    `;
    });
    listBody.innerHTML = html;
}

//탭 숫자 계산 함수
function calculateTabCounts(data) {
	//대기 리스트 탭 숫자 초기화
    let total = data.length;
    let ing = 0;		// 진료중 (003)
    let examWait = 0;	// 진료대기 (002)
    let wait = 0;		// 대기 (001)
    
    data.forEach(patient => {
        const status = patient.registrationVO ? patient.registrationVO.registrationStatus : '001';
        if(status === '003') ing++;
        else if(status === '002') examWait++;
        else if(status === '001') wait++;
    });
    
    updateTabCounts(total, ing, examWait, wait);
}

//탭 숫자 업데이트 함수
function updateTabCounts(total, ing, examWait, wait) {
    if(document.getElementById('wait-total-count')) document.getElementById('wait-total-count').innerText = total;	 // 전체 환자 수
    if(document.getElementById('ing-count')) document.getElementById('ing-count').innerText = ing;					 // '진료중' 상태 수
    if(document.getElementById('exam-wait-count')) document.getElementById('exam-wait-count').innerText = examWait;	 // '진료대기' 상태 수
    if(document.getElementById('wait-count')) document.getElementById('wait-count').innerText = wait;				 // '대기' 상태 수
}

// 진료/수술 예약 캘린더
// 1. 캘린더 초기화 함수 ==> 예약 모달로 이동


// 2. 업무 탭 전환 시 호출 로직
window.showTab = function(event, tabId) {
	
    //모든 패널 숨기기
    document.querySelectorAll('.tab-panel').forEach(panel => {
        panel.classList.add('hidden');
    });
    
    //선택한 패널 보이기
    const targetPanel = document.getElementById(tabId);
    if (targetPanel) {
        targetPanel.classList.remove('hidden');
    }
    
    //업무 탭 버튼 active 제거 후 선택한 버튼에 추가
    if (event && event.currentTarget) {
        const tabs = event.currentTarget.parentElement.querySelectorAll('.tab');
        tabs.forEach(t => t.classList.remove('active'));
        event.currentTarget.classList.add('active');
    }
    
    // 예약 탭일 때만 캘린더 초기화 호출
    if (tabId === 'tab-reservation') {
        // 탭이 완전히 표시(hidden 제거)된 후 그려야 캘린더 크기가 깨지지 않음
        setTimeout(() => {
            if (typeof initCalendar === 'function') {
                initCalendar();
            }
        }, 100);
    }
};

// 완료 후 현재 탭 유지
// 새로고침 직후에 탭을 복구 후 다음번 일반 새로고침을 위해 저장된 값을 바로 지워줌
function initTab() {
    const savedTab = localStorage.getItem('activeTab');
    if (!savedTab) return; 

    // 복구 로직 실행 
    const targetButton = document.querySelector(`button[onclick*="${savedTab}"]`);
    if (targetButton) {
        targetButton.click();
    }
	
	// 복구 후 바로 삭제 (일반 새로고침 시 튕김 방지)
    localStorage.removeItem('activeTab'); 
}

//[외래/입원/제증명 공통] 환자 접수 검색
window.executePatientSearch = function(searchValue) {
	// 앞뒤 공백 제거 및 값 확인
    const keyword = searchValue ? searchValue.trim() : "";
    
    if(!keyword) {
        Swal.fire('알림', '검색어를 입력해주세요.', 'info');
        return;
    }

    // 현재 열려있는 탭 확인
    const isOutpatientTab = document.getElementById('tab-outpatient').offsetParent !== null;
    const isInpatientTab = document.getElementById('tab-inpatient').offsetParent !== null;
    const isCertificateTab = document.getElementById('tab-certificate').offsetParent !== null; 

    // 입원 탭일 때만 입원 전용 검색 사용, 그 외(외래/제증명)는 일반 검색 사용
    const url = isInpatientTab ? '/reception/searchInpatient' : '/reception/searchPatient'; 
    
    // 서버의 Controller로 검색 요청을 보냄
    axios.get(url, {
		    params: { keyword: keyword}
		})
    	.then(response => {
            const patients = response.data; // 서버에서 보낸 PatientVO 객체
            // 탭에 맞는 드롭다운 객체
            let dropdownId = 'outSearchDropdown';
            if(isInpatientTab) dropdownId = 'inSearchDropdown';
            else if(isCertificateTab) dropdownId = 'certSearchDropdown';
            
            const dropdown = document.getElementById(dropdownId); // 드롭다운 객체 가져오기

            console.log("검색된 환자들 목록:", patients);
            console.log("검색된 환자 수:", patients.length);
                 
            if (!patients || patients.length === 0) {
                Swal.fire({
                    icon: 'warning', 
                    title: '검색 결과 없음',
                    text: '등록되지 않은 환자입니다.',
                    confirmButtonColor: '#7a61e0'
                });
                //resetSelectedPatient();
             	// 제증명 환자 초기화
            	if(!isCertificateTab) resetSelectedPatient();
             	return;
            } 
            
            // 검색 결과가 1명일 때
            if (patients.length === 1) {
            	// 현재 탭에 맞는 함수 호출
                if(isOutpatientTab) selectPatient(patients[0]);
                else if(isInpatientTab) selectInpatient(patients[0]);
                else if(isCertificateTab) selectCertPatient(patients[0]);
            	
                if(dropdown) dropdown.classList.add('hidden'); //1명 선택 시 닫기
            } 
            else {
                // 2명 이상일 때(동명이인): 선택창 팝업
                const inputOptions = {};
                patients.forEach(p => {
                	const name = p.patientName || "이름없음"; 
                    const regno = p.patientRegno1 || "******"; 
                    const pNo = p.patientNo;
                    
                    inputOptions[pNo] = `${name} (${regno})`;
                });

                Swal.fire({
                	icon: 'info',
                    title: '동명이인이 존재합니다',
                    text: '대상 환자를 선택해주세요.',
                    input: 'select',
                    inputOptions: inputOptions,
                    inputPlaceholder: '환자 선택',
                    showCancelButton: true,
                    confirmButtonText: '확인',
                    cancelButtonText: '취소',
                    confirmButtonColor: '#7a61e0'
                }).then((result) => {
                    if (result.value) {
                        const selected = patients.find(p => p.patientNo == result.value);
                     	
                     	// 탭별 분기 처리하여 바인딩 함수 호출
                        if (isCertificateTab) {
                            selectCertPatient(selected);
                        } else if (isOutpatientTab) {
                            selectPatient(selected); 
                        } else {
                            selectInpatient(selected);
                        }
                        
                        if(dropdown) dropdown.classList.add('hidden'); // 팝업 선택 완료 시 닫기
                    }
                });
            }
        })
        .catch(err => {
            console.error("검색 오류:", err);
            Swal.fire({ icon: 'error', title: '오류', text: '환자 정보를 가져오지 못했습니다.' });
        });
};

//환자 선택 취소 버튼 로직
window.resetSelectedPatient = function() {
    window.selectedPatientNo = null;
    document.getElementById('outPatientName').value = "";
    document.getElementById('outPatientNameDisplay').innerText = "-";
    document.getElementById('outPatientIdDisplay').innerText = "-";
    document.getElementById('auto-selected-patient').classList.add('hidden');
    document.getElementById('outSearch').value = "";
    document.getElementById('outSearch').focus();
};

// [신규/외래/입원 공통] 접수 의사 조회
// 재직 의사 목록을 가져와 select 박스에 바인딩
function loadDoctorList() {
    axios.get('/reception/getDoctorList')
        .then(res => {
            const doctors = res.data;
            if(!doctors || doctors.length === 0) {
                console.error("서버에서 받은 의사 데이터가 없습니다.");
                return;
            }
            
         	// 신규(locationNo), 외래(outEmployeeChange), 입원(inEmployeeChange)
            const selectIds = ['locationNo', 'outEmployeeChange', 'inEmployeeChange'];
            
            selectIds.forEach(id => {
                const selectEl = document.getElementById(id);
                if(!selectEl) return;                        
                
                let html = '<option value="">담당의를 선택하세요</option>';
                doctors.forEach(doc => {
					// 디비에 저장할 번호(쿼리의 location_no 컬럼값)
					const realLocNo = doc.employeeDetailLicence || "";
					// 화면 출력 이름 (쿼리의 locationNo 별칭값)
					const locDisplayName = doc.locationNo || "진료실 미배정";
					
                	// 진료실 번호가 존재할 때만 표시 제 ${locNo}
                    //const locationDisplay = (locNo && locNo !== '0') ? `${locNo}` : '진료실 미배정';
                	
                    // value는 사번(employeeNo), data-location은 진료실 번호(locationNo)
					html += `<option value="${doc.employeeNo}" data-location="${realLocNo}">
					                ${locDisplayName} / ${doc.employeeName}
					            </option>`;
                });
                selectEl.innerHTML = html;
            });
            console.log("재직 의사 목록 바인딩 완료");
        })
        .catch(err => console.error("의사 목록 로드 실패:", err));
}

// [외래/입원/제증명 공통] 접수 검색 드롭다운
let searchTimer; // 연속 타이핑 방지용 타이머

window.showSearchDropdown = function(val, type) {
    const keyword = val.trim();
    // 외래(OUT)인지 입원(IN)인지 제증명(CERT)에 따라 타겟 설정
    let dropdownId, url;
    if(type === 'OUT'){dropdownId = 'outSearchDropdown'; url = '/reception/searchPatient';}
    else if(type === 'IN'){dropdownId = 'inSearchDropdown'; url = '/reception/searchInpatient';}
    else if(type === 'CERT'){dropdownId = 'certSearchDropdown'; url = '/reception/searchPatient';}
    
    const dropdown = document.getElementById(dropdownId);
    if (keyword.length < 1) {
		dropdown.classList.add('hidden');
        dropdown.style.display = 'none';
        //hideSearchDropdown(type);
        return;
    }
    
	clearTimeout(searchTimer);
    searchTimer = setTimeout(() => {
		axios.get(url, { params: { keyword: keyword } })
	       .then(res => {
	           const list = res.data;
			
			// 검색 도중 키워드가 지워졌을 가능성 체크
	           const currentVal = document.getElementById(type === 'OUT' ? 'outSearch' : (type === 'IN' ? 'inSearch' : 'certSearch')).value;
	           if(!currentVal.trim()) {
	               dropdown.classList.add('hidden');
	               return;
	           }
			
	           if (list.length === 0) {
	               dropdown.innerHTML = '<div class="search-item text-slate-400 text-xs text-center">검색 결과가 없습니다.</div>';
	           } else {
	               let html = '';
	               list.forEach((p, index) => {                    
	                   const targetFunc = (type === 'CERT') ? 'selectCertPatient' : (type === 'OUT' ? 'selectPatient' : 'selectInpatient');
	                   const gender = (p.patientGen === 'MALE' || p.patientGen === 'M' || p.PATIENT_GEN === 'MALE') ? '남' : '여';
	                   
					// 전화번호 뒷자리 추출 로직 추가
	                   const tel = p.patientTel || p.PATIENT_TEL || ""; 
	                   const lastTel = tel.length >= 4 ? tel.slice(-4) : "****";
					
					html += `
	                       <div class="search-item" id="${type}-item-${index}" 
	                            onclick='${targetFunc}(${JSON.stringify(p)});'
	                            onmouseover="this.classList.add('bg-slate-50')"
	                            onmouseout="this.classList.remove('bg-slate-50')">
	                           <span class="p-name">${p.patientNo}.${p.patientName}</span>
	                           <span class="p-info">
	                           	${p.patientRegno1} | ${gender} | 010-****-${lastTel}
	                           </span>
	                       </div>`;
	               });
	               dropdown.innerHTML = html;
	           }
	           dropdown.classList.remove('hidden');
	           dropdown.style.display = 'block';
	       })
	       .catch(err => console.error("Dropdown Search Error:", err));
	}, 200);
   
};

// [외래/입원/제증명 공통] 접수 검색 드롭다운을 닫고 입력창을 초기화
window.hideSearchDropdown = function(type) {
    let dropdownId, searchId;
    
    // 타입별 ID 매핑
    if(type === 'OUT'){
    	dropdownId = 'outSearchDropdown';
    	searchId = 'outSearch';
    } else if(type === 'IN'){
    	dropdownId = 'inSearchDropdown';
    	searchId = 'inSearch';
    } else if(type === 'CERT'){
    	dropdownId = 'certSearchDropdown';
    	searchId = 'certSearch';
    }
    
    const dropdown = document.getElementById(dropdownId);
    const searchInput = document.getElementById(searchId);
    
    if (dropdown) {
        dropdown.classList.add('hidden');
        dropdown.style.display = 'none';
    }
    if (searchInput) {
        searchInput.value = "";
    }
};

//선택된 환자 정보를 화면에 출력하는 공통 함수
function selectPatient(patient) {
	console.log("서버가 보내준 환자 전체 데이터:", patient);

	hideSearchDropdown('OUT'); // 드롭다운 닫기
	
    window.selectedPatientNo = patient.patientNo;
    
    window.selectedPatientStatus = patient.currentStatus;
    console.log("환자 선택 완료! 상태값:", window.selectedPatientStatus);

	// "번호.이름" 형식으로 바인딩 
    const pNo = window.selectedPatientNo;
    const pName = patient.patientName || patient.PATIENT_NAME;
    document.getElementById('outPatientName').value = pNo + "." + pName;
	
	// 담당의 바인딩
	const regVO = patient.registrationVO || {};
	if(regVO.employeeNo) {
	    const outSelect = document.getElementById('outEmployeeChange');
	    if(outSelect) {
	        // 사번이 숫자일 수 있으므로 String으로 변환해서 value 지정
	        setTimeout(() => {
	            outSelect.value = String(regVO.employeeNo);
	            console.log("담당의 셀렉트 박스 변경 완료:", regVO.employeeNo);
	        }, 100);
	    }
	}
	
    //환자 메모가 있다면 메모창에도 넣어줌
    if(patient.patientMemo) {
        document.getElementById('outSearchPatientMemo').value = patient.patientMemo; 
    } else {
        document.getElementById('outSearchPatientMemo').value = ""; // 이전 검색 환자 메모 초기화
    }
    
}

// 외래 환자 접수
window.completeRegistration = function() {
	console.log("--- 접수 시도 ---");
    console.log("선택된 환자번호:", window.selectedPatientNo);
    
    const status = window.selectedPatientStatus; // 환자의 최근 외래 상태
	console.log("현재 체크할 상태:", status);
	
    //환자 선택 여부 확인
    if(!window.selectedPatientNo) {
        Swal.fire('확인', '접수할 환자를 먼저 검색하여 선택해주세요.', 'warning');
        return;
    }

	// 입원 환자 체크
	if(status === 'ADMIT') {
        Swal.fire('접수 불가', '현재 입원 중인 환자입니다. 퇴원 처리 후 접수 가능합니다.', 'error');
        return;
    }
	
 	// 환자 상태 체크 (진료중이거나 대기중이면 차단)
    // 검색 시 저장해둔 상태값
    if(status && (status === '001' || status === '002' || status === '003')) {
	    Swal.fire('접수 불가', '현재 환자는 이미 대기 또는 진료 중입니다.', 'error');
	    return;
	}
    
 	// 필수값 및 진료실/담당의 선택 값
	const locationSelect = document.getElementById('outEmployeeChange');
    const selectedOption = locationSelect.options[locationSelect.selectedIndex];
    const employeeNo = locationSelect.value;
    const locationNo = selectedOption ? selectedOption.getAttribute('data-location') : null;

    // 담당의 체크 
    if(!employeeNo || employeeNo === "") {
        Swal.fire('알림', '진료 담당 의사를 선택해주세요.', 'warning');
        return;
    }
    // 진료실 체크 
    if(!locationNo || locationNo === "0") {
        Swal.fire('알림', '해당 의사의 진료실 정보가 없습니다.', 'warning');
        return;
    }
	
	
    //데이터 수집
    const sendData = {
        patientNo: window.selectedPatientNo, // 환자 번호
        patientMemo: document.getElementById('outSearchPatientMemo').value, // 환자 메모
        registrationVO: {
			locationNo: locationNo,
            employeeNo: employeeNo,		
            registrationInsurance: document.getElementById('outInsurance').value, // 보험 유형
            registrationVisittype: document.getElementById('outVisittype').value, // 재진
            registrationStatus: "001" // 초기 상태 '대기' 고정
        }
    };

    //서버 전송
    axios.post('/reception/registerOutpatient', sendData)
        .then(res => {
        	const chartInfo = res.data;
            if(chartInfo.status === "success") {
            	Swal.fire({
                    title: '외래 접수 및 차트 생성 완료',
                    html: `
                        <div style="text-align: left; padding: 10px; background: #f0fdf4; border-radius: 8px;">
                            <p><b>발행 차트번호:</b> <span style="color: #059669; font-weight: bold;">${chartInfo.chartNo}</span></p>
                            <p><b>환자명:</b> ${document.getElementById('outPatientName').value}</p>
                        </div>
                    `,
                    icon: 'success'
                }).then(() => {
					//location.reload();
					loadWaitingList();	// 대기 환자 목록 갱신
					resetSelectedPatient(); // 입력했떤 검색창 초기화
				});
            }
        });
};

// 입원 접수 대상 환자 검색
window.executeInpatientSearch = function(searchValue) {
    const keyword = searchValue ? searchValue.trim() : "";
    const dropdown = document.getElementById('inSearchDropdown');
    
    if(!keyword) {
        Swal.fire('알림', '검색어를 입력해주세요.', 'info');
        return;
    }

	
    // 서버 검색 
    axios.get('/reception/searchInpatient', { params: { keyword: keyword } })
        .then(response => {
            const patients = response.data;

            if (!patients || patients.length === 0) {
            	Swal.fire({ 
                    icon: 'warning', 
                    title: '검색 결과 없음', 
                    text: '입원 대상 환자가 아니거나 이미 입원 중인 환자입니다.' 
                });
                return;
            } 
            
            if (patients.length === 1) {
                // 1명일 때는 바로 선택 처리 (아래 함수 호출)
                selectInpatient(patients[0]);
                if(dropdown) {
                    dropdown.classList.add('hidden');
                    dropdown.style.display = 'none'; 
                }
            } else if (patients.length > 1) {
                // 동명이인 처리 로직 
                const inputOptions = {};
                patients.forEach(p => {
                	const name = p.patientName || "이름없음"; 
                    const regno = p.patientRegno1 || "******"; 
                    inputOptions[p.patientNo] = `${name} (${regno})`;
                });

                Swal.fire({
                	icon: 'info',
                	title: '동명이인이 존재합니다',
                    text: '입원 접수할 환자를 선택해주세요.',
                    input: 'select',
                    inputOptions: inputOptions,
                    inputPlaceholder: '환자 선택',
                    showCancelButton: true,
                    confirmButtonText: '확인',
                    cancelButtonText: '취소',
                    confirmButtonColor: '#7c3aed' 
                }).then((result) => {
                    if (result.value) {
                        const selected = patients.find(p => p.patientNo == result.value);
                        selectInpatient(selected);
                        if(dropdown) {
                            dropdown.classList.add('hidden');
                            dropdown.style.display = 'none';
                        }
                    }
                });
            }
        })
        .catch(err => console.error("입원 환자 검색 오류:", err));
};

//입원접수 환자 검색 상태값 체크
function selectInpatient(patient) {
	console.log("객체 전체:", patient);
	
	// 환자 상태값 체크
	const regVO = patient.registrationVO || {};
	const status = regVO.registrationStatus;
	
	console.log('체크할 환자 상태값:', status);
	
	// 상태별 분기 처리
	if(status == '005'){
		// 수납 완료인 경우만 데이터 바인딩
		proceedBinding(patient);
	}
	else if(['001', '002', '003'].includes(status)){
		Swal.fire('알림', '현재 진료 절차가 진행 중인 환자입니다. 진료 완료 및 수납 후 입원이 가능합니다.', 'info');
	}
	else if (status === '004') {
        Swal.fire('알림', '외래 수납이 대기 상태입니다. 수납 완료 후 다시 시도해주세요.', 'warning');
    } 
    else {
        // 데이터는 왔으나 001~005 외의 예외 상황
        Swal.fire('알림', '입원 가능한 외래 접수 내역을 찾을 수 없습니다.', 'error');
    }
	
}

// 입원 접수 검색 환자 정보 바인딩
function proceedBinding(patient){
	hideSearchDropdown('IN'); // 드롭다운 닫기
		
	const regVO = patient.registrationVO || {};	
	// '입원중'인지 판단
	window.selectedPatientStatus = regVO.registrationStatus;
    window.selectedPatientNo = patient.patientNo; 
    // 환자 이름 저장
    window.selectedPatientName = patient.patientName;
	
	// UI 바인딩
    document.getElementById('inPatientName').value = patient.patientNo + "." + patient.patientName;

    // 최근 진료 정보있으면 자동 입력
    if(regVO.employeeNo){     
        
        // 셀렉트 박스 진료실 번호 기준으로 담당의 자동 선택
        const inSelect = document.getElementById('inEmployeeChange');
        if(inSelect) {
        	setTimeout(() => {
                // value를 사번(String 또는 Number)으로 강제 매칭
                inSelect.value = String(regVO.employeeNo); 
                console.log("의사 자동 선택 완료:", regVO.employeeNo);
            }, 100);
        }
        
        // 히든 필드에 데이터 바인딩
		if(document.getElementById('inEmployeeNo')) document.getElementById('inEmployeeNo').value = regVO.employeeNo;
        if(document.getElementById('inLocationNo')) document.getElementById('inLocationNo').value = regVO.locationNo;
        window.selectedRegistrationNo = regVO.registrationNo;
    }
    
 	// 메모 바인딩
    if(patient.patientMemo) {
        document.getElementById('inMemo').value = patient.patientMemo;
    }
}

// 입원 접수
window.completeInpatientRegistration = function() {
	const submitBtn = document.getElementById('inpatientBtn');
	
	if (window.selectedPatientStatus === '입원중') {
	    Swal.fire('접수 불가', '해당 환자는 이미 입원 중입니다.', 'error');
	    return;
	}
	
	
 	// 필수 값 존재 여부 체크
    const inSelect = document.getElementById('inEmployeeChange');
    const employeeNo = inSelect.value;
    const patientNo = window.selectedPatientNo;
    const bedNo = window.selectedBedNo; 

    // 2. 필수값 누락 체크 (ADMISSION 테이블 NOT NULL 기준)
    if(!patientNo) {
        Swal.fire('알림', '입원할 환자를 먼저 선택해주세요.', 'warning');
        return;
    }
    if(!employeeNo || employeeNo === "") {
        Swal.fire('알림', '입원 주치의를 선택해주세요.', 'warning');
        return;
    }
    if(!bedNo) {
        Swal.fire('알림', '배정된 병상이 없습니다. 병동 현황 조회 후 배정해주세요.', 'warning');
        return;
    }
	
	console.log("체크 데이터 - 환자번호:", "선택된 이름:", window.selectedPatientName, window.selectedPatientNo, "사번:", "병상번호:", window.selectedBedNo);
	
    // AdmissionVO 구조에 맞춘 데이터 전송
    const sendData = {
		patientNo: parseInt(patientNo),
        patientName: window.selectedPatientName,
        registrationNo: parseInt(window.selectedRegistrationNo),
        employeeNo: parseInt(employeeNo),
        bedNo: parseInt(bedNo),
        admissionInsurance: document.getElementById('inInsurance').value,
        admissionVisittype: "002", // 입원
        admissionStatus: "001", // 입원중
        admissionMemo: document.getElementById('inMemo').value.trim()
    };
    
    console.log("최종 전송 데이터:", sendData);
    
    axios.post('/reception/insertAdmission', sendData)
        .then(res => {
        	console.log("서버 응답 데이터 확인:", res.data);
        	const result = res.data;
            if(result.status === "success") {
            	Swal.fire({
                    title: '입원 접수 및 차트 생성 완료',
                    html: `
                        <div style="text-align: left; padding: 10px; background: #f5f3ff; border-radius: 8px;">
                            <p><b>입원 차트번호:</b> <span style="color: #7c3aed; font-weight: bold;">${result.chartNo}</span></p>
                            <p><b>환자명:</b> ${result.patientName}</p>
                        </div>
                    `,
                    icon: 'success'
                }).then(() => {
					// 리로드 직전 현재 탭 ID 저장
					localStorage.setItem('activeTab', 'tab-inpatient');
					location.reload();
				});
            }
        })
        .catch(err => {
            // 네트워크 에러 등 발생 시 버튼 다시 활성화
            console.error("접수 오류:", err);
            submitBtn.disabled = false;
            submitBtn.innerText = originalText;
            Swal.fire('오류', '시스템 오류가 발생했습니다.', 'error');
        });
};

// 입원 접수 병동 현황 조회 모달
// 1. 전역 변수로 선택된 침상 정보 보관
window.selectedBedNo = null; 
let tempBedNo = null;
let tempBedDisplay = "";
let tempLocationNo = null;

// 2. 병상 상태 조회
function openWardModal() {
    
    axios.get('/reception/selectBedList') 
        .then(res => {
            const bedList = res.data; 
            
            // 모든 병상 버튼 초기화
            document.querySelectorAll('.bed-item').forEach(btn => {
                btn.classList.remove('occupied', 'selected');
                btn.classList.add('available');
                btn.querySelector('.bed-status').innerText = '배정가능';
                btn.disabled = false;
            });

            // DB 상태 반영
            bedList.forEach(bed => {
                // DB의 bedNo와 JSP의 data-bed-no 매칭
                const targetBtn = document.querySelector(`.bed-item[data-bed-no="${bed.bedNo}"]`);
                
                if (targetBtn && bed.bedStatus === '002') {
                    targetBtn.classList.remove('available');
                    targetBtn.classList.add('occupied'); 
                    targetBtn.querySelector('.bed-status').innerText = '사용중';
                    targetBtn.disabled = true; // '사용중'인 병상은 선택 불가
                }
            });

            // 데이터 반영 후 모달 열기
            openModal('modal-ward-status');
        })
        .catch(err => {
            console.error("병상 조회 실패:", err);
            Swal.fire('오류', '병상 정보를 불러오지 못했습니다.', 'error');
        });
}

// 3.병상 선택 처리
function selectBed(element) {
	
	// '사용중'인 병상은 클릭해도 아무 동작 안 함
    if(element.classList.contains('occupied')) return;
	// 모든 선택 해제
    document.querySelectorAll('.bed-item.available').forEach(el => el.classList.remove('selected'));
 	// 현재 클릭한 병상 선택
	element.classList.add('selected');
    
    // 데이터 추출
    tempBedNo = element.getAttribute('data-bed-no');
    tempLocationNo = element.getAttribute('data-location-no'); // 병실 번호를 장소 번호로 활용
    tempBedDisplay = element.getAttribute('data-display');
    
    const textEl = document.getElementById('tempSelectedBedText');
    if(textEl) textEl.innerText = tempBedDisplay;
}

// 4. 배정 확정 (메인 화면 반영)
function confirmBedAssignment() {
    if(!tempBedNo) {
        Swal.fire('알림', '배정할 병상을 선택해주세요.', 'warning');
        return;
    }
    
    // 메인 화면 전역 변수 및 UI 업데이트
    window.selectedBedNo = tempBedNo;
    window.selectedLocationNo = tempLocationNo; // 입원 접수 시 locationNo로 사용
    const infoSpan = document.getElementById('selectedBedInfo');
    if(infoSpan) {
        infoSpan.innerText = tempBedDisplay;
        infoSpan.classList.add('text-purple-800', 'font-bold');
    }
    
    closeModal('modal-ward-status');
    Swal.fire({
        icon: 'success',
        title: '병상 배정 완료',
        text: tempBedDisplay + '로 배정되었습니다.',
        timer: 1000,
        showConfirmButton: false
    });
}

// 제증명 선택한 환자 검색 정보 바인딩
function selectCertPatient(patient){
	// 드롭다운 닫기
	hideSearchDropdown('CERT');
	
	window.selectedCertPatientName = patient.patientName || patient.PATIENT_NAME;
	
	// 환자 번호 저장
	window.selectedCertPatientNo = patient.patientNo;
	console.log("제증명 발급 대상 선택 : ", patient.patientName);
	
	// 환자 정보 바인딩
	const infoArea = document.getElementById('certSelectedPatientInfo');
	const nameDisplay = document.getElementById('certPatientNameDisplay');
	const noDisplay = document.getElementById('certPatientNoDisplay');
	const certBillName = document.getElementById('certBillName');
	
	// 수납 내역 타이틀 환자 이름 바인딩
	if(certBillName){
		certBillName.innerText = patient.patientName || patient.PATIENT_NAME;
	}
	
	if(infoArea && nameDisplay && noDisplay){
		nameDisplay.innerText = patient.patientName;
		noDisplay.innerText = `(${patient.patientNo})`;
		infoArea.classList.remove('hidden'); // 정보 영역 표시
	}
	
	
	
	// 의사 작성 증명서 내역 로드
	if(typeof loadCertList === 'function'){
		loadCertList(patient.patientNo);
	}
}

// 제증명 환자 선택 취소
function resetCertSelection(){
	window.selectedCertPatientNo = null;
	window.selectedCertPatientName = null;
	window.selectedRegistrationNo = null;
	window.selectedAdmissionNo = null;
	
	// 좌측 환자 정보 및 검색창 초기화
	const infoArea = document.getElementById('certSelectedPatientInfo');
	if(infoArea) infoArea.classList.add('hidden');
	
	const searchInput = document.getElementById('certSearch');
	if(searchInput) searchInput.value = "";
	
	// 우측 수납 내역 타이틀 환자 이름 초기화
	const certBillName = document.getElementById('certBillName');
    if(certBillName) {
        certBillName.innerText = "환자"; 
    }
	
	// 증명서 목록 초기화
	document.getElementById('certDoctorListBody').innerHTML = `
		<tr>
			<td colspan="5" class="py-16 text-center text-slate-400">환자를 검색하면 작성된 문서가 표시됩니다.</td>
		</tr>`;
	
	// 체크 박스 해제하고 수납 내역 및 금액 초기화
	const masterCb = document.getElementById('certCheckAll');
	if(masterCb){
		masterCb.checked = false;
	}
	
	const checkboxes = document.querySelectorAll('input[name=certItem]');
	checkboxes.forEach(cb => {cb.checked = false;});
	
	// 제증명 수납 내역 함수 호출
	if(typeof updateCertBill === 'function'){
		updateCertBill();
	}
	
	if(searchInput) searchInput.focus();
}

// 증명서 내역 로드
let currentCertListData = []; // 필터링 시 사용

function loadCertList(patientNo){
	const listBody = document.getElementById('certDoctorListBody');
	
	axios.get('/reception/certificate/list', { params: {patientNo: patientNo}})
		.then(res => {
			// 필터링
			currentCertListData = res.data; 
			filterCertHistory('all'); // 필터링 : 초기값은 '전체'로 출력

		})
		.catch(err => {
			console.error("내역 로드 오류 : ", err);
			listBody.innerHTML = `
				<tr>
					<td colspan="5" class="py-16 text-center text-red-400">데이터 로드 중 오류가 발생했습니다.</td>
				</tr>`;
		});
}

// 제증명 내역 필터 버튼 클릭 시 호출되는 함수
function filterCertHistory(range) {
    // 버튼 스타일 변경 (선택된 버튼 강조)
    const buttons = ['today', 'week', 'all'];
    buttons.forEach(b => {
        const btn = document.getElementById(`btn-filter-${b}`);
        if(b === range) {
            btn.classList.add('bg-white', 'text-blue-600', 'shadow-sm');
            btn.classList.remove('text-slate-500');
        } else {
            btn.classList.remove('bg-white', 'text-blue-600', 'shadow-sm');
            btn.classList.add('text-slate-500');
        }
    });

    // 데이터 필터링 로직 실행
    applyCertFilter(range);
}

// 제증명 내역 필터 실행
function applyCertFilter(range) {
    if (!currentCertListData) return;

    const now = new Date();
    let filteredData = currentCertListData.filter(cert => {
        const certDate = new Date(cert.MEDICAL_CERTIFICATE_DATE);
        
        if (range === 'today') {
            return certDate.toDateString() === now.toDateString();
        } else if (range === 'week') {
            const weekAgo = new Date();
            weekAgo.setDate(now.getDate() - 7);
            return certDate >= weekAgo;
        }
        return true; // 'all'인 경우
    });

    renderCertTable(filteredData); // 필터링된 데이터로 테이블 그리기
}

// 제증명 필터 - 테이블 생성
function renderCertTable(data) {
    const listBody = document.getElementById('certDoctorListBody');
    
	// 중복 제거
	data = data.reduce((acc, current) => {
	    const existing = acc.find(item => item.CERTIFICATE_CODE === current.CERTIFICATE_CODE);
	    if (!existing) {
	        return acc.concat([current]);
	    } else {
	        // 더 높은 상태값(002 수납대기)을 가진 데이터를 우선 선택
	        return (current.MEDICAL_CERTIFICATE_STATUS > existing.MEDICAL_CERTIFICATE_STATUS) 
	               ? acc.map(item => item.CERTIFICATE_CODE === current.CERTIFICATE_CODE ? current : item) 
	               : acc;
	    }
	}, []);
	
	let html = "";

    // 데이터 없을 때 초기 문구 출력
    if(!data || data.length === 0){
		listBody.innerHTML = `
			<tr>
				<td colspan="5" class="py-16 text-center text-slate-400">작성된 증명서 내역이 없습니다.</td>
			</tr>`;
		return;
	}

    data.forEach(cert => {
		 
		// 데이터 키값
		const status = cert.MEDICAL_CERTIFICATE_STATUS; // 발급요청(001), 수납대기(002), 수납완료(003)
	    const date = cert.MEDICAL_CERTIFICATE_DATE;
	    const name = cert.CERTIFICATE_NAME;
	    const price = cert.CERTIFICATE_PRICE;
	    const printNo = cert.MEDICAL_CERTIFICATE_PRINT_NO;
		
		let statusName = "";
		let badgeClass = "";
		let isCheckable = false; // 체크박스 활성화 여부
		
		// 조회 버튼 활성화 : 발급요청(001)이 아닐 때
		const canView = (status === '002' || status === '003');
		
		// 결정된 상태값에 따른 분기 처리
		if(status === '001'){
			statusName = "발급요청";
			badgeClass = "badge-default"; // 회색
			isCheckable = false;
		}else if(status == '002'){
			statusName = "수납대기";
			badgeClass = "badge-info"; // 파란색
			isCheckable = true; // 수납 가능하므로 체크 허용
		}else if(status === '003'){
			statusName = "수납완료";
			badgeClass = "badge-success"; // 초록색
			isCheckable = false; // 중복 결제 방지
		}else{
			statusName = "기타";
			badgeClass = "badge-default";
		}
		
		html += `
			<tr class="hover:bg-slate-50/50 transition-colors border-b border-slate-50">
					<td class="py-3 px-2 text-center align-middle">
			            <input type="hidden" class="cert-type-code" value="${cert.CERTIFICATE_CODE}"> 
			            
			            <input type="checkbox" name="certItem" value="${printNo}" 
			                   data-price="${price}" data-name="${name}"
			                   class="accent-blue-600 cursor-pointer" 
			                   ${isCheckable ? '' : 'disabled'} onchange="updateCertBill()">
		        </td>
	            <td class="py-3 px-3 text-left font-medium text-slate-700 truncate align-middle">${name}</td>
	            <td class="py-3 px-3 text-center text-slate-500 align-middle">${date}</td>
	            <td class="py-3 px-3 text-center align-middle">
	                <span class="badge ${badgeClass} inline-block w-full text-center text-[11px] font-bold">${statusName}</span>
	            </td>
	            <td class="py-3 px-3 text-center align-middle">
	                <button type="button" onclick="viewCertPdf('${printNo}')" 
	                        class="flex items-center justify-center mx-auto p-2 rounded-lg transition-all ${canView ? 'text-blue-600 hover:bg-blue-50' : 'text-slate-300 cursor-not-allowed'}"
	                        ${canView ? '' : 'disabled'}>
	                    <i class="ri-search-2-line" style="font-size: 1.25rem; font-weight: bold; display: inline-block;"></i>
	                    조회
	                </button>
	            </td>
	        </tr>`;
    });
    listBody.innerHTML = html;
}

// 제증명 조회
function viewCertPdf(printNo){
	if(!printNo) return;
	
	const url = "/reception/certificate/viewCertificate?printNo=" + printNo;
	
	// 증명서 전용 팝업 창 옵션
	const width = 900;
	const height = 800;
	const left = (window.screen.width / 2) - (width / 2);
	const top = (window.screen.height / 2) - (height / 2);
	
	// 독립정인 뷰어 창 생성
	window.open(url, 'CertViewer_' + printNo,
		`width=${width},height=${height},left=${left},top=${top},scrollbars=yes,resizable=yes`);
	
}

// 제증명 전체 선택/해제
window.toggleCertAll = function(masterCheckbox){
	// 비활성화되지 않은 것들만 선택
	const checkboxes = document.querySelectorAll('input[name=certItem]:not(:disabled)');
	
	checkboxes.forEach(cb => {
		cb.checked = masterCheckbox.checked;
	});
	
	// 우측 결제 내역 업데이트 함수 호출
	if(typeof updateCertBill === 'function'){
		updateCertBill();
	}
};

// 제증명 발급 요청
window.requestCertToDoctor = function(btn) {

    const certType = document.getElementById('certTypeRequest').value;
    const patientNo = window.selectedCertPatientNo; 
	const patientName = window.selectedCertPatientName || patientNo; // 환자명 변수 (없으면 번호로 표시)

	// 긴급 여부
	const urgentCheck = document.getElementById('certUrgentCheck');
	const isUrgent = document.getElementById('certUrgentCheck').checked ? 'Y' : 'N';
	
	// 코드에 따른 증명서 한글 매핑
	const certTitleMap = {
		'DIAG': '진단서 발급 요청',
		'OPIN': '소견서 발급 요청'
	};
	const alertTitle = certTitleMap[certType] || '제증명 발급 요청';
	
    // 모든 조건 만족 시 버튼 비활성화
    if(btn) btn.disabled = true;
	
    // 서버로 발급 요청 데이터 전송 (발급상태를 발급요청(001)으로 저장)
    axios.post('/reception/certificate/request', {
        patientNo: patientNo,
        certificateType: certType // 'DIAG' 또는 'OPIN'
    }).then(res => {
		// 서버에서 응답받은 실제 담당의 사번
		const doctorEmpNo = res.data.doctorEmpNo;
		
		if(doctorEmpNo){
			sendNewNotification(
				doctorEmpNo,		// 서버에서 받은 실제 담당의 사번
				alertTitle,			// 제목(제증명 타입)
				`${patientName}(${patientNo})님의 증명서 발급 요청이 접수되었습니다.`,	// 내용
				'001',				// 구분 코드
				'/certificate/main',	// 이동 경로
				isUrgent			// 긴급 여부
			);
		}
		
		urgentCheck.checked = false; // 완료 후 토글 스위치 초기화
        Swal.fire('성공', '의사에게 발급 요청이 전송되었습니다.', 'success');
        loadCertList(patientNo); // 리스트 새로고침
    }).catch(err => {
		console.error("발급 요청 실패 :", err);
	})
	.finally(() => {
    	if(btn) btn.disabled = false; // 완료 후 버튼 다시 활성
    });
}

// 제증명 발급 요청 전 중복 체크
function requestCertificate(btn) {
    const certType = document.getElementById('certTypeRequest').value; // 진단서(DIAG) 또는 소견서(OPIN)
    const patientNo = window.selectedCertPatientNo;

 	// 환자 선택 여부
    if (!patientNo) {
        Swal.fire('알림', '환자를 먼저 선택해주세요.', 'warning');
        return;
    }
    // 증명서 선택 여부
    if (!certType) {
        Swal.fire('알림', '발급할 증명서 종류를 선택해주세요.', 'warning');
        return;
    }
    
    // 중복 발급 방지 로직
    // 현재 리스트에 선택한 증명서 종류가 이미 있는지 확인
    const rows = document.querySelectorAll('#certDoctorListBody tr');
    let isAlreadyRequested = false;
    
    rows.forEach(row => {
    	const rowTypeInput = row.querySelector('.cert-type-code');
    	if(rowTypeInput && rowTypeInput.value === certType){
    		isAlreadyRequested = true;
    	}
    });

    if(isAlreadyRequested) {
        Swal.fire('알림', '해당 차트에 이미 동일한 증명서가 존재합니다.', 'warning');
        return;
    }

    // 중복이 없을 때만 인서트 실행
    requestCertToDoctor(btn);
}

// 제증명 수납 내역
function updateCertBill() {
    const billItems = document.getElementById('cert-bill-items');
    const totalAmountDisplay = document.getElementById('cert-total-amount');
	
	// '전체 선택' 체크박스 동기화
	const allEnabled = document.querySelectorAll('input[name=certItem]:not(:disabled)');
	const allChecked = document.querySelectorAll('input[name=certItem]:checked');
	const masterCb = document.getElementById('certCheckAll');
    
    let html = "";
    let total = 0;
	
    if (allChecked.length === 0) {
        billItems.innerHTML = '<tr><td colspan="2" class="py-4 text-center text-slate-400">문서를 선택해주세요.</td></tr>';
        totalAmountDisplay.innerText = "0 원";
		
		// 전체 선택 체크박스 해제
		if(masterCb) masterCb.checked = false;
        return;
    }

    allChecked.forEach(cb => {
        const name = cb.getAttribute('data-name');
        const price = parseInt(cb.getAttribute('data-price') || 0);
        
        total += price;
        html += `
            <tr class="hover:bg-slate-50/50">
                <td class="py-3 px-4 text-sm text-slate-700">${name}</td>
                <td class="text-right py-3 px-4 font-medium text-slate-900">${price.toLocaleString()}원</td>
            </tr>`;
    });

	const finalTotal = Math.floor(total / 10) * 10; // 10원 미만 절삭 허용
    billItems.innerHTML = html;
    //totalAmountDisplay.innerText = `${total.toLocaleString()} 원`;
	totalAmountDisplay.innerText = `${finalTotal.toLocaleString()} 원`;
	window.currentCertTotalAmount = finalTotal; // 절삭된 최종 금액 저장
	
	// 전체 선택 체크박스 동기화
	if(masterCb && allEnabled.length > 0){
		masterCb.checked = (allEnabled.length === allChecked.length);
	}
}

// 제증명 전용 결제 
function completeCertPayment(method){
	// 선택된 체크박스들 가져오기
	const selectedCerts = document.querySelectorAll('input[name="certItem"]:checked');
	const patientNo = window.selectedCertPatientNo;
	
	if(!patientNo || selectedCerts.length === 0){
		Swal.fire('알림', '결제할 증명서 항목을 선택해주세요.', 'warning');
		return;
	}
	
	// 총 금액 및 항목명 계산
	let totalAmount = 0;
	let certNames = [];
	let printNos = [];
	
	selectedCerts.forEach(cb => {
        totalAmount += parseInt(cb.getAttribute('data-price') || 0);
        certNames.push(cb.getAttribute('data-name'));
        printNos.push(cb.value); // MEDICAL_CERTIFICATE_PRINT_NO
    });

    const itemName = certNames.length > 1 
        ? `${certNames[0]} 외 ${certNames.length - 1}건` 
        : certNames[0];

    if (method === 'CARD') {
        // 카카오페이 데이터 
        const payData = {
              patientNo: patientNo
            , paymentAmount: totalAmount
            , itemName: "[제증명] " + itemName
            , certPrintNoList: printNos // 서버에서 처리할 발급번호 리스트(key값)
            , type: 'CERT' // 제증명 구분자
        };

        // 기존 카카오페이 준비 API 호출
        axios.post('/payment/kakaoPayReady', payData)
            .then(res => {
                const pcUrl = res.data.next_redirect_pc_url || res.data.NEXT_REDIRECT_PC_URL;
                if (pcUrl) {
                    window.open(pcUrl, 'kakaoPayAccept', 'width=500,height=600');
                }
            })
            .catch(err => {
                Swal.fire('오류', '결제 연결에 실패했습니다.', 'error');
            });
    } else {
        // 현금 결제 로직 
	    window.currentCertTotalAmount = totalAmount; 
	    // 외래/입원 변수 초기화
	    window.selectedRegistrationNo = null;
	    window.selectedAdmissionNo = null;
        
    	executeFinalPayment(null); 
        
    }
}

//[외래/입원 공통] 수납 대기 환자 검색
window.executeSettlementSearch = function(searchValue, type){
	
	const keyword = searchValue ? searchValue.trim() : "";
	
	// 외래(OUT), 입원(IN)인지에 따라 필터링 대상 데이터 선택
	const isOutpatient = (type === 'OUT');
	// 외래는 isOutpatient, 입원은 allInpatientWaitingData
	const targetData = isOutpatient ? allSettlementData : allInpatientWaitingData;
	
	//키워드 없으면 전체 수납 대기 목록 출력
	if(!keyword){
		isOutpatient ? renderSettlementWaitingList(allSettlementData) : renderInpatientSettlementList(allInpatientWaitingData);
		return;
	}
	
	// 필터링
	const filtered = targetData.filter(p => {
		const pName = p.patient_name || p.PATIENT_NAME;
        const pNo = String(p.patient_no || p.PATIENT_NO);
        const matches = pName.includes(keyword) || pNo.includes(keyword);
        
        if(isOutpatient){
        	// 외래는 '수납대기(004)' 상태만 검색
        	const status = p.registration_status || p.REGISTRATION_STATUS;
            return status === '004' && matches;
        }else{
        	// 입원은 '퇴원대기(002)', '퇴원수납대기(003)' 상태 검색
        	const status = p.admission_status || p.ADMISSION_STATUS;
            return (status === '002' || status === '003') && matches;
        }
    });
		
	// 화면 렌더링 함수 호출
	if(isOutpatient){
		renderSettlementWaitingList(filtered);
	}else{
		renderInpatientSettlementList(filtered);
	}
};

// 외래 수납 대기 목록
function renderSettlementWaitingList(data){
	
	const settlementBody = document.getElementById('outpatient-waiting-list');
	if(!settlementBody) return;
	
	// '수납대기'인 환자 필터링
	const toSettle = data.filter(patient => {
		const status = patient.registration_status || patient.REGISTRATION_STATUS;
		return status == '004'; // 수납 대기
	});
	
	let html = "";
	if(toSettle.length === 0){
		settlementBody.innerHTML = '<div class="p-4 text-center text-slate-400 text-xs">수납 대상자가 없습니다.</div>';
		return;
	}
	
	toSettle.forEach(patient => {
		const pName = patient.patient_name || patient.PATIENT_NAME;
        const pNo = patient.patient_no || patient.PATIENT_NO;
        const regNo = patient.registration_no || patient.REGISTRATION_NO;
        const locName = patient.location_no || patient.LOCATION_NO || '진료실 미지정';
        const docName = patient.employee_name || patient.EMPLOYEE_NAME || '담당의 미지정';
        html += `
            <div onclick="loadOutpatientBill('${pName}', '${pNo}', ${regNo})" 
                 class="flex items-center justify-between p-4 bg-white border border-slate-200 rounded-lg shadow-sm cursor-pointer hover:border-emerald-500 transition-all group">
                <div class="flex items-center gap-3">
                    <div class="w-1 h-8 bg-emerald-500 rounded-full opacity-0 group-hover:opacity-100 transition-opacity"></div>
                    <div>
                        <p class="text-sm font-bold text-slate-800">${pName} (${pNo})</p>
                        <p class="text-[11px] text-slate-500 mt-0.5">
                            ${locName} | 담당의: ${docName}
                        </p>
                    </div>
                </div>
            </div>`;
	});
	settlementBody.innerHTML = html;
}

// 외래 수납 대기 환자 클릭 시 상세 내역 출력
window.loadOutpatientBill = function(name, patientNo, regNo){
	document.getElementById('outpatient-bill-target-name').innerText = name;
	document.getElementById('outpatient-bill-target-no').innerText = patientNo;
	window.selectedRegistrationNo = regNo;	// 결제 시 사용
	window.currentSettlementPatientNo = patientNo;
	
	console.log("전달된 접수번호:", regNo);
	
	// 상세 내역 가져오기
	axios.get('/payment/getPrescriptionDetails', {params: {registrationNo:regNo}})
		.then(res => {
			console.log("서버에서 온 데이터 확인:", res.data);
			let details = res.data;
			
			// 데이터가 배열인지 강제로 확인하고, 아니면 배열로 감싸줌
			if (!Array.isArray(details)) {
                details = details ? [details] : [];
            }
			
			let html = "";
			let total = 0;
			details.forEach(item => {
				// 대문자나 소문자 중 있는 값을 가져오도록 처리
				const category = item.CATEGORY || item.category || '-';
				const name = item.item_name || item.ITEM_NAME || 
                 item.EXAMINATION_NAME || item.TREATMENT_NAME || '항목명 없음';
				const price = parseInt(item.item_price || item.ITEM_PRICE || 
                        item.EXAMINATION_PRICE || item.TREATMENT_PRICE || 0);
	            
	            total += price;
				html += `
                    <tr class="hover:bg-slate-50/50">
                        <td class="py-3 px-4 text-sm text-slate-700">${name}</td>
                        <td class="text-right py-3 px-4 font-medium text-slate-900">${price.toLocaleString()}</td>
                    </tr>`;
			});
			
			//window.currentTotalAmount = total;
			window.currentTotalAmount = Math.floor(total / 10) * 10; // 10원 미만 절삭 적용
			document.getElementById('outpatient-bill-items').innerHTML = html;
			//document.getElementById('outpatient-total-price').innerText = total.toLocaleString() + "원";
			document.getElementById('outpatient-total-price').innerText = window.currentTotalAmount.toLocaleString() + "원";
		});
}

// [외래/입원/제증명 공통] 결제 알림창
window.completePayment = function(method){
	// 제증명 탭에서 선택된 항목이 있는지 확인
    const selectedCerts = document.querySelectorAll('input[name="certItem"]:checked');
    const isCertificate = selectedCerts.length > 0;

    // 선택된 환자 확인
    if(!isCertificate && !window.selectedRegistrationNo && !window.selectedAdmissionNo){
        Swal.fire({
            icon: 'warning',
            title: '알림',
            text: '수납하실 환자를 먼저 선택해주세요.',
            confirmButtonColor: '#10b981'
        });
        return;
    }
	
	// 외래 여부
	const isOutpatient = !!window.selectedRegistrationNo;
	
	// 중복 결제 방지 체크
	//외래는 이미 수납완료(005)인지 확인
	if(isOutpatient && window.currentRegistrationStatus === '005') {
        Swal.fire('알림', '이미 수납이 완료된 외래 건입니다.', 'info');
        return;
    }
    
	//입원은 이미 퇴원(004)인지 확인
    if(!isOutpatient && window.currentAdmissionStatus === '004') {
        Swal.fire('알림', '이미 퇴원 수납이 완료된 입원 건입니다.', 'info');
        return;
    }
	
	if(method === 'CARD'){
		// 카드 결제
		const payData = {
			patientNo: window.currentSettlementPatientNo || window.selectedCertPatientNo,
            paymentAmount: window.currentTotalAmount || window.currentCertTotalAmount,
            itemName: isCertificate ? "[제증명] " + (document.getElementById('certBillName')?.innerText || "증명서") : 
                     (isOutpatient ? "외래 진료비 수납" : "입원 진료비 수납")
		};
		
		if(isOutpatient) payData.registrationNo = window.selectedRegistrationNo;
		else if(!isCertificate) payData.admissionNo = window.selectedAdmissionNo;
		
		if(isCertificate) {
            payData.certPrintNoList = Array.from(selectedCerts).map(cb => cb.value);
            payData.type = 'CERT';
        }
		
		// 카카오 결제 준비 요청
		axios.post('/payment/kakaoPayReady', payData)
			.then(res => {
						
				
				// 서비스에서 보낸 already_paid 상태값 확인 - 중복 결제 방지
		        if(res.data.status === 'already_paid') {
		            Swal.fire({
		                icon: 'error',
		                title: '결제 불가',
		                text: '이미 수납이 완료된 건입니다.',
		                confirmButtonColor: '#ef4444'
		            });
		            return;
		        }
				
				let data = res.data;
				let pcUrl = data.next_redirect_pc_url || data.NEXT_REDIRECT_PC_URL;
				console.log("원본 URL:", pcUrl);
				
				if (pcUrl) {
					
					// /info를 포함한 이후 모든 경로와 파라미터 제거
					pcUrl = pcUrl.replace(/\/info.*$/, "");
					
		            window.open(pcUrl, 'kakaoPayAccept', 'width=500,height=600');
		        } else {
		            Swal.fire('오류', '결제 페이지 URL을 받지 못했습니다.', 'error');
		        }
			})
			.catch(err => {
				console.log("카카오 결제 준비 에러:", err);
				Swal.fire('오류', '카카오 결제 연결에 실패했습니다.', 'error');
			});
	}else{
		// 현금 결제
		executeFinalPayment(null); 
	}
	
};


// [외래/입원/제증명 공통] 수납 완료 처리(db 저장)
function executeFinalPayment(tid = null){
	
	const isOutpatient = !!window.selectedRegistrationNo; // 외래 여부 판별
	const isInpatient = !!window.selectedAdmissionNo; // 입원 여부 판별
	// 제증명 여부 판별
	const selectedCerts = document.querySelectorAll('input[name="certItem"]:checked');
    const isCertificate = selectedCerts.length > 0 && !isOutpatient && !isInpatient;
	
	
	if(isOutpatient){
		// 외래 수납 처리
		const sendData = {
			registrationNo: window.selectedRegistrationNo,	// 외래 접수 번호
			patientNo: window.currentSettlementPatientNo,	// 환자 번호
			registrationStatus: "005", 					    // 수납 완료 상태 코드로 변경
			paymentAmount: window.currentTotalAmount,	    // 총 결제 금액
			resUid: tid	// 카카오 결제 거래 고유 번호(현금일땐 null)
		};
		axios.post('/payment/updateRegistrationStatus', sendData)
			.then(res => {
				handlePaymentSuccess("외래");
			})
			.catch(err => {
				console.error("외래 결제 오류:", err);
				Swal.fire('오류', '외래 수납 처리 중 문제가 발생했습니다.', 'error');
			});
	}else if(isInpatient){
		// 입원 수납 처리
		const sendData = {
			admissionNo: window.selectedAdmissionNo,
			patientNo: window.currentSettlementPatientNo,
			admissionStatus: "004", // 퇴원
			bedNo: window.selectedBedNo, // 침상 상태 변경(사용가능(001))
			paymentAmount: window.currentTotalAmount,
			resUid: tid
		};
		axios.post('/payment/updateAdmissionStatus', sendData)
			.then(res => {
				handlePaymentSuccess("입원");
			})
			.catch(err => {
				console.error("입원 결제 오류:", err);
				Swal.fire('오류', '입원 수납 처리 중 문제가 발생했습니다.', 'error');
			});
		
	}else if(isCertificate){
		let printNos = Array.from(selectedCerts).map(cb => cb.value);
		
		const sendData = {
			patientNo: window.selectedCertPatientNo,
            certPrintNoList: printNos,
            paymentAmount: window.currentCertTotalAmount, // 합계 계산값
            registrationStatus: "003", //  수납완료(003) 
            resUid: tid, // 현금이면 null, 카드면 tid
            type: 'CERT'
		};
		axios.post('/payment/updateCertificateStatus', sendData) 
        .then(res => {
        	// 출력 여부 알림창
        	Swal.fire({
                icon: 'success',
                title: '결제 완료',
                text: '제증명 수납이 완료되었습니다. 지금 증명서를 출력하시겠습니까?',
                showCancelButton: true,
                confirmButtonColor: '#10b981',
                cancelButtonColor: '#64748b',
                confirmButtonText: '즉시 출력',
                cancelButtonText: '목록으로'
            }).then((result) => {
                if (result.isConfirmed) {
                    // 제증명 팝업 함수 호출 : 첫 번째 증명서 한 장만 팝업으로 띄움
                	viewCertPdf(printNos[0]);
                }
             	// 제증명 목록만 다시 로드하여 탭 유지
                loadCertList(window.selectedCertPatientNo); 
                
             	// 체크박스 전체 해제 
                const checkboxes = document.querySelectorAll('input[name="certItem"]');
                checkboxes.forEach(cb => {
                    cb.checked = false;
                });
             	
                // 결제 영역(오른쪽) 초기화
                updateCertBill();
            });
        })
        .catch(err => {
            Swal.fire('오류', '제증명 수납 처리 중 문제가 발생했습니다.', 'error');
        });
		
	}
	
}

// [외래/입원 공통] 결제 성공 처리
function handlePaymentSuccess(type){
	// 접수유형 : 외래(001), 입원(002)
	const typeName = (type === "002") ? "입원" : "외래";
	
	Swal.fire({
		icon: 'success',
		title: '결제 완료',
		text: `${typeName} 수납 처리가 정상적으로 완료되었습니다.`,
		confirmButtonColor: '#10b981'
	})
	.then(() => {
		// 입원 접수유형 코드 입원(002)인 경우에만 탭 유지 정보를 저장 
        if (type === "002") {
            localStorage.setItem('activeTab', 'tab-inpatient');
        }
		
		location.reload(); // 데이터 갱신을 위한 페이지 새로고침
	});
}

//[외래/입원 공통] 수납 대기 환자 클릭 시 상세 내역 출력
let allSettlementData = []; 	   // 외래 수납 대기 환자 목록
let allInpatientWaitingData = []; // 입원 수납 대기 환자 보관용

// [외래/입원 공통] 수납 대기 명단 로드
function loadInpatientWaitingList(){
	
	axios.get('/payment/allWaitingList')
		.then(res => {
			// 외래 수납 데이터 할당 및 화면 출력
            allSettlementData = res.data.outpatient; 
            renderSettlementWaitingList(allSettlementData);
            
            // 입원 수납 데이터 할당 및 화면 출력
            allInpatientWaitingData = res.data.inpatient;
            renderInpatientSettlementList(allInpatientWaitingData);
        })
        .catch(err => console.error("수납 목록 로드 실패:", err));
}

// 입원 수납 대기 명단 출력
function renderInpatientSettlementList(data){
	const listBody = document.getElementById('inpatient-waiting-list');
	let html = "";
	
	if(!data || data.length === 0){
		listBody.innerHTML = '<div class="p-4 text-center text-slate-400 text-xs">수납 대상자가 없습니다.</div>';
        return;
	}
	
	data.forEach(p => {
		const pName = p.patient_name || p.PATIENT_NAME;
        const pNo = p.patient_no || p.PATIENT_NO;
        const admNo = p.admission_no || p.ADMISSION_NO;
        const status = p.admission_status || p.ADMISSION_STATUS;
        const bedNo = p.bed_no || p.BED_NO;
        const roomGrade = p.room_grade || p.ROOM_GRADE || '미정';
        const stayDays = p.stayDays || p.STAYDAYS || 0;
		// 상태값에 따른 뱃지 처리
		const statusText = p.admissionStatus === '002' ? '퇴원대기' : '수납대기';
		const badgeClass = p.admissionStatus === '002' ? 'tag-info' : 'tag-warning';
		
		html += `
            <div onclick="loadInpatientBill('${pName}', '${pNo}', ${admNo}, ${stayDays}, ${bedNo})" 
                 class="flex items-center justify-between p-4 bg-white border-2 border-amber-400 rounded-lg shadow-sm cursor-pointer hover:bg-amber-50 transition-all group relative">
                <span class="absolute -left-1 top-1/2 -translate-y-1/2 w-1 h-10 bg-amber-500 rounded-r-full"></span>
                <div class="flex items-center gap-3">
                    <div>
                        <p class="text-sm font-bold text-slate-800">${pName} (${pNo})</p>
                        <p class="text-[11px] text-slate-500 mt-1">병실: ${roomGrade} / ${stayDays}일 입원</p>
                    </div>
                </div>
                <div class="text-right">
                    <span class="tag ${badgeClass} text-[10px]">${statusText}</span>
                </div>
            </div>`;
	});
	listBody.innerHTML = html;
}

//입원 상세 정산 내역 조회
window.loadInpatientBill = function(name, patientNo, admissionNo, stayDays, bedNo) {
    document.getElementById('inpatient-bill-name').innerText = name;
    
 	// stayDays가 0이면 1로 표시, 그 외엔 원래 값 표시(최소 입원 일수를 1일로 보장)
    const displayDays = stayDays == 0 ? 1 : stayDays;
    document.getElementById('inpatient-stay-days').innerText = `입원일수: ${displayDays}일`;
    
    window.selectedAdmissionNo = admissionNo; // 결제 시 사용
    window.currentSettlementPatientNo = patientNo;
    window.selectedBedNo = bedNo;
    window.selectedRegistrationNo = null; // 외래 정보 초기화

    // 입원 처방 내역 조회
    axios.get('/payment/getInpatientPrescriptionDetails', { params: { admissionNo: admissionNo } })
        .then(res => {
            let details = res.data;
            let html = "";
            let total = 0;

            details.forEach(item => {
            	const name = item.NAME || item.name || '항목명 없음';
            	const price = parseInt(item.PRICE || item.price || 0);
                total += price;
                html += `
                    <tr class="hover:bg-slate-50/50">
                        <td class="py-3 px-4">${item.NAME}</td>
                        <td class="text-right py-3 px-4 font-bold">${price.toLocaleString()}</td>
                    </tr>`;
            });
            
            //window.currentTotalAmount = total;
            window.currentTotalAmount = Math.floor(total / 10) * 10; // 10원 미만 절삭 적용
            document.getElementById('inpatient-bill-items').innerHTML = html;
            //document.getElementById('inpatient-total-amount').innerText = total.toLocaleString() + " 원";
            document.getElementById('inpatient-total-amount').innerText = window.currentTotalAmount.toLocaleString() + " 원";
        });
}

// 클릭 이벤트
document.addEventListener('click', function(e){
	// [외래접수/입원접수/제증명 공통]검색 드롭다운 - 클릭된 요소가 검색 영역이 아니면 닫기
	if(!e.target.closest('.relative')){
		hideSearchDropdown('OUT');
		hideSearchDropdown('IN');
		hideSearchDropdown('CERT');
	}
});

//페이지 로드 시 자동으로 불러오도록 설정
document.addEventListener('DOMContentLoaded', function() {
	// 완료 후 탭 유지
	initTab();
	
	 // [신규/외래/입원 공통] 접수 의사 목록 select 박스에 바인딩
    loadDoctorList();
	// 접수 환자 대기 리스트
    loadWaitingList();
	// 외래/입원 수납 환자 대기 리스트
    loadInpatientWaitingList();
	
	// 신규 등록 환자 유효성 검사
    // 성명 
    const nameInput = document.getElementById('patientName');
    if(nameInput) {
        const nameRegex = /^[가-힣]{2,5}$|^[a-zA-Z]{2,20}$/;
        
     	// input과 keyup을 동시에 사용하여 실시간 반응성 극대화
        ['input', 'compositionend', 'compositionupdate'].forEach(eventName => {
            nameInput.addEventListener(eventName, function() {
            	// 브라우저가 값을 확정한 직후에 실행되도록 0초 지연
                setTimeout(() => {
                    validateField('patientName', nameRegex, 'err-patientName');
                }, 0);
            });
        });
    }

    // 연락처 
    const telInput = document.getElementById('patientTel');
    if(telInput) {
        telInput.addEventListener('input', function() {
            const telRegex = /^01[0-9]-\d{3,4}-\d{4}$/;
            validateField('patientTel', telRegex, 'err-patientTel');
        });
    }

    // 주민번호
    ['patientRegno1', 'patientRegno2'].forEach(id => {
        const input = document.getElementById(id);
        if(input) {
            input.addEventListener('input', function() {
                const r1Regex = /^\d{6}$/;
                const r2Regex = /^\d{7}$/;
                const isR1 = validateField('patientRegno1', r1Regex, 'err-patientRegno');
                const isR2 = validateField('patientRegno2', r2Regex, 'err-patientRegno');
                
                const errSpan = document.getElementById('err-patientRegno');
                if(!isR1 || !isR2) {
                    errSpan.style.display = 'block';
                } else {
                    errSpan.style.display = 'none';
					
					// 자릿수가 모두 정상이면 00년생 이후 세대 체크 로직 추가
	                const r1Value = document.getElementById('patientRegno1').value;
	                const r2Value = document.getElementById('patientRegno2').value;
					const selectedGen = document.getElementById('patientGen').value; // 성별 값 가져오기
	                
	                const birthYearPrefix = parseInt(r1Value.substring(0, 2)); // 앞 2자리 (예: 00)
	                const genderDigit = r2Value.substring(0, 1); // 뒷자리 첫 숫자 (예: 1)

					let isInvalid = false;
	                let errorText = "";
					
					// 2000년대생(00~26)인데 뒷자리가 1 또는 2인 경우
	                if (birthYearPrefix <= 26 && (genderDigit === '1' || genderDigit === '2')) {
	                    isInvalid = true;
	                    errorText = '2000년 이후 출생자는 뒷자리가 3 또는 4로 시작해야 합니다.';
	                } 
	                // 1900년대생(27~99)인데 뒷자리가 3 또는 4인 경우
	                else if (birthYearPrefix > 26 && (genderDigit === '3' || genderDigit === '4')) {
	                    isInvalid = true;
	                    errorText = '1900년대 출생자는 뒷자리가 1 또는 2로 시작해야 합니다.';
	                }

					// 선택한 성별과 뒷자리 첫 글자 일치 여부 검증 
	                if (!isInvalid && selectedGen !== "") {
	                    // 남성(MALE)인데 짝수(2, 4)인 경우
	                    if (selectedGen === 'MALE' && (genderDigit === '2' || genderDigit === '4')) {
	                        isInvalid = true;
	                        errorText = '선택한 성별(남성)과 주민번호 뒷자리가 일치하지 않습니다.';
	                    }
	                    // 여성(FEMALE)인데 홀수(1, 3)인 경우
	                    else if (selectedGen === 'FEMALE' && (genderDigit === '1' || genderDigit === '3')) {
	                        isInvalid = true;
	                        errorText = '선택한 성별(여성)과 주민번호 뒷자리가 일치하지 않습니다.';
	                    }
	                }
					
	                if (isInvalid) {
	                    Swal.fire({
	                        title: '입력 정보 불일치',
	                        text: errorText + ' 다시 입력해주세요.',
	                        icon: 'warning',
	                        confirmButtonColor: '#ef4444',
	                        confirmButtonText: '다시 입력'
	                    }).then((result) => {
	                        const r2Input = document.getElementById('patientRegno2');
	                        r2Input.value = ""; 
	                        r2Input.focus(); 
	                        errSpan.style.display = 'block'; 
	                    });
	                }
	            }
            });
        }
    });
    
 	// 상세 주소 
    const addr2Input = document.getElementById('patientAddr2');
    if(addr2Input) {
        addr2Input.addEventListener('input', function() {
            // 정규식: 한글, 영문, 숫자, 공백 허용 (2~20자)
            const addr2Regex = /^[가-힣a-zA-Z0-9\s]{2,20}$/;
            validateField('patientAddr2', addr2Regex, 'err-patientAddr2');
        });
    }
 
});