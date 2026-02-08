package kr.or.ddit.cpr.reservation.controller;



import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.reservation.service.IReservationService;
import kr.or.ddit.cpr.vo.ScheduleVO;
import lombok.extern.slf4j.Slf4j;
@Slf4j
@RestController
@RequestMapping("/reservation")
public class PatientScheduleRestController {
	
	@Autowired
	private IReservationService service;
	/**
	 * 작성자: 이지은
	 * 진료예약 인서트 메소드 
	 * @param scheduleVO scheduleVO 인서트 할 진료 예약 정보
	 * @param customUser 로그인한 유저
	 * @return 성공하면 1, 실패하면 0
	 */
    @PostMapping("/reservationinsert")
    @ResponseBody
    public ResponseEntity<String> reservationInsert(@RequestBody ScheduleVO schedulevo, @AuthenticationPrincipal CustomEmployee customUser) {
    	
    	int employeeNo = customUser.getEmployee().getEmployeeNo();	//로그인 한 사용자 사번
    	String employeeName = customUser.getEmployee().getEmployeeName();	//로그인 한 사용자 이름
    	schedulevo.setEmployeeNo(employeeNo);
    	schedulevo.setEmployeeName(employeeName);
    	log.info("schedulevo:{}",schedulevo);
    	int result = service.reservationInsert(schedulevo);
    	if (result > 0) {             
            return new ResponseEntity<>("SUCCESS", HttpStatus.OK);
        } else {
           return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
    /**
     * 작성자: 이지은
     * 수술예약 인서트 메서드
     * @param schedulevo scheduleVO 인서트 할 수술 예약 정보
     * @param customUser 로그인한 유저
     * @return 성공하면 1, 실패하면 0
     */
    @PostMapping("/opreservationinsert")
    @ResponseBody
    public ResponseEntity<String> opReservationInsert(@RequestBody ScheduleVO schedulevo, @AuthenticationPrincipal CustomEmployee customUser) {
    	String employeeName = customUser.getEmployee().getEmployeeName();	//로그인 한 사용자 이름
    	schedulevo.setEmployeeName(employeeName);
    	int result = service.opReservationInsert(schedulevo);
    	if (result > 0) {             
            return new ResponseEntity<>("SUCCESS", HttpStatus.OK);
        } else {
           return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
    }
    
    /**
     * 작성자: 이지은
     * 일정 있는 의사 셀렉트 메소드
     * @param schedulevo 시작시간과 끝시간이 들어있는 vo
     * @return 일정있는 의사 목록 리스트
     */
    @PostMapping("/selectBusyDoctor")
    @ResponseBody
    public List<Integer> selectBusyDoctor(@RequestBody ScheduleVO schedulevo){ 	
    	
    	List<Integer> doctorList = service.selectBusyDoctor(schedulevo);
    	return doctorList;
    }
   
}
