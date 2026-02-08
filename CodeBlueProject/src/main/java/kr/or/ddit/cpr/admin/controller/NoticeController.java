package kr.or.ddit.cpr.admin.controller;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.InputStreamResource;
import org.springframework.core.io.Resource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal; // [추가]
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.ModelAndView;

import kr.or.ddit.cpr.admin.service.INoticeService;
import kr.or.ddit.cpr.admin.vo.NoticeVO;
import kr.or.ddit.cpr.vo.AttachmentDetailVO;
// [추가] CustomEmployee 패키지 경로를 확인해주세요 (예: kr.or.ddit.cpr.common.security.CustomEmployee)
import kr.or.ddit.cpr.common.security.CustomEmployee; 
import lombok.extern.slf4j.Slf4j;

@PreAuthorize("hasRole('ROLE_ADMIN')")
@Slf4j
@RestController
@RequestMapping("/admin/notice")
public class NoticeController {

	@Autowired
	private INoticeService noticeService;

	// ... (list, listData, detail 메서드는 기존과 동일하므로 생략하거나 그대로 둡니다) ...
    
    @GetMapping("/list")
	public ModelAndView goNoticeList() {
		return new ModelAndView("notice/list");
	}

	@GetMapping("/listData")
	public ResponseEntity<List<NoticeVO>> getNoticeList() {
		List<NoticeVO> list = noticeService.retrieveNoticeList();
		return new ResponseEntity<>(list, HttpStatus.OK);
	}

	@GetMapping("/detail/{noticeNo}")
	public ResponseEntity<NoticeVO> getNoticeDetail(@PathVariable("noticeNo") int noticeNo) {
		NoticeVO noticeVO = noticeService.retrieveNotice(noticeNo);
		if (noticeVO != null) {
			return new ResponseEntity<>(noticeVO, HttpStatus.OK);
		} else {
			return new ResponseEntity<>(HttpStatus.NOT_FOUND);
		}
	}

	@PostMapping("/insert")
	public ResponseEntity<String> insertNotice(
            NoticeVO noticeVO,
            @AuthenticationPrincipal CustomEmployee customUser
    ) {
		log.info("비동기 공지사항 등록 요청: " + noticeVO.getNoticeTitle());

		try {
            // [확인 포인트]
            if(customUser != null) {
                int empNo = customUser.getEmployee().getEmployeeNo();
                noticeVO.setEmployeeNo(empNo);
                
                // 1. 서버 로그로 확인 (기존 코드)
                log.info("작성자 사번 세팅 완료: {}", empNo);
                
                // 2. 콘솔에 눈에 띄게 출력 (테스트 후 삭제 추천)
                System.out.println("=====================================");
                System.out.println(">>> [DEBUG] 현재 로그인한 사번 : " + empNo);
                System.out.println(">>> [DEBUG] 이름 : " + customUser.getEmployee().getEmployeeName());
                System.out.println("=====================================");
                
            } else {
                // 로그인이 안 된 상태거나 인증 객체가 없을 때
                System.out.println("=====================================");
                System.out.println(">>> [ERROR] 로그인 정보(customUser)가 NULL 입니다!");
                System.out.println("=====================================");
                
                // 필요하다면 여기서 에러를 리턴할 수도 있음
                return new ResponseEntity<>("LOGIN_REQUIRED", HttpStatus.UNAUTHORIZED);
            }

			int result = noticeService.createNotice(noticeVO);

			if (result > 0) {
				return new ResponseEntity<>("SUCCESS", HttpStatus.OK);
			} else {
				return new ResponseEntity<>("FAIL", HttpStatus.INTERNAL_SERVER_ERROR);
			}
		} catch (Exception e) {
			log.error("등록 중 에러 발생", e);
			return new ResponseEntity<>("ERROR", HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}

	// ==========================================
	// 5. 수정 (수정됨: 로그인한 사번 확인 가능)
	// ==========================================
	@PostMapping("/update")
	public ResponseEntity<String> updateNotice(
			NoticeVO noticeVO, 
			@RequestParam(value = "deleteFileNos", required = false) List<Integer> deleteFileNos,
			@RequestParam(value = "files", required = false) List<MultipartFile> files,
            @AuthenticationPrincipal CustomEmployee customUser // [추가]
	) {
		log.info("수정 요청 - 제목: {}", noticeVO.getNoticeTitle());

		try {
            // [선택 사항] 수정자 정보를 업데이트해야 한다면 여기서도 세팅
            if(customUser != null) {
                int empNo = customUser.getEmployee().getEmployeeNo();
                // noticeVO.setUpdateEmployeeNo(empNo); // 만약 수정자 컬럼이 따로 있다면
                log.info("수정 요청자 사번: {}", empNo);
            }
            
			noticeService.updateNotice(noticeVO, deleteFileNos, files);
			return new ResponseEntity<>("SUCCESS", HttpStatus.OK);
		} catch (Exception e) {
			log.error("수정 에러", e);
			return new ResponseEntity<>("FAIL", HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}

    // ... (delete, download 메서드는 기존과 동일) ...
    @PostMapping("/delete/{noticeNo}")
	public ResponseEntity<String> deleteNotice(@PathVariable("noticeNo") int noticeNo) {
		try {
			int result = noticeService.removeNotice(noticeNo);
			if (result > 0) return new ResponseEntity<>("SUCCESS", HttpStatus.OK);
			else return new ResponseEntity<>("FAIL", HttpStatus.INTERNAL_SERVER_ERROR);
		} catch (Exception e) {
			return new ResponseEntity<>("ERROR", HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}

	@GetMapping("/download/{detailNo}")
	public ResponseEntity<Resource> downloadFile(@PathVariable("detailNo") int detailNo) {
		try {
			AttachmentDetailVO fileDetail = noticeService.selectFileDetail(detailNo);
			if (fileDetail == null) return new ResponseEntity<>(HttpStatus.NOT_FOUND);

			String savePath = fileDetail.getAttachmentDetailPath();
			Path path = Paths.get(savePath);
			Resource resource = new InputStreamResource(Files.newInputStream(path));

			String saveName = fileDetail.getAttachmentDetailName();
			String originalFileName = saveName.substring(saveName.indexOf("_") + 1);

			HttpHeaders headers = new HttpHeaders();
			headers.setContentDisposition(ContentDisposition.builder("attachment")
					.filename(originalFileName, StandardCharsets.UTF_8).build());
			headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);

			return new ResponseEntity<>(resource, headers, HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			return new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}
}