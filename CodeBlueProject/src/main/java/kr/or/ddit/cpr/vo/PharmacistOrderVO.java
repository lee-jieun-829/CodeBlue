package kr.or.ddit.cpr.vo;

import java.util.Date;
import java.util.List;

import lombok.Data;

/**
 * 약제실 오더에 대한 VO
 * 환자정보, 입원정보, 차트정보, 처방정보, 약제처방 정보를 담는다.
 */
@Data
public class PharmacistOrderVO {
	
	private Long predetailNo;
	// private Date predetailRegdate;
	private String predetailRegdate;
	private int chartNo;
	
	private int patientNo;
	private String patientName;
	private String patientAge;
	private String patientGen;			
	 private String patientMemo;
 
	private int admissionNo;
	private int roomNo; // 입원병실
	
	private int employeeNo; // 사번
	private String employeeName; // 주치의 이름
	
	private String drugNames; 
	private String predrugDetailStatus;
	private String stockOutFlag; // 재고가 부족한지 (Y: 부족 / N: 정상)
	
	// private PatientVO patientVO;
	private List<DrugVO> drugList;
}
