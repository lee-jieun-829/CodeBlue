package kr.or.ddit.cpr.common.util;

import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;

import kr.or.ddit.cpr.common.security.CustomEmployee;
/**
 * <p>Spring Security 로그인 정보 UTILS</p>
 * * <pre>
 * 
 * 1. 현재 로그인한 사용자의 사번(ID)을 조회
 * 2. 어디서든 SecurityUtils.getCurrentUsername()으로 호출하여 사용
 * 사용법 : String myId = SecurityUtils.getCurrentUsername();
 *		   하면 내 사번 나옴~
 * </pre>
 * * @author 김경희
 *
 */
public class SecurityUtils {
	
    public static String getCurrentUsername() {
    	
    	Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    	
		if (auth == null || auth.getName().equals("anonymousUser")) return null;
		
		Object principal = auth.getPrincipal();
		
		if (principal instanceof UserDetails) {
			return ((UserDetails) principal).getUsername();
		}
		return principal.toString();
	}
    
    // 파싱없이 원본객체에서 int 로 꺼내기
	public static int getCurrentEmployeeNo() {
		Authentication auth = SecurityContextHolder.getContext().getAuthentication();
		
		if (auth == null || auth.getPrincipal() == null) {
			throw new RuntimeException("로그인 정보가 없습니다.");
		}
		
		Object principal = auth.getPrincipal();

		if (principal instanceof CustomEmployee) {
			CustomEmployee customEmp = (CustomEmployee) principal;
			return customEmp.getEmployee().getEmployeeNo(); 
		}
		
		throw new RuntimeException("로그인 사용자 정보 타입이 올바르지 않습니다.");
	}
}