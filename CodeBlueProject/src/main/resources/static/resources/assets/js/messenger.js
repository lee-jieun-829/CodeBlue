/**
 * messenger.js
 * auth : Been Daye
 * date : 2026-01-20
 * desc : 실시간 채팅 기능에 대한 javascript
 */

let stompClient = null; // 웹소켓 클라이언트
let currentRoomNo = null; // 현재 채팅방 번호
let currentSubscription = null; // 구독 객체 저장용 추가
let selectedUsers = new Map(); // 선택된 직원 저장 (Key: 사번, Value: 이름)

// 검색용 (임시)
let allEmployeeData = [];

document.addEventListener("DOMContentLoaded", function(){
	initEventListeners();
    textareaAutoHeight();
    
    loadChatRoomList(); 
	connectWebSocketForStatus();
})

// ESC 키로 모달 닫기
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
        const openModals = document.querySelectorAll('.modal-backdrop[style*="display: flex"]');
        openModals.forEach(modal => {
            modal.style.display = 'none';
        });
        document.body.style.overflow = 'auto';
    }
});


function messengerOpen(e){
	let mbtn = e.currentTarget;		
	let messenger = document.querySelector("#messengerContainer");
	
	messenger.classList.toggle("show");
	
	if(messenger.classList.contains("show")){ // show 클래스가 존재한다면
		const rect = mbtn.getBoundingClientRect(); // 버튼의 좌표값 가져오기
		messenger.style.bottom = (rect.height - 12) + "px";
		messenger.style.left = (rect.right + 12) + "px";
	}
}

// 이벤트 리스너 초기화 (중복 방지)
function initEventListeners(){
    const sendBtn = document.querySelector("#sendButton");
    const messageInput = document.querySelector("#messageInput");
    
    if(sendBtn){
        sendBtn.addEventListener("click", sendMessage);
    }
    
    if(messageInput){
        messageInput.addEventListener("keypress", function(e){
            if(e.key === 'Enter' && !e.shiftKey){
                e.preventDefault();
                sendMessage();
            }
        });
    }
	
	// 직원 검색 이벤트 리스너 (임시)
	const searchInput = document.querySelector("#userSearchInput");
    if(searchInput) {
        searchInput.addEventListener("input", function(e){
            filterEmployeeList(e.target.value);
        });
    }
}

// ======= 웹소켓 연결 ========
// ======= 온/오프라인 상태 전용 WebSocket 연결 =======
function connectWebSocketForStatus(){
	const socket = new SockJS("/ws/chat", null, {
		transports: ['websocket', 'xhr-streaming', 'xhr-polling'],
		// 쿠키를 포함하도록 설정
		withCredentials: true
	});
	stompClient = Stomp.over(socket);
	
	stompClient.connect(
		{},
		function(frame) {
			console.log("✅ 상태 WebSocket 연결 성공", frame);
			
			// 온/오프라인 상태만 구독
			subscribeStatus();
			
			// ⭐ 서버에 내가 접속했다고 알리기
			/*const currentUserId = document.querySelector("#currentUserId").value;
			stompClient.send("/app/chat.addUser", {}, JSON.stringify({
	            type: "JOIN",
	            chattingDetailSender: currentUserId
	        }));*/
		},
		function(error) {
			console.error("❌ 상태 WebSocket 연결 실패", error);
		}
	)
}


