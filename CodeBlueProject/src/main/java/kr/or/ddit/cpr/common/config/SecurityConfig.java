package kr.or.ddit.cpr.common.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.security.servlet.PathRequest;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityCustomizer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import jakarta.servlet.DispatcherType;
import jakarta.servlet.http.HttpServletResponse;
import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.common.security.CustomEmployeeDetailsService;
import kr.or.ddit.cpr.common.security.handler.JwtAccessDeniedHandler;
import kr.or.ddit.cpr.common.security.handler.JwtAuthenticationEntryPoint;
import kr.or.ddit.cpr.common.security.handler.LoginFailureHandler;
import kr.or.ddit.cpr.common.security.handler.LoginSuccessHandler;
import kr.or.ddit.cpr.common.security.jwt.JwtAuthenticationFilter;
import kr.or.ddit.cpr.common.security.jwt.JwtTokenProvider;
import kr.or.ddit.cpr.common.util.RequestUtils;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {
	
	@Autowired
	private JwtTokenProvider jwtTokenProvider;
	
	@Autowired
	private CustomEmployeeDetailsService customEmployeeDetailsService;
	
	@Autowired
	private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;
	
	@Autowired
	private JwtAccessDeniedHandler jwtAccessDeniedHandler;
	
	@Autowired
	private LoginSuccessHandler loginSuccessHandler;
	
	@Autowired
	private LoginFailureHandler loginFailureHandler;
	
	
	// permitAll 설정할 url 목록들
	private static final String[] PASS_URL = {
			"/",
			"/index.html",
			"/login",
			"/error",
			"/api/login/**",
			"/.well-known/**"
	};
	
	// react api ㅇㅋ
	private static final String[] REACT_PASS_URL = {
			"/api/**"
	};
	
	// 개발용으로 뚫어놧어유 (추후에 주석 처리)
	private static final String[] DEV_PERMIT_URL = {
			"/doctor/**", "/nurse/**", "/pharmacist/**", 
			"/radiologist/**", "/therapist/**", "/management/**",
			"/reception/**", "/admin/**", "/payment/**", "/certificate/**",
			"/notification/**", "/ws/**", "/upload/**", "/macro/**", "/waiting/**"
	};
	
	// 우리 static resource 는 봐주자! → 모두 우회 가능
	@Bean
	public WebSecurityCustomizer configure() {
		return (web)->web.ignoring()
						 .requestMatchers(PathRequest.toStaticResources().atCommonLocations())
						 .requestMatchers("/resources/**");
	}
	
	// 토큰 기반 필터 체인 구성 - 우선순위 1번째
	// api 전용 (jsp & react 전부!!)
	@Order(1)
	@Bean
	protected SecurityFilterChain filterChain(HttpSecurity http) throws Exception{
		log.info("filterChain 시~작");
		
		// 1차 방어선의 형태 변경 → '/api/**' 얘는 1차오더로 작동
		http.securityMatcher("/api/**");
		
		// CSRF, 스프링 기본 로그인이랑 basic 인증 비활성화..
		http.csrf((csrf)->csrf.disable());
		http.formLogin((login)->login.disable());
		http.httpBasic((basic)->basic.disable());
		
		// 헤더 설정 → 보안용 (우리꺼말고 다른거 뜨지말라고)
		http.headers((config)->config.frameOptions((fOpt)->fOpt.sameOrigin()));
		http.cors(cors -> cors.configurationSource(corsConfigurationSource()));
		
		// api 때문에 세션 끔 (stateless)
		http.sessionManagement((management)->management.sessionCreationPolicy(SessionCreationPolicy.STATELESS));
		
		http.addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider), UsernamePasswordAuthenticationFilter.class);
		
		// 1차 방어선 : React API 권한 설정
		http.authorizeHttpRequests((authorize)->authorize.requestMatchers(REACT_PASS_URL).permitAll()
														 .requestMatchers(DEV_PERMIT_URL).permitAll() // 개발용
														 .anyRequest().authenticated());

		
		// 예외 처리 (API는 JSON 응답)
		http.exceptionHandling(conf -> conf.authenticationEntryPoint(jwtAuthenticationEntryPoint)
										   .accessDeniedHandler(jwtAccessDeniedHandler)
		);
		
		
        return http.build();
	}
	
	
	// 세션 기반 필터 체인 구성 - 우선순위 2번째
	// JSP, 화면 전용 
	@Order(2)
	@Bean
	protected SecurityFilterChain filterChain2(HttpSecurity http) throws Exception{
		log.info("filterChain2 시~작");
		
		http.securityMatcher("/**");
		
		// CSRF 비활성화
		http.csrf((csrf)->csrf.disable());
		http.cors(cors -> cors.configurationSource(corsConfigurationSource()));
		
		// JSP 도 쿠키(JWT) 쓰니까 세션 끔
		http.sessionManagement((management)->management.sessionCreationPolicy(SessionCreationPolicy.STATELESS));
		
		// 2차 방어선 : JSP 웹 권한 설정
		http.authorizeHttpRequests((authorize)->authorize
				.dispatcherTypeMatchers(DispatcherType.FORWARD, DispatcherType.ASYNC, DispatcherType.INCLUDE).permitAll()
				.requestMatchers(PASS_URL).permitAll()
				.requestMatchers(DEV_PERMIT_URL).permitAll() // 개발용
				.anyRequest().authenticated());
		
		// 인증 예외 처리 (리다이렉트 방식) → 인증되지 않은 사용자가 접근햇을시
		http.exceptionHandling(conf -> conf.authenticationEntryPoint((request, response, authException) -> {
								//  AJAX나 API 라면 JSON 응답
								if(RequestUtils.isAjaxOrApi(request)) {
									response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
									response.setContentType("application/json;charset=UTF-8");
									response.getWriter().write("{\"msg\":\"인증이 필요합니다.\"}");
								}else {
									response.sendRedirect(request.getContextPath() + "/login");
								}}));
				
		http.httpBasic((hbasic)->hbasic.disable());
		
		// 로그인 설정 활성화랑 핸들러 등록하기
		http.formLogin((login)-> login.loginPage("/login")
								  	  .loginProcessingUrl("/login/check") 
									  .usernameParameter("employeeNo")
								      .passwordParameter("employeePassword")
									  .successHandler(loginSuccessHandler)
									  .failureHandler(loginFailureHandler)
									  .permitAll());
		
		
		// JWT 필터 등록 (JSP도 쿠키에서 토큰 꺼내야 함)
		http.addFilterBefore(new JwtAuthenticationFilter(jwtTokenProvider), UsernamePasswordAuthenticationFilter.class);
		
		// 로그아웃 처리, 쿠키 삭제 & 로그아웃 성공 핸들러 추가
		http.logout(logout -> logout.logoutUrl("/logout")
									// 쿠키 삭제
									.deleteCookies("ACCESS_TOKEN", "JSESSIONID")
									// 로그아웃 성공 핸들러
									.logoutSuccessHandler((request, response, authentication) -> {
										
			if (authentication != null && authentication.getPrincipal() instanceof CustomEmployee) {
		            CustomEmployee customEmployee = (CustomEmployee) authentication.getPrincipal();
		            log.info("## 로그아웃 완료 {}", customEmployee.getEmployee().getEmployeeName());
		        } else {
		            log.info("## 이미 만료됨");
		        }
			response.sendRedirect(request.getContextPath() + "/login?logout=true");
		    }));
		return http.build();
	}


	// 로그인 api 용 
	@Bean
	public AuthenticationManager authenticationManager(BCryptPasswordEncoder bCryptPasswordEncoder) {
		// 인증 제공자 인증 처리
		DaoAuthenticationProvider authProvider = new DaoAuthenticationProvider();
		// 사용자 정보를 가져올 서비스를 설정한다 이때 설정하는 클래스는 UserDetailsService 를 상속받는 클래스여야한다
		authProvider.setUserDetailsService(customEmployeeDetailsService);
		// 비밀번호 암호화하기 위한 인코더를 설정한다
		authProvider.setPasswordEncoder(bCryptPasswordEncoder);
		
		return new ProviderManager(authProvider);
	}
	
	// 비밀번호 암호화
	@Bean
	protected PasswordEncoder passwordEncoder() {
		return new BCryptPasswordEncoder();
	}
	
	// react 연동
	@Bean
	public CorsConfigurationSource corsConfigurationSource() {
		
		CorsConfiguration configuration = new CorsConfiguration();
		// 리액트 포트넘버
		configuration.addAllowedOrigin("http://localhost:5173");
		// 시연용 - pl의 ip 허용ㅎㅎ (추후 지울예정)
	    configuration.addAllowedOriginPattern("http://192.168.*.*:5173");
		// 메소드 전부 ㅇㅋ
		configuration.addAllowedMethod("*");
		// 헤더 너도 뭐 ㄱㅊ
		configuration.addAllowedHeader("*");
		// 너 충분히 자격잇어 ㅇㅇ
		configuration.setAllowCredentials(true);
		
		UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
		source.registerCorsConfiguration("/**", configuration);
		return source;
	}
}