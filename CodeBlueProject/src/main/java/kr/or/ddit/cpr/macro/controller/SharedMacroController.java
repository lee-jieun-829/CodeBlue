package kr.or.ddit.cpr.macro.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/macro")
public class SharedMacroController {

	@GetMapping("/shared")
	public String sharedPage() {
		return "macro/sharedpage";
	}
}