// 웹소켓 연결 시작
// @param {number} roomNo 채팅방 번호
// 웹소켓 연결 시작 (채팅방 진입 시)
function connectWebSocket(roomNo){
    console.log("WebSocket 연결 시도 : 채팅방", roomNo);
    currentRoomNo = roomNo;
    
    // 1. 이미 연결이 확실하게 된 경우
	if(stompClient !== null && stompClient.connected){
        
        try {
            // 혹시 모를 이전 방 구독 해제 (안전장치)
            if(currentSubscription) {
                currentSubscription.unsubscribe();
            }
            
            subscribeToRoom(roomNo); // 채팅방 메시지 구독
            
            // 입장 메시지 전송
            const name = document.querySelector("#currentUserName").value;
            const enterMsg = {
                chattingroomNo : parseInt(roomNo),
                senderName : name,
                type : "ENTER"
            };
            
            stompClient.send("/app/chat.sendMessage", {}, JSON.stringify(enterMsg));
            return; // 성공 시 여기서 종료

        } catch (error) {
            console.warn("⚠️ 기존 연결이 불안정하여 재연결을 시도합니다.", error);
            // 에러 발생 시 stompClient를 null로 만들어서 아래 3번 로직(신규 연결)으로 넘어가게 함
            stompClient = null; 
        }
    }
    
    // 연결은 시도했지만(객체 있음) 아직 완료되지 않은 경우
    // => 0.1초 뒤에 다시 이 함수를 실행해서 확인 (재귀 호출)
    if(stompClient !== null && !stompClient.connected){
        setTimeout(function(){
            connectWebSocket(roomNo);
        }, 100);
        return;
    }

    const socket = new SockJS("/ws/chat", null, {
        transports: ['websocket', 'xhr-streaming', 'xhr-polling'],
        withCredentials: true
    });
    stompClient = Stomp.over(socket);

    // connectHeaders 변수 오류 방지를 위해 {} 빈 객체 사용
    stompClient.connect({}, 
        // 연결 성공
		function(frame) {
            subscribeStatus(); // 온오프라인 상태값 구독
            subscribeToRoom(roomNo); // 채팅방 메시지 구독
            
            // ★ 연결 직후 입장 메시지 전송 (필요시 추가)
            const name = document.querySelector("#currentUserName").value;
            const enterMsg = {
                chattingroomNo : parseInt(roomNo),
                senderName : name,
                type : "ENTER"
            };
            stompClient.send("/app/chat.sendMessage", {}, JSON.stringify(enterMsg));
        },
        // 연결 실패
        function(error) {
            console.error("WebSocket 연결 실패 : ", error);
            updateConnectionStatus(false);
        }
    );
}

// 웹소켓 연결 해제
// 웹소켓 '채팅방' 구독만 해제 (소켓 연결은 유지!)
function disconnectWebSocket(){
	// 현재 채팅방 구독 객체가 있으면 해제
    if(currentSubscription){
        currentSubscription.unsubscribe();
	    currentSubscription = null;
	}
	
    // 주의: stompClient.disconnect()는 호출하지 않음!
    // 호출하면 전체 연결이 끊겨서 온라인 상태 알림도 못 받음.
	
	currentRoomNo = null;
}

// ======= UI 업데이트 ========
// 메신저 로드 시 공통 상태 구독
function subscribeStatus(){
	stompClient.subscribe("/topic/status", function(message){
		const data = JSON.parse(message.body);
		const userId = data.chattingDetailSender;
		const status = data.type;
		
		updateConnectionStatus(userId, status);
	})
}
// 연결 상태 표시 업데이트
// @param {boolean} isConnected 연결 여부
function updateConnectionStatus(userId, status){
	const statusDots = document.querySelectorAll(`.status-dot[data-user-id="${userId}"]`); // 온오프라인 연결 여부 UI
	
	// ONLINE이라는 문자열이랑 똑같을 때만 true
	const isOnline = (status === "ONLINE");
	
	statusDots.forEach(statusDot => {
        if(isOnline){
            statusDot.classList.remove("offline");
            statusDot.classList.add("online");
        } else {
            statusDot.classList.remove("online");
            statusDot.classList.add("offline");
        }
    });
}

// ======= 채팅방 열기 / 닫기 ========

// 채팅방 열기
// @param {number} roomNo 채팅방 번호
// @param {string} roomName 채팅방 이름
async function openChatRoom(roomNo, roomName) {
	console.log("채팅방 열기 :", roomNo, roomName);
	
	// hidden input 설정
	document.querySelector("#roomNo").value = roomNo;
	document.querySelector("#roomName").textContent = roomName;
	
	// UI 표시
	document.querySelector("#messengerRoom").classList.add("show");
	document.querySelector("#messageArea").innerHTML = ""; // 초기화
	
	// 1. 이전 메시지를 먼저 가져오고 기다림(await)
	await loadPreviousMessage(roomNo);
	
	// 2. 메시지가 다 로드된 뒤에 소켓 연결 및 입장 메시지 전송
	// (이렇게 해야 "참여했습니다"가 맨 아래에 붙음)
	connectWebSocket(roomNo); 
}

