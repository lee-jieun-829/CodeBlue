package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class OperationVO {
	
	private Long operationNo; // 수술번호
	private String operationCode; // 수술코드
	private String operationName; // 수술명
	private String operationPrice; // 수술수가
	private String preoperationStatus; // 수술상태
	
	private Long predetailNo; // 처방상세번호
	private String preoperationRegdate; // 수술일자
	
	private Long employeeNo; // 직원번호
	private String employeeName;
	
	private String predetailRegdate;
}
