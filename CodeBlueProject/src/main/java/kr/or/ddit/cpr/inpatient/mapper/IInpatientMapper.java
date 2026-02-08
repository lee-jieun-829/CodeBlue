package kr.or.ddit.cpr.inpatient.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.vo.ClinicalDetailVO;
import kr.or.ddit.cpr.vo.DietVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.ExaminationVO;
import kr.or.ddit.cpr.vo.InpatientVO;
import kr.or.ddit.cpr.vo.OperationVO;
import kr.or.ddit.cpr.vo.OrderListVO;
import kr.or.ddit.cpr.vo.OrderSearchVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.ProgressNoteVO;
import kr.or.ddit.cpr.vo.TreatmentVO;


@Mapper
public interface IInpatientMapper {

	public List<InpatientVO> selectInpatientList(Map<String, Object> dataMap);
	public ClinicalDetailVO selectClinicalDetail(Long patientNo);
	public OrderListVO selectOrderList(Long patientNo);
	public List<OrderSearchVO> searchOrder(String category, String keyword);
	
	public int insertProgressNote(ProgressNoteVO noteVO);
	
	public void insertPreDetail(PredetailVO predetail);
	public void insertPreDrug(DrugVO drug);
	public void insertPreExamination(ExaminationVO exam);
	public void insertPreTreatment(TreatmentVO treat);
	public void insertPreDiet(DietVO diet);
	public void insertPreOperation(OperationVO oper);
	public void updatePreOperationStatus(Map<String, Object> param);
	
	public void updatePreStatusDC(Map<String, Object> pre);
	public void updatePreStatusChange(Map<String, Object> pre);
	public int updateDischarge(Map<String, Object> dischargeMap);
	public int insertDiagnosisDetail(Map<String, Object> params);
	


}
