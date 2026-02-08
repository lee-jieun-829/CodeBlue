package kr.or.ddit.cpr.vo;

import java.util.Date;

import lombok.Data;

@Data
public class InpatientVO {
	
	private int patientNo; // 환자 번호
	private String patientName; // 환자 이름
	private String patientGen; // 환자 성별
	private String patientAge; // 환자 나이
	private String patientRegno1; //환자 주민번호 앞자리
	private String patientMemo;		//환자 메모
	
	private int locationNo; // 장소 번호
	private String locationName; // 장소 이름
	private int roomNo; // 병실 번호
	private String bedStatus;  // 상태
	private int bedNo; // 침상 번호
	
	private int oldBedNo;//전실 전 쓰고 있던 침상번호
	
	private int employeeNo; // 직원 번호
	private String employeeName; // 직원 이름
	
	private int admissionNo; // 입원 번호
	private String admissionInsurance; // 입원 보험 유형
	private String admissionDate; // 입원 날짜
	private String dischargeDate; // 퇴원 날짜
	private String admissionStatus; // 입원 상태
	
}
