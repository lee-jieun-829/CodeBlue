package kr.or.ddit.cpr.master.diagnosis.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class DiagnosisVO {
	private int diagnosisNo;
	private String diagnosisCode;
	private String diagnosisName;
	
	private String diagnosisDetailYn;
}
