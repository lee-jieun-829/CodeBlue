package kr.or.ddit.cpr.outpatient.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import kr.or.ddit.cpr.outpatient.service.IOutPatientService;
import kr.or.ddit.cpr.patient.vo.PatientVO;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequestMapping("/nurse")
public class NurseOutpatientController {
	
	@Autowired
	private IOutPatientService service; 
	
	/**
	 * 작성자 : 한이혜지
	 * 외래 간호사 차트화면 출력 컨트롤러
	 * @return outpatientnursing.jsp
	 */
	
	@GetMapping("/outpatientnurse")
	public String outpatientnursingpage(Model model) {
		log.info("outpatientnursingpage 실행 중...!");

		return "nurse/outpatientnurse";
	}
	

}
