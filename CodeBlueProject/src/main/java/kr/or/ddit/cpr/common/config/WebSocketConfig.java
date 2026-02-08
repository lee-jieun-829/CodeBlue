package kr.or.ddit.cpr.common.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

import kr.or.ddit.cpr.common.security.jwt.JwtHandshakeInterceptor;
import kr.or.ddit.cpr.notification.handler.NotificationWebSocketHandler;

/**
 * 웹소켓 연결 설정 파일
 */
@Configuration
@EnableWebSocket // 웹소켓 기능 활성화(알림용)
@EnableWebSocketMessageBroker // 채팅용 STOMP 활성화	
public class WebSocketConfig implements 
	WebSocketConfigurer,				// 알림용 인터페이스
	WebSocketMessageBrokerConfigurer	// 채팅용 인터페이스
{
	
	@Autowired
	private NotificationWebSocketHandler notificationWebSocketHandler;
	
	@Override
	public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
		// 핸들러 등록하고, 클라이언트가 접속할 주소 "/ws/alarm"으로 설정
		registry.addHandler(notificationWebSocketHandler, "/ws/alarm")
				//.setAllowedOrigins("http://localhost:5173") // 리액트 서버 접근 허용
				.setAllowedOriginPatterns("*") // 모든 도메인과 IP 허용
				//검증 인터셉터
				.addInterceptors(new JwtHandshakeInterceptor());
	}
	
	
	/**
	 * 실시간 채팅 설정
	 * 1) Message Broker 설정
	 * @param registry
	 */
	@Override
	public void configureMessageBroker(MessageBrokerRegistry registry) {
		// 클라이언트로 메시지 전송 시 prefix
		registry.enableSimpleBroker("/topic","/queue");
		// 클라이언트에서 서버로 메시지 발행 시 prefix
		registry.setApplicationDestinationPrefixes("/app");
		// 특정 사용자에게 메시지 보낼 때 prefix (읽음 처리 등)
		registry.setUserDestinationPrefix("/user");
	}
	
	/**
	 * 실시간 채팅 설정
	 * 2) STOMP Endpoint 등록
	 * @param registry
	 */
	
	@Override
	public void registerStompEndpoints(StompEndpointRegistry registry) {
		registry.addEndpoint("/ws/chat")
			/*.setAllowedOrigins(
		        "http://localhost:8060",  // JSP (같은 서버)
		        "http://localhost:5173"   // React
		    )*/
			.setAllowedOriginPatterns("*") // CORS 설정 => 임시**
			.withSockJS() // SockJS fallback 지원
			.setSessionCookieNeeded(true); 
	}

}
