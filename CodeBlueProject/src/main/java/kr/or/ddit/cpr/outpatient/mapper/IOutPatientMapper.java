package kr.or.ddit.cpr.outpatient.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import kr.or.ddit.cpr.outpatient.vo.OutPatientChartDrugVO;
import kr.or.ddit.cpr.patient.vo.PatientVO;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.ScreeningVO;

@Mapper
public interface IOutPatientMapper {

	//외래진료 대기 환자 조회
	public List<PatientVO> list();
	
	//상태별 환자 수 조회
	public Map<String, Object> readStatus();
	
	//외래 환자 검색
	public List<PatientVO> selectOutPatientList(String search);


	//외래 대기 환자 상태 변경
	public int updateRegistrationStatus(Map<String, Object> params);

	//외래 환자 상세 정보 가져오기
	public PatientVO readPatientDetail(@Param("patientNo") int patientNo,
            @Param("registrationNo") Integer registrationNo);


	//외래 환자 내원이력 조회
	public ChartVO readChartDetail(int patientNo);

	
	//환자 차트 조회
	public List<OutPatientChartDrugVO> chartListWatch(int patientNo);

	//투약 및 처치 기록 (간호사 오더 수행)
//	public Map<String, Object> registerVital(PatientVO patientVO);
	public Map<String, Object> chartListWatch(ScreeningVO screeningVO);

	//외래 환자 바이탈 입력(등록)
	public int registerVital(ScreeningVO screeningVO);

	//환자 메모 수정
	public void addPatientMemo(ScreeningVO screeningVO);
	
	//투약 및 처치 상태 변경
	public void updatePreDrogStatus(OutPatientChartDrugVO outPatientChartDrugVO);

	//처치 완료 버튼 클릭 이벤트
	public int updateRegistrationFinalStatus(Map<String, Object> params);

	//차트 중심으로 처방 내역 다 가져오기
	public List<PredetailVO> selectPredetailList(ChartVO vo);

	//상병 리스트 가져오기
	public List<DiagnosisVO> selectdiagnosisList(ChartVO vo);

	//내원이력 가져오기
	public List<Map<String, Object>> selectVisitHistory(Integer patientNo);

	//환자 메모 따로 저장하기
	int updatePatientMemo(@Param("patientNo") int patientNo,
            @Param("patientMemo") String patientMemo);

	//오늘: 접수번호 기준
	public List<OutPatientChartDrugVO> chartListWatchByRegistrationNo(@Param("registrationNo") int registrationNo);

	//과거: 차트번호 기준
	public List<OutPatientChartDrugVO> chartListWatchByChartNo(@Param("chartNo") int chartNo);

	



	







	

	

}
