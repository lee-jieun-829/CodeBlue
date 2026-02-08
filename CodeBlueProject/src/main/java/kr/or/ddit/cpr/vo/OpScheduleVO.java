package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class OpScheduleVO {
	private int scheduleNo; /* 일정번호 */
	private int employeeNo; /* 집도의 */
	private String opScheduleContent; /* 수술명 */
}
