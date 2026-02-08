package kr.or.ddit.cpr.reservation.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.vo.OpScheduleVO;
import kr.or.ddit.cpr.vo.ScheduleVO;
@Mapper
public interface IReservationMapper {
    // 의사 목록 조회
    List<Map<String, Object>> selectDoctorList();
    
    //진료,입원 일정 예약 인서트
  	public int reservationInsert(ScheduleVO scheduleVO);
  	//수술 일정 예약 인서트
  	public int opReservationInsert(OpScheduleVO op);
  	
  	// 일정 있는 의사 목록 조회
  	public List<Integer> selectBusyDoctor(Map<String, Object> map);	
  	
  	//진료, 수술, 입원 일정 조회
	public List<ScheduleVO> scheduleList();

	
}
