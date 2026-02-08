package kr.or.ddit.cpr.order.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.OrderDetailVO;
import kr.or.ddit.cpr.vo.OrdersVO;
import kr.or.ddit.cpr.vo.ProductVO;

@Mapper
public interface IOrderMapper {
	//약품 리스트
	public List<DrugVO> drugSelect(long startRow, int endRow, String searchWord);
	//총 약품 갯수 카운트(페이징용)
	public int selectDrugCount(String searchWord);
	//부족약품리스트
	public List<DrugVO> notEnoughDrugSelect();
	//발주신청 인서트
	public int orderInsert(OrdersVO ordersVO);
	//약품 발주신청 상세 인서트
	public int detailInsert(OrderDetailVO detail);
	//발주 리스트
	public List<OrdersVO> orderSelect(long startRow, int endRow, String searchWord,int empNo);
	//발주 리스트 카운트
	public int selectOrderCount(String searchWord);
	//발주 상세
	public List<OrderDetailVO> orderDetailSelect(int orderNo);
	//발주 삭제
	public int orderDelete(int orderNo);
	public int orderDetailDelete(int orderNo);
	//물품 리스트
	public List<ProductVO> productSelect(long startRow, int endRow, String searchWord);
	//총 물품 갯수 카운트(페이징용)
	public int selectProductCount(String searchWord);
	//부족물품리스트
	public List<ProductVO> notEnoughProductSelect();
	//약품 및 물품 주문완료 수량 업데이트
	public int drugAmountUpdate(@Param("drugNo") int drugNo, @Param("drugAmount") int amount);
	public int productAmountUpdate(@Param("productNo") int productNo, @Param("productAmount") int amount);	
	public int ordersStatusUpdate(int orderNo);
	//발주 수정 검색기능
	public List<DrugVO> searchDrugs(String keyword);
	public List<ProductVO> searchProducts(String keyword);
	//관리자 발주 상태 업데이트 기능
	public int orderupdate(@Param("orderNo") int orderNo, @Param("orderStatus") String orderStatus, @Param("orderContent") String orderContent);
	
	
	
	
}
