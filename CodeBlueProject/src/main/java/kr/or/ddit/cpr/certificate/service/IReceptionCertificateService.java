package kr.or.ddit.cpr.certificate.service;

import java.util.List;
import java.util.Map;

import kr.or.ddit.cpr.vo.DiagnosisVO;

public interface IReceptionCertificateService {

	/**
	 * <p>증명서 내역 조회</p>
	 * @param patientNo
	 * @return
	 */
	public List<Map<String, Object>> selectMedicalCertificateList(int patientNo);

	/**
	 * <p>증명서 발급 요청</p>
	 * @param params
	 * @return
	 */
	public int requestCertificate(Map<String, Object> params);

	/**
	 * <p>증명서 상세 조회</p>
	 * @param printNo
	 * @return
	 */
	public Map<String, Object> selectCertificateDetail(String printNo);

	/**
	 * <p>특정 차트의 상병 리스트 조회</p>
	 * @param chartNo
	 * @return
	 */
	public List<DiagnosisVO> selectDiagnosisList(int chartNo);
	
	/**
	 * <p>증명서 발급 요청 해당 환자 담당의 사번 조회</p>
	 * @param patientNo
	 * @return
	 */
	public int selectCurrentDoctorNo(int patientNo);

}
