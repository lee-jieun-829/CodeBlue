package kr.or.ddit.cpr.patient.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.billing.service.IReceptionService;
import kr.or.ddit.cpr.vo.PatientVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/waiting")
public class WaitingListController {

	@Autowired
	private IReceptionService receptionService;
	
	@GetMapping("/realTime")
	public List<PatientVO> getWaitingList(){
		log.info("실시간 대기 명단 요청 수신");
		return receptionService.getWaitingList();
	}
}
