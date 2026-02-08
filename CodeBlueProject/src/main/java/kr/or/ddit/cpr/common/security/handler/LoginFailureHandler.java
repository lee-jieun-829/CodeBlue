package kr.or.ddit.cpr.common.security.handler;

import java.io.IOException;

import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.authentication.AuthenticationFailureHandler;
import org.springframework.stereotype.Component;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import kr.or.ddit.cpr.common.util.RequestUtils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class LoginFailureHandler implements AuthenticationFailureHandler{
	
	@Override
	public void onAuthenticationFailure(HttpServletRequest request, HttpServletResponse response, AuthenticationException exception) throws IOException, ServletException {
	
	if(RequestUtils.isAjaxOrApi(request)) {
		// axios, api → 401
		log.info("## 로그인 실패 {}", exception.getMessage());
		response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().write("{\"msg\":\"사번 또는 비밀번호가 일치하지 않습니다.\"}");
	}else {
		// form 리다이렉트
		log.info("## 로그인 실패 : 리다이렉트");
        response.sendRedirect(request.getContextPath() + "/login?error=true");
        }
	}
}