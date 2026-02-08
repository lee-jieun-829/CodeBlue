package kr.or.ddit.cpr.vo;

import java.sql.Date;
import java.util.List;

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
	private String employeeName;			// 주치의명
	private int patientNo;					// 환자번호
	private int registrationNo;				// 접수번호
	private int admissionNo;				// 입원번호
	private int predetailCnt;				// 이 차트에 몇개의 처방이 있는지
	
	private List<DiagnosisVO> diagnosis;	// 차트에 포함된 상병 리스트
	private List<ProgressNoteVO> progressNotes;
	private List<NursingChartVO> nursingCharts;
	private List<NursingAssessmentVO> assessments;
	private List<PredetailVO> predetails;
}
