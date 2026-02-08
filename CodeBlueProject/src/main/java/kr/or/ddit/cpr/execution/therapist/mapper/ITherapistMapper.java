package kr.or.ddit.cpr.execution.therapist.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.vo.PatientDetailVO;
import kr.or.ddit.cpr.vo.PatientVO;
import kr.or.ddit.cpr.vo.PredetailWatingListVO;
import kr.or.ddit.cpr.vo.TreatmentOrderVO;
import kr.or.ddit.cpr.vo.TreatmentVO;

@Mapper
public interface ITherapistMapper {

	public List<PredetailWatingListVO> getWaitingList();
	public int updateWaitingStatus(int predetailNo, String preTreatdetailStatus);
	public List<PatientDetailVO> getPatientDetail(int patientNo);
	public int updatePatientMemo(PatientVO patientVO);
	public List<TreatmentOrderVO> getOrderList(int patientNo);
	public List<TreatmentOrderVO> getOrderDetail(int predetailNo);
	public int updateComplete(TreatmentVO treatmentVO);

}
