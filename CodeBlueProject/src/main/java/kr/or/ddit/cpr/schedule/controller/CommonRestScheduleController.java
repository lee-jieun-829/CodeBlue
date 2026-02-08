package kr.or.ddit.cpr.schedule.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.schedule.service.IScheduleService;
import kr.or.ddit.cpr.schedule.vo.ScheduleAdminVO;

@RestController
@RequestMapping("/schedule")
public class CommonRestScheduleController {

    @Autowired
    private IScheduleService scheduleService;    
   
    
    @GetMapping("/selectdoctor")    
    public List<Map<String, Object>> getDoctorList() {
        return scheduleService.getDoctorList();
    }
    
    
    @GetMapping("/list")
    public List<ScheduleAdminVO> getScheduleList(@RequestParam(required = false, defaultValue = "0") int employeeNo) {
        return scheduleService.getScheduleList(employeeNo);
    }

    
}