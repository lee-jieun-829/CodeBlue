package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class NursingAssessmentVO {
	private int chartNo;			//차트번호
    private int nursingAssessmentNo; // 간호정보조사지번호
    private String nursingAssessmentAdminPath; // 입원경로
    private int nursingAssessmentPainscore; // 통증점수 
    private String nursingAssessmentPainsite; // 통증부위
    private String nursingAssessmentFallrisk; // 낙상위험도
    private String nursingAssessmentSorerisk; // 욕창위험도
    private String nursingAssessmentSmoking; // 흡연
    private String nursingAssessmentAlcohol; // 음주
    private String nursingAssessmentDraft; // 임시저장여부
    private String nursingAssessmentHeight; // 키
    private String nursingAssessmentWeight; // 체중
    private String nursingAssessmentHistory; // 과거병력 및 알레르기
}
	
