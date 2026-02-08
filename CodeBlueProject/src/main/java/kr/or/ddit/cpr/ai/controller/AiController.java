package kr.or.ddit.cpr.ai.controller;


import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import kr.or.ddit.cpr.ai.service.IAiService;
import kr.or.ddit.cpr.vo.AiDiagnosisVO;
import kr.or.ddit.cpr.vo.AiDrugVO;
import kr.or.ddit.cpr.vo.aiVO;
import lombok.extern.slf4j.Slf4j;
@Slf4j
@RestController
@RequestMapping("/doctor")
public class AiController {
	@Autowired
	private IAiService service;	
	
	/**
	 * ai 어시스턴트 기능
	 * @param payload 환자와 의사 대화기록
	 * @return ai 어시스턴트 결과
	 */
	@PostMapping("/ai")
	public Map<String, Object> aiAssistent(@RequestBody Map<String, String> payload) {
		log.info("aiDiagnosisService.runDiagnosisProcess()메서드 실행======");
		String userPrompt = payload.get("userPrompt");
		String patientAge= payload.get("patientAge");
		String patientGender= payload.get("patientGender");		
		Map<String, Object> ai=service.aiAssistant(userPrompt,patientAge,patientGender);		
	    System.out.println(ai);
	    return ai;
	}
	
	/**
	 * ai 어시스턴트 결과 insert 기능
	 * @param reqData ai 어시스턴트 결과
	 * @return 성공하면 OK, 실패하면 INTERNAL_SERVER_ERROR
	 */
	@PostMapping("/insert")
	public ResponseEntity<String> aiInsert(@RequestBody Map<String, Object> reqData) { 	
		log.info("AI 진료 기록 저장 요청 데이터==="+ reqData);
			
		
		//서비스 로직으로 보내기
	    try {
	    	aiVO aiVO = new aiVO();	    	
	    	aiVO.setChartNo(Integer.parseInt(String.valueOf(reqData.get("chartNo"))));
            aiVO.setPatientNo(Integer.parseInt(String.valueOf(reqData.get("patientNo"))));
            aiVO.setAiContent((String) reqData.get("aiContent"));
            
            //상병결과 상병테이블과 매핑
            List<Map<String, Object>> diagMapList = (List<Map<String, Object>>) reqData.get("aiDiagnosis");
            List<AiDiagnosisVO> diagList = new ArrayList<>();
            
            if (diagMapList != null) {
                for (Map<String, Object> map : diagMapList) {
                    AiDiagnosisVO diag = new AiDiagnosisVO();                    
                   
                    diag.setAiDiagnosisCode((String) map.get("diagnosisCode"));
                    diag.setAiDiagnosisName((String) map.get("diagnosisName"));
                    
                    diagList.add(diag);
                }
                aiVO.setAiDiagnosis(diagList);
            }
            
            //약품결과 약품테이블과 매핑
            List<Map<String, Object>> drugMapList = (List<Map<String, Object>>) reqData.get("aiDrug");
            List<AiDrugVO> drugList = new ArrayList<>();

            if (drugMapList != null) {
                for (Map<String, Object> map : drugMapList) {
                    AiDrugVO drug = new AiDrugVO();
                    
                    
                    drug.setAiDrugCode((String) map.get("drugCode"));          
                    String rawName = (String) map.get("drugName");
                    if (rawName != null && rawName.contains("(")) {                        
                        rawName = rawName.split("\\(")[0].trim();
                    }
                    drug.setAiDrugName(rawName);
                    drug.setAiDrugDose(Integer.parseInt(String.valueOf(map.get("drugSpec"))));
                   
                    drugList.add(drug);
                }
                log.info("AI insert data====", aiVO);
                aiVO.setAiDrug(drugList);
            }
            
	    	service.aiInsert(aiVO);
	        return new ResponseEntity<>("success", HttpStatus.OK);
	    } catch (Exception e) {
	        e.printStackTrace();
	        return new ResponseEntity<>("fail", HttpStatus.INTERNAL_SERVER_ERROR);
	    }
	}
	
	/**
	 * 진료중인 환자의 ai어시스턴트 기록 select
	 * @param aiVO 환자번호를 포함한 aiVO
	 * @return ai 어시스턴트 기록 데이터
	 */
	@GetMapping("/aiselect")
	public ArrayList<aiVO> aiSelect(@RequestParam("patientNo") String patientNo){
		log.info("aiSelect 환자번호==="+ patientNo);
		ArrayList<aiVO> aiData = service.aiSelect(patientNo);
		return aiData;
	}
	
}
