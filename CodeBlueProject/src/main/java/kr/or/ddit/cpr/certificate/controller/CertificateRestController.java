package kr.or.ddit.cpr.certificate.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.google.auto.value.AutoAnnotation;

import kr.or.ddit.cpr.certificate.service.ICertificateService;
import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.notification.service.INotificationService;
import kr.or.ddit.cpr.vo.CertificateVO;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.PatientVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/certificate/api")
public class CertificateRestController {
	
	@Autowired
	private ICertificateService certificateService;
	
	@Autowired
	private INotificationService notificationService;
	
	/**
	 * 사용자가 검색어를 입력하고 비동기 요청을 하면 DB에서 환자 정보를 가져와 반환하는 함수
	 * @author 박성현
	 * @date 2026-01-09
	 * @param keyword 환자명 및 환자번호 검색
	 * @param loginUser
	 * @return ResponseEntity<List<CertificateVO>> 리스트 형식의 환자 정보 반환
	 */
	@GetMapping("/searchPatient")
	public ResponseEntity<List<CertificateVO>> searchPatient(
			@RequestParam(name = "keyword", required = false) String keyword,
            @AuthenticationPrincipal CustomEmployee loginUser){
		
		List<CertificateVO> list = certificateService.searchPatient(keyword);

	    if (list == null || list.isEmpty()) {
	        return ResponseEntity.noContent().build(); 
	    }

	    return ResponseEntity.ok(list);
	}
	
	/**
	 * 환자 선택 시 차트목록 반환하는 함수
	 * @author 박성현
	 * @date 2026-01-09
	 * @param patientNo 환자번호로 검색
	 * @return ResponseEntity<List<ChartVO>> 리스트 형식의 환자 차트정보 반환
	 */
	@GetMapping("/patientChartDetail")
    public ResponseEntity<List<ChartVO>> PatientChartDetail(@RequestParam int patientNo) {
        List<ChartVO> list = certificateService.selectPatientChart(patientNo);
        return ResponseEntity.ok(list);
    }
	
	/**
	 * 환자 검색 후 서류 불어오는 함수
	 * @author 박성현
	 * @date 2026-01-12
	 * @param patientNo
	 * @return ResponseEntity<List<CertificateVO>> 리스트 형식의 환자 서류 정보 반환
	 */
	@GetMapping("/patientDocList")
	public ResponseEntity<List<CertificateVO>> patientDocList(@RequestParam int patientNo){
		List<CertificateVO> list = certificateService.selectPatientDoc(patientNo);
		
		return ResponseEntity.ok(list);
	}
	
	/**
	 * 진단서 및 소견서 서류 입력값 불러오는 함수
	 * @author 박성현
	 * @date 2026-01-12
	 * @param certificateNo
	 * @param chartNo
	 * @return ResponseEntity<List<CertificateVO>> 리스트 형식의 환자 서류 입력값 정보 반환
	 */
	@GetMapping("/patientDocDetail")
	public ResponseEntity<List<CertificateVO>> patientDocDetail(
			@RequestParam String docType,
			@RequestParam(name = "certificateNo", required = false) Integer certificateNo,
			@RequestParam int chartNo,
			@RequestParam(name = "clickDate", required = false) String clickDate){
		
		log.info("상세조회 요청 - 타입: {}, 증명서번호: {}, 차트번호: {}", docType, certificateNo, chartNo, clickDate);
		
		int certNo = (certificateNo == null) ? 0 : certificateNo;
		List<CertificateVO> list = certificateService.selectDocDetail(docType, certNo, chartNo, clickDate);
		
		return ResponseEntity.ok(list);
	}
	
	/**
	 * 진단서 및 소견서 서류 입력 저장하는 함수
	 * @author 박성현
	 * @date 2026-01-13
	 * @param vo
	 * @param loginUser
	 * @return
	 */
	@PostMapping("/insertCertificate")
	public Map<String, Object> insertCertificate(
			@RequestBody CertificateVO vo,
			@AuthenticationPrincipal CustomEmployee loginUser){
		
		int employeeNo = loginUser.getEmployee().getEmployeeNo();
		log.info("등록 시도 사번: {}, 차트번호: {}", employeeNo, vo.getChartNo());
		vo.setEmployeeNo(employeeNo);
		
		return certificateService.insertCertificate(vo);
	}

}





















