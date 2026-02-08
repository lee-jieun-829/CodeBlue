package kr.or.ddit.cpr.billing.service;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import jakarta.servlet.http.HttpServletRequest;
import kr.or.ddit.cpr.billing.mapper.IPaymentMapper;
import kr.or.ddit.cpr.prescription.service.IPrescriptionService;
import kr.or.ddit.cpr.vo.AdmissionVO;
import kr.or.ddit.cpr.vo.DietVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.ExaminationVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.TreatmentVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class PaymentServiceImpl implements IPaymentService {

	@Autowired
	private IPaymentMapper mapper;
	
	// 외래 수납 대기 목록 조회 (수납대기(004)인 환자)
	@Override
	public List<Map<String, Object>> selectOutpatientWaitingList() {
		return mapper.selectOutpatientWaitingList();
	}

	// 입원 수납 대기 목록 조회(퇴원대기(002), 퇴원수납대기(003)인 환자)
	@Override
	public List<Map<String, Object>> selectInpatientWaitingList() {
		return mapper.selectInpatientWaitingList();
	}
	
	// 외래 수납 상세 내역 조회
	@Override
	public List<Map<String, Object>> selectPrescriptionDetails(int registrationNo) {		
		return mapper.selectPrescriptionDetails(registrationNo);
	}

	// 외래 수납 및 완료 처리(결제 내역 저장 및 접수 상태 변경)
	@Transactional
	@Override
	public int updateRegistrationStatus(Map<String, Object> paymentData) {
		// 10원 절삭
		int originalAmount = Integer.parseInt(paymentData.get("paymentAmount").toString());
		paymentData.put("paymentAmount", (originalAmount / 10) * 10);
		
		// 현재 상태 재조회 (중복 수납 방지)
		String currentStatus = mapper.selectRegistrationStatus(paymentData);
	    if ("005".equals(currentStatus)) { // 이미 수납완료 상태라면
	        return -1; // 중복 결제 신호 반환
	    }
		
		// 수납 내역 저장
		mapper.insertBill(paymentData);
		
		// 결제 내역 저장
		mapper.insertPayment(paymentData);
		
		// 접수 상태 변경(수납 완료)
		int row = mapper.updateRegistrationStatus(paymentData);
		
		return row;
	}

	// 입원 수납 상세 내역 조회
	@Override
	public List<Map<String, Object>> selectInpatientPrescriptionDetails(int admissionNo) {		
		
		// 수술과 병실 내역 가져오기
		List<Map<String, Object>> finalBill = mapper.selectInpatientPrescriptionDetails(admissionNo);
		
		// 해당 입원의 모든 처방(PREDETAIL) 리스트 조회
		List<PredetailVO> preList = mapper.selectPredetailListByAdmission(admissionNo);
		
		if(preList != null && !preList.isEmpty()) {
			for(int i = 0; i < preList.size(); i++) {
				PredetailVO current = preList.get(i);
				
				// 날짜 구간 계산 (후처방 등록일 - 전처방 등록일)
				long activeDays = 0;
				if(i < preList.size() - 1) {
					// 다음 처방이 있는 경우 : 다음 등록일 전까지
					activeDays = calculateDays(current.getPredetailRegdate(), preList.get(i + 1).getPredetailRegdate());
				}else {
					// 마지막 처방인 경우 : 오늘(또는 퇴원일)까지
					activeDays = calculateDays(current.getPredetailRegdate(), new Date());
				}
				
				if(activeDays < 1) activeDays = 1; // 당일 변경 대비 최소 1일 보장
				
				// 처방별 상세 내역 합산(완료(001) 및 중단(004) 항목 포함)
				addPrescriptionItemsToBill(finalBill, current, activeDays);
			}
		}
		return finalBill;
	}

	// 처방 상세 항목(약, 치료, 검사, 식이)을 합산하여 리스트에 추가
	private void addPrescriptionItemsToBill(List<Map<String, Object>> bill, PredetailVO vo, long days) {
		// 약품 리스트
		if(vo.getDrugList() != null) {
			for(DrugVO drug : vo.getDrugList()) {
				String status = drug.getPredrugDetailStatus();
				if("001".equals(status) || "004".equals(status)) {
					Map<String, Object> item = new HashMap<>();
					item.put("NAME", drug.getDrugName() + ("004".equals(status) ? " (중단)" : "" ));
					item.put("PRICE", (long)drug.getDrugPrice() * drug.getPredrugDetailFreq() * days);
					bill.add(item);
				}
			}
		}
		
		// 치료 리스트
		if(vo.getTreatList() != null) {
			for(TreatmentVO treat : vo.getTreatList()) {
				String status = treat.getPretreatmentDetailStatus();
				if("001".equals(status) || "004".equals(status)) {
					Map<String, Object> item = new HashMap<>();
					item.put("NAME", treat.getTreatmentName() + ("004".equals(status) ? " (중단)" : ""));
					item.put("PRICE", treat.getTreatmentPrice() * treat.getPretreatmentDetailFreq() * days);
					bill.add(item);
				}
			}
		}
		
		// 검사 리스트
		if(vo.getExamList() != null) {
			for(ExaminationVO exam : vo.getExamList()) {
				String status = exam.getPreexaminationDetailStatus();
				if("001".equals(status) || "004".equals(status)) {
					Map<String, Object> item = new HashMap<>();
					item.put("NAME", exam.getExaminationName() + ("004".equals(status) ? " (중단)" : ""));
					item.put("PRICE", (long)(exam.getExaminationPrice() * exam.getPreexaminationDetailFreq() * days));
					bill.add(item);
				}
			}
		}
		
		// 식이 리스트
		if(vo.getDietList() != null) {
			for(DietVO diet : vo.getDietList()) {
				String status = diet.getPredietStatus();
				if("001".equals(status) || "004".equals(status)) {
					Map<String, Object> item = new HashMap<>();
					item.put("NAME", diet.getDietName() + ("004".equals(status) ? " (중단)" : ""));
					
					// String일 경우 숫자로 변환하여 계산 (Null 방어 포함)
					long price = (diet.getDietPrice() != null) ? Long.parseLong(diet.getDietPrice().toString()) : 0L;
					long freq = (diet.getPredietFreq() != null) ? Long.parseLong(diet.getPredietFreq().toString()) : 0L;

					item.put("PRICE", price * freq * days);
					bill.add(item);
				}
			}
		}
	}

	// 일수 계산용 
	private long calculateDays(Date start, Date end) {
		long diff = Math.abs(end.getTime() - start.getTime());
		return TimeUnit.DAYS.convert(diff, TimeUnit.MILLISECONDS);
	}

	// 입원 수납 및 퇴원 완료 처리
	@Transactional
	@Override
	public int updateAdmissionStatus(Map<String, Object> paymentData) {
		// 10원 절삭
		int originalAmount = Integer.parseInt(paymentData.get("paymentAmount").toString());
		paymentData.put("paymentAmount", (originalAmount / 10) * 10);
		
		// 현재 상태 재조회 (중복 수납 방지)
		String currentStatus = mapper.selectAdmissionStatus(paymentData);
	    if ("004".equals(currentStatus)) { // 이미 퇴원(수납완료) 상태라면
	        return -1;
	    }
		
		// 수납 내역 저장
		mapper.insertBill(paymentData);
		
		// 결제 내역 저장
		mapper.insertPayment(paymentData);
		
		// 입원 수납 상태 '퇴원(004)'으로 변경 
		int row = mapper.updateAdmissionStatus(paymentData);
		
		// 수납 처리 성공하면 침상 상태 '사용가능(001)'으로 변경
		if(row > 0 && paymentData.get("bedNo") != null) {
			int bedNo = Integer.parseInt(paymentData.get("bedNo").toString());
			mapper.updateBedStatusAvailable(bedNo);
		}
		
		return row;
	}

	// 카카오페이 결제 준비 (Ready)
	@Override
	public Map<String, Object> kakaoPayReady(Map<String, Object> params) {
		
		// 결제 준비 전 상태 재조회 (중복 결제 방지)
		String currentStatus = "";
	    if (params.get("admissionNo") != null) {
	        currentStatus = mapper.selectAdmissionStatus(params);
	        if ("004".equals(currentStatus)) { // 입원 퇴원(수납완료)
	            Map<String, Object> error = new HashMap<>();
	            error.put("status", "already_paid");
	            return error;
	        }
	    } else if (params.get("registrationNo") != null) {
	        currentStatus = mapper.selectRegistrationStatus(params);
	        if ("005".equals(currentStatus)) { // 외래 수납완료
	            Map<String, Object> error = new HashMap<>();
	            error.put("status", "already_paid");
	            return error;
	        }
	    }
		
		RestTemplate restTemplate = new RestTemplate();

	    // 헤더 설정 (SECRET_KEY 인증 방식)
	    HttpHeaders headers = new HttpHeaders();
	    headers.set("Authorization", "SECRET_KEY " + "DEV9413D1C4BDA552835C1053A44214BD88A6744"); // 실제_SECRET_KEY_DEV 넣어야함
	    headers.setContentType(MediaType.APPLICATION_JSON);

	    // 바디 설정 (HashMap/JSON 방식)
	    Map<String, Object> body = new HashMap<>();
	    body.put("cid", "TC0ONETIME"); // 테스트 가맹점 코드
	    // 외래면 접수번호, 입원이면 입원번호
	    String orderId = "";
	    if (params.get("registrationNo") != null) {
	        orderId = params.get("registrationNo").toString();
	    } else if (params.get("admissionNo") != null) {
	        orderId = params.get("admissionNo").toString();
	    } else if ("CERT".equals(params.get("type"))) {
	        // 제증명일 경우 발급번호 리스트 중 첫 번째 번호를 주문번호로 사용
	        List<String> certList = (List<String>) params.get("certPrintNoList");
	        if (certList != null && !certList.isEmpty()) {
	            orderId = certList.get(0);
	        } else {
	            orderId = "CERT_" + System.currentTimeMillis(); // 비상용 ID
	        }
	    }
	    
	    body.put("partner_order_id", orderId);
	    body.put("partner_user_id", "PATIENT_" + params.get("patientNo"));	// 환자 번호
	    body.put("item_name", params.get("itemName").toString());			// 상품명
	    body.put("quantity", 1);											// 상품 수량
	    //body.put("total_amount", Integer.parseInt(params.get("paymentAmount").toString())); // 상품 총액
	    // 10원 미만 절삭 로직
	    int rawAmount = Integer.parseInt(params.get("paymentAmount").toString());
	    int finalAmount = (rawAmount / 10) * 10; // 10원 단위 절삭
	    body.put("total_amount", finalAmount); // 상품 총액
	    body.put("tax_free_amount", 0);										// 상품 비과세 금액
	    
	    // 성공/취소/실패 리다이렉트 URL 
	    //String baseUrl = "http://localhost:8060/payment";
	    HttpServletRequest req = ((ServletRequestAttributes) RequestContextHolder.getRequestAttributes()).getRequest();
	    String scheme = req.getScheme();   // http
	    String serverName = req.getServerName(); // IP 또는 localhost
	    int serverPort = req.getServerPort();    // 8060

	    String baseUrl = scheme + "://" + serverName + ":" + serverPort + "/payment";
	    
	    body.put("approval_url", baseUrl + "/kakaoPaySuccess?orderId=" + orderId); 
	    body.put("cancel_url", baseUrl + "/kakaoPayCancel");
	    body.put("fail_url", baseUrl + "/kakaoPayFail");

	    // URL로 POST 요청 전송
	    String url = "https://open-api.kakaopay.com/online/v1/payment/ready";
	    HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);

	    try {
	        return restTemplate.postForObject(url, request, Map.class);
	    } catch (Exception e) {
	        log.error("카카오 결제 준비 에러: {}", e.getMessage());
	        return null;
	    }
	}

	// 제증명 수납 완료 처리
	@Transactional
	@Override
	public int updateCertificateStatus(Map<String, Object> params) {
		// 10원 절삭
		int originalAmount = Integer.parseInt(params.get("paymentAmount").toString());
		params.put("paymentAmount", (originalAmount / 10) * 10); // 10원 미만 절삭
		
		// 수납 테이블에 수냅 내역 생성
		mapper.insertBill(params);
		
		// 결제 테이블에 결제 내역 생성
		mapper.insertPayment(params);
		
		// 증명서 테이블에 상태 업데이트
		return mapper.updateCertificateStatus(params);
	}

}
