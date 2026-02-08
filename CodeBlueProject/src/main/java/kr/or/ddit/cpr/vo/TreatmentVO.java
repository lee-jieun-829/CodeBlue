package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class TreatmentVO {

	private Long treatmentNo; // 치료번호
	private String treatmentCode; // 치료코드
	private String treatmentName; // 치로명
	private Long treatmentPrice; // 치료수가
	
	private Long predetailNo; // 처방상세번호
	private Long pretreatmentDetailDose; // 1회 투여량
	private Long pretreatmentDetailFreq; // 횟수
	private Long pretreatmentDetailDay; // 일수
	private String pretreatmentDetailMethod; // 방법
	private String pretreatmentDetailStatus; // 상태
	private String pretreatmentDetailRemark; // 비고
	
	private String predetailRegdate;
}
