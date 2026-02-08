package kr.or.ddit.cpr.messenger.controller;

import java.security.Principal;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.vo.ChattingDetailVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class MessengerEventListener {
	
	@Autowired
	private SimpMessageSendingOperations messagingTemplete;
	
	// 온오프라인 오류 방지
	private static final Set<String> onlineUsers = ConcurrentHashMap.newKeySet();
	
	/**
	 * 사용자가 웹소켓에 연결되었을 때
	 * @author 빈다예
	 * @param event
	 */
	@EventListener
	public void handleWebSocketConnectListener(SessionConnectedEvent event) {
		log.info("새로운 웹소켓 연결 발생");
		// "누가" 연결됐는지 확인해서 전체 사용자에게 "누가" 접속했는지 브로드캐스트
		StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
		
		Principal principal = headerAccessor.getUser();
		
		if (principal != null && principal instanceof Authentication) {
			Authentication auth = (Authentication) principal;
			
			// CustomEmployee로 형변환하여 사번 추출
			if (auth.getPrincipal() instanceof CustomEmployee) {
				CustomEmployee customUser = (CustomEmployee) auth.getPrincipal();
				String employeeNo = customUser.getUsername(); // 또는 getEmployee().getEmployeeNo() 등
				
				log.info("[메신저 리스너] 사용자 접속 감지: {}", employeeNo);
				
				// 온라인 명단 등록
				onlineUsers.add(employeeNo);
				
				// 연결 끊김(Disconnect) 처리를 위해 세션에 사번 저장해두기
				// (Disconnect 때는 Principal이 이미 날아가거나 접근이 애매할 수 있어 여기에 백업합니다)
				if(headerAccessor.getSessionAttributes() != null) {
					headerAccessor.getSessionAttributes().put("employeeNo", employeeNo);
				}
				
				// 전체 방송 (필요하다면)
				broadcastStatus(employeeNo, "ONLINE");
			}
		} else {
			log.warn("[메신저 리스너] 인증되지 않은 연결 감지됨");
		}
		
	}
	
	/**
	 * 사용자가 웹소켓 연결을 끊었을 때 (브라우저 종료, 로그아웃 등)
	 * @author 빈다예
	 * @param event
	 */
	@EventListener
	public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
		StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
		
		// 여기도 Null 체크 추가
        Map<String, Object> sessionAttributes = headerAccessor.getSessionAttributes();
        
        if (sessionAttributes == null) {
        		String employeeNo = (String) sessionAttributes.get("employeeNo");
			
			if (employeeNo != null) {
				log.info("[메신저 리스너] 사용자 연결 종료: {}", employeeNo);
				
				// 명단에서 삭제
				onlineUsers.remove(employeeNo);
				
				// 퇴장 방송
				broadcastStatus(employeeNo, "OFFLINE");
			}
        }
	}
	
	// 상태 알림 방송 메서드 (여기에 선언!)
	private void broadcastStatus(String employeeNo, String status) {
		ChattingDetailVO statusMessage = new ChattingDetailVO();
		statusMessage.setType(status); // "ONLINE" 또는 "OFFLINE"
		statusMessage.setChattingDetailSender(employeeNo); // 누가?
		
		try {
			messagingTemplete.convertAndSend("/topic/status", statusMessage);
			log.info("### [메신저 방송 성공] {} -> {}", employeeNo, status);
		} catch (Exception e) {
			log.error("메시지 방송 중 에러", e);
		}
	}
	
	// 현재 누가 온라인인지 리스트를 확인하고 싶을 때 쓰는 메서드
	public static Set<String> getOnlineUsers() {
		return new HashSet<>(onlineUsers);
	}

	// 컨트롤러에서 호출할 수 있는 수동 등록 메서드
	public static void addOnlineUser(String employeeNo) {
        if (employeeNo != null) {
            onlineUsers.add(employeeNo);
            log.info("### 온라인 명단에 추가됨 : {} (현재 총 인원: {}명)", employeeNo, onlineUsers.size());
        }
    }
}
