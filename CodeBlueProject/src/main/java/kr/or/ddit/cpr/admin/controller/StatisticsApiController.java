package kr.or.ddit.cpr.admin.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.admin.service.IStatsService;
import kr.or.ddit.cpr.vo.StatsVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/admin/stats")
@PreAuthorize("hasRole('ROLE_ADMIN')")
public class StatisticsApiController {
	
	@Autowired
	private IStatsService statsService;
	
	@GetMapping("/yearstats")
	public ResponseEntity<List<StatsVO>> selectYearsStats(@RequestParam int year){
		log.info("{} 년도의 통계 요청함", year);
		
		// 연도 유효성
		if(year < 2000 || year > 2100) {
			return ResponseEntity.badRequest().build();
		}
		
		List<StatsVO> list = statsService.selectYearsStats(year);
		return ResponseEntity.ok(list);
	}
	
	@GetMapping("/demographics")
	public ResponseEntity<List<StatsVO>> selectDemographicsStats(@RequestParam int year){
		log.info("{} 년도의 통계 요청함", year);
		
		List<StatsVO> list = statsService.selectDemographicsStats(year);
		return ResponseEntity.ok(list);
	}
	
	// 신규 or 재방문 환자
	@GetMapping("/dailyPatients")
	public ResponseEntity<List<StatsVO>> selectDailyPatientStats(@RequestParam int year, @RequestParam int month){
		List<StatsVO> list = statsService.selectDailyPatientStats(year, month);
		
		return ResponseEntity.ok(list);
	}
	
	
}