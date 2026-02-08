package kr.or.ddit.cpr.schedule.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import kr.or.ddit.cpr.schedule.mapper.IScheduleMapper;
import kr.or.ddit.cpr.schedule.vo.ScheduleAdminVO;

@Service
public class ScheduleServiceImpl implements IScheduleService {

    @Autowired
    private IScheduleMapper scheduleMapper;

    /**
     * 작성자: 윤여범
     * 일정 목록 조회 구현
     * @param employeeNo 사원 번호
     * @return 일정 목록 리스트
     */
    @Override
    public List<ScheduleAdminVO> getScheduleList(int employeeNo) {
        return scheduleMapper.selectScheduleList(employeeNo);
    }

    /**
     * 작성자: 윤여범
     * 일정 등록 구현
     * @param scheduleVO 등록할 일정 정보
     * @return 등록된 행의 수
     */
    @Override
    public int insertSchedule(ScheduleAdminVO scheduleVO) {
        return scheduleMapper.insertSchedule(scheduleVO);
    }

    /**
     * 작성자: 윤여범
     * 일정 수정 구현
     * @param scheduleVO 수정할 일정 정보
     * @return 수정된 행의 수
     */
    @Override
    public int updateSchedule(ScheduleAdminVO scheduleVO) {
        return scheduleMapper.updateSchedule(scheduleVO);
    }

    /**
     * 작성자: 윤여범
     * 일정 삭제 구현
     * @param scheduleNo 삭제할 일정 번호
     * @return 삭제된 행의 수
     */
    @Override
    public int deleteSchedule(int scheduleNo) {
        return scheduleMapper.deleteSchedule(scheduleNo);
    }

    /**
     * 작성자: 윤여범
     * 의사 목록 조회 구현
     * @return 의사 정보 리스트
     */
    @Override
    public List<Map<String, Object>> getDoctorList() {
        return scheduleMapper.selectDoctorList();
    }
}