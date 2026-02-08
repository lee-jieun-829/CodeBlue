package kr.or.ddit.cpr.admin.service;

import java.io.File;
import java.util.List;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.cpr.admin.mapper.INoticeMapper;
import kr.or.ddit.cpr.admin.vo.AttachmentVO;
import kr.or.ddit.cpr.admin.vo.NoticeVO;
import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.vo.AttachmentDetailVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class NoticeServiceImpl implements INoticeService {

	@Autowired
	private INoticeMapper mapper;

	// application.properties 설정 경로
	@Value("${kr.or.ddit.upload.notice.path}")
	private String uploadPath;

	/**
	 * 작성자: 윤여범
	 * 공지사항 전체 목록을 조회하는 메서드
	 * @return 공지사항 VO 리스트
	 */
	@Override
	public List<NoticeVO> retrieveNoticeList() {
		return mapper.selectNoticeList();
	}

	/**
	 * 작성자: 윤여범
	 * 공지사항 상세 정보를 조회하는 메서드
	 * @param noticeNo 조회할 공지사항 번호
	 * @return 해당 공지사항의 상세 정보 VO
	 */
	@Override
	public NoticeVO retrieveNotice(int noticeNo) {
		return mapper.selectNotice(noticeNo);
	}

	/**
	 * 작성자: 윤여범
	 * 공지사항을 등록하는 메서드 (파일 업로드 포함)
	 * @param noticeVO 등록할 공지사항 정보 (작성자, 제목, 내용, 파일 등)
	 * @return 등록 성공 시 1, 실패 시 0
	 */
	@Transactional(rollbackFor = Exception.class)
	@Override
	public int createNotice(NoticeVO noticeVO) {
		// 1. 작성자 정보 설정 (Spring Security 컨텍스트에서 사용자 정보 가져옴)
		CustomEmployee user = (CustomEmployee) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
		int userNo = user.getEmployee().getEmployeeNo();
		noticeVO.setEmployeeNo(userNo);

		// 2. 파일 처리 
		// 파일이 있으면 Attachment 테이블 생성 -> Detail 저장 -> noticeVO에 fileNo 세팅까지 수행
		processFiles(noticeVO, noticeVO.getFiles());
		
		// 3. 게시글 등록
		return mapper.insertNotice(noticeVO);
	}

	/**
	 * 작성자: 윤여범
	 * 공지사항 기본 정보를 수정하는 메서드
	 * @param noticeVO 수정할 공지사항 정보
	 * @return 수정 성공 시 1, 실패 시 0
	 */
	@Override
	public int modifyNotice(NoticeVO noticeVO) {
		return mapper.updateNotice(noticeVO);
	}

	/**
	 * 작성자: 윤여범
	 * 공지사항을 삭제하는 메서드
	 * @param noticeNo 삭제할 공지사항 번호
	 * @return 삭제 성공 시 1, 실패 시 0
	 */
	@Override
	public int removeNotice(int noticeNo) {
		return mapper.deleteNotice(noticeNo);
	}

	/**
	 * 작성자: 윤여범
	 * 파일 다운로드를 위해 첨부파일의 상세 정보를 조회하는 메서드
	 * @param detailNo 첨부파일 상세 번호
	 * @return 첨부파일 상세 정보 VO
	 */
	@Override
	public AttachmentDetailVO selectFileDetail(int detailNo) {
		return mapper.selectFileDetail(detailNo);
	}

	/**
	 * 작성자: 윤여범
	 * 공지사항을 수정하는 메서드 (파일 삭제 + 파일 추가 + 내용 수정)
	 * @param noticeVO 수정할 공지사항 제목 및 내용
	 * @param deleteFileNos 삭제할 첨부파일 번호 리스트
	 * @param files 새로 추가할 첨부파일 리스트
	 */
	@Transactional(rollbackFor = Exception.class)
	@Override
	public void updateNotice(NoticeVO noticeVO, List<Integer> deleteFileNos, List<MultipartFile> files) {
	    
	    // 1. 기존 게시글 정보 조회 (기존 파일 번호를 유지하기 위함)
	    NoticeVO savedNotice = mapper.selectNotice(noticeVO.getNoticeNo());
	    if (savedNotice != null) {
	        noticeVO.setFileNo(savedNotice.getFileNo()); 
	    }

	    // 2. 파일 삭제 (사용자가 삭제를 요청한 파일 처리)
	    if (deleteFileNos != null && !deleteFileNos.isEmpty()) {
	        for (Integer detailNo : deleteFileNos) {
	            AttachmentDetailVO fileInfo = mapper.selectFileDetail(detailNo);
	            if (fileInfo != null) {
	                // 물리적 파일 삭제
	                File file = new File(fileInfo.getAttachmentDetailPath());
	                if (file.exists()) {
	                    file.delete();
	                }
	                // DB 데이터 삭제
	                mapper.deleteAttachmentDetail(detailNo);
	            }
	        }
	    }

	    // 3. 파일 추가 (새로 업로드된 파일 처리)
	    processFiles(noticeVO, files);

	    // 4. 게시글 정보 업데이트 (제목, 내용 등)
	    mapper.updateNotice(noticeVO);
	}

    /**
     * 작성자: 윤여범
     * 파일 그룹 번호(AttachmentNo) 관리 및 파일 저장 분기 처리 메서드
     * @param noticeVO 공지사항 VO (파일 번호 설정용)
     * @param files 업로드된 파일 리스트
     */
    private void processFiles(NoticeVO noticeVO, List<MultipartFile> files) {
        if (files == null || files.isEmpty()) return;

        // 1. 실제로 업로드된 유효한 파일이 있는지 체크
        boolean hasRealFile = false;
        for (MultipartFile f : files) {
            if (!f.isEmpty()) {
                hasRealFile = true;
                break;
            }
        }

        // 2. 유효한 파일이 있다면 저장 진행
        if (hasRealFile) {
            int currentAttachNo = noticeVO.getFileNo();

            // 2-1. 기존 파일 그룹이 없으면(0) -> ATTACHMENT 테이블에 새로 INSERT하고 PK 가져옴
            if (currentAttachNo == 0) {
                AttachmentVO attachVO = new AttachmentVO();
                mapper.insertAttachment(attachVO); // selectKey로 attachmentNo가 채워짐
                currentAttachNo = attachVO.getAttachmentNo();
                
                // VO에 설정하여 updateNotice나 insertNotice에서 DB에 반영되도록 함
                noticeVO.setFileNo(currentAttachNo); 
            }

            // 2-2. 물리적 저장 및 DB 상세 정보(Detail) 저장
            File folder = new File(uploadPath);
            if (!folder.exists()) folder.mkdirs();

            for (MultipartFile file : files) {
                if (file.isEmpty()) continue;
                saveFileToDiskAndDB(file, currentAttachNo);
            }
        }
    }

    /**
     * 작성자: 윤여범
     * 실제 물리적 파일 저장 및 ATTACHMENT_DETAIL 테이블 Insert 수행 메서드
     * @param file 저장할 파일 객체
     * @param attachmentNo 파일이 속할 그룹 번호
     */
    private void saveFileToDiskAndDB(MultipartFile file, int attachmentNo) {
        try {
            String originalName = file.getOriginalFilename();
            String uuid = UUID.randomUUID().toString();
            String saveName = uuid + "_" + originalName;
            
            // 확장자 추출 처리
            String ext = "";
            int dotIndex = originalName.lastIndexOf(".");
            if (dotIndex > -1) {
            	ext = originalName.substring(dotIndex + 1);
            }
            
            String savePath = uploadPath + "/" + saveName; // 경로 구분자 명시 권장

            // 물리적 저장
            File saveFile = new File(savePath);
            file.transferTo(saveFile);

            // DB 저장
            AttachmentDetailVO detailVO = new AttachmentDetailVO();
            detailVO.setAttachmentNo(attachmentNo);
            detailVO.setAttachmentDetailName(saveName);
            detailVO.setAttachmentDetailMime(originalName); // Mime 컬럼에 원본명 저장 중
            detailVO.setAttachmentDetailPath(savePath);
            detailVO.setAttachmentDetailExt(ext);
            detailVO.setAttachmentDetailSize((int) file.getSize());

            mapper.insertAttachmentDetail(detailVO);
            
        } catch (Exception e) {
            log.error("파일 저장 중 오류 발생", e);
            throw new RuntimeException("파일 저장 실패", e);
        }
    }
}