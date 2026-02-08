package kr.or.ddit.cpr.master.drug.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/drug")
public class DrugController {
	
	@GetMapping("/drugview")
	public String drugView() {
		log.info("drugView() 진입..");
		
		return "drug/drugview";
	}
	
}
