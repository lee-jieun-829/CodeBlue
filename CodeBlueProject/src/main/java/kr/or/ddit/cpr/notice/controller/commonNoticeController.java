package kr.or.ddit.cpr.notice.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import kr.or.ddit.cpr.admin.service.INoticeService;
import kr.or.ddit.cpr.admin.vo.NoticeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/notice")
public class commonNoticeController {
	@Autowired
	public INoticeService noticeService;
	/**
	 * 작성자 : 이지은
	 * 공통 공지사항 메인 출력 메소드
	 * @return notice/main.jsp
	 */
	@GetMapping("/main")
	public String outpatientForm() {		
		return "notice/main";
	}
	
	/**
	 * 작성자 : 이지은
	 * 공통 공지사항 리스트 출력 메소드
	 * @return
	 */
	@ResponseBody
	@GetMapping("/select")
    public List<NoticeVO> getNoticeList() {       
        List<NoticeVO> list = noticeService.retrieveNoticeList();        
        return list;
    }
	
	/**
	 * 작성자 : 이지은
	 * @param noticeNo 찾을 공지사항 번호
	 * @return noticeNo에 해당하는 vo
	 */
	@ResponseBody
	@GetMapping("/detail/{noticeNo}")
    public ResponseEntity<NoticeVO> getNoticeDetail(@PathVariable("noticeNo") int noticeNo) {       
		NoticeVO noticeVO = noticeService.retrieveNotice(noticeNo);		
		if (noticeVO != null) {
			return new ResponseEntity<>(noticeVO, HttpStatus.OK);
		} else {
			return new ResponseEntity<>(HttpStatus.NOT_FOUND);
		}
       
    }

}
