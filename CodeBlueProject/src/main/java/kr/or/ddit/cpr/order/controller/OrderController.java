package kr.or.ddit.cpr.order.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.http.HttpStatus;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.order.service.IOrderService;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.OrderDetailVO;
import kr.or.ddit.cpr.vo.OrdersVO;
import kr.or.ddit.cpr.vo.ProductVO;
import lombok.extern.slf4j.Slf4j;
@Controller
@Slf4j
@RequestMapping("/order")
public class OrderController {	
		@Autowired
		private IOrderService service; 

		/**
		 * 작성자 : 이지은
		 * 약품 메인 출력 컨트롤러
		 * @return order/drug.jsp
		 */
		@GetMapping("/drug")
		public String drugForm() {		
			return "order/drug";
		}
		
		/**
		 * 작성자 : 이지은
		 * 약품 메인 출력 컨트롤러
		 * @return order/product.jsp
		 */
		@GetMapping("/product")
		public String productForm() {		
			return "order/product";
		}
		
		/**
		 * 작성자 : 이지은
		 * 주문목록 출력 컨트롤러
		 * @return order/list.jsp
		 */
		@GetMapping("/list")
		public String listForm() {		
			return "order/list";
		}
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
				@PageableDefault(size = 7, sort = "drugNo", direction = Sort.Direction.ASC) Pageable pageable,
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
	            @RequestParam(required=false, defaultValue="") String searchWord,
	            @AuthenticationPrincipal CustomEmployee customUser){
			int empNo = customUser.getEmployee().getEmployeeNo();
			Page<OrdersVO> orderList = service.orderSelect(pageable, searchWord,empNo);			
			return new ResponseEntity<>(orderList, HttpStatus.OK);
		}
		/**
		 * 작성자: 이지은
		 * @param orderNo 발주 주문 번호
		 * @return orderNo의 발주 상세
		 */
		@ResponseBody
		@GetMapping("/orderDetailSelect")
		public List<OrderDetailVO> orderDetailSelect(@RequestParam("orderNo") int orderNo){
			List<OrderDetailVO> OrderDetailVO = service.orderDetailSelect(orderNo);
			return OrderDetailVO;
		}
		/**
		 * 작성자: 이지은
		 * 발주 신청 삭제
		 * @param orderNo 삭제할 발주번호
		 * @return 성공하면 1, 실패하면 0
		 */
		@ResponseBody
		@GetMapping("/orderDelete")
		public int orderDelete(@RequestParam("orderNo") int orderNo) {
			int result = service.orderDelete(orderNo);
			return result;
		}
		/**
		 * 수정시 검색 기능
		 * @param type
		 * @param keyword
		 * @return 검색한 item vo
		 */
		@GetMapping("/searchItems")
		@ResponseBody
		public List<?> searchItems(@RequestParam String type, @RequestParam String keyword) {
		    if ("001".equals(type)) {
		        // DrugVO 리스트 반환 
		        return service.searchDrugs(keyword); 
		    } else {
		        // ProductVO 리스트 반환 
		        return service.searchProducts(keyword);
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
				@PageableDefault(size = 7, sort = "productNo", direction = Sort.Direction.ASC) Pageable pageable,
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
		
}
