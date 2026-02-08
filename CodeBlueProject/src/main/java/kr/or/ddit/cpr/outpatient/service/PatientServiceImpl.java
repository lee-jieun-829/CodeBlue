package kr.or.ddit.cpr.outpatient.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.outpatient.mapper.IPatientMapper;
import kr.or.ddit.cpr.prescription.service.IPrescriptionService;
import kr.or.ddit.cpr.vo.AnatomyVO;
import kr.or.ddit.cpr.vo.ChartListVO;
import kr.or.ddit.cpr.vo.ChartVO;
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

@Service
public class PatientServiceImpl implements IPatientService{

	@Autowired
	IPatientMapper patientMapper;
	
	@Autowired
	IPrescriptionService prescriptionService;
	
	@Override
	public List<DiagnosisVO> selectDiagnosisList(String searchWord) {
//		List<DiagnosisVO> list = null;
//		try {
//			list = patientMapper.selectDiagnosisList(searchWord);
//		} catch (Exception e) {
//			e.printStackTrace();
//		}
//		return list;
		
//		마이바티스만 이용할때는 굳이 서비스단에서 트라이캐치해서 NULL 체크 안해도 됩니다.
// 		왜냐하면 마이바티스가 알아서 DB오류나면 NULL로 데이터 조회에는 성공했는데 조회된 건 수가 0건이면
//		빈 리턴타입으로 반환하기 때문에. 그냥 바로 리턴하세요
		
		return patientMapper.selectDiagnosisList(searchWord);
	}

	@Override
	public List<DrugVO> selectDrugList(String searchWord) {
		return patientMapper.selectDrugList(searchWord);
	}

	@Override
	public List<TreatmentVO> selectTreatmentList(String searchWord) {
		return patientMapper.selectTreatmentList(searchWord);
	}


	@Override
	public List<OutPatientListVO> selectOutPatientList(EmployeeVO vo) {
		
		return patientMapper.selectOutPatientList(vo);
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public void insertPrescription(PredetailVO vo) {
		
		// 반복문이 많이돌아서 DB가 힘들지 않을까 싶지만 큰 데이터도 아니고 
		// 의사가 뭐 약품 3천개 이런식으로 처방할 일은 없으니 걱정 X
		
		// 약품처방 디테일
 		List<DrugVO> drugList = vo.getDrugList();
		// 치료처방 디테일
 		List<TreatmentVO> treatList = vo.getTreatList();
 		// 검사처방 디테일
 		List<ExaminationVO> examList = vo.getExamList();
 		// 수술처방 디테일
 		List<OperationVO> operList = vo.getOperList();
 		// 진단 디테일에 들어갈 상병목록
 		List<DiagnosisVO> diagList = vo.getDiagList();

 		
 		// 진단 디테일 인설트
 		if(diagList != null && !diagList.isEmpty()) {
 			for(DiagnosisVO diag : diagList) {
 				patientMapper.insertDiagnosis(diag);
 			}
 		}
 		
		
		// drugList 데이터가 실제로 있는지 검증 하고 인설트
		if(drugList != null && !drugList.isEmpty()) {
			//처방 디테일 상태를 001로 ( 약처방 )
			vo.setPredetailType("001");
			// 처방 디테일 인설트
			patientMapper.insertPredetail(vo);
			// 처방디테일 인설트 하면서 셀렉트키로 받아온 처방디테일번호
			int predetailNo = vo.getPredetailNo();
			
			for(DrugVO drug : drugList) {
				drug.setPredetailNo((long) predetailNo);
				
				patientMapper.insertPredrugDetail(drug);
			}
		}
		
		// examList 데이터가 실제로 있는지 검증 하고 인설트
		if(examList != null && !examList.isEmpty()) {
			//처방 디테일 상태를 002로 ( 검사처방 )
			vo.setPredetailType("002");;
			// 처방 디테일 인설트
			patientMapper.insertPredetail(vo);
			// 처방디테일 인설트 하면서 셀렉트키로 받아온 처방디테일번호
			int predetailNo = vo.getPredetailNo();
			for(ExaminationVO ex : examList) {
				ex.setPredetailNo((long) predetailNo);
				
				patientMapper.insertPreExamination(ex);
			}
		}
		
		// treatList 데이터가 실제로 있는지 검증 하고 인설트
		if(treatList != null && !treatList.isEmpty()) {
			//처방 디테일 상태를 003로 ( 치료처방 )
			vo.setPredetailType("003");
			// 처방 디테일 인설트
			patientMapper.insertPredetail(vo);
			// 처방디테일 인설트 하면서 셀렉트키로 받아온 처방디테일번호
			int predetailNo = vo.getPredetailNo();
			for(TreatmentVO treat : treatList) {
				treat.setPredetailNo((long) predetailNo);
				
				patientMapper.insertTreatMent(treat);
			}
		}
		
		// operList 데이터가 있는지 검증하고 인설트
		if(operList != null && !operList.isEmpty()) {
			// 처방 디테일 상태를 005로 ( 수술처방 )
			vo.setPredetailType("005");
			// 처방 디테일 인설트
			patientMapper.insertPredetail(vo);
			// 처방 디테일 인설트 하면서 셀렉트키로 받아온 처방디테일번호
			int predetailNo = vo.getPredetailNo();
			for(OperationVO oper : operList) {
				oper.setPredetailNo((long) predetailNo);
				
				patientMapper.insertOperation(oper);
			}
		}
		
 		// 차트 콘텐츠 업데이트
 		patientMapper.updateChartContent(vo);
		
	}

	@Override
	public PatientCompositeVO selectPatientInfo(PatientCompositeVO vo) {
		PatientCompositeVO returnVO = patientMapper.selectPatientInfo(vo);
		int patientNo = vo.getPatientVO().getPatientNo();
		List<ChartListVO> chartList = prescriptionService.selectChartList(patientNo);
		returnVO.setChartList(chartList);
		return returnVO;
	}

	@Override
	public List<DrugVO> selectInjectList(String searchWord) {
		return patientMapper.selectInjectList(searchWord);
	}

	@Override
	public int updatePatientStatus(RegistrationVO vo) {
		return patientMapper.updatePatientStatus(vo);
	}

	@Override
	public List<OperationVO> selectOperationList(String searchWord) {
		return patientMapper.selectOperationList(searchWord);
	}

	@Override
	public List<AnatomyVO> selectAnatomy() {
		return patientMapper.selectAnatomy();
	}

}
