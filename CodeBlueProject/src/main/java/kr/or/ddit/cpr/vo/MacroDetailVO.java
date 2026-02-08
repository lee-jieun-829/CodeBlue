package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class MacroDetailVO {
	
	private int macroDetailNo;			// 매크로 상세번호 
	private String macroDetailType;		// 구분
	private String macroDetailPrename;	// 처방명 (이전에 수정한 컬럼명)
	private int macroNo;				// 매크로 번호
	
}
