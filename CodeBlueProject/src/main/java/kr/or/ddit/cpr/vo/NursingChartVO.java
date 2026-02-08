package kr.or.ddit.cpr.vo;

import java.util.Date;

import lombok.Data;

@Data
public class NursingChartVO {
	
	private int chartNo;		//차트번호 
	private int nursingchartNo; // 간호기록지번호
    private String nursingchartContent; // 간호기록내용
    private Date nursingchartDate; // 기록날짜
    private String nursingchartPressure; // 혈압
    private String nursingchartTemperature; // 체온
    private String nursingchartPulse; // 맥박
    private String nursingchartDiet; // 식이상태
    private int employeeNo; // 직원번호
    
    private String employeeName; // 직원명      
	
}
