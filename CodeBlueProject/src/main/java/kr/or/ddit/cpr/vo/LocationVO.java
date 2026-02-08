package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class LocationVO {
	private int locationNo; /* 장소번호 */
	private String locationCode; /* 장소코드 */
	private String locationName; /* 장소이름 */
	private int employeeNo; /* 사번 */
	
	private String employeeName;			// 직원 이름
	private String employeeCode;			// 직원 구분
}
