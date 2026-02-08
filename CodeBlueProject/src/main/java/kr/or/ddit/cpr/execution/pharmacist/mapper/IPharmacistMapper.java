package kr.or.ddit.cpr.execution.pharmacist.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.data.repository.query.Param;

import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.PharmacistOrderVO;

@Mapper
public interface IPharmacistMapper {
	public List<PharmacistOrderVO> getWaitingList();
    
    // 파라미터가 2개이므로 @Param을 붙여 XML에서 #{...}로 찾을 수 있게 합니다.
	public int updateWaitingStatus(@Param("predetailNo") Long predetailNo, 
                            @Param("preDrugdetailStatus") String preDrugdetailStatus);
    
	public PharmacistOrderVO getPatientDetail(Long predetailNo);
	public List<DrugVO> getOrderDrugList(Long predetailNo);
	public int decreaseDrugStock(DrugVO drug);
	public int updatePrescriptionStatus(@Param("predetailNo") Long predetailNo);
}