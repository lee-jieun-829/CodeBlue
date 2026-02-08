package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class DietVO {
	
	private Long dietNo; // 식이 번호
	private String dietCode; // 식이 코드
	private String dietName; // 식이 이름
	private String dietType; // 식이 유형
	private String dietPrice; // 식이 수가
	
	private Long predetailNo; // 처방상세 번호
	private Long predietDose; // 식이처방 용량
	private Long predietFreq; // 식이처방 빈도
	private Long predietDay; // 식이처방 일수
	private String predietStatus; // 식이처방 상태
	
	private String predetailRegdate;
}
