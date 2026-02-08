package kr.or.ddit.cpr.outpatient.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.employee.controller.AdminEmployeeController;
import kr.or.ddit.cpr.outpatient.service.IOutPatientService;
import kr.or.ddit.cpr.outpatient.vo.OutPatientChartDrugVO;
import kr.or.ddit.cpr.patient.vo.PatientVO;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.ScreeningVO;
import lombok.extern.slf4j.Slf4j;

@RestController
@Slf4j
@RequestMapping("/nurse")
public class NurseOutpatientRestController {

	private final AdminEmployeeController adminEmployeeController;

	@Autowired
	private IOutPatientService service;
	
	@Autowired
	private SimpMessagingTemplate messagingTemplate;

	NurseOutpatientRestController(AdminEmployeeController adminEmployeeController) {
		this.adminEmployeeController = adminEmployeeController;
	}

	// 상태 업데이트
	/*
	 * 환자 대기 목록 상태 변경 이벤트 처치 완료 버튼 클릭 후 환자 대기 상태 변경 이벤트
	 * 
	 */
	@PostMapping("/updateStatus")
	@ResponseBody
	public Map<String, Object> updateStatus(@RequestBody Map<String, Object> params) {

	    Map<String, Object> response = new HashMap<>();

	    int result  = service.updateRegistrationStatus(params);
	    int result1 = service.updateRegistrationFinalStatus(params);

	    boolean ok = (result > 0) && (result1 > 0);

	    response.put("status", ok ? "success" : "fail");

	    // 성공일 때만 counts 내려주는 게 깔끔함
	    if(ok){
	    	messagingTemplate.convertAndSend("/topic/waitingList", "REFRESH");
	        response.put("newCounts", service.readStatus());
	    }else{
	        // 디버깅용 정보(원하면 제거)
	        response.put("result", result);
	        response.put("result1", result1);
	    }

	    return response;
	}


	/**
	 * <p>
	 * 사용자가 검색어를 입력하고 비동기 요청을 하면 DB에서 환자 정보를 가져와 반환하는 함수
	 * </p>
	 * 
	 * @author 한이혜지
	 * @param Search 환자이름 및 환자번호 검색
	 * @date 2026/01/05
	 * 
	 *       나중에 map을 VO로 변경 필요.
	 */
	@PostMapping("/getOutPatientList")
	public Map<String, Object> getOutPatientList(@RequestBody(required = false) Map<String, String> map) {

		String search = (map == null) ? null : map.get("search");
		log.info("getOutPatientList() 실행 .. search = {}", search);

		List<PatientVO> list;

		if (search == null || search.trim().isEmpty()) {
			// ✅ 전체 대기 목록 (기존 service.list() 사용)
			list = service.list();
		} else {
			// ✅ 검색 목록
			list = service.selectOutPatientList(search);
		}

		Map<String, Object> res = new HashMap<>();
		res.put("list", list);
		res.put("counts", service.readStatus()); // ✅ 탭 카운트도 같이

		return res;
	}

