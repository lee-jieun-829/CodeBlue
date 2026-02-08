package kr.or.ddit.cpr.schedule.controller;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import kr.or.ddit.cpr.schedule.service.IScheduleService;
import kr.or.ddit.cpr.schedule.vo.ScheduleAdminVO;

@RestController
@RequestMapping("/api/calendar") 
@CrossOrigin(origins = "http://localhost:5173") 
public class ScheduleController {

    @Autowired
    private IScheduleService scheduleService;

    /**
     * 작성자: 윤여범
     * 일정 목록을 조회하는 메서드
     * @param employeeNo 사원 번호 (0일 경우 전체 또는 공통 일정 로직 적용)
     * @return 일정 목록 리스트
     */
    @GetMapping("/list")
    public List<ScheduleAdminVO> getScheduleList(@RequestParam(required = false, defaultValue = "0") int employeeNo) {
        return scheduleService.getScheduleList(employeeNo);
    }

    /**
     * 작성자: 윤여범
     * 새 일정을 등록하는 메서드
     * @param scheduleVO 등록할 일정 정보
     * @return 등록 성공 여부 (1: 성공, 0: 실패)
     */
    @PostMapping("/add")
    public int addSchedule(@RequestBody ScheduleAdminVO scheduleVO) {
        System.out.println("등록 데이터: " + scheduleVO);
        return scheduleService.insertSchedule(scheduleVO);
    }

    /**
     * 작성자: 윤여범
     * 기존 일정을 수정하는 메서드
     * @param scheduleVO 수정할 일정 정보
     * @return 수정 성공 여부 (1: 성공, 0: 실패)
     */
    @PostMapping("/update")
    public int updateSchedule(@RequestBody ScheduleAdminVO scheduleVO) {
        System.out.println("수정 데이터: " + scheduleVO);
        return scheduleService.updateSchedule(scheduleVO);
    }

    /**
     * 작성자: 윤여범
     * 일정을 삭제하는 메서드
     * @param scheduleNo 삭제할 일정 번호
     * @return 삭제 성공 여부 (1: 성공, 0: 실패)
     */
    @PostMapping("/delete/{scheduleNo}")
    public int deleteSchedule(@PathVariable int scheduleNo) {
        return scheduleService.deleteSchedule(scheduleNo);
    }

    /**
     * 작성자: 윤여범
     * 의사 목록을 조회하는 메서드 (일정 배정용)
     * @return 의사 정보 맵 리스트 (사번, 이름 등)
     */
    @GetMapping("/doctors")
    public List<Map<String, Object>> getDoctorList() {
        return scheduleService.getDoctorList();
    }
}