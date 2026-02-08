package kr.or.ddit.cpr.notification.handler;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import org.springframework.web.util.UriComponentsBuilder;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.common.security.jwt.JwtTokenProvider;
import lombok.extern.slf4j.Slf4j;

/**
 * 실시간 알림 전송을 위한 웹소켓 핸들러
 * @author 강지현
 * 
 */
@Slf4j
@Component
public class NotificationWebSocketHandler extends TextWebSocketHandler{
	
	@Autowired
	private JwtTokenProvider provider; // 토큰 검증
	
	// 현재 접속 중인 사용자 세션 저장하는 Map(key : 사번, Value : 웹소켓 세션)
	// 멀티 스레드 환경에서 안전하도록 CuncurrentHashMap 사용
	private static final Map<Integer, WebSocketSession> userSessions = new ConcurrentHashMap<>();
	
	/**
	 * 클라이언트가 서버에 웹소켓 연결을 성공했을 때 호출
	 */
	@Override
	public void afterConnectionEstablished(WebSocketSession session) throws Exception {
		
		// 인터셉터가 담아준 토큰 꺼내기
		Map<String, Object> attributes = session.getAttributes();
		String token = (String) session.getAttributes().get("ACCESS_TOKEN");
	    log.info("전달된 토큰 확인: [{}]", token);
	    log.info("세션 속성 전체 출력: {}", session.getAttributes());
		
		// 토큰 유효성 검사 및 사번 추출 : 내부적으로 CustomEmployeeDetailsService가 동작하여 정보를 채워줌
        if (token != null && provider.validToken(token)) {
        	
        	// 인증정보 추출
        	Authentication authentication = provider.getAuthentication(token);
        	
        	if (authentication != null && authentication.getPrincipal() instanceof CustomEmployee) {
                CustomEmployee customEmployee = (CustomEmployee) authentication.getPrincipal();
                int empNo = customEmployee.getEmployee().getEmployeeNo();

                log.info("웹소켓 연결 성공: 사번 {}", empNo);
                userSessions.put(empNo, session);
        	}
        } else {
            log.warn("유효하지 않은 토큰 연결 시도 - 세션 종료");
            session.close(CloseStatus.POLICY_VIOLATION);
        }
	}
	
	
	// 하드코딩 테스트
	/*
	@Override
	public void afterConnectionEstablished(WebSocketSession session) throws Exception {
	    // 일단 무조건 연결되게 테스트 (사번 하드코딩)
	    int empNo = 26037909; 
	    userSessions.put(empNo, session);
	    log.info("강제 연결 성공: {}", empNo);
	}
	*/
	
	/**
	 * 전체 알림 및 실시간 대기 환자 목록 갱신을 위한 전체 전송 메서드
	 * @param message
	 */
	public void sendNotificationToAll(String message) {
		userSessions.values().forEach(session -> {
			try {
				if(session.isOpen()) {
					session.sendMessage(new TextMessage(message));
				}
			}catch(Exception e) {
				log.error("[WebSocket] 전체 알림 전송 중 에러", e);
			}
		});
	}
	
	/**
	 * 발신자 제외 전송
	 * @param message
	 * @param senderNo
	 */
	public void sendNotificationToAll(String message, int senderNo) {
		userSessions.forEach((empNo, session) -> {
			try {
				// 본인 제외
				if(empNo != senderNo && session.isOpen()) {
					session.sendMessage(new TextMessage(message));
				}
			}catch(Exception e) {
				log.error("[WebSocket] 발신자 제외 전체 전송 중 에러", e);
			}
		});
	}
	
	/**
	 * 특정 사용자에게 실시간 알림 메세지를 전송하는 공용 메서드
	 * @param targetEmpNo 수신자 사번
	 * @param message 전송할 내용
	 */
	public void sendNotification(int targetEmpNo, String message) {
		WebSocketSession targetSession = userSessions.get(targetEmpNo);
		
		try {
			// 상대방이 접속 중이고 세션이 열려있는 경우에만 전송
			if(targetSession != null && targetSession.isOpen()) {
				targetSession.sendMessage(new TextMessage(message));
				log.info("[WebSocket] 알림 전송 완료 - 대상: {}, 내용: {}", targetEmpNo, message);
			}else {
				log.info("[WebSocket] 알림 전송 건너뜀 -  대상: {}", targetEmpNo);
			}
			
		}catch(Exception e) {
			log.error("[WebSocket] 알림 전송 중 에러 발생 - 대상: {}", targetEmpNo, e);
		}
	}
	
	/**
	 * 클라이언트와 연결이 끊겼을 때 호출
	 */
	@Override
	public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
		// 연결 종료 시 맵에서 해당 세션제거
		userSessions.values().remove(session);
	    log.info("[WebSocket] 연결 종료");
	}
	
	/**
	 * 웹소켓 연결 URI에서 token 파라미터 추출
	 * @param session
	 * @return
	 */
	private String extractToken(WebSocketSession session) {
		String query = session.getUri().getQuery();
        if (query != null) {
            return UriComponentsBuilder.fromUriString("?" + query)
                    .build()
                    .getQueryParams()
                    .getFirst("token");
        }
        return null;
    }
	
}




