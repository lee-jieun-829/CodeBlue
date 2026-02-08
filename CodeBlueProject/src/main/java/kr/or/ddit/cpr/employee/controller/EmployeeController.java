package kr.or.ddit.cpr.employee.controller;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.ContentDisposition;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import kr.or.ddit.cpr.employee.service.IEmployeeService;
import kr.or.ddit.cpr.vo.AttachmentDetailVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
@RequestMapping("/employee")
public class EmployeeController {
	
	@Autowired
	private IEmployeeService employeeService;
	
	// 마이페이지
	@GetMapping("/mypage")
	public String myPage(@RequestAttribute(value = "employee", required = false) EmployeeVO employeeVO
						 , Model model) {
		
		// 토큰없거나 만료되면 로그인으로 쫓아냄
		if(employeeVO == null) {
			return "redirect:/login";
		}
		
		EmployeeVO employee = employeeService.selectMyPage(employeeVO.getEmployeeNo());
		
		model.addAttribute("employee", employee);
		
        return "employee/mypage";
    }
	
	// 마이페이지 - 프로필 사진 노출
	@GetMapping("/profile/{fileNo}")
	public ResponseEntity<Resource> viewProfile(@PathVariable("fileNo") int detailNo){
		try {		
			// 파일 상세정보 조회
			AttachmentDetailVO fileDetail = employeeService.selectFileDetail(detailNo);
			
			// db 에 fileNo 찾기
			if (fileDetail == null) {
				log.info("❌ DB에서 파일 정보를 찾을 수 없음: 번호 {}" + fileDetail);
				return ResponseEntity.notFound().build();
			}
			
			// 경로 확인용 로그 추가!
			System.out.println("📂 DB에 저장된 경로: " + fileDetail.getAttachmentDetailPath());
			
			// 경로 찍기
			Path path = Paths.get(fileDetail.getAttachmentDetailPath());
			if (!Files.exists(path)){
				log.info("❌ 실제 파일이 존재하지 않음! 경로 확인 필요, {}", path);
				return ResponseEntity.notFound().build();
			}
			
			// 리소스 생성
			Resource resource = new UrlResource(path.toUri());

			// MIME 타입 감지
			String contentType = Files.probeContentType(path);
			if (contentType == null) contentType = "application/octet-stream";

			// 헤더 설정
			HttpHeaders headers = new HttpHeaders();
			headers.setContentType(MediaType.parseMediaType(contentType));
			
			headers.setContentDisposition(ContentDisposition.inline()
															.filename(fileDetail.getAttachmentDetailName(), StandardCharsets.UTF_8) 
															.build()
			);
			
			return ResponseEntity.ok().headers(headers).body(resource);
			
		} catch (Exception e) {
			e.printStackTrace();
	        return ResponseEntity.internalServerError().build();
		}
	}
}