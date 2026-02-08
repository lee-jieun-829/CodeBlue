package kr.or.ddit.cpr.outpatient.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.outpatient.service.IPatientService;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.OutPatientListVO;
import lombok.extern.slf4j.Slf4j;

@Controller
@Slf4j
@RequestMapping("/doctor")
public class OutpatientController {
	
	@Autowired
	IPatientService patientService;
	
	/**
	 * 작성자 : 이지은
	 * 외래진료화면 출력 컨트롤러
	 * @return outpatient.jsp
	 * @수정 장우석 2026/01/08
	 */
	@GetMapping("/outpatient")
	public String outpatientForm(Authentication auth, Model model) {
		
		CustomEmployee user = (CustomEmployee)auth.getPrincipal();
		
		String username = user.getUsername();
		
		EmployeeVO employeeVO = new EmployeeVO();
		employeeVO.setEmployeeNo(Integer.parseInt(username));
		
		List<OutPatientListVO> patientList = patientService.selectOutPatientList(employeeVO);
		
		model.addAttribute("patientList",patientList);
		
		
		return "doctor/outpatient";
	}
}