package kr.or.ddit.cpr.schedule.vo;

import lombok.Data;

@Data
public class ScheduleAdminVO {

    private int scheduleNo;     // PK
    private int employeeNo;     // 사번
    private int employeeCode;   // 직책 코드
    private int scheduleDoctorNo; //의사 사번(휴진시에 사용)
    private String title;       
    private String description; // 내용
    private String type;        

    private String start; 
    private String end;   

    private int allDay;         // 0 또는 1

    private String backgroundColor;      
    private String textColor;           

    public String getId() {
        return String.valueOf(scheduleNo);
    }
}