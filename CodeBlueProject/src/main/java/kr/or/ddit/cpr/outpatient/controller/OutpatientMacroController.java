package kr.or.ddit.cpr.outpatient.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/macro")
public class OutpatientMacroController {
	
	@GetMapping("/doctorpage")
	public String macroPage() {
		return "doctor/doctorpage";
	}
}
