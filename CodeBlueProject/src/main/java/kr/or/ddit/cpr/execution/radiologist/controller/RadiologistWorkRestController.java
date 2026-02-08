package kr.or.ddit.cpr.execution.radiologist.controller;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import jakarta.servlet.http.HttpServletRequest;
import kr.or.ddit.cpr.execution.radiologist.service.IRadiologistWorkService;
import kr.or.ddit.cpr.vo.ExamOrderVO;
import kr.or.ddit.cpr.vo.PatientDetailVO;
import kr.or.ddit.cpr.vo.PatientVO;
import kr.or.ddit.cpr.vo.PredetailWatingListVO;
import lombok.extern.slf4j.Slf4j;

/**
 * ================================
 * - 영상검사 workview 비동기 컨트롤러
 * - auth : Been daye
 * - date : 2026.01.02
 * ================================
 */
@Slf4j
@RestController
@RequestMapping("/radiologist/workview")
public class RadiologistWorkRestController {

	@Autowired
	private IRadiologistWorkService service;
	
	/**
	 * 환자 대기 목록
	 * @return 200. 환자 대기 목록
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
	 * @param params
	 * @return 성공 / 실패
	 */
	@PostMapping("/waitingStatus")
	public ResponseEntity<Map<String, Object>> updateWaitingStatus(@RequestBody Map<String, Object> params) {
	    try {
	        int predetailNo = Integer.parseInt(params.get("predetailNo").toString());
	        String preExamdetailStatus = params.get("preExamdetailStatus").toString();
	        
	        service.updateWaitingStatus(predetailNo, preExamdetailStatus);
	        
	        return ResponseEntity.ok(Map.of("success", true));
	        
	    } catch (Exception e) {
	        log.error("상태 변경 실패: {}", e.getMessage());
	        return ResponseEntity.ok(Map.of("success", false, "message", e.getMessage()));
	    }
	}

	/**
     * 환자 상세 정보 조회 
     * @param patientNo 환자번호
     * @param chartNo 차트번호 => 삭제
     * @return 200. 환자 상세 정보
     */
    @GetMapping("/patient/{patientNo}")
    public ResponseEntity<List<PatientDetailVO>> getPatientDetail(@PathVariable Integer patientNo){
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
    public ResponseEntity<List<ExamOrderVO>> getOrderList(@PathVariable Integer patientNo){
    	log.info("영상검사 오더 목록 조회 시작 - patientNo: {}", patientNo);
        
        // 1. 서비스 호출 (List로 받기)
        List<ExamOrderVO> orderList = service.getOrderList(patientNo);
        
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
    public ResponseEntity<List<ExamOrderVO>> getOrderDetail(@PathVariable int predetailNo){
    	log.info("영상검사 오더 상세조회 - predetail: {}", predetailNo);
    	
    	List<ExamOrderVO> list = service.getOrderDetail(predetailNo);
    	log.info("조회된 오더 건수: {}", list.size());
    	
    	return ResponseEntity.ok(list);
    }
    
    /**
     * 오더 결과 및 상태값 전송
     * @param orderVO
     * @return 성공 / 서버 에러
     */
    @PostMapping("/completeExam")
    public ResponseEntity<Map<String, Object>> completeExam(MultipartHttpServletRequest request){
        Map<String, Object> result = new HashMap<>();

        try {
            // 1. 파라미터 추출 및 검증
            String predetailNoStr = request.getParameter("predetailNo");
            String chartNoStr = request.getParameter("chartNo");
            String status = request.getParameter("preExamdetailStatus");

            if(predetailNoStr == null || predetailNoStr.isEmpty()) {
                result.put("success", false);
                result.put("message", "처방번호가 누락됐습니다.");
                return ResponseEntity.badRequest().body(result);
            }

            // 2. VO 생성
            ExamOrderVO orderVO = new ExamOrderVO();
            orderVO.setPredetailNo(Integer.parseInt(predetailNoStr));
            orderVO.setChartNo(Integer.parseInt(chartNoStr));
            orderVO.setPreExamdetailStatus(status);

            // 3. 파일 파싱 (Helper 메서드 사용)
            Map<Integer, List<MultipartFile>> filesByExamItem = parseFilesFromRequest(request);
            
            if(filesByExamItem.isEmpty()) {
                 result.put("success", false);
                 result.put("message", "전송된 파일이 없습니다.");
                 return ResponseEntity.badRequest().body(result);
            }

            // 4. Service 호출
            int updateResult = service.updateCompleteExam(orderVO, filesByExamItem);

            if(updateResult > 0) {
                result.put("success", true);
                result.put("message", "검사가 완료되었습니다.");
                return ResponseEntity.ok(result);
            } else {
                result.put("success", false);
                result.put("message", "처리된 항목이 없습니다.");
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
            }
            
        } catch (Exception e) {
            log.error("검사 완료 처리 중 오류: ", e);
            result.put("success", false);
            result.put("message", "서버 에러: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(result);
        }
    }

    // 파일 파싱 헬퍼 메서드
    private Map<Integer, List<MultipartFile>> parseFilesFromRequest(MultipartHttpServletRequest request) {
        Map<Integer, List<MultipartFile>> fileMap = new HashMap<>();
        Iterator<String> fileNames = request.getFileNames();
        
        while(fileNames.hasNext()) {
            String paramName = fileNames.next(); // ex: "files_123"
            if(paramName.startsWith("files_")) {
                 try {
                    // "files_" 뒤의 숫자가 검사 항목 PK(preExamdetailNo)임
                    int examItemPK = Integer.parseInt(paramName.substring(6));
                    
                    List<MultipartFile> files = request.getFiles(paramName).stream()
                                                .filter(f -> !f.isEmpty())
                                                .collect(Collectors.toList());
                                                
                    if(!files.isEmpty()) fileMap.put(examItemPK, files);
                    
                 } catch (NumberFormatException e) {
                     log.warn("파일 파라미터 파싱 실패: {}", paramName);
                 }
            }
        }
        return fileMap;
    }
}
