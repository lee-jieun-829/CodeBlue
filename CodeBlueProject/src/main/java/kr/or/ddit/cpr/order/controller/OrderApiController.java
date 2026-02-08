package kr.or.ddit.cpr.order.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.order.service.IOrderService;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.OrdersVO;
import kr.or.ddit.cpr.vo.ProductVO;
import lombok.extern.slf4j.Slf4j;

@RestController 
@RequestMapping("/api/order") 
@Slf4j
public class OrderApiController {
	@Autowired
    private IOrderService service;
	
	/**
	 * 작성자: 이지은
	 * 약품 목록 출력 컨트롤러 
	 * @param pageable size= 한페이지에 출력될 갯수, sort 정렬기준, sort 정렬방법 
	 * @param searchWord 검색할 단어
	 * @return
	 */
	@ResponseBody
	@GetMapping("/drugList")
	public ResponseEntity<Page<DrugVO>> drugList(
			@PageableDefault(size = 9, sort = "drugNo", direction = Sort.Direction.ASC) Pageable pageable,
			@RequestParam(required = false) String searchWord){
		Page<DrugVO> drugList = service.drugSelect(pageable,searchWord); 
		System.out.println(drugList);
		return new ResponseEntity<>(drugList, HttpStatus.OK);
	}
	
	/**
	 * 작성자: 이지은
	 * 부족 약품 리스트 출력 컨트롤러
	 * @return 부족 약품 리스트
	 */
	@ResponseBody
	@GetMapping("/notEnoughDrug")
	public List<DrugVO> notEnoughDrug(){
		List<DrugVO> drugList = service.notEnoughDrugSelect();
		return drugList;
	}
	
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
	 * 물품 목록 출력 컨트롤러 
	 * @param pageable size= 한페이지에 출력될 갯수, sort 정렬기준, sort 정렬방법 
	 * @param searchWord 검색할 단어
	 * @return 물품 목록리스트
	 */
	@ResponseBody
	@GetMapping("/productList")
	public ResponseEntity<Page<ProductVO>> productList(
			@PageableDefault(size = 9, sort = "productNo", direction = Sort.Direction.ASC) Pageable pageable,
			@RequestParam(required = false) String searchWord){
		Page<ProductVO> productList = service.productSelect(pageable,searchWord); 
		System.out.println(productList);
		return new ResponseEntity<>(productList, HttpStatus.OK);
	}
	/**
	 * 작성자: 이지은
	 * 부족 물품 리스트 출력 컨트롤러
	 * @return 부족 물품 리스트
	 */
	@ResponseBody
	@GetMapping("/notEnoughProduct")
	public List<ProductVO> notEnoughProduct(){
		List<ProductVO> productList = service.notEnoughProductSelect();
		return productList;
	}
	
	/**
	 * 발주목록 리스트 출력 컨트롤러
	 * @param pageable size= 한페이지에 출력될 갯수, sort 정렬기준, sort 정렬방법
	 * @param searchType 
	 * @param searchWord 검색 단어
	 * @param customUser EmployeeNo담고있는 user객체
	 * @return 발주목록 리스트
	 */
	@ResponseBody
	@GetMapping("/orderList")
	public ResponseEntity<Page<OrdersVO>> orderList(
			@PageableDefault(size = 10, sort = "orderNo", direction = Sort.Direction.DESC) Pageable pageable,	            
            @RequestParam(required=false, defaultValue="") String searchWord            ){
		int empNo = 0;
		Page<OrdersVO> orderList = service.orderSelect(pageable, searchWord,empNo);			
		return new ResponseEntity<>(orderList, HttpStatus.OK);
	}
	
	@ResponseBody
	@PostMapping("/orderupdate")
	public ResponseEntity<String> orderupdate(@RequestBody OrdersVO ordersVO){
		String orderStatus = ordersVO.getOrderStatus();		
		String orderContent = ordersVO.getOrderContent();
		int orderNo = ordersVO.getOrderNo();
		int result = service.orderupdate(orderNo,orderStatus,orderContent);
		
		if (result > 0) {             
            return new ResponseEntity<>("SUCCESS", HttpStatus.OK);
        } else {
           return new ResponseEntity<>(HttpStatus.NOT_FOUND);
        }
	}

}
