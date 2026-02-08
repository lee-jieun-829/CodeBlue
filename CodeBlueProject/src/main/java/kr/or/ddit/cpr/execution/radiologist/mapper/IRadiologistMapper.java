package kr.or.ddit.cpr.execution.radiologist.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.admin.vo.AttachmentVO;
import kr.or.ddit.cpr.vo.AttachmentDetailVO;
import kr.or.ddit.cpr.vo.ExamOrderVO;
import kr.or.ddit.cpr.vo.PatientDetailVO;
import kr.or.ddit.cpr.vo.PatientVO;
import kr.or.ddit.cpr.vo.PredetailWatingListVO;

@Mapper
public interface IRadiologistMapper {

	public List<PredetailWatingListVO> getWaitingList();
    public int updateWaitingStatus(int predetailNo, String preExamdetailStatus);
    public List<PatientDetailVO> getPatientDetail(Integer patientNo);
    public List<ExamOrderVO> getOrderList(int patientNo);
    public List<ExamOrderVO> getOrderDetail(int predetailNo);
    
    // 첨부파일 및 검사 완료 처리
    public ExamOrderVO getPatientInfoByChartNo(int chartNo);
    public void insertAttachment(AttachmentVO attachmentVO);
    public void insertAttachmentDetail(AttachmentDetailVO detail);

    public int updateCompleteExam(ExamOrderVO updateVO);
    
    // 환자메모
    public int updatePatientMemo(PatientVO patientVO);

}
