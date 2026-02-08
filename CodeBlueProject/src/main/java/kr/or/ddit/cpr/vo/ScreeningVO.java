package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class ScreeningVO {
	private int screeningNo;
	private int screeningHeight;
	private int screeningWeight;
	private int screeningSystolic;
	private int screeningDiastolic;
	private double screeningTemperature;
	private int screeningPulse;
	private int patientNo;
	private int employeeNo;
	private int registrationNo;			// 접수번호
	private String patientMemo;
}
