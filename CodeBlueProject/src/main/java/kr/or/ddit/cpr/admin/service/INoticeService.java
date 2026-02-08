package kr.or.ddit.cpr.admin.service;

import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.cpr.admin.vo.NoticeVO;
import kr.or.ddit.cpr.vo.AttachmentDetailVO;

public interface INoticeService {

	/**
	 * 작성자: 윤여범
	 * 공지사항 전체 목록을 조회하는 메서드
	 * @return 공지사항 VO 리스트
	 */
	public List<NoticeVO> retrieveNoticeList();

	/**
	 * 작성자: 윤여범
	 * 공지사항 상세 정보를 조회하는 메서드
	 * @param noticeNo 조회할 공지사항 번호
	 * @return 해당 공지사항의 상세 정보 VO
	 */
	public NoticeVO retrieveNotice(int noticeNo);

	/**
	 * 작성자: 윤여범
	 * 공지사항을 등록하는 메서드 (파일 업로드 로직 포함)
	 * @param noticeVO 등록할 공지사항 정보
	 * @return 등록 성공 시 1, 실패 시 0
	 */
	public int createNotice(NoticeVO noticeVO);

	/**
	 * 작성자: 윤여범
	 * 공지사항 기본 정보를 수정하는 메서드
	 * @param noticeVO 수정할 공지사항 정보
	 * @return 수정 성공 시 1, 실패 시 0
	 */
	public int modifyNotice(NoticeVO noticeVO);

	/**
	 * 작성자: 윤여범
	 * 공지사항을 삭제하는 메서드
	 * @param noticeNo 삭제할 공지사항 번호
	 * @return 삭제 성공 시 1, 실패 시 0
	 */
	public int removeNotice(int noticeNo);

	/**
	 * 작성자: 윤여범
	 * 파일 다운로드를 위해 첨부파일의 상세 정보를 조회하는 메서드
	 * @param detailNo 첨부파일 상세 번호
	 * @return 첨부파일 상세 정보 VO
	 */
	public AttachmentDetailVO selectFileDetail(int detailNo);

	/**
	 * 작성자: 윤여범
	 * 공지사항을 수정하는 메서드 (기본 정보 수정 + 파일 삭제 + 파일 추가)
	 * @param noticeVO 수정할 공지사항 제목 및 내용
	 * @param deleteFileNos 삭제할 첨부파일 번호 리스트
	 * @param files 새로 추가할 첨부파일 리스트
	 */
	public void updateNotice(NoticeVO noticeVO, List<Integer> deleteFileNos, List<MultipartFile> files);

}