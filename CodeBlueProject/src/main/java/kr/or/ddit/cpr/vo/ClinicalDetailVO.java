package kr.or.ddit.cpr.vo;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;


@Data
public class ClinicalDetailVO extends InpatientVO {
	private Long chartNo; // 차트번호
	
    private List<ProgressNoteVO> progressNotes; // 경과기록지 리스트
    private List<DiagnosisVO> diagnosis; // 진단 리스트
    private List<NursingChartVO> nursingCharts; // 간호기록지 리스트
    private List<NursingAssessmentVO> assessments; // 간호정보조사지 리스트
    private List<ConsultationVO> consultations; // 협진기록 리스트
    private List<OrderListVO> prescription; // 처방내역 리스트 
    
    private List<DietVO> diet; // 식이VO 리스트
	private List<OperationVO> operation; // 수술VO 리스트
	private List<DrugVO> drug; // 처방VO 리스트
	private List<TreatmentVO> treatment; // 치료VO 리스트
	private List<ExaminationVO> examination; // 검사VO 리스트
	
	private int attachmentNo;				// 첨부파일번호
	private MultipartFile[] uploadFiles;
	private List<AttachmentDetailVO> fileList;
    
    private String latestPressure; // 최근 혈압
    private String latestTemperature; // 최근 체온
    private String latestPulse; // 최근 맥박
    private Integer latestPainScore; // 최근 통증점수
    
    private String preoperationRegdate; // 수술일자
    
    public void setChartNo(Long chartNo) {
        this.chartNo = chartNo;
    }

    public Long getChartNo() {
        return this.chartNo;
    }
	
}
