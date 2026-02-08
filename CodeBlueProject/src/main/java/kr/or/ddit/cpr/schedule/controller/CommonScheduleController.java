package kr.or.ddit.cpr.schedule.controller;




import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;



@Controller
@RequestMapping("/schedule")
public class CommonScheduleController {

    
    @GetMapping("/main")    
	public String scheduleForm() {		
		return "schedule/main";
	}
    
   
    
}