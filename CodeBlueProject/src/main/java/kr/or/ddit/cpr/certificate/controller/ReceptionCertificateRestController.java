package kr.or.ddit.cpr.certificate.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.ModelAndView;

import kr.or.ddit.cpr.certificate.service.IReceptionCertificateService;
import kr.or.ddit.cpr.vo.DiagnosisVO;
import lombok.extern.slf4j.Slf4j;

/**
 * <p>원무 제증명 데이터 처리 비동기 컨트롤러</p>
 * @author 강지현
 */
@Slf4j
@RestController
@RequestMapping("/reception/certificate")
public class ReceptionCertificateRestController {

	@Autowired
	private IReceptionCertificateService service;
	
	/**
	 * <p>증명서 내역 조회</p>
	 * @param patientNo
	 * @return
	 */
	@GetMapping("/list")
	public List<Map<String, Object>> getCertificateList(@RequestParam("patientNo") int patientNo){
		// 환자 번호 파라미터로 받아 서비스 호출
		return service.selectMedicalCertificateList(patientNo);
	}
	
	/**
	 * <p>증명서 발급 요청</p>
	 * @param params
	 * @return
	 */
	@PostMapping("/request")
	@ResponseBody
	public ResponseEntity<?> requestCertificate(@RequestBody Map<String, Object> params) {
		// 제증명 발급 요청 저장
	    // params에는 patientNo와 certificateType('DIAG' 또는 'OPIN')이 담겨옴
	    int result = service.requestCertificate(params);
	    
	    if(result > 0) {
	    	// 알림 보낼 해당 환자의 현재 담당의 사번 조회(환자 번호 기준)
	    	int patientNo = Integer.parseInt(params.get("patientNo").toString());
	    	int doctorEmpNo = service.selectCurrentDoctorNo(patientNo);
	    	
	    	// 상태값과 사번 함께 반환
	    	return ResponseEntity.ok(Map.of(
	    			"status", "success",
	    			"doctorEmpNo", doctorEmpNo
	    	));
	    }
	    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("fail");
	}
	
	/**
	 * <p>증명서 상세 조회</p>
	 * @param printNo
	 * @return
	 */
	@GetMapping("/viewCertificate")
	public ModelAndView viewCertificatePdf(@RequestParam String printNo) { // ModelAndView : @RestController 내부에서 특정 메서드만 JSP 화면(View)을 보여줘야 할 때 사용
		// 환자 정보 및 증명서 조회
		Map<String, Object> certData = service.selectCertificateDetail(printNo);
		
	    if (certData == null || certData.isEmpty()) {
	        return new ModelAndView("certificate/certificatePdf").addObject("error", "Y");
	    }
	    
	    // 상병리스트 조회 후 Map에 추가
	    int chartNo = Integer.parseInt(certData.get("CHART_NO").toString());
	    List<DiagnosisVO> diagnosisList = service.selectDiagnosisList(chartNo);
	    certData.put("diagnosisList", diagnosisList);
	    
	    return new ModelAndView("certificate/certificatePdf").addObject("certData", certData);
		
	}
}
