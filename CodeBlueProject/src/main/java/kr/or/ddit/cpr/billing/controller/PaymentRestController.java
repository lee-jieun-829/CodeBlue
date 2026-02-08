package kr.or.ddit.cpr.billing.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.billing.service.IPaymentService;
import kr.or.ddit.cpr.vo.AdmissionVO;
import lombok.extern.slf4j.Slf4j;

/**
 * 원무 수납 및 결제 컨트롤러
 */
@Slf4j
@RestController
@RequestMapping("/payment")
public class PaymentRestController {

	@Autowired
	private IPaymentService service;
	
	/**
	 * <p>[외래/입원 공통] 수납 대기 목록 조회</p>
	 * @return
	 */
	@GetMapping("/allWaitingList")
	public Map<String, Object> getAllWaitingList(){
		Map<String, Object> result = new HashMap<>();
		result.put("outpatient", service.selectOutpatientWaitingList());
		result.put("inpatient", service.selectInpatientWaitingList());
		return result;
	}
	
	/**
	 * <p>외래 수납 상세 내역(진료 항목 및 수가) 조회</p>
	 * @param registrationNo
	 * @return
	 */
	@GetMapping("/getPrescriptionDetails")
	public List<Map<String, Object>> getPrescriptionDetails(@RequestParam int registrationNo){
		log.info("getPrescriptionDetails() 실행 - 접수 번호 :", registrationNo);
		return service.selectPrescriptionDetails(registrationNo);
	}
	
	/**
	 * <p>외래 수납 및 완료 처리(결제 내역 저장 및 접수 상태 변경)</p>
	 * @param regVO
	 * @return
	 */
	@PostMapping("/updateRegistrationStatus")
	public ResponseEntity<String> updateRegistrationStatus(@RequestBody Map<String, Object> paymentData){
		log.info("updateRegistrationStatus() 실행 - 데이터 : ", paymentData);
		
		int row = service.updateRegistrationStatus(paymentData);
		
		// 중복 결제로 인해 -1을 반환했다면 클라이언트에 알림
		if(row == -1) return ResponseEntity.status(409).body("already_paid");
		
		return row > 0 ? ResponseEntity.ok("success") : ResponseEntity.status(500).body("fail");
	}
	
	/**
	 * <p>입원 수납 상세 내역 조회</p>
	 * @param admissionNo
	 * @return
	 */
	@GetMapping("/getInpatientPrescriptionDetails")
	public List<Map<String, Object>> getInpatientPrescriptionDetails(@RequestParam int admissionNo){
		log.info("getInpatientPrescriptionDetails() 실행 - 입원번호 : ", admissionNo);
		return service.selectInpatientPrescriptionDetails(admissionNo);
	}
	
	/**
	 * <p>입원 수납 및 퇴원 완료 처리</p>
	 * @param admissionVO
	 * @return
	 */
	@PostMapping("/updateAdmissionStatus")
	public ResponseEntity<String> updateAdmissionStatus(@RequestBody Map<String, Object> paymentData){
		log.info("updateAdmissionStatus() 실행 - 데이터 : ", paymentData);
		
		int row = service.updateAdmissionStatus(paymentData);
		
		return row > 0 ? ResponseEntity.ok("success") : ResponseEntity.status(500).body("fail");
	}
	
	/**
	 * <p>카카오페이 결제 준비 (Ready)</p>
	 * @param params
	 * @return
	 */
	@PostMapping("/kakaoPayReady")
	public Map<String, Object> kakaoPayReady(@RequestBody Map<String, Object> params){
		log.info("kakaoPayReady() 실행 - 상품명, 금액 : ", params.get("itemName"), params.get("paymentAmount"));
		
		// 카카오 서버와 통신 후 TID와 URL 담은 Map 반환
		return service.kakaoPayReady(params);
	}
	
	/**
	 * <p>카카오페이 결제 승인(Approve)</p>
	 * @param pgToken
	 * @param registrationNo
	 * @return
	 */
	@GetMapping("/kakaoPaySuccess")
	public String kakaoPaySuccess(@RequestParam("pg_token") String pgToken, 
				@RequestParam("orderId") String orderId) {
	    log.info("결제 승인 성공 - 토큰: {}, 접수번호: {}", pgToken, orderId);
	    
	    // 팝업창에 "결제 완료" 메시지를 띄움
	    return "<script>" +
	       "  alert('결제가 완료되었습니다.');" +
	       "  if (window.opener && !window.opener.closed) {" +
	       "    window.opener.executeFinalPayment('" + pgToken + "');" + 
	       "  }" +
	       "  window.close();" +
	       "</script>";
	}
	
	/**
	 * <p>제증명 수납 완료 처리</p>
	 * @param params
	 * @return
	 */
	@ResponseBody
	@PostMapping("/updateCertificateStatus")
	public String updateCertificateStatus(@RequestBody Map<String, Object> params) {
		int result = service.updateCertificateStatus(params);
		return result > 0 ? "success" : "fail";
	}
}
