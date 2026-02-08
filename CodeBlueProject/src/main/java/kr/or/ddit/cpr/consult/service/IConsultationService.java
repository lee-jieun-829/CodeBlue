package kr.or.ddit.cpr.consult.service;

import java.util.List;
import java.util.Map;

import kr.or.ddit.cpr.vo.ConsultationVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.PatientVO;

public interface IConsultationService {

	/**
	 * <p> 환자 목록 조회 </p>
	 * @author 박성현
	 * @param patientNo
	 * @return
	 */
	public List<ConsultationVO> selectReqConsultPatient(int employeeNo, Integer patientNo);

	/**
	 * <p> 환자 상세 협진 정보 조회 </p>
	 * @author 박성현
	 * @param consultationNo
	 * @return
	 */
	public ConsultationVO selectConsultationDetail(int consultationNo);

	/**
	 * <p> 환자 검색 </p>
	 * @author 박성현
	 * @param keyword
	 * @return
	 */
	public List<ConsultationVO> searchPatient(String keyword);
	
	/**
	 * <p> 의사 조회 </p>
	 * @author 박성현
	 * @return
	 */
	public List<EmployeeVO> selectDoctorList();
	
	/**
	 * <p> 담당 환자 협진 요청 저장 </p>
	 * @author 박성현
	 * @param vo
	 * @return
	 */
	public Map<String, Object> insertReqConsultation(ConsultationVO vo);

	/**
	 * <p> 협진 회신 등록 </p>
	 * @author 박성현
	 * @param vo
	 * @return
	 */
	public Map<String, Object> updateRespConsultation(ConsultationVO vo);

	/**
	 * <p> 협진 거절 등록 </p>
	 * @author 박성현
	 * @param vo
	 * @return
	 */
	public Map<String, Object> updateRejectConsultation(ConsultationVO vo);

	/**
	 * <p> 환자 차트 상세 정보 조회 </p>
	 * @author 박성현
	 * @param chartNo
	 * @return
	 */
	public ConsultationVO selectChartDetail(int chartNo);



}
