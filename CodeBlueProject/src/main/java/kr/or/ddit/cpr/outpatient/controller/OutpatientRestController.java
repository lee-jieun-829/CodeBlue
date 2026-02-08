package kr.or.ddit.cpr.outpatient.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.outpatient.service.IPatientService;
import kr.or.ddit.cpr.prescription.service.IPrescriptionService;
import kr.or.ddit.cpr.vo.AnatomyVO;
import kr.or.ddit.cpr.vo.ChartListVO;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.OperationVO;
import kr.or.ddit.cpr.vo.OutPatientListVO;
import kr.or.ddit.cpr.vo.PatientCompositeVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.RegistrationVO;
import kr.or.ddit.cpr.vo.TreatmentVO;
import lombok.extern.slf4j.Slf4j;

/**
 * 	의사 - 외래진료 페이지 비동기요청 처리 컨트롤러
 */

@RestController
@Slf4j
@RequestMapping("/doctor/api")
public class OutpatientRestController {

	@Autowired
	IPatientService patientService; 
	@Autowired
	IPrescriptionService prescriptionService;
	
	@Autowired
    private SimpMessagingTemplate messagingTemplate;
	
	/**
	 * <p>사용자가 검색어를 입력하고 비동기 요청을 하면 DB에서 진단명 정보를 가져와 반환하는 함수</p>
	 * @author 장우석
	 * @param SearchWord 상병코드 및 상병명 검색
	 * @return  ResponseEntity<List<DiagnosisVO>,상태> 리스트 형식의 상병데이터 반환
	 * @date 2026/01/02
	 * 
	 * 나중에 map을 VO로 변경 필요.
	 */
	@PostMapping("/getDiagnosis")
	public ResponseEntity<List<DiagnosisVO>> getDiagnosisList(@RequestBody Map<String, String> map){
		
		// 상병 및 진단명 검색어 
		String searchWord = map.get("searchWord");
		log.info("getDiagnosisList() 실행 .. searchWord = {}",searchWord);
		
		// 검색한 결과 가져오기 
		List<DiagnosisVO> list = patientService.selectDiagnosisList(searchWord);
		
		// 결과를 상태 200코드와 함께 리턴
		return new ResponseEntity<>(list,HttpStatus.OK);
	}
	
	
	/**
	 * <p> 사용자가 검색어를 입력하고 비동기 요청을 하면 DB에서 치료 정보를 가져와 반환하는 함수</p>
	 * @author 장우석
	 * @param map
	 * @return ResponseEntity<List<TreatmentVO>,상태> 리스트 형식의 치료데이터 반환
	 * 
	 * 나중에 map을 VO로 변경.
	 */
	@PostMapping("/getTreatment")
	public ResponseEntity<List<TreatmentVO>> getTreatment(@RequestBody Map<String, String> map){
		
		// 치료명 검색
		String searchWord = map.get("searchWord");
		log.info("getTreatment() 실행.. searchWord = {}", searchWord);
		
		// 검색한 결과 가져오기
		List<TreatmentVO> list = patientService.selectTreatmentList(searchWord);
		
		return new ResponseEntity<>(list,HttpStatus.OK);
	}
	
	/**
	 * <p>사용자가 검색어를 입력하고 비동기 요청을 하면 DB에서 약품 정보를 가져와 반환하는 함수</p>
	 * @author 장우석
	 * @param map
	 * @return ResponseEntity<List<DrugVO>,상태> 리스트 형식의 약품데이터 반환
	 * @date 2026/01/03 
	 * 
	 * 나중에 map을 VO로 변경.
	 */
	@PostMapping("/getDrug")
	public ResponseEntity<List<DrugVO>> getDrugList(@RequestBody Map<String, String> map){
		
		// 약품명 검색
		String searchWord = map.get("searchWord");
		log.info("getDrugList() 실행.. searchWord = {}", searchWord);
		
		// 검색한 결과 가져오기
		List<DrugVO> list = patientService.selectDrugList(searchWord);
		
		// 결과를 상태 200코드와 함께 리턴
		return new ResponseEntity<>(list,HttpStatus.OK);
	}
	
	/**
	 * <p>사용자가 검색어를 입력하고 비동기 요청을 하면 DB에서 약품 정보를 가져와 반환하는 함수</p>
	 * @author 장우석
	 * @param map
	 * @return ResponseEntity<List<DrugVO>,상태> 리스트 형식의 약품데이터 반환
	 * @date 2026/01/03 
	 * 
	 * 나중에 map을 VO로 변경.
	 */
	@PostMapping("/getInject")
	public ResponseEntity<List<DrugVO>> getInjectList(@RequestBody Map<String, String> map){
		
		// 약품명 검색
		String searchWord = map.get("searchWord");
		log.info("getInjectList() 실행.. searchWord = {}", searchWord);
		
		// 검색한 결과 가져오기
		List<DrugVO> list = patientService.selectInjectList(searchWord);
		
		// 결과를 상태 200코드와 함께 리턴
		return new ResponseEntity<>(list,HttpStatus.OK);
	}
	
