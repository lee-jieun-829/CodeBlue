package kr.or.ddit.cpr.vo;

import java.util.Date;

import org.apache.commons.io.FileUtils;

import lombok.Data;

@Data
public class AttachmentDetailVO {

	private int attachmentDetailNo;				// 상세파일번호
	private String attachmentDetailName;		// 파일이름
	private String attachmentDetailMime;		// 파일원본명
	private Date attachmentDetailDate;			// 파일등록일
	private String attachmentDetailPath;		// 파일주소
	private String attachmentDetailExt;			// 상세파일확장자
	private int attachmentDetailSize;			// 상세파일크기
	private int attachmentNo;					// 첨부파일번호
	private String attachmentDetailFancysize;	// 파일펜시사이즈
	
	public void setAttachmentDetailSize(int attachmentDetailSize) {
		this.attachmentDetailSize = attachmentDetailSize;
		this.attachmentDetailFancysize = FileUtils.byteCountToDisplaySize(attachmentDetailSize);
	}
}