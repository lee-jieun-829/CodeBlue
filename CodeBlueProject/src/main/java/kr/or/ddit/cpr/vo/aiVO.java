package kr.or.ddit.cpr.vo;

import java.sql.Date;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.Data;

@Data
public class aiVO {
	//ai테이블
	 private int aiNo;
	 private String aiContent;	
	 @JsonFormat(pattern = "yyyy-MM-dd")	
	 private Date aiDate;
	 private int chartNo;
	 private int patientNo;
	 
	 private List<AiDiagnosisVO> aiDiagnosis;
	 private List<AiDrugVO> aiDrug;
	 
	  
	
	 
	//ai 치료테이블	 
	 private int aiTreatmentNo;
	 private String aiTreatmentType;
	 private String aiTreatmentCode;
	 private String aiTreatmentName;
	 private int aiTreatmentDose;
	 private int aiTreatmentProq;
	 
	
	 
	 
}
