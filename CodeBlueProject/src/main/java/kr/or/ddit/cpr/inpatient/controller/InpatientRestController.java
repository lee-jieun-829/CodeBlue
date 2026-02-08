package kr.or.ddit.cpr.inpatient.controller;

import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.UriUtils;

import jakarta.servlet.http.HttpSession;
import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.inpatient.service.IInpatientService;
import kr.or.ddit.cpr.notification.service.INotificationService;
import kr.or.ddit.cpr.vo.ClinicalDetailVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.InpatientVO;
import kr.or.ddit.cpr.vo.OrderListVO;
import kr.or.ddit.cpr.vo.OrderSearchVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.ProgressNoteVO;
import lombok.extern.slf4j.Slf4j;

/**
 * 의사 - 입원진료 페이지 비동기요청 처리 컨트롤러
 */

@Slf4j
@RestController
@RequestMapping("/doctor/inpatient/api")
public class InpatientRestController {
    
	@Autowired 
    private IInpatientService inpatientService;
	
	@Autowired
	private INotificationService notificationService;

	/**
	 * 사용자가 검색어를 입력하고 비동기 요청을 하면 DB에서 환자명 정보를 가져와 반환하는 함수
	 * @author 박성현
	 * @date 2026-01-05
	 * @param locationNo 장소번호별 리스트 반환
	 * @param keyword 환자명 및 환자번호 검색
	 * @return ResponseEntity<List<InpatientVO>> 리스트 형식의 환자정보 반환
	 */
    @GetMapping("/patientList")
    public ResponseEntity<List<InpatientVO>> getPatientList(
            @RequestParam(name = "locationNo", required = false) Long locationNo,
            @RequestParam(name = "keyword", required = false) String keyword,
            @AuthenticationPrincipal CustomEmployee loginUser) {
        
    	// 장소, 환자명 및 환자번호 검색어
        Map<String, Object> dataMap = new HashMap<>();
        dataMap.put("locationNo", locationNo);
        dataMap.put("keyword", keyword);
        dataMap.put("employeeNo", loginUser.getEmployee().getEmployeeNo());
        
        // 환자 목록 가져오기
        List<InpatientVO> list = inpatientService.selectInpatientList(dataMap);
        
        return ResponseEntity.ok(list);
    }
    
    /**
     * <p> 환자 정보 클릭하고 비동기 요청을 하면 DB에서 환자 세부정보(경과기록, 간호기록, 바이탈, 협진결과 등)
     * 을 가져와 반환하는 함수 </p>
     * @author 박성현
	 * @date 2026-01-05
     * @param patientNo
     * @return ResponseEntity<ClinicalDetailVO> 리스트 형식의 환자정보 반환
     */
    @GetMapping("/clinicalDetail")
    @ResponseBody
    public ResponseEntity<ClinicalDetailVO> getClinicalDetail(@RequestParam("patientNo") Long patientNo) {
        
    	// 환자 세부정보 가져오기
    	ClinicalDetailVO clinicalDetailVO = inpatientService.selectClinicalDetail(patientNo);
    	
        return ResponseEntity.ok(clinicalDetailVO);
    }
    
    /**
     * <p> 환자 정보 클릭하고 비동기 요청을 하면 DB에서 환자 세부정보(처방내역 등)
     * 를 가져와 반환하는 함수 </p>
     * @author 박성현
	 * @date 2026-01-05
     * @param patientNo
     * @return ResponseEntity<OrderListVO> 리스트 형식의 환자정보 반환
     */
    @GetMapping("/orderList")
    @ResponseBody
    public ResponseEntity<OrderListVO> getOrderList(@RequestParam("patientNo") Long patientNo) {
    	
    	// 환자 처방내역 가져오기
    	OrderListVO orderListVO = inpatientService.selectOrderList(patientNo);
    	
    	return ResponseEntity.ok(orderListVO);
    }
    
