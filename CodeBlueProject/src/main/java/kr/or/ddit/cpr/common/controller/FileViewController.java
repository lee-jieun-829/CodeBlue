package kr.or.ddit.cpr.common.controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.servlet.HandlerMapping;

import jakarta.servlet.http.HttpServletRequest;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Controller
public class FileViewController {
// 필요없음
//	@GetMapping("/upload/**")
//	public ResponseEntity<Resource> streamFile(HttpServletRequest request){
//		String fullPath = (String) request.getAttribute(HandlerMapping.PATH_WITHIN_HANDLER_MAPPING_ATTRIBUTE);
//	    String relativePath = fullPath.substring("/upload/".length());
//
//	    try {
//	        relativePath = java.net.URLDecoder.decode(relativePath, "UTF-8");
//	    } catch (java.io.UnsupportedEncodingException e) {
//	        log.error("인코딩 디코딩 실패", e);
//	    }
//
//	    String baseDir = "\\\\112.220.114.130\\upload\\";
//	    Path filePath = Paths.get(baseDir, relativePath).normalize();
//	    
//	    log.info("🚩 [디코딩 완료] 실제 탐색 경로: {}", filePath.toAbsolutePath());
//
//	    Resource resource = new FileSystemResource(filePath.toFile());
//
//	    if (!resource.exists()) {
//	        log.error("❌ [파일 없음] 실제 하드디스크에 파일이 없습니다: {}", filePath.toAbsolutePath());
//	        return new ResponseEntity<>(HttpStatus.NOT_FOUND);
//	    }
//
//	    HttpHeaders headers = new HttpHeaders();
//	    try {
//	        headers.add("Content-Type", Files.probeContentType(filePath));
//	    } catch (IOException e) {
//	        log.error("파일 타입 분석 실패", e);
//	    }
//
//	    return new ResponseEntity<>(resource, headers, HttpStatus.OK);
//	}
}
