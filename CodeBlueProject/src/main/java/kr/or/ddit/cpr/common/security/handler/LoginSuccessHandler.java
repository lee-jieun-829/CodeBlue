package kr.or.ddit.cpr.common.security.handler;

import java.io.IOException;
import java.time.Duration;

import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import kr.or.ddit.cpr.common.constant.SecurityConstants;
import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.common.security.jwt.JwtTokenProvider;
import kr.or.ddit.cpr.vo.EmployeeVO;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

/**
 * 로그인 성공 핸들러
 * 
 * 역할
 * 1) 로그인 성공 시 JWT(Access Token) 발급
 * 2) HttpOnly 쿠키 (ACCESS_TOKEN) 토큰 저장
 * 3) 리액트의 메인 대시보드(5173)로 보냄
 * 
 * 
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class LoginSuccessHandler implements AuthenticationSuccessHandler{
	
	// 토큰 발급기
    private final JwtTokenProvider jwtTokenProvider;
    
	@Override
	public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
			Authentication authentication) throws IOException, ServletException {

		log.info("로그인 성공, 계정: {}", authentication.getName());

        // 로그인한 계정 정보
        CustomEmployee principal = (CustomEmployee) authentication.getPrincipal();
        EmployeeVO employee = principal.getEmployee();
        
        //  JWT 토큰 생성, 개발용으로 24시간 설정함
        String accessToken = jwtTokenProvider.generateToken(employee, Duration.ofHours(24));
		
        // HttpOnly 쿠키 생성 (상수 사용)
        ResponseCookie cookie = ResponseCookie.from(SecurityConstants.ACCESS_TOKEN_COOKIE, accessToken)
                .path("/")             		 // 모든 경로에서 유효
                .sameSite("Lax")      		 // 리액트와 통신 호환성 유지
                .httpOnly(true)       		 // 자바스크립트 접근 차단
                .secure(false)         		 // https 적용 전이라 false (배포 시 true 변경)
                .maxAge(Duration.ofHours(24)) // 쿠키 수명 24시간 (개발용)
                .build();
        
        // 응답 헤더에 쿠키 넣기 (Set-Cookie)
        response.setHeader(HttpHeaders.SET_COOKIE, cookie.toString());

        // localhost 가 아닌 직접 접속한 ip를 계속 사용함
        response.sendRedirect(request.getContextPath() + "/login/router");

	}
}