    /**
     * <p> 카테고리(처방) 선택 후 찾으려는 이름을 검색하면 비동기 요청을 하면 DB에서
     * 정보를 가져와 반환하는 함수 </p>
     * @author 박성현
	 * @date 2026-01-07
     * @param category
     * @param keyword
     * @return ResponseEntity<List<OrderSearchVO>> 리스트 형식의 처방정보 반환
     */
    @GetMapping("/searchOrder")
    @ResponseBody
    public ResponseEntity<List<OrderSearchVO>> searchOrder(
    		@RequestParam String category, 
    	    @RequestParam String keyword
    		) {
        
    	// 환자 세부정보 가져오기
    	List<OrderSearchVO> result = inpatientService.searchOrder(category, keyword);
    	
        return ResponseEntity.ok(result);
    }
    
    /**
     * <p> 경과기록지 입력하는 함수</p>
     * @author 박성현
	 * @date 2026-01-07
     * @param map
     * @param loginUser
     * @return
     */
    @PostMapping("/insertProgress")
    public Map<String, Object> insertProgressNote(
            @RequestBody HashMap<String, Object> map, 
            @AuthenticationPrincipal CustomEmployee loginUser) {

        ProgressNoteVO noteVO = new ProgressNoteVO();
        
        if (map.get("chartNo") != null) {
            noteVO.setChartNo(Integer.parseInt(map.get("chartNo").toString()));
        }
        
        if (map.get("progressnoteContent") != null) {
            noteVO.setProgressnoteContent(map.get("progressnoteContent").toString());
        }
        
        // 로그인 정보 불러오기
        noteVO.setEmployeeNo(loginUser.getEmployee().getEmployeeNo());

        return inpatientService.insertProgressNote(noteVO);
    }
    
    /**
     * <p> 처방 추가하는 함수</p>
     * @author 박성현
	 * @date 2026-01-08
     * @param prescriptionList
     * @param loginUser
     * @return
     */
    @PostMapping("/insertPrescription")
    public Map<String, Object> insertPrescription(
    		@RequestBody List<PredetailVO> prescriptionList,
    		@AuthenticationPrincipal CustomEmployee loginUser) {
    	
    	int employeeNo = loginUser.getEmployee().getEmployeeNo();
    	for(PredetailVO pre : prescriptionList) {
            pre.setEmployeeNo(employeeNo); 
        }
    	
    	return inpatientService.insertPrescription(prescriptionList);
    }
    
    /**
     * <p> 처방 변경하는 함수</p>
     * @author 박성현
	 * @date 2026-01-08
     * @param prescriptionList
     * @param loginUser
     * @return
     */
    @PostMapping("/updatePrescription")
    public Map<String, Object> updatePrescription(
    		@RequestBody List<Map<String, Object>> updateList,
    		@AuthenticationPrincipal CustomEmployee loginUser) {
    	
    	int employeeNo = loginUser.getEmployee().getEmployeeNo();
    	for(Map<String, Object> pre : updateList) {
    		pre.put("employeeNo", employeeNo);
    	}
    	
    	return inpatientService.updatePrescription(updateList);
    }
 
    /**
     * <p> 처방 세부정보 변경하는 함수</p>
     * @author 박성현
	 * @date 2026-01-19
     * @param dischargeMap
     * @param loginUser
     * @return
     */
    @PostMapping("/updateDischarge")
    public Map<String, Object> updateDischarge(
    		@RequestBody Map<String, Object> dischargeMap,
    		@AuthenticationPrincipal CustomEmployee loginUser){
    	
    	int employeeNo = loginUser.getEmployee().getEmployeeNo();
    	dischargeMap.put("employeeNo", employeeNo);
    	
    	return inpatientService.updateDischarge(dischargeMap);
    }
    
    /**
     * <p> 상병 추가하는 함수</p>
     * @author 박성현
	 * @date 2026-01-24
     * @param params
     * @return
     */
    @PostMapping("/insertDiagnosis")
    public ResponseEntity<Map<String, Object>> insertDiagnosis(@RequestBody Map<String, Object> params) {
        Map<String, Object> result = new HashMap<>();
        
        try {
            int count = inpatientService.insertDiagnosisDetail(params);
            
            if(count > 0) {
                result.put("status", "success");
            } else {
                result.put("status", "fail");
            }
        } catch (Exception e) {
            result.put("status", "error");
            result.put("message", e.getMessage());
        }
        
        return ResponseEntity.ok(result);
    }
}
















