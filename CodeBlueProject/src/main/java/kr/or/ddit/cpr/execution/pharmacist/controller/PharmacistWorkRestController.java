package kr.or.ddit.cpr.execution.pharmacist.controller;

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

import kr.or.ddit.cpr.execution.pharmacist.service.IPharmacistService;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.PharmacistOrderVO;
import kr.or.ddit.cpr.vo.TreatmentOrderVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/pharmacist")
public class PharmacistWorkRestController {

	@Autowired
	private IPharmacistService service;
	
	// 환자 검색

	

	/**
     * 대기 환자 조회 
     * @author 빈다예
     * @return 200. 환자 상세 정보
     */
	@GetMapping("/patient/waitingList")
    public ResponseEntity<List<PharmacistOrderVO>> getWaitingList(){
        log.info("getWaitingList() 실행 중 >> ");
        List<PharmacistOrderVO> orderVO = service.getWaitingList();
        return ResponseEntity.ok(orderVO);
    }

	/**
	 * 대기 환자 상태 변경
	 * 트랜잭션 처리
	 * @author 빈다예
	 * @param status
	 * @return 성공 / 실패
	 */
	@PostMapping("/patient/waitingStatus")
	public ResponseEntity<Map<String, Object>> updateWaitingStatus(@RequestBody Map<String, Object> params){
		try {
	        Long predetailNo = Long.parseLong(String.valueOf(params.get("predetailNo")));
	        String preDrugdetailStatus = String.valueOf(params.get("predrugDetailStatus"));
	        
	        log.info("상태 변경 요청 - 번호: {}, 상태: {}", predetailNo, preDrugdetailStatus);
	        
	        service.updateWaitingStatus(predetailNo, preDrugdetailStatus);
	        
	        return ResponseEntity.ok(Map.of("success", true));
	        
	    } catch (Exception e) {
	        log.error("상태 변경 실패: {}", e.getMessage());
	        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
	                             .body(Map.of("success", false, "message", "파라미터가 올바르지 않습니다."));
	    }
	}
	
	/**
     * 환자 상세 정보 조회 
     * @author 빈다예
     * @param predetailNo 접수번호
     * @return 200. 환자 상세 정보
     */
	@GetMapping("/{predetailNo}")
	public ResponseEntity<PharmacistOrderVO> getPatientDetail(@PathVariable Long predetailNo){
		log.info("getPatientDetail() 실행 중 >>");
		PharmacistOrderVO patientDetail = service.getPatientDetail(predetailNo);
		if(patientDetail == null) {
			return ResponseEntity.notFound().build();
		} 
		return ResponseEntity.ok(patientDetail);
	}
	
	/**
     * 조제 약품 목록 조회 + 약품 재고 조회
     * @author 빈다예
     * @param predetailNo 접수번호
     * @return 200. 약품 목록
     */
	@GetMapping("/patientOrder/{predetailNo}")
    public ResponseEntity<List<DrugVO>> getPatientOrder(@PathVariable Long predetailNo) {
        try {
            List<DrugVO> drugList = service.getOrderDrugList(predetailNo);
            
            if (drugList == null || drugList.isEmpty()) {
                // 데이터가 없는 경우 204 No Content 반환
                return ResponseEntity.noContent().build();
            }
            
            // 데이터가 있는 경우 200 OK와 함께 목록 반환
            return ResponseEntity.ok(drugList);
            
        } catch (Exception e) {
            log.error("약 처방 목록 조회 중 오류 발생: {}", e.getMessage());
            // 서버 오류 발생 시 500 Internal Server Error 반환
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
	
	// 조제 약품 재고량 업데이트 + 상태 변경
	/**
     * 오더 결과 및 상태값 전송
     * @param orderVO
     * @return 성공 / 서버 에러
     */
    @PostMapping("/workview/complete")
    public ResponseEntity<Map<String, Object>> completeOrder(@RequestBody DrugVO drugVO){
    	Map<String, Object> result = new HashMap<>();
    	
    	try {
    		// 처방번호 오뎅?
    		if(drugVO.getPredetailNo() == null || drugVO.getPredetailNo() == 0) {
    			result.put("success", false);
    			result.put("message", "처방번호가 누락됐습니다. 확인해주세요.");
    			return ResponseEntity.badRequest().body(result);
    		}
    		
    		int updateResult = service.updateComplete(drugVO.getPredetailNo());
    		
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