	/**
	 * 환자 상세 정보, 바이탈, 내원이력, 진료차트 조회 (비동기)
	 */
	/*
	 * @GetMapping("/patientDetail/{patientNo}") public Map<String, Object>
	 * getPatientDetail(
	 * 
	 * @PathVariable int patientNo,
	 * 
	 * @RequestParam(required = false) Integer registrationNo, ChartVO vo ) {
	 * log.info("getPatientDetail 실행 중... 환자번호: {}", patientNo);
	 * 
	 * // 1) 환자 기본/접수/차트 정보 PatientVO detail = service.readPatientDetail(patientNo);
	 * 
	 * // 2) VO 세팅 (핵심!!) vo.setPatientNo(patientNo);
	 * 
	 * Integer chartNo = (detail != null) ? detail.getChartNo() : null; //
	 * PatientVO가 Integer일 때 if (chartNo != null) { vo.setChartNo(chartNo); }
	 * 
	 * 
	 * // registrationNo도 필요하면 같이 세팅 (ChartVO에 필드가 있을 때만) // if (registrationNo !=
	 * null) vo.setRegistrationNo(registrationNo);
	 * 
	 * // 3) 나머지 조회 List<OutPatientChartDrugVO> chartList =
	 * service.chartListWatch(patientNo); List<PredetailVO> chartListAll =
	 * service.selectPredetailList(vo); List<DiagnosisVO> diagnosisList =
	 * service.selectdiagnosisList(vo);
	 * 
	 * Map<String, Object> param = new HashMap<>(); param.put("detail", detail);
	 * param.put("chartList", chartList); param.put("chartListAll", chartListAll);
	 * param.put("diagnosisList", diagnosisList);
	 * 
	 * return param; }
	 */
	
	
	/**
	 * 환자 상세 정보, 바이탈, 내원이력, 진료차트 조회 (비동기)
	 *
	 * 호출 예)
	 * - 오늘(기본): GET /nurse/patientDetail/{patientNo}
	 * - 내원이력 클릭(과거): GET /nurse/patientDetail/{patientNo}?chartNo=123
	 */
	@GetMapping("/patientDetail/{patientNo}")
	public Map<String, Object> getPatientDetail(
	        @PathVariable int patientNo,
	        @RequestParam(required = false) Integer registrationNo,
	        ChartVO vo
	) {
	    log.info("getPatientDetail 실행... patientNo={}, reqChartNo={}",
	            patientNo, (vo != null ? vo.getChartNo() : null));

	    PatientVO detail = service.readPatientDetail(patientNo, registrationNo);

	    if (vo == null) vo = new ChartVO();
	    vo.setPatientNo(patientNo);

	    // 요청 chartNo(내원이력 클릭) 우선
	    Integer reqChartNo = vo.getChartNo();

	    // 없으면 detail의 chartNo(오늘)
	    Integer todayChartNo = (detail != null) ? detail.getChartNo() : null;

	    Integer effectiveChartNo = (reqChartNo != null && reqChartNo > 0)
	            ? reqChartNo
	            : (todayChartNo != null && todayChartNo > 0 ? todayChartNo : null);

	    // ✅ 여기서만 세팅 (null이면 세팅 안 함)
	    if (effectiveChartNo != null) {
	        vo.setChartNo(effectiveChartNo);
	    }

	    // 내원이력(방문 단위)
	    List<Map<String, Object>> visitHistory = service.selectVisitHistory(patientNo);

	    // 오더(기존 유지)
	    List<OutPatientChartDrugVO> chartList = service.chartListWatch(patientNo);

	    // 우측 패널 데이터(차트가 있을 때만)
	    List<PredetailVO> chartListAll = java.util.Collections.emptyList();
	    List<DiagnosisVO> diagnosisList = java.util.Collections.emptyList();

	    if (effectiveChartNo != null) {
	        chartListAll = service.selectPredetailList(vo);
	        diagnosisList = service.selectdiagnosisList(vo);
	    }

	    Map<String, Object> param = new HashMap<>();
	    param.put("detail", detail);
	    param.put("chartList", chartList);
	    param.put("chartListAll", chartListAll);
	    param.put("diagnosisList", diagnosisList);
	    param.put("visitHistory", visitHistory);
	    param.put("effectiveChartNo", effectiveChartNo);

	    return param;
	}

	


	// 투약 상태 업데이트
	/*
	 * @PostMapping("/updateDrogStatus") public Map<String, Object>
	 * updateDrogStatus(@RequestParam Map<String, Object> params) {
	 * log.info("###updateDrogStatus 실행 중..!:");
	 * 
	 * int result = service.updatePreDrogStatus(params); Map<String, Object>
	 * response = new HashMap<>(); if(result > 0) { response.put("result",
	 * "success"); } return response; }
	 */

	@PostMapping("/updateDrogStatus")
	@ResponseBody
	public String updateDrogStatus(@RequestBody OutPatientChartDrugVO outPatientChartDrugVO) {
		// service.updateStatus(vo) 로직 수행
		service.updatePreDrogStatus(outPatientChartDrugVO);
		return "success";
	}

	/**
	 * 외래 간호사 페이지 바이탈 정보 입력 (비동기) 01/12-01/13
	 */
	@PostMapping("/registerVital")
	public Map<String, String> registerVital(@RequestBody ScreeningVO screeningVO) {
		log.info("registerVital() 실행");
		Map<String, String> param = new HashMap<>();
		int status = service.registerVital(screeningVO);
		if (status > 0) {
			param.put("status", "OK");
		} else {
			param.put("status", "FAILED");
		}
		return param;
	}
	
	/**
	 * 환자 메모 분리 저장
	 */
	@PostMapping("/updatePatientMemo")
	@ResponseBody
	public String updatePatientMemo(@RequestBody Map<String, Object> body) {
	    int patientNo = Integer.parseInt(String.valueOf(body.get("patientNo")));
	    String patientMemo = String.valueOf(body.getOrDefault("patientMemo", ""));

	    int cnt = service.updatePatientMemo(patientNo, patientMemo);
	    return cnt > 0 ? "success" : "fail";
	}

	

}
