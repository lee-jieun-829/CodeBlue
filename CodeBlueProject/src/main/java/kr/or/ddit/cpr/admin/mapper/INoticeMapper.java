package kr.or.ddit.cpr.admin.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.admin.vo.AttachmentVO;
import kr.or.ddit.cpr.admin.vo.NoticeVO;
import kr.or.ddit.cpr.vo.AttachmentDetailVO;

@Mapper
public interface INoticeMapper {

	// 공지사항 관련 기능
	public List<NoticeVO> selectNoticeList();		// 목록 조회
	public NoticeVO selectNotice(int noticeNo);		// 상세 조회
	public int insertNotice(NoticeVO noticeVO);		// 등록
	public int updateNotice(NoticeVO noticeVO);		// 수정
	public int deleteNotice(int noticeNo);			// 삭제

	// 첨부파일 관련 기능 (파일 업로드/다운로드)
	public void insertAttachment(AttachmentVO attachVO);

	// 파일 정보(Detail)저장
	public void insertAttachmentDetail(AttachmentDetailVO detailVO);

	// 다운로드 할 때 파일 정보 조회
	public AttachmentDetailVO selectFileDetail(int detailNo);
	
	// DB 데이터 삭제
	public int deleteAttachmentDetail(int detailNo);

}
