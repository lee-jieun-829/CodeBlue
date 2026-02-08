package kr.or.ddit.cpr.vo;

import java.util.Date;

import lombok.Data;

@Data
public class OutPatientListVO {

	/* 식별자 (PK/FK) */
	private int registrationNo;        // 접수번호 (PK)
	private int patientNo;             // 환자번호
	private int employeeNo;            // 직원번호 (담당의)
	private String employeeName;

	/* 환자 기본 정보 */
	private String patientName;         // 환자명
	private String patientGen;          // 성별
	private String patientRegno1;       // 주민번호 앞자리 (생년월일)
	private String patientRegno2;
	private int patientAge;
	private String patientGenKr;
    private String reservationYn;		// 예약여부
    private String reservationTime;		// 예약일시
	
	/* 진료 상태 정보 */
	private String statusName;          // 상태명 (Alias: STATUS_NAME) -> "진료중"
	private String registrationStatus;  
	/* 내원 유형 정보 */
	private String visittypeName;       // 내원유형명 (Alias: VISITTYPE_NAME) -> "초진"
	private String registrationVisittype; 

	/* 보험 유형 정보 */
	private String insuranceName;       // 보험유형명 (Alias: INSURANCE_NAME) -> "건강보험"
	private String registrationInsurance; 

	/* 접수 일자 */
	private Date registrationRegdate;   // 접수일시
}
