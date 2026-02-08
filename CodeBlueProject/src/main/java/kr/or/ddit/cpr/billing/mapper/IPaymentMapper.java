package kr.or.ddit.cpr.billing.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.vo.AdmissionVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.RegistrationVO;

@Mapper
public interface IPaymentMapper {

	/**
	 * 외래 수납 대기 목록 조회 (수납대기(004)인 환자)
	 * @return
	 */
	public List<Map<String, Object>> selectOutpatientWaitingList();

	/**
	 * 입원 수납 대기 목록 조회(퇴원대기(002), 퇴원수납대기(003)인 환자)
	 * @return
	 */
	public List<Map<String, Object>> selectInpatientWaitingList();
	
	/**
	 * 외래 수납 상세 내역 조회
	 * @param registrationNo
	 * @return
	 */
	public List<Map<String, Object>> selectPrescriptionDetails(int registrationNo);

	/**
	 * 외래 수납 현재 상태 재조회 (중복 수납 방지)
	 * @param paymentData
	 * @return
	 */
	public String selectRegistrationStatus(Map<String, Object> paymentData);

	/**
	 * 입원 수납 현재 상태 재조회 (중복 수납 방지)
	 * @param paymentData
	 * @return
	 */
	public String selectAdmissionStatus(Map<String, Object> paymentData);
	
	/**
	 * 외래 수납 완료 처리
	 * @param regVO
	 * @return
	 */
	public int updateRegistrationStatus(Map<String, Object> paymentData);
	
	/**
	 * (외래) 수납 내역 저장
	 * @param regVO
	 */
	public void insertBill(Map<String, Object> paymentData);
	
	/**
	 * (외래) 결제 내역 저장
	 * @param regVO
	 * @return
	 */
	public int insertPayment(Map<String, Object> paymentData);

	/**
	 * 입원 수납 상세 내역 조회
	 * @param admissionNo
	 * @return
	 */
	public List<Map<String, Object>> selectInpatientPrescriptionDetails(int admissionNo);
	
	/**
	 * 입원 번호로 모든 처방 이력 조회
	 * @param admissionNo
	 * @return
	 */
	public List<PredetailVO> selectPredetailListByAdmission(int admissionNo);
	
	/**
	 * 입원 수납 및 퇴원 완료 처리
	 * @param admissionVO
	 * @return
	 */
	public int updateAdmissionStatus(Map<String, Object> paymentData);

	/**
	 * 퇴원 완료 처리하면 침상 상태 변경
	 * @param bedNo
	 */
	public void updateBedStatusAvailable(int bedNo);

	/**
	 * 제증명 수납 완료 처리
	 * @param params
	 * @return
	 */
	public int updateCertificateStatus(Map<String, Object> params);


}
