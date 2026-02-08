package kr.or.ddit.cpr.vo;

import java.util.Date;
import java.util.List;

import lombok.Data;

@Data
public class PredetailVO {

	private int predetailNo;
	private Date predetailRegdate;
	private String predetailType;
	private int chartNo;
	private String predetailStatus;
	private String chartContent;
	
	private int employeeNo;
	private String employeeName;
	
	List<DiagnosisVO> diagList;
	
	List<DrugVO> drugList;
	List<TreatmentVO> treatList;
	List<ExaminationVO> examList;
	List<OperationVO> operList;
	List<DietVO> dietList;
	
}
