package kr.or.ddit.cpr.outpatient.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.vo.AnatomyVO;
import kr.or.ddit.cpr.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.ExaminationVO;
import kr.or.ddit.cpr.vo.OperationVO;
import kr.or.ddit.cpr.vo.OutPatientListVO;
import kr.or.ddit.cpr.vo.PatientCompositeVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.RegistrationVO;
import kr.or.ddit.cpr.vo.TreatmentVO;

@Mapper
public interface IPatientMapper {

	public List<DiagnosisVO> selectDiagnosisList(String searchWord);

	public List<DrugVO> selectDrugList(String searchWord);

	public List<TreatmentVO> selectTreatmentList(String searchWord);

	public int insertPredrugDetail(DrugVO vo);

	public List<OutPatientListVO> selectOutPatientList(EmployeeVO vo);

	public void insertPredetail(PredetailVO vo);

	public void insertTreatMent(TreatmentVO treat);

	public void insertPreExamination(ExaminationVO ex);

	public PatientCompositeVO selectPatientInfo(PatientCompositeVO vo);

	public List<DrugVO> selectInjectList(String searchWord);

	public void insertDiagnosis(DiagnosisVO diag);

	public void updateChartContent(PredetailVO vo);

	public int updatePatientStatus(RegistrationVO vo);

	public List<OperationVO> selectOperationList(String searchWord);

	public void insertOperation(OperationVO oper);

	public List<AnatomyVO> selectAnatomy();
	
	
}
