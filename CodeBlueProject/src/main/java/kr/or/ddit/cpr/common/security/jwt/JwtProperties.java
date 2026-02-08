package kr.or.ddit.cpr.common.security.jwt;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * Jwt 발급/검증에 필요한 설정 값을 보관하는 클래스
 * 
 * 1. 토큰 발급자 (issuer) : 토큰을 발행한 주체를 식별, 검증시 우리 병원이 발급한게 맞는지 확인할때 사용!
 * 2. 시크릿키 (secretKey) : 토큰을 생성/검증할 때 사용하는 암호화 키. 위조방지로 제일 중요함
 * 3. 유효시간 (expirationTime) : 토큰 발급된 후 유효시간 설정, 시간 오버시 만료되어 인증 실패!
 */

@Data
@Component
@ConfigurationProperties(prefix="jwt")
public class JwtProperties {
	// token 제공자 (kr.or.ddit.jwt.issuer > issuer)
	private String issuer;
	// 시크릿 키 (kr.or.ddit.jwt.secret_key > secretKey)
	private String secretKey;
	// token 유효 시간 → 1800000ms(application.properties에 설정함)
	private long expirationTime;
}