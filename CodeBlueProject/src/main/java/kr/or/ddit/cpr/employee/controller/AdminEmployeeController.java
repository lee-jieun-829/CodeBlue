package kr.or.ddit.cpr.employee.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import kr.or.ddit.cpr.employee.EmployeeSearchVO;
import kr.or.ddit.cpr.employee.service.IEmployeeService;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.LocationVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/admin/employees")
@PreAuthorize("hasRole('ROLE_ADMIN')")
public class AdminEmployeeController {
	
	@Autowired
	private IEmployeeService employeeService;
	
	// 관리자 - 계정 전체 조회 (메인 화면, 페이징 & 검색)
	@GetMapping
	public ResponseEntity<Page<EmployeeVO>> getEmployeeList(@PageableDefault(size=10, page=0) Pageable pageable,
															@ModelAttribute EmployeeSearchVO searchVO, HttpServletRequest request){
		Page<EmployeeVO> list = employeeService.selectEmployeeList(pageable, searchVO);
		return ResponseEntity.ok(list);
	}
	
	// 관리자 - 계정 생성
	@PostMapping
	public ResponseEntity<Map<String, Object>> createEmployee(@ModelAttribute EmployeeVO employeeVO,
												 			  @RequestParam(value="file", required=false) MultipartFile profile){
		employeeVO.setHospitalNo(1);	// 병원번호 고정
		int createNo = employeeService.insertAcc(employeeVO, profile);
		
		Map<String,Object> response = Map.of("msg", "계정 생성 완료", "employeeNo", createNo);
		return ResponseEntity.ok(response);
	}
	
	// 관리자 - 엑셀 일괄 등록
	@PostMapping("/excel/upload")
	public ResponseEntity<Map<String, Object>> uploadBulkExcel(@RequestParam("file") MultipartFile file){
		
		Map<String, Object> result = employeeService.uploadBulkExcel(file);
		
		Map<String, Object> body = new HashMap<>(result);
		body.put("msg", "엑셀 일괄 등록 처리가 완료되었습니다.");
		
		return ResponseEntity.ok(body);
	}
	
	// 관리자 - 엑셀 일괄 다운로드
	@GetMapping("/excel/download")
	public void downloadExcel(HttpServletResponse response, @ModelAttribute EmployeeSearchVO searchVO){
		employeeService.downloadBulkExcel(response, searchVO);
	}
	
	// 관리자 - 계정 상세 조회
	@GetMapping("/{employeeNo}")
	public ResponseEntity<EmployeeVO> getEmployeeDetail(@PathVariable("employeeNo") int employeeNo){
		EmployeeVO employeeVO = employeeService.selectEmployeeDetail(employeeNo);
		return ResponseEntity.ok(employeeVO);
	}
	
	// 관리자 - 계정 정보 수정(프로필도 수정 가능함)
	@PostMapping("/{employeeNo}/update")
	public ResponseEntity<Map<String, Object>> updateEmployee(@PathVariable("employeeNo") int employeeNo, @ModelAttribute EmployeeVO employeeVO,
												 @RequestParam(value="file", required=false) MultipartFile profile){
		employeeVO.setEmployeeNo(employeeNo);
		int updated = employeeService.updateAcc(employeeVO, profile);
		
		Map<String,Object> response = Map.of("msg", "계정 수정 완료", "employeeNo", employeeNo, "updated", updated);
		return ResponseEntity.ok(response);
	}
	
	// 관리자 - 계정 퇴사 처리
	@PostMapping("/{employeeNo}/retire")
	public ResponseEntity<Map<String, Object>> retireEmployee(@PathVariable("employeeNo") int employeeNo){
		int updated = employeeService.retireAcc(employeeNo);
		Map<String,Object> response = Map.of("msg", "퇴사 처리 완료", "retireNo", employeeNo, "updated", updated);
		return ResponseEntity.ok(response);
	}
	
	// 관리자 - 배정 관리 모달 전체 조회
	@GetMapping("/location")
	public ResponseEntity<List<LocationVO>> getLocationList() {
	    List<LocationVO> list = employeeService.selectLocationList();
	    return ResponseEntity.ok(list);
	}
	
	// 특정 계정 조회
	@GetMapping("/location/{employeeNo}")
	public ResponseEntity<List<LocationVO>> getEmployeeLocation(@PathVariable int employeeNo) {
	    List<LocationVO> list = employeeService.selectEmployeeLocation(employeeNo);
	    return ResponseEntity.ok(list);
	}
	
	// 3. 배정 저장 (1:1 매칭 - 덮어쓰기)
    @PostMapping("/location/save")
    public ResponseEntity<Map<String, String>> saveEmployeeLocation(@RequestBody LocationVO locationVO) {
       
    	employeeService.saveEmployeeLocation(locationVO);
        
        Map<String, String> response = new HashMap<>();
        response.put("msg", "배정이 완료되었습니다.");
        return ResponseEntity.ok(response);
    }
}