// 채팅방 닫기
function closeChatRoom(){
	// 웹소켓 연결 해제
	disconnectWebSocket();
	// 패널 전환
	document.querySelector("#messengerRoom").classList.remove("show");
	// hidden input 초기화
	document.querySelector("#roomNo").value = '';
}

// 채팅방 나가기
function leaveChatRoom(){
	sweetAlert("warning", "이 채팅방을 나가시겠습니까? 대화 목록에서 삭제됩니다.", "확인", "취소", true)
	.then((result) => {
		if(result.isConfirmed){
			// 확인 버튼 클릭했을 때
			const roomNo = document.querySelector("#roomNo").value;
			const name = document.querySelector("#currentUserName").value;
			const leaveMsg = {
				chattingroomNo: roomNo,
				senderName: name,
				type: "LEAVE"
			};
			if(stompClient !== null && stompClient.connected){
                try {
                    stompClient.send("/app/chat.leaveRoom", {}, JSON.stringify(leaveMsg));
                } catch (error) {
                    console.error("나가기 메시지 전송 실패 (이미 연결 끊김):", error);
                }
            } else {
                console.warn("웹소켓이 연결되지 않아 나가기 메시지를 보낼 수 없습니다.");
            }
			closeChatRoom();
			sweetAlert("success", "채팅방 나가기가 성공적으로 실행되었습니다.", "닫기");
		} else if(result.isDenied){
			sweetAlert("info", "채팅방 나가기가 취소되었습니다.", "확인");
			return;
		}
	})
}

// ======= 채팅 만들기 ========
// 직원 목록 로드 함수
async function loadEmployeeList() {
	
	try {
		// 직원 전체 목록 가져오기 
        // (이미 Controller에서 온라인 여부(online: true/false)를 판단해서 줍니다)
		const response = await axios.get("/api/chat/employees");
		const employees = response.data;
		
		// 검색용 (임시) 원본 데이터를 전역 변수에 저장 (검색용)
		allEmployeeData = employees;
		
        renderEmployeeList(employees);
        
    } catch(error){
		console.error(error);
        sweetAlert("error", "메신저 로드에 실패했습니다.", "확인");
    }
}

// 메신저 로드 시 공통 상태 구독
function subscribeStatus(){
    // 이미 구독 중이라면 중복 구독 방지 (선택 사항)
    if (stompClient.subscriptions['/topic/status']) return; 

    stompClient.subscribe("/topic/status", function(message){
        const data = JSON.parse(message.body);
        const userId = data.chattingDetailSender;
        const status = data.type; // "ONLINE" 또는 "OFFLINE"
        
        // 수정된 함수 호출
        updateConnectionStatus(userId, status);
    });
}

