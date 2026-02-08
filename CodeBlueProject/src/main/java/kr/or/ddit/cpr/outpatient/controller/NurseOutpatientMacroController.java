package kr.or.ddit.cpr.outpatient.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/macro")
public class NurseOutpatientMacroController {

	@GetMapping("/nurse")
	public String macroPage() {
		return "nurse/nursepage";
	}
}
