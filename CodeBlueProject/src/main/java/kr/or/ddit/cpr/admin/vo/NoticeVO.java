package kr.or.ddit.cpr.admin.vo;

import java.util.Date;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.multipart.MultipartFile;

import com.fasterxml.jackson.annotation.JsonFormat;

import kr.or.ddit.cpr.vo.AttachmentDetailVO;
import lombok.Data;

@Data
public class NoticeVO {

	private int noticeNo;				// 공지사항 번호
	private int fileNo;					// 공지사항 첨부파일
	private int employeeNo;				// 공지사항 사번
	private String noticeTitle;			// 공지사항 제목
	private String noticeContent;		// 공지사항 내용
	private String noticeImportant;		// 공지사항 주요도
	@DateTimeFormat(pattern = "yyyy-MM-dd") 
	@JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd", timezone = "Asia/Seoul")
    private Date noticeRegDate;			// 공지사항 등록일
	private String adminName;

	// 화면에서 넘겨받을 변수
	private List<MultipartFile> files;
	
	// 목록 조회 시 첨부파일 추가
	private List<AttachmentDetailVO> fileList;
	
}
