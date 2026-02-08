package kr.or.ddit.cpr.vo;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

@Data
public class ExaminationVO {
	
	private Long chartNo; // 차트번호

	private Long examinationNo; // 검사번호
	private String examinationCode; // 검사코드
	private String examinationName; // 검사명
	private Long examinationPrice; // 검사수가
	
	private Long predetailNo; // 처방상세번호
	private Long preexaminationDetailFreq; // 횟수
	private Long preexaminationDetailDay; // 일수
	private String preexaminationDetailSite; // 환부(부위)
	private String preexaminationDetailStatus; // 상태(완료여부)
	private String preexaminationDetailRemark; // 비고
	private String preexaminationDetailLaterality; // 좌우구분
	private String preexaminationNo; // pk임
	
	private String predetailRegdate;
	
	private Long attachmentNo; // 첨부파일번호
	private String attachmentDetailPath; 
	private String attachmentDetailName;
	private String attachmentDetailNo;
	private MultipartFile[] uploadFiles;
	private List<AttachmentDetailVO> fileList;
}