	/**
	 * <p>수술 리스트를 가져오는 함수</p>
	 * @author 장우석
	 * @param map
	 * @return ResponseEntity<>
	 */
	@PostMapping("/getOperation")
	public ResponseEntity<List<OperationVO>> getOperation(@RequestBody Map<String, String> map){
		
		String searchWord = map.get("searchWord");
		List<OperationVO> list = patientService.selectOperationList(searchWord);
		
		return new ResponseEntity<>(list,HttpStatus.OK);
	}
	
	/**
	 * <p>수납 완료를 하지 않은 전체 외래환자 리스트</p>
	 * @author 장우석
	 * @return ResponseEntity<List<OutPatientListVO>,상태> 전체 외래환자 리스트
	 * @date 2026/01/07
	 */
	@PostMapping("/getOutPatientList")
	public ResponseEntity<List<OutPatientListVO>> getOutPatientList(Authentication auth){
		log.info("getOutPatientList() 실행..");
		
		CustomEmployee user = (CustomEmployee)auth.getPrincipal();
		
		EmployeeVO employee = user.getEmployee();
		
		
		// 전체 외래환자 가져오기
		List<OutPatientListVO> list =  patientService.selectOutPatientList(employee);
		
		// 결과를 상태 200코드와 함께 리턴
		return new ResponseEntity<>(list,HttpStatus.OK);
		
	}
	
	/**
	 * <p>환자 번호로 환자정보(바이탈포함)를 조회하는 메서드</p>
	 * @author 장우석
	 * @param PatientVO vo
	 * @return ResponseEntity<PatientCompositeVO,상태>
	 */
	@PostMapping("/getPatientInfo")
	public ResponseEntity<PatientCompositeVO> getPatientInfo(@RequestBody PatientCompositeVO vo){
		log.info("getPatientInfo() 실행..");
		log.info("vo확인() {}",vo);
		// 환자정보 호출
		PatientCompositeVO patientInfoVO = patientService.selectPatientInfo(vo);
		
		return ResponseEntity.ok(patientInfoVO);
	}
	
	/**
	 * <p> 트랜잭션 처리해야할 모든 처방관련 입력처리를 수행하는 함수 </p>
	 * @author 장우석
	 * @param vo
	 * @return 성공, 실패 메시지와 상태
	 */
	@PostMapping("/insertPrescription")
	public ResponseEntity<String> insertPredetail(@RequestBody PredetailVO vo){
		log.info("insertPredetail() 실행.. {}",vo);
		
		try {
			patientService.insertPrescription(vo);
			return new ResponseEntity<>("처방에 성공했습니다",HttpStatus.OK);
		} catch (Exception e) {
			e.printStackTrace();
			return new ResponseEntity<>("서버 에러 발생",HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}
	
	/**
	 * <p>환자 상태 변경 메서드</p>
	 * @author 장우석
	 * @param RegistrationVO vo
	 * @return ResponseEntity<String>
	 */
	@PostMapping("/updatePatientStatus")
	public ResponseEntity<String> updatePatientStat(@RequestBody RegistrationVO vo){
		log.info("updatePatientStat() 실행..");
		
		// 환자 상태 업데이트
		int status = patientService.updatePatientStatus(vo);
		
		if(status > 0) {
			messagingTemplate.convertAndSend("/topic/waitingList", "REFRESH");
			return new ResponseEntity<>("변경에 성공했습니다",HttpStatus.OK);
		} else {
			return new ResponseEntity<>("서버 에러 발생",HttpStatus.INTERNAL_SERVER_ERROR);
		}
	}
	

	/**
	 * <p>차트번호로 해당 차트의 처방 전부 가져오기</p>
	 * @author 장우석
	 * @param ChartVO vo
	 * @return List<PredetailVO> 처방정보 리스트
	 */
	@PostMapping("/selectChart")
	public ResponseEntity<List<PredetailVO>> selectChart(@RequestBody ChartVO vo){
		log.info("selectChart() 실행...");
		
		List<PredetailVO> list = prescriptionService.selectPredetailList(vo);
		
		return new ResponseEntity<>(list,HttpStatus.OK);
	}
	
	/**
	 * 	<p> svg에 사용할 기본 부위정보를 가져오는 함수 </p>
	 * 	@author 장우석
	 * 	@Return AnatomyVO 
	 */
	@PostMapping("/selectAnatomy")
	public ResponseEntity<List<AnatomyVO>> selectAnatomy(){
		List<AnatomyVO> list = patientService.selectAnatomy();
		return new ResponseEntity<>(list,HttpStatus.OK);
	}
	
}