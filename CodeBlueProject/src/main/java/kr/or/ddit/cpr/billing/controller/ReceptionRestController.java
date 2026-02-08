package kr.or.ddit.cpr.billing.controller;

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

import kr.or.ddit.cpr.billing.service.IReceptionService;
import kr.or.ddit.cpr.vo.AdmissionVO;
import kr.or.ddit.cpr.vo.BedVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.PatientVO;
import lombok.extern.slf4j.Slf4j;

/**
 * <p>원무 접수 데이터 처리 비동기 컨트롤러</p>
 * <pre>
 * 1. 신규 환자 등록 및 접수 관련 비동기 처리
 * </pre>
 * @author 강지현
 */
@Slf4j
@RestController
@RequestMapping("/reception")
public class ReceptionRestController {

	@Autowired
	private IReceptionService service;
	
	
	/**
	 * <p>신규 환자 등록 및 접수, 차트 생성</p>
	 * @author 강지현
	 * @param patientVO 환자 정보 및 접수 정보
	 * @return 성공 여부 및 생성된 차트 번호
	 */
	@PostMapping("/insertpatient")
	public Map<String, Object> insertPatient(@RequestBody PatientVO patientVO) {
		log.info("insertPatient() 실행");
		 
        return service.insertPatient(patientVO);
	}
	
	/**
	 * <p>대기 상태인 환자 리스트 조회</p>
	 * @author 강지현
	 * @return 대기 상태 환자 목록이 담긴 ResponseEntity
	 */
	@GetMapping("/waitingList")
	public ResponseEntity<List<PatientVO>> getWatingList(){
		log.info("getWatingList() 실행");
		List<PatientVO> waitingList = service.getWaitingList();
		return ResponseEntity.ok(waitingList);
	}
	
	/**
     * <p>외래 재진 접수를 위해 기존 환자 정보 검색</p>
     * @author 강지현
     * @param keyword 검색어 (환자 성명 또는 환자 번호)
     * @return 검색된 환자의 상세 정보 (PatientVO)
     */
    @GetMapping("/searchPatient")
    @ResponseBody
    public List<PatientVO> searchPatientList(@RequestParam("keyword") String keyword) {
    	log.info("searchPatientList() 실행");
    	return service.retrievePatientList(keyword);
    }
	
    /**
     * <p>검색된 기존 환자의 외래 접수(재진) 및 차트 생성</p>
     * @author 강지현
     * @param patientVO 환자 번호와 접수 정보
     * @return 성공 여부 및 생성된 차트 번호
     */
    @PostMapping("/registerOutpatient")
    @ResponseBody
    public Map<String, Object> registerOutpatient(@RequestBody PatientVO patientVO) {
    	log.info("registerOutpatient() 실행");
    	
    	return service.createOutpatientRegistration(patientVO);
    }
    
    /**
     * 입원 대상 환자 검색 
     * @param keyword 환자명 또는 차트번호
     * @return 입원 가능 대상자 리스트
     */
    @GetMapping("/searchInpatient")
    public List<PatientVO> searchInpatient(@RequestParam String keyword) {
        log.info("searchInpatient() 실행");
        return service.searchInpatient(keyword);
    }
    
    /**
     * <p>검색된 기존 환자의 입원 접수 및 침상 상태 변경, 차트 생성</p>
     * @author 강지현
     * @param admissionVO 입원 정보 상세 객체
     * @return 성공 여부 및 생성된 차트 번호
     */
    @PostMapping("/insertAdmission")
    @ResponseBody
    public Map<String, Object> insertAdmission(@RequestBody AdmissionVO admissionVO) {
        log.info("insertAdmission() 실행 - 환자번호: {}, 침상번호: {}, 받은 이름: {}", 
                 admissionVO.getPatientNo(), admissionVO.getBedNo(), admissionVO.getPatientName());
        
        return service.registerAdmission(admissionVO);
    }
    
    /**
     * <p>병상 전체 목록 조회</p>
     * @return
     */
    @GetMapping("/selectBedList")
    @ResponseBody
    public List<BedVO> selectBedList() {
        return service.selectBedList(); 
    }
    
    /**
     * <p>접수 시 의사 조회</p>
     * @return
     */
    @GetMapping("/getDoctorList")
    @ResponseBody
    public List<EmployeeVO> getDoctorList() {
        
        return service.getDoctorList();
    }
}
