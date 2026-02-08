package kr.or.ddit.cpr.certificate.service;

import java.util.List;
import java.util.Map;

import kr.or.ddit.cpr.vo.CertificateVO;
import kr.or.ddit.cpr.vo.ChartVO;

public interface ICertificateService {

	/**
	 * <p> 환자 목록 조회 </p>
	 * @author 박성현
	 * @param keyword
	 * @return
	 */
	public List<CertificateVO> searchPatient(String keyword);
	
	/**
	 * <p> 환자 선택 시 차트목록 반환 </p>
	 * @author 박성현
	 * @param patientNo
	 * @return
	 */
	public List<ChartVO> selectPatientChart(int patientNo);

	/**
	 * <p> 환자 선택 시 서류목록 반환 </p>
	 * @author 박성현
	 * @param patientNo
	 * @return
	 */
	public List<CertificateVO> selectPatientDoc(int patientNo);

	/**
	 * <p> 서류 선택 시 입력값 반환 </p>
	 * @author 박성현
	 * @param docType
	 * @param certificateNo
	 * @param chartNo
	 * @return
	 */
	public List<CertificateVO> selectDocDetail(String docType, int certificateNo, int chartNo, String clickDate);

	/**
	 * <p> 서류 저장하는 함수 </p>
	 * @author 박성현
	 * @param vo
	 * @return
	 */
	public Map<String, Object> insertCertificate(CertificateVO vo);

}