function renderEmployeeList(data){
	let employeeList = document.querySelector("#employeeList");
	
	// 데이터 없을 때
	if(!data || data.length === 0) {
		employeeList.innerHTML = `
			<div class="empty-state">
			    <div class="empty-state-title">검색 결과가 없습니다.</div>
			</div>
		`;
		return;
	}
	
	
	let html = "";
			
	const deptConfig = {
	    "의사": { icon: "icon-doctor", label: "의사"},
	    "외래간호사": { icon: "icon-doctor-bag", label: "외래간호"},
	    "입원간호사": { icon: "icon-doctor-bag", label: "입원간호"},
	    "약사": { icon: "icon-drug", label: "약제"},
	    "원무": { icon: "icon-folder", label: "원무과"},
	    "방사선사": { icon: "icon-doctor-bag", label: "방사선"},
	    "물리치료사": { icon: "icon-doctor-bag", label: "물리치료" },
	    "관리자": { icon: "icon-user", label: "관리자" },
	    "": { icon: "icon-user", label: "직원" }
	};

	// 부서별로 그룹화
	const groupedData = data.reduce((acc, emp) => { // reduce그룹화하기 acc : 결과를 담을 바구니, emp : 직원뽑아내기
	    const dept = emp.employeeCode || "";
	    if (!acc[dept]) acc[dept] = []; // 결과를 담을 바구니가 없으면 새로 만들기
	    acc[dept].push(emp); // 바구니가 있으면 해당 직원을 넣기.
	    return acc;
	}, {});

	// 부서 객체
	const deptOrder = ["의사", "외래간호사", "입원간호사", "약사", "방사선사", "원무", "관리자"]; // 뽑을 순서 정하기

	deptOrder.forEach(dept => {
		const emps = groupedData[dept];
		if(!emps || emps.length === 0) return; // 해당 부서에 직원이 없으면 패스
		
		const config = deptConfig[dept] || deptConfig[""];
		
		// 섹션
		html += `
			<div class="box-section">
	            <div class="box-title">
	                <i class="icon ${config.icon} icon-sm"></i>
	                <span class="text-sm font-semibold">${config.label}</span>
	            </div>
	            <div class="list">
		`;
		
		// 해당 부서의 직원들
		emps.forEach(emp => {
	        // 온라인 상태에 따라 불 켜주기
	        const statusClass = emp.online ? 'online' : 'offline';
			
			// 이미 선택된 사용자인지 확인 (재오픈 시 상태 유지)
			const isSelected = selectedUsers.has(String(emp.employeeNo));
			const iconClass = isSelected ? "icon-success" : "icon-muted";
			
	        html += `
                <div class="list-item">
                    <div class="flex justify-between items-center">
						<div class="flex items-center gap-sm">
	                        <div class="user-profile-info">
	                            <img src="https://placehold.co/40x40" alt="${emp.employeeName}">
	                            <span class="status-dot ${statusClass}" data-user-id="${emp.employeeNo}"></span>
	                        </div>
	                        <div class="user-chat-info">
	                            <span>${emp.employeeName} ${emp.employeeCode}</span>
	                        </div>
						</div>
						<button class="btn btn-icon btn-lg" onclick="chatSelect(this, '${emp.employeeNo}', '${emp.employeeName}')">
							<i class="icon icon-check-circle-one icon-lg ${iconClass}"></i>
						</button>
                    </div>
                </div>
	        `;
		})
		
		html += `
				</div>
			</div>
		`;
	});
	
	employeeList.innerHTML = html;
}

function chatSelect(btn, empNo, empName){
    // 아이콘 요소 찾기 (버튼 내부의 i 태그)
    const icon = btn.querySelector("i");
    
    // 사번은 문자열로 통일
    const id = String(empNo);
    
    if(selectedUsers.has(id)){
        // 이미 선택됨 -> 해제
        selectedUsers.delete(id);
        icon.classList.remove("icon-success");
        icon.classList.add("icon-muted");
    } else {
        // 선택 안됨 -> 추가
        selectedUsers.set(id, empName);
        icon.classList.remove("icon-muted");
        icon.classList.add("icon-success");
    }
    
    // 태그 리스트 다시 그리기
    renderSelectedTags();
}

// 태그리스트 그리기
function renderSelectedTags(){
	const container = document.querySelector("#selectedList");
    let html = "";
	
    selectedUsers.forEach((name, id) => {
        html += `
            <span class="tag tag-removable">
                ${name}
				<i class="icon icon-x-circle tag-remove" onclick="removeTag('${id}')"></i>
            </span>
        `;
    });
    
    container.innerHTML = html;
}
// 태그 삭제 기능
function removeTag(id){
    // 맵에서 삭제
    selectedUsers.delete(id);
    
    // 태그 리스트 갱신
    renderSelectedTags();
  
    // 리스트가 현재 화면에 떠있다면 아이콘 상태 동기화
    // onclick="chatSelect(this, '사번'...)" 에서 사번으로 버튼을 찾기 어려우므로 재로딩 or DOM 탐색
    loadEmployeeList(); // 가장 간단한 방법: 리스트를 다시 그려서 상태 반영
}

