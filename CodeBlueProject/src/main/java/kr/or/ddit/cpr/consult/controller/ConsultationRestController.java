package kr.or.ddit.cpr.consult.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.consult.service.IConsultationService;
import kr.or.ddit.cpr.notification.service.INotificationService;
import kr.or.ddit.cpr.order.controller.OrderApiController;
import kr.or.ddit.cpr.vo.ConsultationVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.PatientVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/consultation/api")
public class ConsultationRestController {

	@Autowired
	private IConsultationService consultationService;
	
	@Autowired
	private INotificationService notificationService;

	/**
	 * DB에서 환자 정보를 가져와 반환하는 함수
	 * @author 박성현
	 * @date 2026-01-16
	 * @param loginUser
	 * @param patientNo
	 * @return ResponseEntity<List<ConsultationVO>> 리스트 형식의 환자 정보 반환
	 */
	@GetMapping("/selectReqConsultPatient")
	public ResponseEntity<List<ConsultationVO>> selectReqConsultPatient(
			@AuthenticationPrincipal CustomEmployee loginUser,
			@RequestParam(required = false) Integer patientNo){
		
		int employeeNo = loginUser.getEmployee().getEmployeeNo();
		
		List<ConsultationVO> list = consultationService.selectReqConsultPatient(employeeNo, patientNo);
		
		if(list == null || list.isEmpty()) {
			return ResponseEntity.noContent().build();
		}
		return ResponseEntity.ok(list);
	}
	
	/**
	 * 협진 환자를 클릭하고 비동기 요청을 하면 DB에서 환자 협진 관련 내용을 가져와 반환하는 함수
	 * @author 박성현
	 * @date 2026-01-17
	 * @param consultationNo
	 * @return ConsultationVO 상세 정보 객체
	 */
	@GetMapping("/consultationDetail")
	public ResponseEntity<ConsultationVO> getConsultationDetail(
			@RequestParam int consultationNo){
		ConsultationVO detail = consultationService.selectConsultationDetail(consultationNo);
		
		if(detail == null) {
			return ResponseEntity.noContent().build();
		}
		return ResponseEntity.ok(detail);
	}
	
	/**
	 * 입원 환자 검색 함수
	 * @author 박성현
	 * @date 2026-01-18
	 * @param keyword
	 * @return
	 */
	@GetMapping("/searchPatient")
	public ResponseEntity<List<ConsultationVO>> searchPatient(
			@RequestParam String keyword){
		List<ConsultationVO> list = consultationService.searchPatient(keyword);
		
		return ResponseEntity.ok(list);
	}
	
	/**
	 * DB 저장된 의사 불러오는 함수
	 * @author 박성현
	 * @date 2026-01-18
	 * @return
	 */
	@GetMapping("/selectDoctorList")
	public ResponseEntity<List<EmployeeVO>> getDoctorList(){
		List<EmployeeVO> list = consultationService.selectDoctorList();
		
		return ResponseEntity.ok(list);
	}
	
	/**
	 * DB 저장된 차트 상세 데이터 조회
	 * @author 박성현
	 * @date 2026-01-18
	 * @param chartNo 조회할 차트 번호
	 * @return 해당 차트의 바이탈, 진단, 기록 등을 포함한 ConsultationVO
	 */
	@GetMapping("/chartDetail")
	public ResponseEntity<ConsultationVO> getChartDetail(@RequestParam int chartNo){
		ConsultationVO vo = consultationService.selectChartDetail(chartNo);
		
		if(vo == null) {
			return ResponseEntity.noContent().build();
		}
		return ResponseEntity.ok(vo);
	}
	
	/**
	 * 새 협진 입력 저장하는 함수
	 * @author 박성현
	 * @date 2026-01-18
	 * @param vo
	 * @param loginUser
	 * @return
	 */
	@PostMapping("/insertReqConsultation")
	public Map<String, Object> insertReqConsultation(
			@RequestBody ConsultationVO vo,
			@AuthenticationPrincipal CustomEmployee loginUser){
		
		int employeeNo = loginUser.getEmployee().getEmployeeNo();
		vo.setConsultationReqdoctor(employeeNo);
		vo.setEmployeeNo(employeeNo);
		
		log.info("협진 저장 요청 VO 데이터 : {}", vo);
		
		return consultationService.insertReqConsultation(vo);
	}
	
	/**
	 * 협진 회신 등록 및 상태 변경 (완료)
	 * @author 박성현
	 * @date 2026-01-19
	 * @param vo
	 * @param loginUser
	 * @return
	 */
	@PostMapping("/updateRespConsultation")
	public Map<String, Object> updateRespConsultation(
			@RequestBody ConsultationVO vo,
			@AuthenticationPrincipal CustomEmployee loginUser){
		vo.setConsultationRespdoctor(loginUser.getEmployee().getEmployeeNo());
		vo.setConsultationStatus("001");
		
		return consultationService.updateRespConsultation(vo);
	}
	
	/**
	 * 협진 거절 처리
	 * @author 박성현
	 * @date 2026-01-19
	 * @param vo
	 * @param loginUser
	 * @return
	 */
	@PostMapping("/updateRejectConsultation")
	public Map<String, Object> updateRejectConsultation(
			@RequestBody ConsultationVO vo,
			@AuthenticationPrincipal CustomEmployee loginUser){
		vo.setConsultationStatus("002");
		vo.setConsultationRespdoctor(loginUser.getEmployee().getEmployeeNo());
		
		return consultationService.updateRespConsultation(vo);
	}
	
}

























