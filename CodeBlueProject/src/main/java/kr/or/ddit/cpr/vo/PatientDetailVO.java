package kr.or.ddit.cpr.vo;


import lombok.Data;

/**
 * ================================
 * - 환자 정보 VO
 * - auth : Been daye
 * - date : 2026.01.04
 * ================================
 */
@Data
public class PatientDetailVO {
	
	private ChartVO chartVO;				// 차트 정보
	private PredetailVO predetailVO;		// 검사 정보
	private PatientVO patientVO;			// 환자정보
    private RegistrationVO registrationVO;	// 접수정보(보험종류)
    private ScreeningVO screeningVO;		// 환자 바이탈 정보
   
    // 주치의 정보
    private int employeeNo;					// 사번
	private String employeeName;			// 직원 이름
    
    private int patientAge; 			// 나이
    private String patientBirthdate; 	// 생일
    private String patientRegnoMasked; 	// 주민등록번호 마킹
    private String patientAddr;
}
