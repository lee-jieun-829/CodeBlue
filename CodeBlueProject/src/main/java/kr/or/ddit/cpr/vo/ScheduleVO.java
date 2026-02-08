package kr.or.ddit.cpr.vo;


import java.time.LocalDateTime;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.Data;

@Data
public class ScheduleVO {
	private int scheduleDoctorNo; /* 의사번호*/
	private int patientNo; /* 환자번호 */
	private int scheduleNo; /* 일정번호 */
	private String scheduleTitle; /* 제목 */
	private String scheduleContent; /* 내용 */
	@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
	private LocalDateTime scheduleStart; /* 시작일시 */
	@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss", timezone = "Asia/Seoul")
	private LocalDateTime scheduleEnd; /* 종료일시 */
	private String scheduleType; /* 일정구분 */
	private int employeeNo; /* 사번 */
	private String backgroundColor; /* 배경색 */
	
	private String patientName; /*일정 제목 및 내용 삽입용*/
	private String employeeName; /*일정 내용 삽입용*/
	private String memo;		/*환자 테이블 특이사항 수정용 */
	
	List<OpScheduleVO> opSchedules;	/*수술예약 테이블 vo*/
}
