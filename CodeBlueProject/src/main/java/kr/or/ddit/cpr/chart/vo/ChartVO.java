package kr.or.ddit.cpr.chart.vo;

import java.sql.Date;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChartVO {
	private int chartNo;					// 차트번호
	private String chartContent;			// 진단내용
	private Date chartRegdate;				// 기록 생성날짜
	private int employeeNo;					// 사번
	private int patientNo;					// 환자번호
	private int registrationNo;				// 접수번호
	private int admissionNo;				// 입원번호
}
