package kr.or.ddit.cpr.messenger.handler;

import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.support.HttpSessionHandshakeInterceptor;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.common.security.jwt.JwtTokenProvider;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class MessengerHandshakeInterceptor extends HttpSessionHandshakeInterceptor {
    
    @Autowired
    private JwtTokenProvider provider;
    
    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response, 
                                   WebSocketHandler wsHandler, Map<String, Object> attributes) throws Exception {
        
        if (request instanceof ServletServerHttpRequest) {
            HttpServletRequest servletRequest = ((ServletServerHttpRequest) request).getServletRequest();
            Cookie[] cookies = servletRequest.getCookies();
            
            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    if ("ACCESS_TOKEN".equals(cookie.getName())) {
                        String token = cookie.getValue();
                        log.info("[메신저] 토큰 발견: {}", token.substring(0, 20) + "...");
                        
                        // 토큰 검증 및 사번 추출
                        if (provider.validToken(token)) {
                            try {
                                Authentication auth = provider.getAuthentication(token);
                                
                                if (auth != null && auth.getPrincipal() instanceof CustomEmployee) {
                                    CustomEmployee customEmployee = (CustomEmployee) auth.getPrincipal();
                                    int empNo = customEmployee.getEmployee().getEmployeeNo();
                                    
                                    // 메신저용 세션 속성에 사번 저장
                                    attributes.put("employeeNo", String.valueOf(empNo));
                                    attributes.put("ACCESS_TOKEN", token); // 토큰도 함께 저장
                                    
                                    log.info("[메신저] 사번 추출 성공: {}", empNo);
                                    return true;
                                }
                            } catch (Exception e) {
                                log.error("[메신저] 사번 추출 중 오류", e);
                            }
                        }
                        
                        log.warn("[메신저] 토큰 검증 실패");
                        return false;
                    }
                }
            }
        }
        
        log.warn("[메신저] 토큰 없음");
        return false;
    }
}
