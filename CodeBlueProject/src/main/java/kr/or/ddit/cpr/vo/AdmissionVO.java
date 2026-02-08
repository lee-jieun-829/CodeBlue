package kr.or.ddit.cpr.vo;

import lombok.Data;

/**
 * <p>입원 환자 접수 정보 객체</p>
 * <pre>
 * 1. 입원 환자의 병상 배정 및 입퇴원 관리
 * 2. REGISTRATION(접수) 테이블과 연동되는 입원 전용 상세 데이터 포함
 * </pre>
 * @author 강지현
 */
@Data
public class AdmissionVO {

	 private int admissionNo;				// 입원번호
	 private String admissionVisittype;		// 내원구분
	 private String admissionInsurance;		// 보험유형
	 private String admissionDate;			// 입원일
	 private String dischargeDate;			// 퇴원일
	 private String admissionStatus;		// 상태
	 private int patientNo;					// 환자번호
	 private int bedNo;						// 침상번호
	 private int employeeNo;				// 주치의(직원번호)
	 
	 private int registrationNo;			// 외래 접수 번호
	 private String admissionMemo;			// 환자 메모
	 private String patientName;			// 환자 이름
	
}
