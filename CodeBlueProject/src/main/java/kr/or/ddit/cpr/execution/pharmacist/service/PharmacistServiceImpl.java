package kr.or.ddit.cpr.execution.pharmacist.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.execution.pharmacist.mapper.IPharmacistMapper;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.PharmacistOrderVO;

@Service
public class PharmacistServiceImpl implements IPharmacistService {

	@Autowired
	private IPharmacistMapper mapper;
	
	@Override
	public List<PharmacistOrderVO> getWaitingList() {
		return mapper.getWaitingList();
	}

	@Transactional(rollbackFor = Exception.class)
	@Override
	public void updateWaitingStatus(Long predetailNo, String preDrugdetailStatus) throws Exception {
		int updated = mapper.updateWaitingStatus(predetailNo, preDrugdetailStatus);
		
		if(updated == 0) {
            throw new Exception("환자 상태를 '조제중'으로 변경하는 데 실패했습니다.");
        }
	}

	@Override
	public PharmacistOrderVO getPatientDetail(Long predetailNo) {
		return mapper.getPatientDetail(predetailNo);
	}

	@Override
	public List<DrugVO> getOrderDrugList(Long predetailNo) {
		// 1. DB에서 처방 약품 목록 및 재고 정보 조회
        List<DrugVO> drugList = mapper.getOrderDrugList(predetailNo);

        // 2. 각 약품별 재고 상태 판별 로직 수행
        for (DrugVO drug : drugList) {
            long totalNeeded = drug.getDrugTotal();
            long currentStock = drug.getDrugAmount();
            long safetyStock = drug.getDrugSaftyStoke();

            if (currentStock < totalNeeded) {
                // 1순위: 현재고가 처방량보다 적어 조제 자체가 불가능한 경우
                drug.setStockStatus("IMPOSSIBLE");
            } else if ((currentStock - totalNeeded) < safetyStock) {
                // 2순위: 조제는 가능하나, 조제 후 남은 양이 안전재고 미만인 경우
                drug.setStockStatus("SHORTAGE");
            } else {
                // 3순위: 재고 충분
                drug.setStockStatus("NORMAL");
            }
        }
        
        return drugList;
	}

	@Transactional(rollbackFor = Exception.class)
	@Override
	public int updateComplete(Long predetailNo) throws Exception {
		List<DrugVO> drugList = mapper.getOrderDrugList(predetailNo);
		
		if (drugList == null || drugList.isEmpty()) {
            throw new Exception("조제할 약품 내역이 없습니다.");
        } 
		
        for (DrugVO drug : drugList) {
            // drug_total(1회량 * 횟수 * 일수)만큼 drug_amount에서 차감
            int stockResult = mapper.decreaseDrugStock(drug);
            
            if (stockResult == 0) {
                // 재고가 부족하거나 업데이트에 실패한 경우 예외를 던져 롤백시킵니다.
                throw new Exception("약품 [" + drug.getDrugName() + "]의 재고가 부족하거나 오류가 발생했습니다.");
            }
        }
		
        return mapper.updatePrescriptionStatus(predetailNo);
	}


}