// 채팅방 생성 함수
async function createChatRoom(){
    // 1. 선택된 인원 확인 (0명일 때)
    if(selectedUsers.size === 0){
        sweetAlert("warning", "대화할 상대를 선택해주세요.", "확인");
        return;
    }
	
    // 2. 인원 제한 확인 (본인 제외 4명 이하 = 총 5명 이하)
    // 멘트가 "4명 이하"이므로 size > 4가 논리적으로 맞습니다.
	if(selectedUsers.size > 4){
		sweetAlert("warning", "대화 인원은 4명 이하로 선택해주세요.", "확인");
		return;
	}
    
    // 3. 참여자 리스트 생성 (내 사번 + 선택된 사번들)
    const currentUserId = document.querySelector("#currentUserId").value;
    let participants = [currentUserId];
    
    selectedUsers.forEach((name, id) => {
        participants.push(id);
    });
	
	const result = await sweetAlert("question", "채팅을 시작하시겠습니까?", "확인", "취소", true);
    // 확인(isConfirmed)이 true가 아니면(취소나 닫기) 함수 종료
	if(!result.isConfirmed) return;
    
    try {
        // 서버 전송
        const response = await axios.post("/api/chat/room", participants);
        
        if(response.data.success){
			sweetAlert("success","채팅방 생성이 완료되었습니다.", "확인")
			.then(() => {
	            // 성공 시 처리
	            const roomNo = response.data.roomNo;
	            const roomName = response.data.roomName; 
	            
	            closeChatModal('selectUserModal'); // 모달 닫기
	            selectedUsers.clear();         // 선택 초기화
	            renderSelectedTags();          // 태그 초기화
	            
				loadChatRoomList();            // 채팅방 목록 갱신
	            
                openChatRoom(roomNo, roomName); // 채팅방 열기
			});
        }
    } catch(error) {
        console.error("채팅방 생성 실패", error);
        sweetAlert("error", "채팅방 생성 중 오류가 발생했습니다.", "확인");
    }
}

// ======= 채팅방 목록 =======

// 채팅방 목록 불러오기 함수
async function loadChatRoomList() {
    try {
        const response = await axios.get("/api/chat/rooms");
        const rooms = response.data;
        
        renderChatRoomList(rooms);
		loadEmployeeList();
        
    } catch(error) {
        console.error("채팅방 목록 로드 실패:", error);
    }
}

// 채팅방 목록 HTML 렌더링
function renderChatRoomList(rooms) {
    const listContainer = document.querySelector("#chatList");
    
    if(!rooms || rooms.length === 0) {
        listContainer.innerHTML = `<div class="no-data">참여 중인 대화가 없습니다.</div>`;
        return;
    }
    
    let html = "";
    
    rooms.forEach(room => {
        // 방 이름이 없으면(나만 있는 방 등) '대화방'으로 표시
        const roomName = room.roomName || '대화방';
        
        // 날짜 포맷팅 (오늘이면 시간, 아니면 날짜)
        const timeStr = formatListDate(room.lastSendAt);
        
        // 마지막 메시지가 없으면 '대화를 시작해보세요'
        const lastMsg = room.lastMessage ? escapeHtml(room.lastMessage) : '대화를 시작해보세요.';
        
        // 안 읽은 개수 뱃지 (0보다 클 때만 표시)
        const badge = room.unreadCount > 0 
            ? `<span class="badge badge-danger rounded-full">${room.unreadCount}</span>` 
            : '';

        html += `
            <div class="list-item" onclick="openChatRoom('${room.chattingroomNo}', '${roomName}')">
                <div class="chat-info-wrap">
                    <div class="user-profile-info">
                        <img src="https://placehold.co/40x40" alt="프로필">
                        </div>
                    <div class="user-chat-info">
                        <div class="flex items-center justify-between">
                            <span class="user-name"><strong>${roomName}</strong></span>
                            ${badge}
                        </div>
                        <p class="chat-content text-ellipsis">${lastMsg}</p>
                    </div>
                    <div class="chat-info flex flex-col">
                        <span class="text-sm text-secondary">${timeStr}</span>
                    </div>
                </div>
            </div>
        `;
    });
    
    listContainer.innerHTML = html;
}

