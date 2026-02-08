package kr.or.ddit.cpr.outpatient.service;

import java.util.List;
import java.util.Map;

import kr.or.ddit.cpr.outpatient.vo.OutPatientChartDrugVO;
import kr.or.ddit.cpr.patient.vo.PatientVO;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.ScreeningVO;

public interface IOutPatientService {

	//외래진료 대기 환자 조회
	public List<PatientVO> list();

	//상태별 환자 수 조회
	public Map<String, Object> readStatus();

	//외래 환자 검색
	public List<PatientVO> selectOutPatientList(String search);

	//대기환자 상태 변경
	public int updateRegistrationStatus(Map<String, Object> params);

	//환자 상세 정보 출력
	public PatientVO readPatientDetail(int patientNo, Integer registrationNo);

	//환자 차트 조회
	public List<OutPatientChartDrugVO> chartListWatch(int patientNo);

	//바이탈 정보 저장 기능
	public int registerVital(ScreeningVO screeningVO);

	//투약 및 처치 상태 변경
	public void updatePreDrogStatus(OutPatientChartDrugVO outPatientChartDrugVO);

	//처치 완료 버튼 클릭 이벤트
	public int updateRegistrationFinalStatus(Map<String, Object> params);
	
	/**
	 * <p>차트번호로 처방 리스트를 가져오는 함수</p>
	 * @author 장우석
	 * @param patientNo
	 * @return List<PredetailVO>
	 */
	public List<PredetailVO> selectPredetailList(ChartVO vo);

	/**
	 * <p>상병 리스트를 가져오는 함수</p>
	 * @author 한이혜지
	 * @param ChartNo
	 * @return List<PredetailVO>
	 */
	public List<DiagnosisVO> selectdiagnosisList(ChartVO vo);

	//내원 이력 가져오기
	public List<Map<String, Object>> selectVisitHistory(Integer patientNo);

	//환자 메모 따로 저장하기
	public int updatePatientMemo(int patientNo, String patientMemo);




	

}
