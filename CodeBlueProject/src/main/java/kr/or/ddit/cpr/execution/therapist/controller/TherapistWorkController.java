package kr.or.ddit.cpr.execution.therapist.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import lombok.extern.slf4j.Slf4j;

/**
 * ================================
 * - 물리치료 workview view 컨트롤러
 * - auth : Been daye
 * - date : 2026.01.12
 * ================================
 */
@Slf4j
@Controller
@RequestMapping("/therapist")
public class TherapistWorkController {

	@GetMapping("/workview")
	public String workVIew() {
		return "therapist/workview";
	}
}
