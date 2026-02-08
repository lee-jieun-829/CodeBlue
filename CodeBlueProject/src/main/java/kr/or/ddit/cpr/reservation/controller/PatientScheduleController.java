package kr.or.ddit.cpr.reservation.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.or.ddit.cpr.reservation.mapper.IReservationMapper;
import kr.or.ddit.cpr.reservation.service.IReservationService;
import kr.or.ddit.cpr.schedule.service.IScheduleService;
import kr.or.ddit.cpr.vo.ScheduleVO;
@Controller
@RequestMapping("/reservation")
public class PatientScheduleController {
	@Autowired
	private IScheduleService service;
	@Autowired
	private IReservationService rService;
	 /**
	  * 작성자: 이지은
	  * 의사목록을 가져오는 메서드
	  * @return 의사 이름과 사번이 들어있는 목록
	  */
    @GetMapping("/doctors")
    @ResponseBody
    public List<Map<String, Object>> getDoctorList() {
    	List<Map<String, Object>> doctorList = service.getDoctorList();
        return doctorList;
    }
    
    /**
     * 작성자: 이지은
     * 진료, 입원, 수술 일정 가져오는 메서드
     * @return 진료, 입원, 수술 일정 리스트
     */
    @GetMapping("/schedulelist")
    @ResponseBody
    public List<ScheduleVO> scheduleList(){
    	List<ScheduleVO> list = rService.scheduleList();
    	return list;
    }
    
}
