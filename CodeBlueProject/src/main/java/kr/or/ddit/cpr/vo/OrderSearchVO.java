package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class OrderSearchVO {
	private String itemNo;		// 검색 처방 항목 번호
    private String itemName;	// 검색 처방 항목 이름
    private String categoryCode;// 처방 항목 카테고리
    private String drugType;// 처방 항목 카테고리
}
