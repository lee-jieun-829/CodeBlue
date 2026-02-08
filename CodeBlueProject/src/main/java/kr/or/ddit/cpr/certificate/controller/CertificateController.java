package kr.or.ddit.cpr.certificate.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/certificate")
public class CertificateController {

	/**
	 * 서류작성화면 출력 컨트롤러
	 * 작성자 : 박성현
	 * 작성일자 : 2026-01-08
	 * @param model
	 * @return certificate/main.jsp
	 */
	@GetMapping("/main")
	public String certificateMain(Model model) {
		log.info("certificateMain() 실행...!");
		
		model.addAttribute("bodyText", "login-page");
		return "certificate/main";
	}
}
