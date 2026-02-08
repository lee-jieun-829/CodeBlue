package kr.or.ddit.cpr.login.controller;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jakarta.servlet.http.HttpSession;
import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.employee.service.IEmployeeService;
import kr.or.ddit.cpr.login.service.ILoginService;
import kr.or.ddit.cpr.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/auth")
public class AuthApiController {

	@Autowired
	private ILoginService loginService;
	
	@Autowired
	private IEmployeeService employeeService;
	
	// 내가 누군지 판별하기
	@GetMapping("/me")
	public ResponseEntity<?> me(@AuthenticationPrincipal CustomEmployee principal) {
		
		int employeeNo = principal.getEmployee().getEmployeeNo();
		
		EmployeeVO employeeVO = employeeService.selectMyPage(employeeNo);
		
		//log.info("DB에서 조회한 사원번호 {} 의 pwTempYn 값: [{}]", employeeNo, employeeVO.getPwTempYn());
		
		List<String> roles = employeeVO.getAuthList().stream().map(a -> a.getAuth()).toList();
		
		String pwTempYn = employeeVO.getPwTempYn() == null ? "N" : employeeVO.getPwTempYn();
		
		// null 값 절 대 넣 지 마 (로그인 안됨 ㅜㅜ) 
		return ResponseEntity.ok(Map.of("employeeNo", employeeVO.getEmployeeNo(), "employeeName",
				employeeVO.getEmployeeName(), "roles", roles, "pwTempYn", pwTempYn));
	}
    
	// 비밀번호 찾기 (비로그인)
	@PostMapping("/findpw")
	public ResponseEntity<?> findpw(@RequestBody EmployeeVO employeeVO){
		try {
			loginService.processFindPassword(employeeVO);
			return ResponseEntity.ok(Map.of("status", "success", "msg", "임시 비밀번호가 메일로 발송되었습니다."));
		} catch (IllegalArgumentException e) {
			return ResponseEntity.badRequest().body(Map.of("msg", e.getMessage()));
		} catch (Exception e) {
			e.printStackTrace();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("msg", "메일 발송 중 오류 발생"));
		}
	}
	

	// 마이페이지 비밀번호 변경 - step 0 : 현재 비번 체크 API
	@PostMapping("/checkpw")
	public ResponseEntity<?> checkpw(@RequestBody Map<String, String> params) {

		String inputPw = params.get("currentPw");
		
		if (inputPw == null || inputPw.isEmpty()) {
			return ResponseEntity.badRequest().body(Map.of("msg", "비밀번호를 입력해주세요."));
		}

		try {
            boolean isMatch = loginService.checkPassword(inputPw);

			if (isMatch) {
				return ResponseEntity.ok(Map.of("status", "success", "msg", "비밀번호 확인 완료"));
			} else {
				return ResponseEntity.badRequest().body(Map.of("msg", "현재 비밀번호가 일치하지 않습니다."));
			}
		} catch (Exception e) {
			e.printStackTrace();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("msg", "서버 오류"));
		}
	}

	// 마이페이지 비밀번호 변경 - step 1 : 이메일 인증번호 발송 API
	@PostMapping("/sendAuthCode")
	public ResponseEntity<?> sendAuthCode(HttpSession httpSession) {
		try {
			String authCode = loginService.sendAuthCodeMail();

			long expiryTime = System.currentTimeMillis() + (3 * 60 * 1000);

			httpSession.setAttribute("pwAuthCode", authCode);
			httpSession.setAttribute("pwAuthExpiry", expiryTime);
			httpSession.setAttribute("pwAuthRetry", 0);

			// 재활용 금지~
			httpSession.removeAttribute("isPwVerified");

			return ResponseEntity.ok(Map.of("status", "success", "msg", "인증번호가 발송되었습니다."));

		} catch (RuntimeException re) {
			return ResponseEntity.badRequest().body(Map.of("msg", re.getMessage()));
		} catch (Exception e) {
			e.printStackTrace();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("msg", "메일 발송 실패"));
		}
	}

	// 마이페이지 비밀번호 변경 - step 1 : 인증번호 검증 API
	@PostMapping("/verifyAuthCode")
	public ResponseEntity<?> verifyAuthCode(@RequestBody Map<String, String> params, HttpSession httpSession) {

		String inputCode = params.get("code");
		String sessionCode = (String) httpSession.getAttribute("pwAuthCode");
		Long expiryTime = (Long) httpSession.getAttribute("pwAuthExpiry");
		Integer retryCount = (Integer) httpSession.getAttribute("pwAuthRetry");

		try {
			loginService.verifyAuthCode(inputCode, sessionCode, expiryTime, retryCount);
			
			// 성공 시 세션 정리
			clearAuthSession(httpSession);
			httpSession.setAttribute("isPwVerified", true);
			return ResponseEntity.ok(Map.of("status", "success", "msg", "인증되었습니다."));
			
		} catch (IllegalStateException e) {
			// 시간/횟수 초과 -> 세션 삭제
			clearAuthSession(httpSession);
			return ResponseEntity.badRequest().body(Map.of("msg", e.getMessage()));
			
		} catch (IllegalArgumentException e) {
			// 불일치 -> 횟수 증가 로직
			if (retryCount != null) {
				httpSession.setAttribute("pwAuthRetry", retryCount + 1);
				int leftCount = 5 - (retryCount + 1);
				return ResponseEntity.badRequest().body(Map.of("msg", "인증번호 불일치 (남은 횟수: " + leftCount + "회)"));
			}
			return ResponseEntity.badRequest().body(Map.of("msg", e.getMessage()));
		}
	}

	private void clearAuthSession(HttpSession httpSession) {
		httpSession.removeAttribute("pwAuthCode");
		httpSession.removeAttribute("pwAuthExpiry");
		httpSession.removeAttribute("pwAuthRetry");
	}

	// 마이페이지 비밀번호 변경 - step 2 : 비밀번호 수정 && 강제변경 모달 비밀번호 변경
	@PostMapping("/updatepw")
	public ResponseEntity<?> updatePassword(@RequestBody Map<String, String> params, HttpSession httpSession,
											@AuthenticationPrincipal CustomEmployee principal) {
		
		int employeeNo = principal.getEmployee().getEmployeeNo();
		EmployeeVO employeeVO = employeeService.selectMyPage(employeeNo);
		

		// step 1 통과했는지 체크
		Boolean isVerified = (Boolean) httpSession.getAttribute("isPwVerified");
		
		// 임시 비번 사용자 구분하기
		boolean isTempUser = "Y".equals(employeeVO.getPwTempYn());
		
		
		// 둘 다 아닐시 차단함
		if ((isVerified == null || !isVerified) && !isTempUser) {
			return ResponseEntity.status(HttpStatus.FORBIDDEN).body(Map.of("msg", "본인 인증이 완료되지 않았습니다."));
		}
		
		// 새로운 비밀번호 유효성 검사
		String newPw = params.get("newPw");
		
		if (newPw == null || newPw.trim().isEmpty()) {
			return ResponseEntity.badRequest().body(Map.of("msg", "새로운 비밀번호를 입력해주세요."));
		}

		try {
			loginService.updatePassword(newPw);
			httpSession.removeAttribute("isPwVerified");
			return ResponseEntity.ok(Map.of("status", "success", "msg", "비밀번호가 성공적으로 변경되었습니다."));
			
		} catch (Exception e) {
			e.printStackTrace();
			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(Map.of("msg", "변경 중 오류가 발생했습니다."));
		}
	}
}