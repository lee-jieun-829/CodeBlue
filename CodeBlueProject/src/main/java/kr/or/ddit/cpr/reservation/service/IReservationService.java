package kr.or.ddit.cpr.reservation.service;

import java.util.List;

import kr.or.ddit.cpr.vo.ScheduleVO;

public interface IReservationService {	
	/**
	 * 작성자: 이지은
	 * 진료예약 인서트 메소드 
	 * @param scheduleVO scheduleVO 인서트 할 진료 예약 정보
	 * @param customUser 로그인한 유저
	 * @return 성공하면 1, 실패하면 0
	 */
	public int reservationInsert(ScheduleVO scheduleVO);
	 /**
     * 작성자: 이지은
     * 일정 있는 의사 셀렉트 메소드
     * @param schedulevo 시작시간과 끝시간이 들어있는 vo
     * @return 일정있는 의사 목록 리스트
     */
	public List<Integer> selectBusyDoctor(ScheduleVO schedulevo);
	/**
	 * 작성자: 이지은
	 * 예약 일정 셀렉트 메소드
	 * @return 진료 및 입원, 수술 일정 리스트
	 */
	public List<ScheduleVO> scheduleList();
	/**
	 * 작성자: 이지은
	 * 수술예약 인서트 메소드 
	 * @param scheduleVO scheduleVO 인서트 할 수술 예약 정보
	 * @param customUser 로그인한 유저
	 * @return 성공하면 1, 실패하면 0
	 */
	public int opReservationInsert(ScheduleVO schedulevo);
	

	
}
