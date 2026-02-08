<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<div id="messengerList" class="messenger-panel">
    <div class="messenger-header">
        <h3 class="title-h2">메신저</h3>
        <button class="btn btn-primary btn-sm" onclick="openChatListModal('selectUserModal')">대화하기 +</button>
    </div>
    <div id="chatList" class="chat-list">
        <!-- <div class="list-item" onclick="openChatRoom('1', '간호사 A (외래)')">
        		<div class="chat-info-wrap">
	            <div class="user-profile-info">
	                <img src="https://placehold.co/40x40" alt="간호사 A">
	                <span class="status-dot"></span>
	            </div>
	            <div class="user-chat-info">
	            	<div class="flex items-center">
	                	<span class="user-name"><strong>김간호사</strong> (외래)</span>
	                	<button onclick="toggleFavorite(event)" class="btn btn-star btn-icon star-icon star-active text-right">★</button>
	                </div>
	                <p class="chat-content">채팅 메시지가 표시됩니다...</p>
	            </div>
	            <div class="chat-info flex flex-col">
	                <span class="text-sm text-secondary">오후 02:30</span>
	            </div>
	    		</div>
        </div> -->
    </div>
</div>

<div id="messengerRoom" class="chat-room-panel">

    <input type="hidden" id="roomNo" value="">
    <input type="hidden" id="currentUserId" value="${employee.employeeNo }">
    <input type="hidden" id="currentUserName" value="${employee.employeeName }">

    <div class="chat-header">
        <div class="chat-user-info">
        	<span class="status-dot"></span>
            <span id="roomName" class="user-nam e">김현수 의사</span>
        </div>
        <div class="popover-wrapper">
            <button class="btn btn-icon btn-goast btn-lg mr-4" onclick="togglePopoverMenu(event, 'chatPop')">
                <i class="icon-dots-vertical icon icon-lg"></i>
            </button>
            <div id="chatPop" class="popover-menu" style="width: 4.8rem;">
                <span class="popover-menu-item" onclick="leaveChatRoom()">삭제</span>
            </div>
        </div>
        <button type="button" class="btn-close" onclick="closeChatRoom()">✕</button>
    </div>

    <div id="messageArea" class="message-display-area">
        <!-- 수신 메시지 예시 -->
        <!-- <div class="message-item received">
            <span class="message-time">오후 2:30</span>
            <div class="message-bubble">안녕하세요, 502호 환자분 차트 확인 부탁드립니다.</div>
        </div> -->
        
        <!-- 발신 메시지 예시 -->
        <!-- <div class="message-item sent">
            <span class="message-time">오후 2:32</span>
            <div class="message-bubble">네, 지금 바로 확인하겠습니다.</div>
        </div> -->
    </div>

    <div class="chat-input-area">
        <textarea class="chat-input textarea" style="min-heigt: var(--height-md)" id="messageInput" placeholder="메시지 입력..."></textarea>
        <button type="button" id="sendButton" class="btn btn-primary btn-send btn-icon h-full"><i class="icon icon icon-send icon-lg"></i></button>
    </div>
</div>

<div id="selectUserModal" class="modal-backdrop chat-hide" onclick="if(event.target === this) closeChatModal('selectUserModal')">
    <div class="modal modal-md search-modal" style="height: calc(100vh - var(--spacing-lg) * 2);">
        <div class="modal-header">
            <h3 class="modal-title">직원 목록</h3>
            <button class="btn btn-icon btn-ghost" onclick="closeChatModal('selectUserModal')">×</button>
        </div>
        <div class="modal-body flex flex-col">
            <!-- 검색 입력창 -->
            <input type="text" id="userSearchInput"
                class="input input-lg input-search mb-4" placeholder="이름으로 검색..." oninput="">
            <div class="flex items-center flex-wrap pb-3 gap-sm" id="selectedList" style="display: none;"></div>
                
            <div class="flex-1 overflow-y-auto">
                <!-- 사용자 목록 -->
                <div class="box" id="employeeList">
                    <!-- 동적 추가 -->
                </div>
            </div>
        </div>
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeChatModal('selectUserModal')">닫기</button>
            <button class="btn btn-primary" onclick="createChatRoom()">대화하기</button>
        </div>
    </div>
</div> 