// 목록용 날짜 포맷터 (유틸 함수)
function formatListDate(dateStr) {
    if(!dateStr) return '';
    const date = new Date(dateStr);
    const now = new Date();
    
    // 오늘 날짜인지 확인
    const isToday = date.getDate() === now.getDate() &&
                    date.getMonth() === now.getMonth() &&
                    date.getFullYear() === now.getFullYear();
                    
    if(isToday) {
        // 오늘이면 오전/오후 시간만
        return formatTime(dateStr); 
    } else {
		// 월 (0부터 시작하므로 +1 필수)
        const month = String(date.getMonth() + 1).padStart(2, '0');
		// 일
        const day = String(date.getDate()).padStart(2, '0');
        // 오늘이 아니면 월-일 표시 (예: 01-27)
        return `${month}/${day}`;
    }
}

// ======= 메시지 구독 =======
// 채팅방 메시지 구독
function subscribeToRoom(roomNo){
	currentSubscription = stompClient.subscribe("/topic/chatroom/" + roomNo, function(message){
		const data = JSON.parse(message.body);
		
		if(data.type === "TALK" || data.type === "ENTER" || data.type === "LEAVE" ){
			displayMessage(data); // 메시지 화면
			scrollToBottom(); // 스크롤 하단으로 이동
		} else if(data.type === "READ"){
			updateReadStatusUI(data);
		}
	})
}

// ======= 메시지 전송 =======
// 메시지 전송 버튼 클릭 이벤트
function sendBtnHandler(){
	const sendBtn = document.querySelector("#sendButton");
	const messageInput = document.querySelector("#messageInput");
	
	if(!sendBtn) return;
	
	sendBtn.addEventListener("click", function(){
		sendMessage();
	})
	
	messageInput.addEventListener("keypress", function(e){
		if(e.key === 'Enter' && !e.shiftKey){
			e.preventDefault();
			sendMessage();
		}
	})
}

// 메시지 전송
function sendMessage(){
	const messageInput = document.querySelector("#messageInput");
	const content = messageInput.value.trim();
	
	if(!content) return;

	if(stompClient === null || !stompClient.connected) { 
		console.warn("⚠️ 소켓 연결 끊김");
		sweetAlert("error", "채팅 서버에 연결되지 않았습니다.", "닫기");
		return;
	}
	
	const roomNo = document.querySelector("#roomNo").value;
	const currentUserName = document.querySelector("#currentUserName").value;
	
	const message = {
		chattingroomNo : parseInt(roomNo),
		senderName : currentUserName,
		chattingDetailContent : content
	};
	
	try {
		stompClient.send("/app/chat.sendMessage", {}, JSON.stringify(message));
		messageInput.value = "";
		messageInput.focus();
		messageInput.style.height = 'auto'; 
		
	} catch (e) {
		sweetAlert("error", "메시지 전송 실패", "확인");
	}
}

