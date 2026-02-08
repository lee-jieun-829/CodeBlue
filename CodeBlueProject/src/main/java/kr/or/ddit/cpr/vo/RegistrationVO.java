package kr.or.ddit.cpr.vo;

import lombok.Data;

/**
 * <p>환자 접수 정보 객체</p>
 * <pre>
 * 1. 내원 구분 및 보험 유형 관리
 * 2. 진료실(장소), 주치의 등의 프로세스 정보 포함
 * </pre>
 * @author 강지현
 */
@Data
public class RegistrationVO {

	 private int registrationNo;			// 접수번호
	 private String registrationVisittype;	// 내원구분
	 private String registrationInsurance;	// 보험유형
	 private String registrationRegdate;	// 접수일자
	 private String registrationStatus;		// 상태
	 private int locationNo;				// 장소번호
	 private int patientNo;					// 환자번호
	 private int employeeNo;				// 주치의
	 private String reservationYn;			// 예약여부
	 private String reservationTime;		// 예약일시
	 
	 private String registrationMemo;		// 환자 메모
}
