package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data

public class StatsVO {
	
	private String yearMonth;		// "2026-01"
	private String typeCode;		// "A0001"
	private String typeName;		// "접수"
	private long cnt;				// "건수"
	private long amount;			// "금액"
}