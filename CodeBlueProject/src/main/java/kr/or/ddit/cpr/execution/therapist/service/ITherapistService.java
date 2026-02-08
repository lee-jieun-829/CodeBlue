package kr.or.ddit.cpr.execution.therapist.service;

import java.util.List;

import kr.or.ddit.cpr.vo.PatientDetailVO;
import kr.or.ddit.cpr.vo.PatientVO;
import kr.or.ddit.cpr.vo.PredetailWatingListVO;
import kr.or.ddit.cpr.vo.TreatmentOrderVO;
import kr.or.ddit.cpr.vo.TreatmentVO;

public interface ITherapistService {

	public List<PredetailWatingListVO> getWaitingList();
	public void updateWaitingStatus(int predetailNo, String preExamdetailStatus) throws Exception;
	public List<PatientDetailVO> getPatientDetail(int patientNo);
	public int updatePatientMemo(PatientVO patientVO);
	public List<TreatmentOrderVO> getOrderList(int patientNo);
	public List<TreatmentOrderVO> getOrderDetail(int predetailNo);
	public int updateComplete(TreatmentVO treatmentVO);

}
