package kr.or.ddit.cpr.common.security.jwt;

import java.util.Map;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.http.server.ServletServerHttpRequest;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.support.HttpSessionHandshakeInterceptor;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class JwtHandshakeInterceptor extends HttpSessionHandshakeInterceptor {

    @Override
    public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse response, 
                                   WebSocketHandler wsHandler, Map<String, Object> attributes) throws Exception {
        
        if (request instanceof ServletServerHttpRequest) {
            HttpServletRequest servletRequest = ((ServletServerHttpRequest) request).getServletRequest();
            Cookie[] cookies = servletRequest.getCookies();

            if (cookies != null) {
                for (Cookie cookie : cookies) {
                    //  JWT 쿠키 
                    if ("ACCESS_TOKEN".equals(cookie.getName())) { 
                        // 찾아낸 토큰을 attributes에 넣어서 핸들러에서 꺼냄
                        attributes.put("ACCESS_TOKEN", cookie.getValue());
                        log.info("인터셉터에서 토큰 발견!");
                        return true; 
                    }
                }
            }
        }
        return true; // 연결은 허용하고 핸들러에서 최종 검증
    }
}