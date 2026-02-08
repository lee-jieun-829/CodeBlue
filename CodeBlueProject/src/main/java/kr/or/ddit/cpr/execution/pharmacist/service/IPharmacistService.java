package kr.or.ddit.cpr.execution.pharmacist.service;

import java.util.List;

import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.PharmacistOrderVO;

public interface IPharmacistService {

	public List<PharmacistOrderVO> getWaitingList();
	public void updateWaitingStatus(Long predetailNo, String preDrugdetailStatus) throws Exception;
	public PharmacistOrderVO getPatientDetail(Long predetailNo);
	public List<DrugVO> getOrderDrugList(Long predetailNo);
	public int updateComplete(Long predetailNo) throws Exception;

}
