package kr.or.ddit.cpr.vo;

import java.util.Date;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

@Data
public class ConsultationVO extends PatientVO {
	
	private int employeeNo; // 사원번호
	private String employeeName; // 사원명
	
	private int consultationNo; // 협진번호
	private int consultationReqdoctor; // 의뢰요청의사번호
	private String reqDoctorName; // 의뢰요청의사명
	private int consultationRespdoctor; // 회신의사번호
	private String respDoctorName; // 회신의사명
	private String consultationReqdate; // 의뢰요청일자
	private String consultationRespdate; // 회신일자
	private String consultationReqcontent; // 의뢰내용
	private String consultationRespcontent; // 회신내용
	private String consultationStatus; // 협진상태
	private String consultationReason; // 거절사유
	
	private int chartNo; // 차트번호
	private int predetailNo; // 처방상세번호
	private String predetailRegdate; // 처방일
	
	private int attachmentNo; // 첨부파일번호
	private MultipartFile[] uploadFiles;
	private List<AttachmentDetailVO> fileList;
	
	private List<ProgressNoteVO> progressNotes; // 경과기록지 리스트
    private List<DiagnosisVO> diagnosis; // 진단 리스트
    private List<NursingChartVO> nursingCharts; // 간호기록지 리스트
    
    private List<DietVO> diet; // 식이VO 리스트
	private List<OperationVO> operation; // 수술VO 리스트
	private List<DrugVO> drug; // 처방VO 리스트
	private List<TreatmentVO> treatment; // 치료VO 리스트
	private List<ExaminationVO> examination; // 검사VO 리스트
    
    private String latestPressure; // 최근 혈압
    private String latestTemperature; // 최근 체온
    
}
