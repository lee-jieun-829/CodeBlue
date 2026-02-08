package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class PredetailWatingListVO {
	// 환자정보
	private int patientNo;				// 환자 번호
	private String patientName;			// 이름
	private String patientRegno1;		// 주민등록번호1
	private String patientGen;			// 성별
	private int patientAge;				// 환자 나이
	
    private int registrationNo;			// 접수번호
	private int admissionNo;			// 입원번호
	
	private String orderDate;
    
    private PredetailVO predetailVO;	// 처방정보
    
    // 검사
    private String preExamdetailStatus;	// 검사상태
    private String examinationName;		// 검사항목리스트
    
    // 치료
    private String preTreatdetailStatus;// 치료상태
    private String treatmentName;		// 치료항목리스트
}
