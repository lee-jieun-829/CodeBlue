package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class PatientVO {

	 private int patientNo;				// 환자 번호
	 private String patientName;		// 이름
	 private String patientRegno1;		// 주민등록번호1
	 private String patientRegno2;		// 주민등록번호2
	 private String patientTel;			// 전화번호
	 private String patientAddr1;		// 기본주소
	 private String patientEmail;		// 이메일
	 private String patientGen;			// 성별
	 private String patientMemo;		// 특이사항
	 private String patientAddr2;		// 상세주소
	 private String patientPostcode;	// 우편번호
	
	 private String patientAge;			// 환자 나이
	 private RegistrationVO registrationVO; // 접수 정보
	 private DrugVO drugVO; // 약품 정보
	 private PredrugDetailVO predrugDetailVO; // 약처방 디테일 정보
	 private PredetailVO predetailVO; // 약처방 디테일 정보
	 private String currentStatus; // 환자 최신 상태 값(selectPatientList 서브쿼리 결과 직접 받을 변수)
	 private String employeeName; // 담당의 이름 (입원 접수 시 필요)
	 
	 
	 
}
