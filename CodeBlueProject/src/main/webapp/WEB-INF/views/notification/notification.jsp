<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<button class="header-icon-btn" aria-label="알림" data-dropdown="alarmDropdown">
    <i class="icon icon-bell icon-lg"></i>
    <span id="alarmDot" class="notification-dot hidden"></span>
</button>

<div class="dropdown-menu w-[480px]" id="alarmDropdown">
    <div class="dropdown-header flex justify-between items-center">
        <span>알림</span>
        <div class="flex items-center gap-md">
            <span id="alarmTotalCount" class="badge badge-primary">0</span>
            <button type="button" class="text-sm text-blue font-semibold" onclick="alarmReadAll()">모두 확인</button>
        </div>
    </div>
    
    <div id="alarmList" class="max-h-[400px] overflow-y-auto">
	    <div id="alarmEmpty" class="empty-state-sm hidden">
	        <p class="empty-state-title">새로운 알림이 없습니다.</p>
	    </div>
	</div>

    <!-- <div class="dropdown-footer">
        <a href="javascript:void(0);" class="dropdown-footer-link">모든 알림 보기</a>
    </div> -->
</div>

<script>

// 알림 목록 조회
function alarmLoadList() {
	console.log("알림 로드 시작");
    axios.get('/notification/list')
        .then(function(response) {
            const alarmDataList = response.data;
            const alarmEmpty = document.getElementById('alarmEmpty');
            const alarmList = document.getElementById('alarmList');

            // 기존 리스트 초기화
            const existingItems = alarmList.querySelectorAll('.dropdown-notification');
            existingItems.forEach(item => item.remove());
            
            if (!alarmDataList || alarmDataList.length === 0) {
                alarmEmpty.classList.remove('hidden');
                alarmUpdateCountUI(0, true); // 개수 0으로 초기화
            } else {
                alarmEmpty.classList.add('hidden');
                alarmDataList.forEach(function(alarm) {
                    alarmRenderItem(alarm); // 항목 생성
                });
                alarmUpdateCountUI(alarmDataList.length, true);
            }
        })
        .catch(function(error) {
            console.error("알림 로드 실패:", error);
        });
}

// 알림 항목 동적 생성
function alarmRenderItem(alarm) {
    const alarmList = document.getElementById('alarmList');
    
    // 긴급 여부
    const isUrgent = alarm.alertUrgent === 'Y';
    const urgentClass = alarm.alertUrgent === 'Y' ? 'text-danger font-bold' : '';
    
    // 알림 타입별 아이콘 매핑 
    const alarmIconMap = {
    		'001': 'icon-clipboard',       // 접수
    	    '002': 'icon-doctor',          // 치료
    	    '003': 'icon-doctor-bag',      // 검사
    	    '004': 'icon-drug',            // 약(주사)
    	    '005': 'icon-users',           // 협진
    	    '006': 'icon-package'         // 물품
    };

    // 매핑된 아이콘이 없으면 기본 '종' 아이콘 사용
    const iconClass = isUrgent ? 'icon-megaphone' : (alarmIconMap[alarm.alertType] || 'icon-bell');
    
 	// 날짜가 null로 올 경우 대비해 현재 시간을 기본값으로 사용
    const displayDate = alarm.alertDate || new Date().toLocaleString(); 
    // 번호가 0으로 올 경우 임시 ID를 부여
    const displayNo = alarm.alertNo || 0;
    const displayName = alarm.alertName || '알림'; 
    const displayUrl = alarm.alertUrl || '#';
    
    const alarmHtml = `
        <div class="dropdown-notification \${alarm.alertReadYn === 'N' ? 'dropdown-notification-unread' : ''}" 
             data-no="\${alarm.alertNo}" 
             onclick="if('\${alarm.alertUrl}' !== '#') location.href='\${alarm.alertUrl}'" 
             style="cursor:pointer;"> <div class="dropdown-notification-icon">
                <i class="icon icon-lg \${iconClass} \${urgentClass}"></i> </div>
            <div class="dropdown-notification-content">
                <div class="dropdown-notification-title \${urgentClass}">\${isUrgent ? '[긴급] ' : ''}\${alarm.alertName}</div> 
                <div class="dropdown-notification-text \${urgentClass}">\${alarm.alertContent}</div> 
                <div class="dropdown-notification-time">\${alarm.alertDate}</div>
            </div>
            <button type="button" class="btn btn-sm btn-secondary ml-2" 
                    onclick="event.stopPropagation(); alarmReadOne(\${alarm.alertNo}, this)">확인</button>
        </div>
    `;
    alarmList.insertAdjacentHTML('beforeend', alarmHtml);
}

