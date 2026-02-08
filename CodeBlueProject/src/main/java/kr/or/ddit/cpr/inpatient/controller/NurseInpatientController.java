package kr.or.ddit.cpr.inpatient.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import kr.or.ddit.cpr.inpatient.service.IInpatientNurseService;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/nurse")
public class NurseInpatientController {
	
	@Autowired
	private IInpatientNurseService inpatientNurseService;
	
	/**
	 * 작성자: 이지은
	 * 입원간호 메인페이지 출력 메서드
	 * @return inpatientnurse.jsp
	 */
	@GetMapping("/inpatientnurse")
	public String inpatientNurseMain() {
		return "nurse/inpatientnurse";
	}
	
}