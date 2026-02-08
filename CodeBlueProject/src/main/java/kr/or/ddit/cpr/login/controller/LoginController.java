package kr.or.ddit.cpr.login.controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

import jakarta.servlet.http.HttpServletRequest;
import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.vo.EmployeeAuthVO;
import lombok.extern.slf4j.Slf4j;

/**
 * 로그인 화면 (jsp) 보여주는 Controller
 * 
 */
@Slf4j
@Controller
public class LoginController {

	// 모든 첫 페이지는 로그인페이지로
    @GetMapping("/")
    public String index() {
        log.info("## 무조건 로그인 페이지로!");
        return "redirect:/login";
    }
    
	// 로그인 화면
	@GetMapping("/login")
	public String loginForm() {
		log.info("## 컨트롤러 들어옴!");
		return "login/loginForm";
	}
	
	// SuccessHandler 가 보냄
	// 로그인 성공 후 교통 정리 (view router)
	@GetMapping("/login/router")
	public String loginRouter(@AuthenticationPrincipal CustomEmployee customEmployee,
							  HttpServletRequest request) {
		
        if (customEmployee == null) {
        	return "redirect:/login";
        }
        
        // ip 주소
        String scheme = request.getScheme();
        String host = request.getServerName();
        
        // 권한 체크
 		boolean isDoctor = false;
 		boolean isNurse = false;
        
 		// 권한에 따라서 루트 태우기
        for (EmployeeAuthVO auth : customEmployee.getEmployee().getAuthList()) {
            String role = auth.getAuth();
            
            if ("ROLE_DOCTOR".equals(role)) isDoctor = true;

            if ("ROLE_NURSE_OUT".equals(role) || "ROLE_NURSE_IN".equals(role)) {
               isNurse = true;
            }
        }

        String target;

        // 의사 잇으면 무조건
        if (isDoctor) {
            target = "redirect:" + scheme + "://" + host + ":5173/";
        }
        // 간호사 있으면
        else if (isNurse) {
            target = "redirect:" + scheme + "://" + host + ":8060/nurse/inpatientnurse";
        }
        // 그 외
        else {
            target = "redirect:" + scheme + "://" + host + ":5173/";
        }
        log.info("{} -> {}", customEmployee.getEmployee().getEmployeeName(), target);
        return target;
	}
}