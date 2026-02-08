package kr.or.ddit.cpr.outpatient.vo;

import lombok.Data;

@Data
public class OutPatientChartDrugVO {
	private int patientNo;				// 환자 번호
	private int predetailNo;
	private String predrugDetailType;  // 약처방 주사냐 약이냐
	private int drugNo; 			// 약품번호
	private String drugName; 			// 약품명
	private String predrugDetailStatus;		// 약품 처방 실행 상태
	private String predrugDetailRemark;// 비고
	private String registrationStatus;// 환자 진료 진행 상태
	private int registrationNo;// 환자 접수 번호
	
	
}
