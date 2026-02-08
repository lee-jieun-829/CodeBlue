package kr.or.ddit.cpr.billing.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import kr.or.ddit.cpr.vo.AdmissionVO;
import kr.or.ddit.cpr.vo.RegistrationVO;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.BedVO;
import kr.or.ddit.cpr.vo.PatientVO;

/**
 * <p>원무 접수 및 등록 관련 매퍼 인터페이스</p>
 * <pre>
 * 1. 기능별 분리 원칙에 따라 등록/접수 기능만 담당
 * </pre>
 * @author 강지현
 */
@Mapper
public interface IReceptionMapper {

	/**
     * <p>신규 환자 정보 저장</p>
     * @author 강지현
     * @param patientVO 환자 정보
     */
	public void insertPatient(PatientVO patientVO);
	
	/**
	 * <p>신규 환자 정보 중복 체크</p>
	 * @param patientVO
	 * @return
	 */
	public int selectPatientDuplicate(PatientVO patientVO);

	/**
     * <p>외래 접수 정보 저장</p>
     * @author 강지현
     * @param registrationVO 접수 상세 정보가 담긴 객체
     */
	public int insertRegistration(RegistrationVO registrationVO);

	/**
	 * <p>대기 환자 조회를 위한 데이터 접근</p>
	 * @author 강지현
	 * @return DB에서 조회된 대기 환자 목록
	 */
	public List<PatientVO> selectWaitingList();

	/**
     * 외래 접수 기존 환자 정보를 조회
     * @author 강지현
     * @param keyword 이름 또는 차트번호
     * @return 검색된 환자 정보
     */
	public List<PatientVO> selectPatientList(String keyword);

	/**
	 * <p>입원 접수 정보 등록</p>
	 * @author 강지현
	 * @param admissionVO 입원 정보 상세 객체
	 * @return 성공 시 1, 실패 시 0
	 */
	public int insertAdmission(AdmissionVO admissionVO);

	/**
     * 입원 접수 환자 정보를 조회
     * @author 강지현
     * @param keyword 이름 또는 차트번호
     * @return 검색된 환자 정보
     */
	public List<PatientVO> selectInpatientSearch(String keyword);

	/**
	 * <p>입원 접수 시 선택한 침상의 상태를 '사용중'으로 변경</p>
	 * @author 강지현
	 * @param bedNo 변경할 침상 번호
	 * @return 성공 시 1, 실패 시 0
	 */
	public int updateBedStatusOccupied(@Param("bedNo") int bedNo);

	/**
	 * <p>차트 생성</p>
	 * @author 강지현
	 * @param chartVO 차트 정보
	 * @return 등록된 행 수
	 */
	public int insertChart(ChartVO chartVO);

	/**
	 * <p>환자 메모 수정</p>
	 * @author 강지현
	 * @param patientVO 수정할 메모와 환자번호가 담긴 객체
	 */
	public void updatePatientMemo(PatientVO patientVO);

	/**
	 * <p>병상 전체 목록 조회</p>
	 * @return
	 */
	public List<BedVO> selectBedList();

	/**
	 * <p>접수 시 의사 조회</p>
	 * @return
	 */
	public List<EmployeeVO> selectDoctorList();



}
