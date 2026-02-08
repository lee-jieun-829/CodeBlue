package kr.or.ddit.cpr.common.security.jwt;

import java.io.IOException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import kr.or.ddit.cpr.common.constant.SecurityConstants;
import kr.or.ddit.cpr.common.security.CustomEmployee;
import lombok.extern.slf4j.Slf4j;

/**
 * JWT 토큰의 유효성을 검증하는 필터
 * SecurityConfig 에서 설정한 FilterChain 앞단에 위치함
 * 
 */
@Slf4j
public class JwtAuthenticationFilter extends OncePerRequestFilter{
	
	// 어노테이션은 쓸 수 없음 → 생성자 빈 안
	private JwtTokenProvider jwtTokenProvider;
	
	// 토큰 검증시 사용할 토큰 key 와 식별자
	private static final String HEADER_AUTHORIZATION  = "Authorization";
	private static final String TOKEN_PREFIX  = "Bearer ";
	
	// 생성자 빈을 이용해서 스프링 자원을 초기화할 때 활용
	public JwtAuthenticationFilter(JwtTokenProvider jwtTokenProvider) {
		this.jwtTokenProvider = jwtTokenProvider;
	}
	
	// override - OncePerRequestFilter() 
	@Override
	protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
			throws ServletException, IOException {
		//log.info("## 토큰 인증 필터");
		
		String token = resolveToken(request);
		
		try {
			// 토큰 ㅇ, 유효성 검증 ㅇ
			if(StringUtils.hasText(token) && jwtTokenProvider.validToken(token)) {
				// token 의 authentication 추출
				Authentication authentication = jwtTokenProvider.getAuthentication(token);
				
				// SeurityContext 에 저장 (로그인 된 거 유지)
				SecurityContextHolder.getContext().setAuthentication(authentication);
				
				// jsp 화면 렌더링 하기위해서 request 에 정보담기
				Object principal = authentication.getPrincipal();
				
				// Principal 이 우리가 만든 CustomEmployee 타입인지 확인
                if (principal instanceof CustomEmployee) {
                    CustomEmployee customEmployee = (CustomEmployee) principal;
                    
                    // JSP에서 ${employee.employeeName} 으로 사용 가능하게 연결
                    request.setAttribute("employee", customEmployee.getEmployee());
                }
				
				//log.info("jwt 인증 성공 : {}, uri : {}", authentication.getName(), request.getRequestURI());
			}
		} catch (Exception e) {
			// 토큰 만료되거나, 잘못됐을때
			SecurityContextHolder.clearContext();
			log.info("유효하지 않은 JWT 토큰 : {}, uri : {}", e.getMessage(), request.getRequestURI());
		}
		
		// 다음 필터로 보내기
		filterChain.doFilter(request, response);
	}

	// 헤더 에서 token 만 뽑는 메소드
	private String resolveToken(HttpServletRequest request) {
		// 헤더에서 먼저 잇는지 찾기
		String bearerToken = request.getHeader(HEADER_AUTHORIZATION);		
		// 있다면 "Bearer " 이후의 문자열만 리턴
		if(StringUtils.hasText(bearerToken) && bearerToken.startsWith(TOKEN_PREFIX)) {
			return bearerToken.substring(7);
		}
		// 없으면? 리액트가 아닌 JSP 환경에서는 쿠키에 토큰 잇음
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (SecurityConstants.ACCESS_TOKEN_COOKIE.equals(cookie.getName())) {
                    return cookie.getValue();
                }
            }
        }
		return null;
	}
}