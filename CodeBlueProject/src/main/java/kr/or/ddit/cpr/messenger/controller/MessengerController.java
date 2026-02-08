package kr.or.ddit.cpr.messenger.controller;

import java.security.Principal;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessageHeaderAccessor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.common.security.jwt.JwtTokenProvider;
import kr.or.ddit.cpr.messenger.service.IMessengerService;
import kr.or.ddit.cpr.vo.ChattingDetailVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
public class MessengerController {

	@Autowired
	private IMessengerService service;

	//@Autowired
	//private JwtTokenProvider jwtTokenProvider;

	@Autowired
	private SimpMessagingTemplate messagingTemplate; // 웹소켓 메시지 전송 도구

	/**
	 * 채팅 메시지 전송 
	 * 클라이언트 : /app/chat.sendMessage
	 * @param message 채팅 메시지
	 * @param headerAccessor 웹소켓 세션 정보
	 */
	@MessageMapping("/chat.sendMessage")
	public void sendMessage(
			@Payload ChattingDetailVO message, 
			Principal principal) { // 전체

		if (principal == null) {
            log.warn("인증되지 않은 사용자의 접근입니다.");
            return;
        }
		
		CustomEmployee loginUser = (CustomEmployee) ((Authentication) principal).getPrincipal();
		String employeeNo = loginUser.getUsername(); // 로그인한 사용자 정보 주입
		message.setChattingDetailSender(employeeNo);
		message.setSenderName(loginUser.getEmployee().getEmployeeName()); // 이름 바로 꺼내기

		log.info("메시지 전송 : roomNo={}, sender={}, senderName={}, content={}", 
				message.getChattingroomNo(),
				message.getChattingDetailSender(),
				message.getSenderName(),
				message.getChattingDetailContent()
		);
		
		// 전송 시간 및 타입 설정
		message.setChattingDetailSendAt(LocalDateTime.now());
		message.setType(message.getType() != null ? message.getType() : "TALK");
		
		// 타입이 TALK일 때만 DB 저장
		if("TALK".equals(message.getType())) {
			service.saveMessage(message); // DB 저장
			
			// 저장 후 안읽은 사람 수 계산 (발신자 제외한 참여자 전체)
			List<ChattingDetailVO> chattingCount = service.getMessageListWithUnreadCount(message.getChattingroomNo()); // 1은 최신 메시지 1개만 조회
			if(!chattingCount.isEmpty()) {
				// 리스트의 마지막 인덱스 번호 = (리스트 크기 - 1)
				int lastIndex = chattingCount.size() - 1;
				// message.setUnreadCount(lastIndex);
				message.setUnreadCount(chattingCount.get(lastIndex).getUnreadCount()); // 리스트의 마지막 객체에서 안읽은갯수 꺼내와야 해
			}
		}
		
		// ENTER 또는 LEAVE는 저장없이 바로 채팅방 구독자 전체에게 메시지 전달
		messagingTemplate.convertAndSend("/topic/chatroom/" + message.getChattingroomNo(), message);
	}

	/**
	 * 읽음 처리 
	 * 클라이언트 : /app/chat.markAsRead
	 * @param message 읽음 처리 정보
	 * @param headerAccessor 웹소켓 접속 정보
	 */
	@MessageMapping("/chat.markAsRead")
	public void markAsRead(
			@Payload ChattingDetailVO message, 
			Principal principal) {

		if (principal == null) {
            log.warn("인증되지 않은 사용자의 접근입니다.");
            return;
        }
		
		CustomEmployee loginUser = (CustomEmployee) ((Authentication) principal).getPrincipal();
		String userId = loginUser.getUsername();  // 사번 추출
		Long roomNo = message.getChattingroomNo();	// 채팅방 번호 추출
		Long lastReadNo = message.getChattingDetailNo();  // 상대방이 마지막으로 읽은 메시지 번호

		log.info("읽음 처리: user={}, roomNo={}, lastReadNo={}", userId, roomNo, lastReadNo);

		// 비즈니스 로직 수행
		service.updateReadStatus(userId, roomNo, lastReadNo);
		
		message.setType("READ");
		message.setChattingDetailSender(userId);

		// 메시지 전송
		// 읽음 처리한 사용자에게만 응답
		//messagingTemplate.convertAndSendToUser(userId, "/queue/read", message);
		// 나에게만 보내는 것이 아니라, 방 전체에 "누가 어디까지 읽었다"라고 알려줌
	    // 그래야 상대방 JS의 subscribe 콜백이 실행되어 UI에서 '1'을 지울 수 있음
		messagingTemplate.convertAndSend("/topic/chatroom/" + roomNo, message);
	}
	
	/**
	 * 채팅방 완전 퇴장
	 * 클라이언트 : app/chat.leaveRoom
	 * @param message
	 * @param headerAccessor
	 */
	@MessageMapping("/chat.leaveRoom")
	public void leaveRoom(
			@Payload ChattingDetailVO message, 
			Principal principal) {

		if (principal == null) {
            log.warn("인증되지 않은 사용자의 접근입니다.");
            return;
        }
		
		CustomEmployee loginUser = (CustomEmployee) ((Authentication) principal).getPrincipal();

		String userId = loginUser.getUsername();
		Long roomNo = message.getChattingroomNo();
	
		service.leaveChatRoom(roomNo, userId);

		message.setType("LEAVE");
		message.setChattingDetailSender(userId); 
	
		messagingTemplate.convertAndSend("/topic/chatroom/" + roomNo, message);
	}
	
	/**
	 * 접속 처리
	 * @param chatMessage
	 * @param headerAccessor
	 * @param loginUser
	 */
	@MessageMapping("/chat.addUser") // 접속할 때
	public void addUser(
			@Payload ChattingDetailVO chatMessage, 
			SimpMessageHeaderAccessor headerAccessor,
			Principal principal) {
		
		// 2. Principal이 null인지 확인
	    if (principal == null) {
	        log.warn("### 메신저 접속 실패: 인증 정보 없음");
	        return;
	    }

	    // 3. 수동으로 CustomEmployee 추출 (가장 확실한 방법)
	    CustomEmployee loginUser = (CustomEmployee) ((Authentication) principal).getPrincipal();
	    String empNoStr = loginUser.getUsername();

	    // 1. 온라인 명단에 추가
	    MessengerEventListener.addOnlineUser(empNoStr);
	    
	    // 2. 연결 해제(Disconnect) 시 처리를 위해 세션에 사번 보관
	    headerAccessor.getSessionAttributes().put("employeeNo", empNoStr);
	    
	    log.info("### 메신저 접속 성공 - 사번: {}, 이름: {}", empNoStr, loginUser.getEmployee().getEmployeeName());
	}
}
