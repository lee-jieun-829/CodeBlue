package kr.or.ddit.cpr.execution.radiologist.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import lombok.extern.slf4j.Slf4j;
/**
 * ================================
 * - 영상검사 workview view 컨트롤러
 * - auth : Been daye
 * - date : 2026.01.02
 * ================================
 */

@Slf4j
@Controller
@RequestMapping("/radiologist")
public class RadiologistWorkController {

	@GetMapping("/workview")
	public String workView() {
		return "radiologist/workview";
	}
}
