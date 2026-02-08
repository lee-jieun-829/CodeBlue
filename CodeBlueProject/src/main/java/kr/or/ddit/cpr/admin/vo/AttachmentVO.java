package kr.or.ddit.cpr.admin.vo;

import java.util.Date;
import lombok.Data;

@Data
public class AttachmentVO {
	private int attachmentNo;		// 첨부파일번호
	private Date attachmentDate; 	// 파일등록일
}
