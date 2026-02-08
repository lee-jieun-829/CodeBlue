package kr.or.ddit.cpr.prescription.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.or.ddit.cpr.prescription.mapper.IPrescriptionMapper;
import kr.or.ddit.cpr.vo.ChartListVO;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.ExaminationVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.TreatmentVO;

@Service
public class PrescriptionServiceImpl implements IPrescriptionService{

	@Autowired
	IPrescriptionMapper preMapper;
	
	@Override
	public List<ChartListVO> selectChartList(int patientNo) {
		return preMapper.selectChartList(patientNo);
	}

	@Override
	public List<PredetailVO> selectPredetailList(ChartVO vo) {
		return preMapper.selectPredetailList(vo);
	}

	@Override
	public List<PredetailVO> selectPrescriptionList(PredetailVO vo) {
		return null;
	}

	@Override
	public List<DrugVO> selectDrugDetailList(PredetailVO vo) {
		return null;
	}

	@Override
	public List<TreatmentVO> selectTreatmentDetailList(PredetailVO vo) {
		// TODO Auto-generated method stub
		return null;
	}

	@Override
	public List<ExaminationVO> selectExamDetailList(PredetailVO vo) {
		// TODO Auto-generated method stub
		return null;
	}
	
	
}
