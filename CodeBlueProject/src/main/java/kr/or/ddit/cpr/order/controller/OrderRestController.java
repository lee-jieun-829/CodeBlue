package kr.or.ddit.cpr.order.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.order.service.IOrderService;
import kr.or.ddit.cpr.vo.OrderDetailVO;
import kr.or.ddit.cpr.vo.OrdersVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/order")
public class OrderRestController {
	@Autowired
	private IOrderService service;
	/**
	 * 약품 발주 메서드
	 * @param ordersVO 발주주문목록
	 * @param customUser 로그인한 직원NO
	 * @return 성공이면 1, 실패면 0
	 */
	@PostMapping("/orderInsert")
	public ResponseEntity<String> orderInsert(
			@RequestBody OrdersVO ordersVO,
			@AuthenticationPrincipal CustomEmployee customUser) {
		int empNo = customUser.getEmployee().getEmployeeNo();
		ordersVO.setEmployeeNo(empNo);
		int result = service.orderInsert(ordersVO);
		
		if (result > 0) {             
            return new ResponseEntity<>("SUCCESS", HttpStatus.OK);
        } else {
           return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
	}
	/**
	 * 작성자: 이지은
	 * 수령완료 시 약품or물품 수량 업데이트
	 * @param detailVO 업데이트 할 itemNO, 수량이 들어있는 vo
	 * @return 성공이면 1, 실패면 0
	 */
	@PostMapping("/orderDetailUpdate")
	public ResponseEntity<String> orderDetailUpdate(@RequestBody OrdersVO detailVO) {
		int result = service.orderDetailUpdate(detailVO);		
		if (result > 0) {             
            return new ResponseEntity<>("SUCCESS", HttpStatus.OK);
        } else {
           return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
	}
	/**
	 * 작성자: 이지은
	 * @param ordersVO 발주 목록 수정 할 정보가 들어있는 vo
	 * @return 성공이면 1, 실패면 0
	 */
	@PostMapping("/updateOrder")
	@ResponseBody
	public int updateOrder(@RequestBody OrdersVO ordersVO) {	    
	    int orderNo = ordersVO.getOrderNo();
	    List<OrderDetailVO> orderDetails = ordersVO.getOrderDetails();
	    
	    return service.updateOrder(orderNo, orderDetails);
	}
	
	
	
}
