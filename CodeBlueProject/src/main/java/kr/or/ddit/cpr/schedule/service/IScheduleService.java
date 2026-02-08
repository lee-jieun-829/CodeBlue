package kr.or.ddit.cpr.schedule.service;

import java.util.List;
import java.util.Map;
import kr.or.ddit.cpr.schedule.vo.ScheduleAdminVO;

public interface IScheduleService {
    List<ScheduleAdminVO> getScheduleList(int employeeNo);
    int insertSchedule(ScheduleAdminVO scheduleVO);
    int updateSchedule(ScheduleAdminVO scheduleVO);
    int deleteSchedule(int scheduleNo);
    List<Map<String, Object>> getDoctorList();
}