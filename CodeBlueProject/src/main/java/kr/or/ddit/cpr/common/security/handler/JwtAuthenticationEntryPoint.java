package kr.or.ddit.cpr.common.security.handler;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.springframework.http.MediaType;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;

/**
 * 인증 실패 처리 핸들러 :: 인증 처리 과정에서 예외가 발생하는 경우 예외를 처리해주는 핸들러
 * 
 * 역할 : 인증에 실패하였을 경우 401 응답을 리턴할수 있도록 EntryPoint를 구현
 * 
 */

@Slf4j
@Component
public class JwtAuthenticationEntryPoint implements AuthenticationEntryPoint {
	
	@Override
	public void commence(HttpServletRequest request, HttpServletResponse response,
			AuthenticationException authException) throws IOException, ServletException {
		
		String requestURI = request.getRequestURI();
		
		// api 붙으면 react 용 → JSON 에러 응답
		if(requestURI.startsWith("/api/")) {
	        
	        log.info("401(인증 실패) :: JSON 응답: uri={}", requestURI);
	        
	        response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
	        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
	        response.setCharacterEncoding("UTF-8");

	        Map<String, Object> body = new HashMap<>();
	        body.put("status", HttpServletResponse.SC_UNAUTHORIZED);
	        body.put("message", "인증이 필요합니다.");
	        
	        ObjectMapper mapper = new ObjectMapper();
	        mapper.writeValue(response.getOutputStream(), body);
	        
	    } else {
	        // JSP 페이지 접속 → 로그인 화면으로 이동
	        log.info("401(인증 실패) :: 로그인 페이지 리다이렉트: uri={}", requestURI);
	       
	        response.sendRedirect("/login"); 
	    }
	}
}