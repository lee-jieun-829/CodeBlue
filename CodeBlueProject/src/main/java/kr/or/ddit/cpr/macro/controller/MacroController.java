package kr.or.ddit.cpr.macro.controller;

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
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.macro.service.IMacroService;
import kr.or.ddit.cpr.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.MacroVO;
import kr.or.ddit.cpr.vo.TreatmentVO;
import lombok.extern.slf4j.Slf4j;

@RestController
@Slf4j
@RequestMapping("/api/macro")
public class MacroController {

	@Autowired
	private IMacroService macroService;
	
	@GetMapping("/list")
	public List<MacroVO> getMacroList(@RequestParam(name="employeeNo", defaultValue="0") int employeeNo) {
		return macroService.retrieveMacroList(employeeNo);
	}		
	
	@GetMapping("/detail/{macroNo}") 
	public MacroVO getMacroDetail(@PathVariable int macroNo) {
		return macroService.retrieveMacro(macroNo);
	}
	
	@PostMapping("/add")
	public ResponseEntity<String> registerMacro(@RequestBody MacroVO macroVO) {
	    try {
	        macroService.createMacro(macroVO);
	        return new ResponseEntity<>("SUCCESS", HttpStatus.OK);
	    } catch (RuntimeException e) {
	        // "매크로는 3개까지만..." 메시지를 담아서 400 에러로 보냄
	        return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
	    }
	}
	
	@PostMapping("/update")
	public String modifyMacro(@RequestBody Map<String, Object> paramMap) {
		log.info("매크로 수정 요청 Map : {}", paramMap);
		try {
			macroService.modifyMacro(paramMap);
			return "SUCCESS";
		} catch (Exception e) {
			log.error("수정 오류", e);
			return "FAIL";
		}
	}
	
	@PostMapping("/delete/{macroNo}")
	public String removeMacro(@PathVariable int macroNo) {
		int cnt = macroService.removeMacro(macroNo);
		return cnt > 0 ? "SUCCESS" : "FAIL";
	}
	
	// 검색 API
	@GetMapping("/diagnosis/search") 
	public List<DiagnosisVO> searchDiagnosisList(@RequestParam(name="keyword", defaultValue = "") String keyword){
		return macroService.retrieveDiagnosisList(keyword);            
	}
	
	@GetMapping("/drug/search")
	public List<DrugVO> searchDrugList(@RequestParam(name="keyword", defaultValue = "") String keyword) {
		return macroService.retrieveDrugList(keyword);
	}
	
	@GetMapping("/treatment/search")
	public List<TreatmentVO> searchTreatmentList(@RequestParam(name="keyword", defaultValue="") String keyword) {
		return macroService.retrieveTreatmentList(keyword);
	}

	// 간호사 매크로 목록 조회 (검색 기능 포함)
	@GetMapping("/nurse/list")
	public List<MacroVO> getNurseMacroList(
	        @RequestParam(name="employeeNo") int employeeNo,
	        @RequestParam(name="keyword", defaultValue="") String keyword) {
	    
	    Map<String, Object> map = new HashMap<>(); // 여기서 빨간줄 뜨면 임포트 필요
	    map.put("employeeNo", employeeNo);
	    map.put("keyword", keyword);
	    
	    return macroService.retrieveNurseMacroList(map);
	}
} 