// ======= 메시지 표시 =======
// 이전 메시지 표시
// 이전 메시지 표시
async function loadPreviousMessage(roomNo){
	const area = document.querySelector("#messageArea");
	
	// 로딩 표시 (기존 내용 유지하면서 맨 밑에 추가하거나, 아예 비우거나 선택)
	// 여기서는 openChatRoom에서 이미 비웠으므로 로딩만 표시
	area.innerHTML = `<div id="loadingMsg" class="chat-loading">메시지를 불러오는 중</div>`;
	
	try {
		const response = await axios.get("/api/chat/messages", {
			params: { roomNo : roomNo }
		})
		const messages = response.data;
		
		// 로딩 메시지 제거
		const loadingEl = document.querySelector("#loadingMsg");
		if(loadingEl) loadingEl.remove();
		
		// 메시지 렌더링
		messages.forEach(msg => displayMessage(msg)); // false 파라미터 불필요 (displayMessage 수정 확인)
		scrollToBottom();
		
		// 마지막 메시지 읽음 처리 (로직 유지)
		if(messages.length > 0){
			const lastMsg = messages[messages.length - 1]; 
			const currentUserId = document.querySelector("#currentUserId").value;
			if(lastMsg.chattingDetailSender !== currentUserId){
				markAsRead(lastMsg.chattingDetailNo);
			}
		}
		
	} catch(error){
		console.error("메시지 로드 실패 :", error);
		area.innerHTML = `<div class="chat-error">메시지를 불러올 수 없습니다.</div>`;
	}
}
// 메시지 화면 표시
function displayMessage(data){
	const area = document.querySelector("#messageArea");
	const currentUserId = document.querySelector("#currentUserId").value;
	
	console.log("메시지 표시 :", data);
	
	//  시스템 메시지(초기/최종 종료)
	if(data.type === "ENTER" || data.type === "LEAVE"){
		const systemText = data.type === "ENTER" 
			? `${data.senderName}님이 참여하셨습니다.`
			: `${data.senderName}님이 나가셨습니다.`;
		
		const systemHTML = `
			<div class="system-message">
				<span>${systemText}</span>
			</div>
		`;
		
		area.insertAdjacentHTML("beforeend", systemHTML);
		scrollToBottom();
		return; // 시스템 메시지면 여기서 함수 종료
	}
	
	// 내 메시지인지 확인
	const isMine = data.chattingDetailSender === currentUserId;
	const messageClass = isMine ? 'sent' : 'received';
	// 시간 포맷
	const timeStr = formatTime(data.chattingDetailSendAt);
	// 읽음 여부 UI
	const unreadCount = (isMine && data.unreadCount > 0) 
		? `<span class="unread-count" data-msg-no="${data.chattingDetailNo}">1</span>`
		: "";
	
	// 메시지 HTML
	let messageHtml = `
		<div class="message-item ${messageClass}">
			${!isMine ? `<span class="sender-name">${data.senderName}</span>` : ""}
            <div class="message-bubble">${escapeHtml(data.chattingDetailContent)}</div>
			<div class="message-info">
				${unreadCount}
            	<span class="message-time">${timeStr}</span>
        	</div>
		</div>
	`;
	
	scrollToBottom();
	area.insertAdjacentHTML("beforeend", messageHtml); // 특정 요소를 마지막 위치에 삽입. 보안처리 필요.
	
	// 내 메시지가 아닐 때의 '읽음 처리'
	if(!isMine) {
		markAsRead(data.chattingDetailNo);
	}
}

// 시간 포맷팅
function formatTime(data){
	if(!data) return; // 들어온 파라미터의 값이 없으면 반환
		
	const date = new Date(data);
	const h = date.getHours();
	const m = date.getMinutes();
	const ampm = h >= 12 ? '오후' : '오전';
	const timeView = h % 12 || 12; // 24시간제를 12시간제로 변환
	
	return `${ampm} ${timeView}:${m.toString().padStart(2, '0')}`; // 숫자를 문자열로 왼쪽에서 0 채워서 2자리로 변환
}

