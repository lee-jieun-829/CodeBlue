package kr.or.ddit.cpr.billing.service;

import java.util.List;
import java.util.Map;

import kr.or.ddit.cpr.vo.AdmissionVO;

public interface IPaymentService {

	/**
	 * 외래 수납 대기 목록 조회
	 * @return
	 */
	public List<Map<String, Object>> selectOutpatientWaitingList();

	/**
	 * 입원 수납 대기 목록 조회
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
	 * 외래 수납 및 완료 처리(결제 내역 저장 및 접수 상태 변경)
	 * @param regVO
	 * @return
	 */
	public int updateRegistrationStatus(Map<String, Object> paymentData);

	/**
	 * 입원 수납 상세 내역 조회
	 * @param admissionNo
	 * @return
	 */
	public List<Map<String, Object>> selectInpatientPrescriptionDetails(int admissionNo);
	
	/**
	 * 입원 수납 및 퇴원 완료 처리
	 * @param paymentData
	 * @return
	 */
	public int updateAdmissionStatus(Map<String, Object> paymentData);

	/**
	 * 카카오페이 결제 준비 요청 (Ready)
	 * @param params (금액, 접수번호 등)
	 * @return 카카오 응답 데이터 (TID, 리다이렉트 URL 등)
	 */
	public Map<String, Object> kakaoPayReady(Map<String, Object> params);

	/**
	 * 제증명 수납 완료 처리
	 * @param params
	 * @return
	 */
	public int updateCertificateStatus(Map<String, Object> params);

}
