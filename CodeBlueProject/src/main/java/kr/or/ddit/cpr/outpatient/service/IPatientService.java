package kr.or.ddit.cpr.outpatient.service;

import java.util.List;

import kr.or.ddit.cpr.vo.AnatomyVO;
import kr.or.ddit.cpr.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.OperationVO;
import kr.or.ddit.cpr.vo.OutPatientListVO;
import kr.or.ddit.cpr.vo.PatientCompositeVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.RegistrationVO;
import kr.or.ddit.cpr.vo.TreatmentVO;

public interface IPatientService {

	/**
	 * <p> 상병 코드 목록 조회 </p>
	 * @author 장우석
	 * @param String searchWord (검색어)
	 * @return List<DiagnosisVO>
	 */
	public List<DiagnosisVO> selectDiagnosisList(String searchWord);

	/**
	 * <p> 약품목록 조회 </p>
	 * @author 장우석
	 * @param String searchWord (검색어)
	 * @return List<DrugVO>
	 */
	public List<DrugVO> selectDrugList(String searchWord);

	/**
	 * <p> 치료목록 조회 </p>
	 * @author 장우석
	 * @param String searchWord (검색어)
	 * @return List<TreatmentVO>
	 */
	public List<TreatmentVO> selectTreatmentList(String searchWord);

	/**
	 * <p> 수납완료 상태가 아닌 외래환자 전체 조회 </p>
	 * @author 장우석
	 * @return List<OutPatientListVO>
	 */
	public List<OutPatientListVO> selectOutPatientList(EmployeeVO vo);

	/**
	 * <p> 처방 데이터 저장 ( 각 하위테이블 역시 포함 한번이 일괄처리 ) </p>
	 * @author 장우석
	 * @param vo
	 * @return int 상태값
	 */
	public void insertPrescription(PredetailVO vo);

	/**
	 * <p> 환자번호로 환자정보 호출 <p>
	 * @author 장우석
	 * @param PatientVO vo
	 * @return PatientCompositeVO (바이탈을 포함한 환자정보)
	 */
	public PatientCompositeVO selectPatientInfo(PatientCompositeVO vo);

	/**
	 * <p> 주사목록 조회 </p>
	 * @author 장우석
	 * @param searchWord
	 * @return List<DrugVO> (주사목록)
	 */
	public List<DrugVO> selectInjectList(String searchWord);

	/**
	 * <p> 환자 상태 업데이트 </p>
	 * @author 장우석
	 * @param RegistrationVO vo
	 * @return 영향받은 행 수 
	 */
	public int updatePatientStatus(RegistrationVO vo);

	/**
	 * <p> 수술목록 조회 </p>
	 * @author 장우석
	 * @param searchWord
	 * @return
	 */
	public List<OperationVO> selectOperationList(String searchWord);

	/**
	 * <p> svg에서 사용할 부위 정보들을 가져오는 함수 </p>
	 * @author 장우석
	 * @return svg에서 사용할 정보들 
	 */
	public List<AnatomyVO> selectAnatomy();
	

}
