package kr.or.ddit.cpr.order.service;


import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.order.mapper.IOrderMapper;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.OrderDetailVO;
import kr.or.ddit.cpr.vo.OrdersVO;
import kr.or.ddit.cpr.vo.ProductVO;
import lombok.extern.slf4j.Slf4j;
@Slf4j
@Service
public class OrderServiceImpl  implements IOrderService{
	
	@Autowired
	private IOrderMapper mapper;
	
	@Override
	public Page<DrugVO> drugSelect(Pageable pageable,String searchWord) {
		long startRow = pageable.getOffset() + 1;
        int endRow = (int) (pageable.getOffset() + pageable.getPageSize());
        
        List<DrugVO> drugList =mapper.drugSelect(startRow, endRow, searchWord);
        int totalCount = mapper.selectDrugCount(searchWord);
        
        PageImpl<DrugVO> page=  new PageImpl<>(drugList, pageable, totalCount);
		return page;
	}

	@Override
	public List<DrugVO> notEnoughDrugSelect() {
		List<DrugVO> drugList=mapper.notEnoughDrugSelect();
		return drugList;
	}
	
	@Transactional
	@Override
	public int orderInsert(OrdersVO ordersVO) {
		int result = mapper.orderInsert(ordersVO);
		if (result > 0) {
			
			int orderNo = ordersVO.getOrderNo();
			List<OrderDetailVO> detailList = ordersVO.getOrderDetails();
			
	        if (detailList != null && !detailList.isEmpty()) {
	            for (OrderDetailVO detail : detailList) {
	            	detail.setOrderNo(orderNo);//부모 키(FK)를 자식에게 주입
	            	mapper.detailInsert(detail);
	            }
	        }
		}
		
		return result;
	}

	@Override
	public Page<OrdersVO> orderSelect(Pageable pageable, String searchWord,int empNo) {
		long startRow = pageable.getOffset() + 1;
        int endRow = (int) (pageable.getOffset() + pageable.getPageSize());
        List<OrdersVO> drugList =mapper.orderSelect(startRow, endRow, searchWord,empNo);
        int totalCount = mapper.selectOrderCount(searchWord);
        
        PageImpl<OrdersVO> page=  new PageImpl<>(drugList, pageable, totalCount);
		return page;
	}

	@Override
	public List<OrderDetailVO> orderDetailSelect(int orderNo) {
		List<OrderDetailVO> orderDetailVO =mapper.orderDetailSelect(orderNo);
		return orderDetailVO;
	}

	@Override
	public Page<ProductVO> productSelect(Pageable pageable, String searchWord) {
		long startRow = pageable.getOffset() + 1;
        int endRow = (int) (pageable.getOffset() + pageable.getPageSize());
        
        List<ProductVO> productList =mapper.productSelect(startRow, endRow, searchWord);
        int totalCount = mapper.selectProductCount(searchWord);
        
        PageImpl<ProductVO> page=  new PageImpl<>(productList, pageable, totalCount);
		return page;
	}

	@Override
	public List<ProductVO> notEnoughProductSelect() {
		List<ProductVO> productList=mapper.notEnoughProductSelect();
		return productList;
	}

	@Override
	@Transactional
	public int orderDetailUpdate(OrdersVO ordersVO) {
		log.info("ordersVO:{}",ordersVO);
		String  orderItemType = ordersVO.getOrderType();
		log.info("orderItemType:{}",orderItemType);
		int result =0;
		for(OrderDetailVO detail : ordersVO.getOrderDetails()) {
			int itemNo = detail.getOrderItemNo();
            int amount = detail.getOrderDetailCount();
			if("001".equals(orderItemType)) {//약품일때 
				log.info("약품 업데이트 시작");
				 mapper.drugAmountUpdate(itemNo,amount);
			}else {//물품일때
				log.info("물품 업데이트 시작");
				mapper.productAmountUpdate(itemNo,amount);
			}			
		}		
		result = mapper.ordersStatusUpdate(ordersVO.getOrderNo());
		return result;		
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public int orderDelete(int orderNo) {		
		  mapper.orderDetailDelete(orderNo);
		  int result = mapper.orderDelete(orderNo);
		return result;
	}

	@Override
	public List<DrugVO> searchDrugs(String keyword) {		
		return mapper.searchDrugs(keyword);
	}

	@Override
	public List<ProductVO> searchProducts(String keyword) {		
		return mapper.searchProducts(keyword);
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public int updateOrder(int orderNo, List<OrderDetailVO> orderDetails) {	
		mapper.orderDetailDelete(orderNo);
		int insertCount = 0;
		for(OrderDetailVO orderDetailVO : orderDetails) {
			orderDetailVO.setOrderNo(orderNo);
			insertCount += mapper.detailInsert(orderDetailVO);
		}
		if (insertCount == orderDetails.size()) {
	        return 1; 
	    } else {	        
	        return 0; 
	    }
	}
	

	@Override
	public int orderupdate(int orderNo, String orderStatus, String orderContent) {
		int result=mapper.orderupdate(orderNo,orderStatus,orderContent);
		return result;
	}

	

}
