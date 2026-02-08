package kr.or.ddit.cpr.schedule.vo;

import lombok.Data;

@Data
public class FullcalendarVO {

	private int fcId; 					// 캘린더설정번호
	private String id;					// 일정구분
	private String allDay;				// 하루종일
	private String start;				// 시작시간
	private String end;					// 끝시간
	private String title;				// 일정제목
	
	// 스타일 및 추가 정보
	private String backgroundColor;		// 배경색
	private String borderColor;			// 선색
	private String textColor;			// 글씨색
	private String type;				// DB일정구분
	
}
