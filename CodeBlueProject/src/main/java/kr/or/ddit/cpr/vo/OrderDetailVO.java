package kr.or.ddit.cpr.vo;

import java.util.List;

import lombok.Data;

@Data
public class OrderDetailVO {
	 private int orderDetailNo;		//발주상세번호
	 private int orderDetailCount;	//주문수량	 
	 private int orderNo;			//주문번호
	 private int orderItemNo;		//약품번호, 물품번호
	 private String orderItemType;	//약품, 물품
	 
	 private List<DrugVO> drugList;
	 private List<ProductVO> productList;
	 
}
