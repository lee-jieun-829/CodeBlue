package kr.or.ddit.cpr.vo;

import java.util.Date;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

/**
 * ================================
 * - 검사 오더 VO
 * - auth : Been daye
 * - date : 2026.01.02
 * ================================
 */

@Data
public class ExamOrderVO {
	
	private int chartNo;
	private int patientNo;
	private String patientName;
	
	private String examinationCode;			// 검사코드
	private String examinationName;			// 검사명
	private int examinationPrice;			// 수가
	
	private int predetailNo;				// 처방상세번호(PK)
	private int examinationNo;				// 검사번호(PK)
	private int preexaminationNo;
	private String preExamdetailSite;		// 환부 (preexaminationDetailSite)
	private String preExamdetailStatus;		// 상태 (preexaminationDetailStatus)
	private String preExamdetailLaterality;		// 위치 (preexaminationDetailLaterality)
	private String predetailRemark;			// 비고 (preexaminationDetailRemark)
	 
	private int attachmentNo;				// 첨부파일번호
	private MultipartFile[] uploadFiles;
	private List<AttachmentDetailVO> fileList;
	 
	private Date predetailRegdate;
	private String predetailType;
	 
	// 커스텀
	private String orderDate;      // TO_CHAR로 만든 날짜 문자열
	private int examCount;         // COUNT로 만든 건수
	private String isCurrentOrder; // 'Y' 또는 'N'
}
