package kr.or.ddit.cpr.vo;

import java.util.List;

import lombok.Data;

@Data
public class CertificateVO extends PatientVO {
	private int chartNo; // 차트번호
	
	private int certificateNo; // 증명서번호
	private String certificateCode; // 증명서코드
	private String certificateName; // 증명서이름
	private String certificatePrice; // 수가
	
	private String medicalCertificatePrintNo; // 발급번호
	
	private String medicalCertificateOnset; // 발병일
	private String medicalCertificateDiagnosis; // 진단일
	private String medicalCertificateContent; // 향후 치료 및 처방 소견
	private String medicalCertificateDate; // 발급일
	private String medicalCertificateRemark; // 비고
	private String medicalCertificatePurpose; // 용도
	private String medicalCertificateStatus; // 발급상태
	
	private String docType; // 서류 구분 코드(확장위해만든거)
	
	private int employeeNo; // 주치의사번
	private String employeeName; // 주치의명
	private String employeeDetailLicence; // 주치의 면허번호
	private String employeeCode; // 직원구분코드

	private int hospitalNo; // 병원번호
	private String hospitalName; // 병원명
	private String hospitalAddr; // 병원주소
	
	private int diagnosisNo; // 진단번호
	private String diagnosisCode; // 상병코드
	private String diagnosisName; // 상병명
	private String diagnosisDetailYn; // 주/부
	
	private List<DiagnosisVO> diagnosisList; // 복수개의 상병 리스트
	private List<ProgressNoteVO> progressNote;       // 1. 경과기록
    private List<NursingChartVO> nursingChart;      // 2. 간호기록
    private List<NursingAssessmentVO> nursingAssessment; // 3. 간호정보조사지
    private List<PredetailVO> predetail;	// 4. 처방내역
}
