package kr.or.ddit.cpr.schedule.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.schedule.vo.ScheduleAdminVO;
import kr.or.ddit.cpr.vo.ScheduleVO;

@Mapper
public interface IScheduleMapper {
    // 일정 조회
    List<ScheduleAdminVO> selectScheduleList(int employeeNo);
    
    // 일정 등록
    int insertSchedule(ScheduleAdminVO scheduleVO);
    
    // 일정 수정
    int updateSchedule(ScheduleAdminVO scheduleVO);
    
    // 일정 삭제
    int deleteSchedule(int scheduleNo);
    
    // 의사 목록 조회
    List<Map<String, Object>> selectDoctorList();
    
    //진료 입원 일정 예약 인서트
  	public int insertPatientSchedule(ScheduleVO scheduleVO);
  	
  	// 일정 있는 의사 목록 조회
  	public List<Integer> selectBusyDoctor(Map<String, Object> map);
}