package kr.or.ddit.cpr.master.drug.controller;

import java.util.Map;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/drug")
public class DrugRestController {
	
	@PostMapping("/insert")
	public Map<String, Object> insertDrug(){
		log.info("insertDrug() 진입..");
		
		
		return null;
	}
	
}