// insertAdjacentHTML 보안 이슈(XSS) 보완을 위한 코드 변환
// XSS : 웹사이트에 악성 스크립트를 삽입하여 방문하는 사용자의 브라우저에서 그 스크립트가 실행되도록하는 보안 취약점 공격. 
// XSS 공격 원인 : 웹사이트가 사용자 입력값을 검증 없이 그대로 화면에 출력할 때 발생
// 사용자가 입력한 데이터 중에 아래의 기호가 있을 경우 유니코드를 사용하여 변환
// 혹시 모를 스크립트 기호가 있을 경우 오류가 발생할 수도 있음
function escapeHtml(text) {
    const map = {
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#039;'
    };
    return text.replace(/[&<>"']/g, m => map[m]);
}

// 스크롤 하단으로 이동
function scrollToBottom(){
	const area = document.querySelector("#messageArea");
	area.scrollTop = area.scrollHeight;
}

// ======= 읽음 처리 =======
// 읽음 처리 구독
function subscribeToReadReceipt(){
	// const currentUserId = document.querySelector("#currentUserId").value;
	
	stompClient.subscribe("/user/queue/read", function(message){ // config에서 설정한 prefix(/user)
		const data = JSON.parse(message.body);
		
		// 읽음 표시 UI 업데이트
		// upcateReadStatus(data);
	})
}

// 메시지 읽음 처리
function markAsRead(lastMessageNo){
	// 연결된 것이 없을 때
	if(stompClient === null || !stompClient.connected){
		return;
	}
	
	const roomNo = document.querySelector("#roomNo").value;
	const message = {
		chattingroomNo: parseInt(roomNo),
		chattingDetailNo: lastMessageNo
	};
	
	// 서버로 전달
	stompClient.send("/app/chat.markAsRead", {}, JSON.stringify(message));	
}

// '1' UI 처리
function updateReadStatusUI(data) {
    const lastReadNo = data.chattingDetailNo; // 상대방이 읽은 마지막 번호
    const unreadElements = document.querySelectorAll(".unread-count"); // 화면에 떠있는 모든 '1'

    unreadElements.forEach(el => {
		// 각 '1' 태그에 저장해둔 메시지 번호(data-msg-no)를 가져와서 비교
        const msgNo = parseInt(el.getAttribute("data-msg-no"));
        // 상대방이 읽은 번호보다 작거나 같은 메시지 번호의 '1'은 모두 제거
        if(msgNo <= lastReadNo) {
            el.remove(); 
        }
    });
}

// 현재 화면에 있는 마지막 메시지 번호 찾기
function getLastMessageNo(){
	const messages = document.querySelectorAll(".unread-count");
    if(messages.length > 0) {
        // 가장 마지막(가장 아래)에 있는 메시지의 번호를 가져옴
        const lastMsg = messages[messages.length - 1];
        return parseInt(lastMsg.getAttribute("data-msg-no"));
    }
    return null;
}

// Popover Menu Toggle (함수명 변경)
function togglePopoverMenu(event, id) {
    event.stopPropagation();
    const popover = document.getElementById(id);
    const allPopovers = document.querySelectorAll('.popover-menu');
    
    allPopovers.forEach(p => {
        if (p.id !== id) p.classList.remove('show');
    });
    
    popover.classList.toggle('show');
}

// ======= 모달 =======
// 모달 열기/닫기 함수
function openChatListModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
		
		if (modalId === 'selectUserModal') {
            loadEmployeeList(); 
        }
    }
}

function closeChatModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.style.display = 'none';
        document.body.style.overflow = 'auto';
    }
}

// ======= 실시간 검색 ========
// [신규] 직원 검색 필터링 함수
function filterEmployeeList(keyword) {
    // 1. 검색어 공백 제거 및 소문자 변환 (대소문자 구분 없이 검색)
    const searchText = keyword.trim().toLowerCase();

    // 2. 검색어가 없으면 전체 목록 표시
    if (searchText === "") {
        renderEmployeeList(allEmployeeData);
        return;
    }

    // 3. 필터링 (이름 또는 사번 포함 여부)
    const filteredData = allEmployeeData.filter(emp => {
        const name = emp.employeeName ? emp.employeeName.toLowerCase() : "";
        const empNo = emp.employeeNo ? String(emp.employeeNo).toLowerCase() : ""; // 사번은 숫자일 수 있으므로 문자열 변환
        
        return name.includes(searchText) || empNo.includes(searchText);
    });

    // 4. 필터링된 데이터로 다시 렌더링
    renderEmployeeList(filteredData);
}


// ======= 즐겨찾기 ========
function toggleFavorite(){
	
}

// ======= 자동줄바꿈 ========
function textareaAutoHeight(){
	const textarea = document.querySelector('#messageInput');

	textarea.addEventListener('input', function(){
		textarea.style.height = 'auto'; 
		textarea.style.height = textarea.scrollHeight + 'px';
	});
}