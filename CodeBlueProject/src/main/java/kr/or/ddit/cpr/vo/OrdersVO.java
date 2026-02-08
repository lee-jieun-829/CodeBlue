package kr.or.ddit.cpr.vo;

import java.sql.Date;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonFormat;

import lombok.Data;

@Data
public class OrdersVO {
	 private int orderNo;				//주문번호
	 private String orderStatus;		//주문상태
	 private int orderTotalamt;			//총금액
	 private int employeeNo;			//주문자 사번
	 private String orderType;			//약품/ 물품
	 private String orderContent;		//반려사유
	 @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd", timezone = "Asia/Seoul")
	 private Date orderDate;			//발주일
	 private String orderRejectDate;	//반려일
	 
	 //상세 주문목록
	 private List<OrderDetailVO> orderDetails;
}
