package kr.or.ddit.cpr.consult.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/consultation")
public class ConsultationController {

	/**
	 * 협진 출력 컨트롤러
	 * 작성자 : 박성현
	 * 작성일자 : 2026-01-10
	 * @param model
	 * @return consultation/main.jsp
	 */
	@GetMapping("/main")
	public String ConsultationMain(Model model) {
		model.addAttribute("bodyText", "login-page");
		return "consultation/main";
	}
}
