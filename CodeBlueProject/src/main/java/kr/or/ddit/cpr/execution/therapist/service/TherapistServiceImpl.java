package kr.or.ddit.cpr.execution.therapist.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.execution.therapist.mapper.ITherapistMapper;
import kr.or.ddit.cpr.vo.ExamOrderVO;
import kr.or.ddit.cpr.vo.PatientDetailVO;
import kr.or.ddit.cpr.vo.PatientVO;
import kr.or.ddit.cpr.vo.PredetailWatingListVO;
import kr.or.ddit.cpr.vo.TreatmentOrderVO;
import kr.or.ddit.cpr.vo.TreatmentVO;

@Service
public class TherapistServiceImpl implements ITherapistService {

	@Autowired
	private ITherapistMapper mapper;
	
	@Override
	public List<PredetailWatingListVO> getWaitingList() {
		return mapper.getWaitingList();
	}

	@Override
	public void updateWaitingStatus(int predetailNo, String preTreatdetailStatus) throws Exception {
		int updated = mapper.updateWaitingStatus(predetailNo, preTreatdetailStatus);
	    
	    if (updated == 0) {
	        throw new Exception("상태 변경에 실패했습니다.");
	    }
	}

	@Override
	public List<PatientDetailVO> getPatientDetail(int patientNo) {
		return mapper.getPatientDetail(patientNo);
	}

	@Transactional(rollbackFor = Exception.class)
	@Override
	public int updatePatientMemo(PatientVO patientVO) {
		return mapper.updatePatientMemo(patientVO);
	}

	@Override
	public List<TreatmentOrderVO> getOrderList(int patientNo) {
		return mapper.getOrderList(patientNo);
	}

	@Override
	public List<TreatmentOrderVO> getOrderDetail(int predetailNo) {
		return mapper.getOrderDetail(predetailNo);
	}

	@Override
	@Transactional(rollbackFor = Exception.class)
	public int updateComplete(TreatmentVO treatmentVO) {
		int statusUpdate = mapper.updateComplete(treatmentVO);
		if(statusUpdate <= 0) { // 업데이트하는게 없으면
			throw new RuntimeException("치료 상태 업데이트에 실패했습니다.");
		}
		return statusUpdate;
	}

}
