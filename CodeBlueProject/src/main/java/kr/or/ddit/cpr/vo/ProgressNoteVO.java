package kr.or.ddit.cpr.vo;

import java.util.Date;

import lombok.Data;

@Data
public class ProgressNoteVO {
	private Long progressnoteNo; // 경과기록지번호
    private String progressnoteContent; // 경과기록내용
    private String progressnoteDate; // 기록날짜
    
    private int patientNo; // 환자번호
    private int employeeNo; // 직원번호
    private String employeeName;
    private int chartNo; // 차트번호
    
    public void setProgressnoteContent(String progressnoteContent) {
        this.progressnoteContent = progressnoteContent;
    }

    public void setChartNo(int chartNo) {
        this.chartNo = chartNo;
    }
}
