package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class ProductVO {
	 
	public int productNo;			//물품번호
	public String productCode;		//물품코드
	public String productName;		//물품명
	public String productCompany;	//제조사
	public int productCost;			//매입가
	public int productAmount;		//재고량
	public String productType;		//물품구분
	public String productSaftyStoke;//안전재고
}
