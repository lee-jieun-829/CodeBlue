package kr.or.ddit.cpr.outpatient.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.outpatient.mapper.IOutPatientMapper;
import kr.or.ddit.cpr.outpatient.vo.OutPatientChartDrugVO;
import kr.or.ddit.cpr.patient.vo.PatientVO;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.ScreeningVO;

@Service
public class OutPatientServiceImpl implements IOutPatientService {
	
	@Autowired
	private IOutPatientMapper mapper;
	

	@Override
	public List<PatientVO> list() {
		return mapper.list();
	}

	@Override
	public Map<String, Object> readStatus() {
		return mapper.readStatus();
	}

	@Override
	public List<PatientVO> selectOutPatientList(String search) {
		return mapper.selectOutPatientList(search);
	}

	@Override
	public int updateRegistrationStatus(Map<String, Object> params) {
		return mapper.updateRegistrationStatus(params);
	}


	@Override
	public PatientVO readPatientDetail(int patientNo, Integer registrationNo) {
		return mapper.readPatientDetail(patientNo, registrationNo);
	}


	@Override
	public List<OutPatientChartDrugVO> chartListWatch(int patientNo) {
		return mapper.chartListWatch(patientNo);
	}

	@Transactional
	@Override
	public int registerVital(ScreeningVO screeningVO) {
		CustomEmployee user = (CustomEmployee) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
		screeningVO.setEmployeeNo(user.getEmployee().getEmployeeNo());
		//mapper.addPatientMemo(screeningVO);
		return mapper.registerVital(screeningVO);
	}

	@Override
	public void updatePreDrogStatus(OutPatientChartDrugVO outPatientChartDrugVO) {
		mapper.updatePreDrogStatus(outPatientChartDrugVO);
		
	}

	@Override
	public int updateRegistrationFinalStatus(Map<String, Object> params) {
		return mapper.updateRegistrationFinalStatus(params);
	}

	@Override
	public List<PredetailVO> selectPredetailList(ChartVO vo) {
		return mapper.selectPredetailList(vo);
	}

	@Override
	public List<DiagnosisVO> selectdiagnosisList(ChartVO vo) {
		return mapper.selectdiagnosisList(vo);
	}

	@Override
	public List<Map<String, Object>> selectVisitHistory(Integer patientNo) {
		return mapper.selectVisitHistory(patientNo);
	}

	@Override
	public int updatePatientMemo(int patientNo, String patientMemo) {
		return mapper.updatePatientMemo(patientNo,patientMemo);
	}

	


	



//여까지 함
	

}
