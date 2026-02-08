package kr.or.ddit.cpr.execution.therapist.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.execution.therapist.service.ITherapistService;
import kr.or.ddit.cpr.vo.PatientDetailVO;
import kr.or.ddit.cpr.vo.PatientVO;
import kr.or.ddit.cpr.vo.PredetailWatingListVO;
import kr.or.ddit.cpr.vo.TreatmentOrderVO;
import kr.or.ddit.cpr.vo.TreatmentVO;
import lombok.extern.slf4j.Slf4j;

/**
 * ================================
 * - 물리치료 workview 비동기 컨트롤러
 * - auth : Been daye
 * - date : 2026.01.12
 * ================================
 */
@Slf4j
@RestController
@RequestMapping("/therapist/workview")
public class TherapistWorkRestController {

	@Autowired
	private ITherapistService service;
	
	/**
	 * <p>대기환자목록</p>
	 * @author 빈다예
	 * @return  ResponseEntity<List<PatientWaitingListVO>> 리스트 형식의 대기환자목록 반환
	 * @date 2026/01/12
	 */
	@GetMapping("/waitingList")
	public ResponseEntity<List<PredetailWatingListVO>> getWatingList(){
		log.info("getWatingList() 실행");
		List<PredetailWatingListVO> waitingList = service.getWaitingList();

		return ResponseEntity.ok(waitingList);
	}
	
	/**
	 * 대기 환자 상태 변경
	 * 트랜잭션 처리
	 * @author 빈다예
	 * @param status
	 * @return 성공 / 실패
	 */
	@PostMapping("/waitingStatus")
	public ResponseEntity<Map<String, Object>> updateWaitingStatus(@RequestBody Map<String, Object> params) {
	    try {
	        int predetailNo = Integer.parseInt(params.get("predetailNo").toString());
	        String preTreatdetailStatus = params.get("preTreatdetailStatus").toString();
	        
	        service.updateWaitingStatus(predetailNo, preTreatdetailStatus);
	        
	        return ResponseEntity.ok(Map.of("success", true));
	        
	    } catch (Exception e) {
	        log.error("상태 변경 실패: {}", e.getMessage());
	        return ResponseEntity.ok(Map.of("success", false, "message", e.getMessage()));
	    }
	}
	
	/**
     * 환자 상세 정보 조회 
     * @author 빈다예
     * @param patientNo 환자번호
     * @return 200. 환자 상세 정보
     */
    @GetMapping("/patient/{patientNo}")
    public ResponseEntity<List<PatientDetailVO>> getPatientDetail(@PathVariable int patientNo){
    	log.info("getPatientDetail() 실행 - patientNo: {}", patientNo);
        List<PatientDetailVO> patientDetail = service.getPatientDetail(patientNo);
        if (patientDetail == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(patientDetail);
    }
    
    /**
     * 환자 메모 업데이트
     * @author 빈다예
     * @param patientVO
     * @return 성공 / 실패
     */
    @PostMapping("/patient/updatePetientMemo")
    public ResponseEntity<Map<String, Object>> updateMemo(@RequestBody PatientVO patientVO ){
    	Map<String, Object> resultMap = new HashMap<>();
    	
    	try { 
    		int result = service.updatePatientMemo(patientVO);
    		
    		if(result > 0) {
    			resultMap.put("success", true);
    			return ResponseEntity.ok(resultMap);
    		} else {
    			resultMap.put("success", false);
    			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(resultMap);
    		}
    	} catch(Exception e) {
    		resultMap.put("success", false);
    		return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(resultMap);
    	}
    }
    
    /**
     * 환자 오더 내역
     * @param patientNo
     * @return 200. 오더 목록
     */
    @GetMapping("/patientOrder/{patientNo}")
    public ResponseEntity<List<TreatmentOrderVO>> getOrderList(@PathVariable int patientNo){
    	log.info("영상검사 오더 목록 조회 시작 - patientNo: {}", patientNo);
        
        // 1. 서비스 호출 (List로 받기)
        List<TreatmentOrderVO> orderList = service.getOrderList(patientNo);
        
        // 2. 로그로 데이터가 잘 왔는지 확인
        log.info("조회된 오더 건수: {}", orderList.size());
        
        // 3. 결과 반환 (데이터가 없어도 빈 리스트 []와 함께 200 OK를 보냅니다)
        return ResponseEntity.ok(orderList);
    }
    
    /**
     * 환자 오더 상세 내역
     * @param predetailNo
     * @return 200.오더 상세 목록
     */
    @GetMapping("/orderDetail/{predetailNo}")
    public ResponseEntity<List<TreatmentOrderVO>> getOrderDetail(@PathVariable int predetailNo){
    	log.info("영상검사 오더 상세조회 - predetail: {}", predetailNo);
    	
    	List<TreatmentOrderVO> list = service.getOrderDetail(predetailNo);
    	log.info("조회된 오더 건수: {}", list.size());
    	
    	return ResponseEntity.ok(list);
    }
    
    /**
     * 오더 결과 및 상태값 전송
     * @param orderVO
     * @return 성공 / 서버 에러
     */
    @PostMapping("/complete")
    public ResponseEntity<Map<String, Object>> completeExam(@RequestBody TreatmentVO treatmentVO){
    	Map<String, Object> result = new HashMap<>();
    	
    	try {
    		// 처방번호 오뎅?
    		if(treatmentVO.getPredetailNo() == 0) {
    			result.put("success", false);
    			result.put("message", "처방번호가 누락됐습니다. 확인해주세요.");
    			return ResponseEntity.badRequest().body(result);
    		}
    		
    		int updateResult = service.updateComplete(treatmentVO);
    		
    		if(updateResult > 0) { // 성공적인 결과값(200)
    			result.put("success", true);
    			
    			return ResponseEntity.ok(result);
    		} else { // 실패..
    			result.put("success", false);
    			result.put("message", "상태 업데이트 중 알 수 없는 오류가 발생했습니다.");
    			// 예외 발생 시에도 500 에러를 명시적으로 던져준다.
    			return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
    		}
    	} catch (Exception e) {
    		e.printStackTrace();
    		result.put("success", false);
            result.put("message", "서버 에러 발생: " + e.getMessage());
            // 예외 발생 시에도 500 에러를 명시적으로 던져준다.
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
    	}
    }
}
