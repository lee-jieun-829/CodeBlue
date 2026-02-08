package kr.or.ddit.cpr.nursing.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.nursing.mapper.INursingMapper;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.ClinicalDetailVO;
import kr.or.ddit.cpr.vo.NursingAssessmentVO;
import kr.or.ddit.cpr.vo.NursingChartVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.PredrugDetailVO;
@Service
public class NursingServiceImpl implements INursingService {
	
	@Autowired
	private INursingMapper mapper;

	@Override
	public List<NursingAssessmentVO> assessmentSelect(int admissionNo) {
		List<NursingAssessmentVO> assessmentList = mapper.assessmentSelect(admissionNo);
		return assessmentList;
	}

	@Override
	public int assessmentInsert(NursingAssessmentVO assessmentVO) {
		int result = mapper.assessmentInsert(assessmentVO);
		return result;
	}

	@Override
	public int assessmentUpdate(NursingAssessmentVO assessmentVO) {
		int result = mapper.assessmentUpdate(assessmentVO);
		return result;
	}

	@Override
	public List<PredetailVO> prescriptionSelect(ChartVO chartVO) {
		List<PredetailVO> list = mapper.prescriptionSelect(chartVO);
		return list;
	}

	@Override
	public int preDrugDetailStatusUpdate(PredrugDetailVO predrugDetailVO) {
		int result = mapper.preDrugDetailStatusUpdate(predrugDetailVO);
		return result;
	}

	@Override
	public int admissionStatusUpdate(int admissionNo) {
		int result = mapper.admissionStatusUpdate(admissionNo);
		return result;
	}
	
	@Transactional
	@Override
	public int nursingChartInsert(NursingChartVO chartVO) {
		int result = mapper.nursingChartInsert(chartVO);
		return result;
	}

	@Override
	public List<NursingChartVO> nursingChartSelect(ChartVO chartVO) {
		List<NursingChartVO> chartList = mapper.nursingChartSelect(chartVO);		
		return chartList;
	}

}