// 알림 개별 읽음 처리
function alarmReadOne(alarmNo, btnElement) {
	
	// CSRF 토큰과 헤더 이름 가져오기
	const csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
	const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;
	
	// 헤더 설정 구성
	const config = {
			params: {alertNo: alarmNo}
	};
	
	// 토큰과 헤더 이름이 존재할 때만 headers 추가
	if(csrfHeader && csrfToken){
		config.headers = {[csrfHeader]: csrfToken};
	}
	
    axios.post('/notification/read', null, config)
    .then(function(response) {
        if (response.data === "success") {
            const alarmItem = btnElement.closest('.dropdown-notification');
            if (alarmItem) {
                alarmItem.remove();
                alarmUpdateCountUI(-1);
            }
        }
    })
    .catch(function(error) {
    	console.error("실패 사유: ", error);
        sweetAlert("error", "개별 알림 확인 처리에 실패했습니다."); 
    });
}

// 알림 모두 확인 처리
function alarmReadAll() {
    sweetAlertC({ 
        icon: "warning",
        title: "모든 알림을 확인 처리하시겠습니까?",
        showCancel: true
    }).then(function(result) {
        if (result.isConfirmed) {
        	// CSRF 토큰과 헤더 이름 가져오기
        	const csrfToken = document.querySelector('meta[name="_csrf"]')?.content;
        	const csrfHeader = document.querySelector('meta[name="_csrf_header"]')?.content;
        	
        	// 헤더 설정 구성
        	const config = {};
        	
        	// 토큰과 헤더 이름이 존재할 때만 headers 추가
        	if(csrfHeader && csrfToken){
        		config.headers = {[csrfHeader]: csrfToken};
        	}
        	
            axios.post('/notification/readAll', null, config)
            .then(function(response) {
                const alarmList = document.getElementById('alarmList');
                alarmList.querySelectorAll('.dropdown-notification').forEach(function(item) {
                    item.remove();
                });
                alarmUpdateCountUI(0, true);
            })
            .catch(function(error) {
                console.error("전체 확인 실패:", error);
                sweetAlert("error", "전체 확인 처리에 실패했습니다."); 
            });
        }
    });
}

// 알림 개수 및 배지 UI 업데이트
function alarmUpdateCountUI(diff, isInit) {
    const countBadge = document.getElementById('alarmTotalCount');
    const alarmDot = document.getElementById('alarmDot');
    const alarmEmpty = document.getElementById('alarmEmpty');
    
    if(!countBadge) return; // 요소 없을 경우 대비
    
    // 기존 숫자 가져오기
    let currentText = countBadge.innerText.trim();
    let currentCount = isInit ? diff : (Number(currentText) || 0) + diff;
    
    if (currentCount < 0) currentCount = 0;
    
    // 화면에 숫자 반영
    countBadge.innerText = currentCount;
    
    // 숫자에 따른 배지(Dot) 및 빈 상태 처리
    if (currentCount === 0) {
        if (alarmDot) alarmDot.classList.add('hidden');
        if (alarmEmpty) alarmEmpty.classList.remove('hidden');
    } else {
        if (alarmDot) alarmDot.classList.remove('hidden');
        if (alarmEmpty) alarmEmpty.classList.add('hidden');
    }
}

// 웹소켓 객체 생성 (서버에서 설정한 주소 /ws/alarm)
let socket = null;

