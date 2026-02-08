package kr.or.ddit.cpr.execution.pharmacist.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/pharmacist")
public class PharmacistWorkController {

	@GetMapping("/workview")
	public String workview() {
		return "pharmacist/workview";
	}
}
