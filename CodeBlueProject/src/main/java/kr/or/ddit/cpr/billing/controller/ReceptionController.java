package kr.or.ddit.cpr.billing.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.extern.slf4j.Slf4j;

/**
 * <p>원무 화면 이동 컨트롤러</p>
 * <pre>
 * 1. billing 패키지 내 원무(Management) 화면 이동
 * </pre>
 * @author 강지현
 */
@Slf4j
@Controller
@RequestMapping("/management")
public class ReceptionController {

	/**
	 * <p>원무 화면으로 이동</p>
	 * @author 강지현
	 * @return 원무 JSP 경로 (/management/reception.jsp)
	 */
	@GetMapping("/reception")
	public String receptionForm() {
		log.info("patientReceptionForm() 실행");
		return "management/reception";
	}
	
}
