package kr.or.ddit.cpr.common.security.jwt;

import java.security.Key;
import java.time.Duration;
import java.util.Date;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Header;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.MalformedJwtException;
import io.jsonwebtoken.UnsupportedJwtException;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import io.jsonwebtoken.security.SecurityException;
import jakarta.annotation.PostConstruct;
import kr.or.ddit.cpr.common.constant.SecurityConstants;
import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.common.security.CustomEmployeeDetailsService;
import kr.or.ddit.cpr.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;



/**
 * Jwt 토큰 발급자
 * 
 * 토큰 생성 : 로그인 성공시 jwt 토근 발급
 * 토큰 유효성 검증 : 위조/만료된건지 검증
 * 토큰 → authentication 으로 바꿈 : 요청이 들어올때 누구 요청인지 security context 에 올려야함
 * 
 */

@Slf4j
@Component
public class JwtTokenProvider {

	// 필드 주입으로 생성 (db로 매번 조회) : 나중에 생성자 주입으로 변경할 수도 있음! 조회 시간 오래걸리면 ㅜ
	@Autowired
	private JwtProperties jwtProperties;

	// db 조회
	@Autowired
	private CustomEmployeeDetailsService employeeDetailsService;
	
	// jwt 발급&검증을 위한 암호화 키
	private Key key;
	
	// PostConstruct → 얘 약간 react 의 useEffect 같은 느낌? 초기화 훅
	@PostConstruct
    public void init() {
		log.info("key 초기화 시~작");
        byte[] keyBytes = Decoders.BASE64.decode(jwtProperties.getSecretKey());
        this.key = Keys.hmacShaKeyFor(keyBytes);
    }
	
	// 1) token 발급하기
	public String generateToken(EmployeeVO employeeVO, Duration expiredAt) {
		Date now = new Date();
		return makeToken(new Date(now.getTime() + expiredAt.toMillis()), employeeVO);
	}
	
	// 2) token 생성하기
	private String makeToken(Date expiry, EmployeeVO employeeVO) {
		Date now = new Date();
		// int → String 으로 변환하여 저장하기..
		String strEmployeeNo = String.valueOf(employeeVO.getEmployeeNo());
		
		return Jwts.builder()
						.setHeaderParam(Header.TYPE, Header.JWT_TYPE)
						// 공용 설정
						.setIssuer(jwtProperties.getIssuer()) 
						.setIssuedAt(now)
						.setExpiration(expiry)
						.setSubject(strEmployeeNo)	// subject 에 넣을거면 int 값 안되고 무조건 string 밖에 안된다네요..
						// 개별 설정, 상수 패키지에 claim 넣어놧으니 안전상 수정함
						.claim(SecurityConstants.CLAIM_NAME, employeeVO.getEmployeeName())
						.claim(SecurityConstants.CLAIM_ROLES, employeeVO.getAuthList().stream()
						.map(auth -> auth.getAuth()).collect(Collectors.toList()))        
						.signWith(key) 
						.compact();
	}
	
	// 3) token 유효성 검증
	public boolean validToken(String token) {
		try {
			Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
			return true;
		} catch (SecurityException | MalformedJwtException e) {
			// 
			log.info("잘못된 JWT 서명 : {}", e.getMessage());
		} catch (ExpiredJwtException e) {
			// 30분 오바됨
			log.info("만료된 JWT 토큰 : {}", e.getMessage());
		} catch (UnsupportedJwtException e) {
			log.info("지원되지 않는 JWT 토큰 : {}", e.getMessage());
		} catch (IllegalArgumentException e) {
			// 프론트 오류
			log.info("JWT 토큰 잘못됨: {}", e.getMessage());
		}
		return false;
	}
	
	// 4) 토큰 기반으로 인증 정보를 가져오는 메소드
	public Authentication getAuthentication(String token) {
		// token 에서 사번 추출
		String strEmployeeNo = getEmployeeNo(token);
		
		// db 조회, UserDetails 로 받지만, 실제 :CustomEmployee 들어있음
		UserDetails userDetails = employeeDetailsService.loadUserByUsername(strEmployeeNo);
		// 형 변환후 db 정보 꺼내오기
		EmployeeVO employeeVO = ((CustomEmployee)userDetails).getEmployee();
		
		return new UsernamePasswordAuthenticationToken(userDetails, "",
													   employeeVO.getAuthList().stream()
													   .map(auth-> new SimpleGrantedAuthority(auth.getAuth()))
													   .collect(Collectors.toList()));
	}

	// 5) 토큰으로 직원 사번 가져오기
	private String getEmployeeNo(String token) {
		return getClaims(token).getSubject();
	}
	
	// 6) Claims 추출 (최신 JJWT 문법 적용)
	private Claims getClaims(String token) {
		return Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token).getBody();
	}

}