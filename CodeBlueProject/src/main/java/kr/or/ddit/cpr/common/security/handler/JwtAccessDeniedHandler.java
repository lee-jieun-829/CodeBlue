package kr.or.ddit.cpr.common.security.handler;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;

import org.springframework.http.MediaType;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;

import com.fasterxml.jackson.databind.ObjectMapper;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;

/**
 * 권한 실패 처리 핸들러 :: 인가 처리 과정에서 에외가 발생하는 경우 처리해주는 핸들러
 * 
 * 역할 : 필요한 권한이 없는 경우 403 응답을 반환하는 핸들러
 * 
 */
@Slf4j
@Component
public class JwtAccessDeniedHandler implements AccessDeniedHandler{
	
	@Override
	public void handle(HttpServletRequest request, HttpServletResponse response,
			AccessDeniedException accessDeniedException) throws IOException, ServletException {
		
		String requestURI = request.getRequestURI();
		
		// '/api/**' 접속시 → 403 JSON response
		if (requestURI.startsWith("/api/")) {
			
			log.info("403(권한 실패) :: JSON 응답: uri={}", requestURI);
	        
	        response.setStatus(HttpServletResponse.SC_FORBIDDEN);
	        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
	        response.setCharacterEncoding("UTF-8");
	        
	        Map<String, Object> body = new HashMap<>();
	        body.put("status", HttpServletResponse.SC_FORBIDDEN);
	        body.put("message", "접근 권한이 없어용");
	        
	        ObjectMapper mapper = new ObjectMapper();
	        mapper.writeValue(response.getOutputStream(), body);
	        
	} else {
		// 권한에 안맞는 파트 접속하면 → 메인 대시보드로 방출 ㄱ
        log.info("403(권한 실패) :: 에러 페이지 : uri={}", requestURI);
       
        response.sendRedirect("http://localhost:5173");
		}
	}
}