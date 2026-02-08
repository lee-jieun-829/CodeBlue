package kr.or.ddit.cpr.common.constant;

public class SecurityConstants {
	
	// 객체 생성 방지
    private SecurityConstants() {}
	
	// 쿠키 이름
    public static final String ACCESS_TOKEN_COOKIE = "ACCESS_TOKEN";
    public static final String REFRESH_TOKEN_COOKIE = "REFRESH_TOKEN";
    
    // jwt 내부 키 - claim keys
    public static final String CLAIM_NAME = "name";
    public static final String CLAIM_ROLES = "roles";

}