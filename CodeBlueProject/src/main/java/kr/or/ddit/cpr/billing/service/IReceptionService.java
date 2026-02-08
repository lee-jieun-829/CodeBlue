package kr.or.ddit.cpr.billing.service;

import java.util.List;
import java.util.Map;

import kr.or.ddit.cpr.vo.AdmissionVO;
import kr.or.ddit.cpr.vo.BedVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.PatientVO;



/**
 * <p>원무 접수 및 등록 관련 비즈니스 로직 인터페이스</p>
 * <pre>
 *  신규 환자 등록 및 외래/입원 접수 처리 인터페이스
 * </pre>
 * @author 강지현
 */
public interface IReceptionService {

	/**
     * <p>신규 환자 정보 등록 및 차트 생성</p>
     * @author 강지현
     * @param patientVO 환자 정보 객체
     * @return 결과 상태 및 차트번호
     */
	public Map<String, Object> insertPatient(PatientVO patientVO);

	/**
	 * <p>대기 중인 환자 목록 가져오기</p>
	 * @author 강지현
	 * @return patientVO 환자 정보 객체
	 */
	public List<PatientVO> getWaitingList();

	/**
     * 외래 환자 상세 정보 조회
     * @author 강지현
     * @param keyword 검색어
     * @return 검색된 환자의 인적 사항을 담은 PatientVO 객체
     */
	public List<PatientVO> retrievePatientList(String keyword);

	/**
     * <p>외래 재진 환자의 접수 정보 등록 및 차트 생성</p>
     * @author 강지현
     * @param patientVO 환자 정보 객체
     * @return 결과 상태 및 차트번호
     */
	public Map<String, Object> createOutpatientRegistration(PatientVO patientVO);

	/** 
	 * <p>입원 대상 환자 검색</p>
	 * @author 강지현
	 * @param keyword 검색어
	 * @return 검색된 환자의 인적 사항을 담은 PatientVO 객체
	 */
	public List<PatientVO> searchInpatient(String keyword);

	/**
	 * <p>입원 환자 접수 정보 등록 및 침상 상태 변경, 차트 생성</p>
	 * @author 강지현
	 * @param admissionVO 입원 접수 정보 객체
	 * @return 결과 상태 및 차트번호
	 */
	public Map<String, Object> registerAdmission(AdmissionVO admissionVO);

	/**
	 * <p>병상 전체 목록 조회</p>
	 * @return
	 */
	public List<BedVO> selectBedList();

	/**
	 * <p>접수 시 의사 선택</p>
	 * @return
	 */
	public List<EmployeeVO> getDoctorList();

	
}
