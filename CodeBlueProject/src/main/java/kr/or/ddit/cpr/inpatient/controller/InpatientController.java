package kr.or.ddit.cpr.inpatient.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/doctor/inpatient")
public class InpatientController {

	/**
	 * 입원진료화면 출력 컨트롤러
	 * 작성자 : 박성현
	 * 작성일자 : 2026-01-05
	 * @param model
	 * @return inpatient/main.jsp
	 */
	@GetMapping("/main")
	public String inpatientMain(Model model) {
		model.addAttribute("bodyText", "login-page");
		return "doctor/inpatient/main";
	}
	

}
