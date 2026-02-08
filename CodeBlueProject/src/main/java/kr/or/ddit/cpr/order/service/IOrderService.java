package kr.or.ddit.cpr.order.service;




import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.OrderDetailVO;
import kr.or.ddit.cpr.vo.OrdersVO;
import kr.or.ddit.cpr.vo.ProductVO;

public interface IOrderService {
	/**
	 * 작성자: 이지은
	 * 약품리스트 select 메서드
	 * @param pageable 페이징할 객체
	 * @param searchWord 검색 할 단어
	 * @return 약품 list
	 */
	public Page<DrugVO> drugSelect(Pageable pageable,String searchWord);
	
	/**
	 * 작성자: 이지은
	 * 부족약품 리스트 select 메서드
	 * @return 부족약품 리스트
	 */
	public List<DrugVO> notEnoughDrugSelect();
	
	/**
	 * 작성자: 이지은
	 * 발주 신청 메서드
	 * @param ordersVO 신청할 물품 or 약품 목록정보 및 주문자 사번
	 * @return 성공하면 1 실패하면 0
	 */
	public int orderInsert(OrdersVO ordersVO);
	
	/**
	 * 작성자: 이지은
	 * @param pageable pageable 페이징할 객체
	 * @param searchWord 검색 할 단어
	 * @return 발주 리스트
	 */
	public Page<OrdersVO> orderSelect(Pageable pageable, String searchWord, int empNo);
	
	/**
	 * 작성자: 이지은
	 * @param orderNo 상세 발주 번호
	 * @return orderNo의 상세 발주 vo
	 */
	public List<OrderDetailVO> orderDetailSelect(int orderNo);
	/**
	 * 작성자: 이지은
	 * 물품리스트 select 메서드
	 * @param pageable 페이징할 객체
	 * @param searchWord 검색 할 단어
	 * @return 물품 list
	 */
	public Page<ProductVO> productSelect(Pageable pageable, String searchWord);
	/**
	 * 작성자: 이지은
	 * 부족물품 리스트 select 메서드
	 * @return 부족약품 리스트
	 */
	public List<ProductVO> notEnoughProductSelect();
	/**
	 * 작성자: 이지은
	 * 물품, 약품 수량 업데이트
	 * @param detailVO 주문수량, 주문물품no가 들어있는 OrderDetailVO
	 * @return 성공하면 1 실패하면 0
	 */
	public int orderDetailUpdate(OrdersVO ordersVO);
	/**
	 * 작성자: 이지은
	 * 발주 기록 삭제 메서드
	 * @param orderNo 삭제할 발주 번호
	 * @return 성공하면 1 실패하면 0
	 */
	public int orderDelete(int orderNo);
	/**
	 * 작성자: 이지은
	 * 발주 수정 검색기능
	 * @param keyword 검색할 단어
	 * @return 검색한 item vo
	 */
	public List<DrugVO> searchDrugs(String keyword);
	public List<ProductVO> searchProducts(String keyword);
	/**
	 * 작성자: 이지은
	 * 발주 수정기능
	 * @param orderNo 업데이트 할 발주번호
	 * @param orderDetails 업데이트 할 발주 디테일
	 * @return 성공하면 1 실패하면 0
	 */
	public int updateOrder(int orderNo, List<OrderDetailVO>  orderDetails);
	/**
	 * 작성자: 이지은
	 * 관리자 승인/ 반려 상태 업데이트 기능
	 * @param orderNo 
	 * @param orderStatus 발주 상태
	 * @param orderRejectDate 반려 날짜
	 * @return 성공하면 1 실패하면 0
	 */
	public int orderupdate(int orderNo, String orderStatus, String orderRejectDate);
	
}
