package kr.or.ddit.cpr.execution.radiologist.service;

import java.util.List;
import java.util.Map;

import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.cpr.vo.ExamOrderVO;
import kr.or.ddit.cpr.vo.PatientDetailVO;
import kr.or.ddit.cpr.vo.PatientVO;
import kr.or.ddit.cpr.vo.PredetailWatingListVO;

public interface IRadiologistWorkService {

	public List<PredetailWatingListVO> getWaitingList();
	public void updateWaitingStatus(int predetailNo, String preExamdetailStatus) throws Exception;
	// public PatientDetailVO getPatientDetail(int patientNo, int chartNo);
	public List<PatientDetailVO> getPatientDetail(Integer patientNo);
	public List<ExamOrderVO> getOrderList(int patientNo);
	public List<ExamOrderVO> getOrderDetail(int predetailNo);
	public int updateCompleteExam(ExamOrderVO orderVO, Map<Integer, List<MultipartFile>> filesByExamItem) throws Exception;
	public int updatePatientMemo(PatientVO patientVO);

}