function connectNotificationWs(){
	// WebSocketConfig에서 설정한 주소
	const wsUri = "ws://" + location.host + "/ws/alarm";
	socket = new WebSocket(wsUri);
	
	// 연결 성공 시
	socket.onopen = function(){
		console.log("알림 웹소켓 연결 성공");
	};
	
	// 서버로부터 알림 받았을 때
	socket.onmessage = function(event){
		console.log("새 알림 수신: ", event.data);
		
		// 서버에서 온 데이터 객체로 변환(JSON 문자열인 경우)
		let alertData = {};
		try{
			alertData = JSON.parse(event.data);
		}catch(e){
			// 만약 단순 문자열로 온다면 텍스트만 처리
			alertData = {alertContent: event.data};
		}
		
		// 본인이 보낸 알림은 팝업 및 목록 갱신 안함
		const currentEmpNo = "${employee.employeeNo}"; // 사번 가져오기
		if(alertData.senderNo && alertData.senderNo == currentEmpNo){
			console.log("본인이 보낸 알림이므로 수신 무시함");
			return;
		}
		
		// 대기 환자 목록 실시간 반영
		if(alertData.alertType === 'RECEPTION_UPDATE'){
			if(typeof loadWaitingList === 'function'){
				loadWaitingList(); // 대기 환자 목록 함수 호출
				console.log("실시간 대기 목록 갱신 실행");
			}
			return;
		}
		
		// 제목 설정
		const alertTitle = alertData.alertName || '새로운 알림';
		// 긴급 여부에 따른 팝업 스타일 
		const isUrgent = alertData.alertUrgent === 'Y';		
		
		// 새로운 알림 오면 알림창
		Swal.fire({
		    toast: true,		  
		    position: 'top-end',
		    showConfirmButton: false,
		    timer: 10000,
		    timerProgressBar: true,
		    showCloseButton: true,      
		    
		    // 디자인 설정
		    icon: isUrgent ? 'error' : 'info',
		    title: (isUrgent ? '🚨 [긴급] ' : '') + alertTitle,
		    text: alertData.alertContent,
		    background: '#ffffff',
		    color: '#1e293b',
		    iconColor: isUrgent ? '#ef4444' : '#3b82f6',
		    
		    customClass: {
		        popup: 'shadow-lg border-0'
		    },
		    
		    showClass: {
		        popup: 'animate__animated animate__fadeInRight'
		    },
		    
		    // 이벤트 설정
		    didOpen: (toast) => {		        		        
		        toast.addEventListener('mouseenter', Swal.stopTimer);	// 마우스 올리면 정지
		        toast.addEventListener('mouseleave', Swal.resumeTimer); // 마우스 떼면 재개
		    }
		});
		
		// 새로운 알림이 오면 기존에 만든 목록 조회 함수 실행해서 화면 갱신
		if(typeof alarmLoadList === 'function'){
			setTimeout(function(){
				console.log("지연 후 알림 목록 갱신 실행");
				alarmLoadList();		
			}, 500);
		}
	};
	
	// 연결 종료 시
	socket.onclose = function(){
		console.log("알림 웹소켓 연결 종료");
	};
	
	// 에러 발생 시
	socket.onerror = function(err){
		console.error("웹소켓 에러: ", err);
	};
}

// 새로운 알림을 생성하고 서버에 저장 요청 보냄
function sendNewNotification(empNo, name, content, type, url, urgent) {
    axios.post('/notification/insert', {
        employeeNo: empNo,			// 수신자 사번
        alertContent: content,		// 알림 내용
        alertType: type,	  		// 알림 구분 코드
        alertUrgent: urgent || 'N',	// 긴급 여부 기본값 'N'
        alertUrl: url || '#',		// 이동 경로 없으면 메인으로 설정
        alertName: name || '알림'		// 알림 제목
    })
    .then(res => console.log("알림 생성 성공"))
    .catch(err => console.error("알림 생성 실패", err));
}

//여러 명에게 알림 전송 
function sendManyNotifications(target, name, content, type, url, urgent) {
	const data = {
		alertName: name || '알림',
        alertContent: content,
        alertType: type,
        alertUrgent: urgent || 'N',
        alertUrl: url || '#'
	}
	
	// target이 사번 리스트(배열)인지 부서 코드(문자열)인지에 따라 필드 설정
	if(Array.isArray(target)){
		data.empNoList = target;		// 수신자 사번 배열 [26037909, 26037910, ...]
	}else{
		data.employeeCode = target;		// 수신자 부서 코드 '1'
	}
	
    axios.post('/notification/insertMany', data)
    .then(res => console.log("다수 알림 전송 결과:", res.data))
    .catch(err => console.error("다수 알림 전송 실패", err));
}

// 전체 알림 전송
function sendAllNotification(name, content, type, url, urgent){
	axios.post('/notification/broadcast', {
		alertName: name || '전체 공지',
		alertContent: content,
		alertType: type,
		alertUrgent: urgent || 'N',
		alertUrl: url || '#'
	})
	.then(function(res){
		if(res.data === "success"){
			console.log("전체 알림 전송 성공");
		}
	})
	.catch(err => console.error("전체 알림 전송 실패", err));
}

//페이지 로드 시 초기화 작업
document.addEventListener('DOMContentLoaded', () => {
    // 안 읽은 알림 목록 로드
	alarmLoadList();
    
    // 실시간 알림 웹소켓 연결
    connectNotificationWs();
});
</script>