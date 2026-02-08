package kr.or.ddit.cpr.inpatient.service;

import java.util.List;
import java.util.Map;

import kr.or.ddit.cpr.vo.ClinicalDetailVO;
import kr.or.ddit.cpr.vo.InpatientVO;
import kr.or.ddit.cpr.vo.OrderListVO;
import kr.or.ddit.cpr.vo.OrderSearchVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.ProgressNoteVO;


public interface IInpatientService {

	/**
	 * <p> 환자 목록 조회 </p>
	 * @author 박성현
	 * @param dataMap
	 * @return List<InpatientVO>
	 */
	public List<InpatientVO> selectInpatientList(Map<String, Object> dataMap);
	
	/**
	 * <p> 환자 세부정보 조회 </p>
	 * @author 박성현
	 * @param patientNo
	 * @return
	 */
	public ClinicalDetailVO selectClinicalDetail(Long patientNo);
	
	/**
	 * <p>환자 오더정보 조회</p>
	 * @author 박성현
	 * @param patientNo
	 * @return
	 */
	public OrderListVO selectOrderList(Long patientNo);

	/**
	 * <p>카테고리별 처방 검색 조회</p>
	 * @author 박성현
	 * @param category
	 * @param keyword
	 * @return
	 */
	public List<OrderSearchVO> searchOrder(String category, String keyword);

	/**
	 * <p>경과기록지 입력 저장</p>
	 * @author 박성현
	 * @param noteVO
	 * @return
	 */
	public Map<String, Object> insertProgressNote(ProgressNoteVO noteVO);

	/**
	 * <p>처방 입력 저장</p>
	 * @author 박성현
	 * @param prescriptionList
	 * @return
	 */
	public Map<String, Object> insertPrescription(List<PredetailVO> prescriptionList);

	/**
	 * <p>처방 수정 </p>
	 * @author 박성현
	 * @param updateList
	 * @return
	 */
	public Map<String, Object> updatePrescription(List<Map<String, Object>> updateList);

	/**
	 * <p> 선택 환자 퇴원 대기 상태로 변경 </p>
	 * @author 박성현
	 * @param dischargeMap
	 * @return
	 */
	public Map<String, Object> updateDischarge(Map<String, Object> dischargeMap);

	/**
	 * <p> 상병명 입력 저장 </p>
	 * @author 박성현
	 * @param params
	 * @return
	 */
	public int insertDiagnosisDetail(Map<String, Object> params);




}
