package kr.or.ddit.cpr.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DiagnosisVO {
	private Long diagnosisNo; // 진단번호
	private String diagnosisCode; // 상병코드
	private String diagnosisName; // 상병명
	private Long chartNo; // 차트번호
	private String diagnosisDetailYN; // 주진단/부진단
}
