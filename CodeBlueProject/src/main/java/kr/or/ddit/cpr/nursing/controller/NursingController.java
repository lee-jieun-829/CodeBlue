package kr.or.ddit.cpr.nursing.controller;


import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.nursing.service.INursingService;
import kr.or.ddit.cpr.vo.AdmissionVO;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.NursingAssessmentVO;
import kr.or.ddit.cpr.vo.NursingChartVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.PredrugDetailVO;
import lombok.extern.slf4j.Slf4j;


@Slf4j
@RestController
@RequestMapping("/nurse")
public class NursingController {
	@Autowired
	private INursingService service;
	
	/**
	 * 작성자: 이지은
	 * 간호정보 조사지 가져오기 메서드
	 * @param admissionNo
	 * @return 간호정보 조사지 정보 list
	 */
	@GetMapping("/assessmentselect")	
	public List<NursingAssessmentVO> assessmentSelect(@RequestParam("admissionNo") int admissionNo){	
		List<NursingAssessmentVO> assesmentlist = service.assessmentSelect(admissionNo);
		return assesmentlist;
	}
	/**
	 * 작성자: 이지은
	 * 간호정보 조사지 등록 메서드	 
	 * @param clinicalDetailVO 차트번호.입원경로.통증점수,통증부위,낙상위험도,욕창위험도,흡연,음주,키,체중,과거병력및알레르기 내용이 들어있는 vo
	 * @return 성공하면 1, 실패하면 0
	 */
	@PostMapping("/assessmentinsert")
	public int assessmentInsert(@RequestBody NursingAssessmentVO assessmentVO) {
		int result = service.assessmentInsert(assessmentVO);
		return result;
	}
	
	/**
	 * 작성자: 이지은
	 * 간호정보 조사지 수정 메서드	 
	 * @param clinicalDetailVO 차트번호.입원경로.통증점수,통증부위,낙상위험도,욕창위험도,흡연,음주,키,체중,과거병력및알레르기 내용이 들어있는 vo
	 * @return 성공하면 1, 실패하면 0
	 */
	@PostMapping("/assessmentupdate")
	public int assessmentUpdate(@RequestBody NursingAssessmentVO assessmentVO) {
		int result = service.assessmentUpdate(assessmentVO);
		return result;
	}
	/**
	 * 작성자: 이지은
	 * 처방 가져오는 메서드
	 * @param chartNo 클릭한 환자에 해당하는 차트 번호
	 * @return 차트번호에 해당하는 처방 리스트
	 */
	@GetMapping("/prescriptionselect")
	public List<PredetailVO> prescriptionSelect(@RequestParam("chartNo") int chartNo) {	    
	    ChartVO chartVO = new ChartVO();
	    chartVO.setChartNo(chartNo);	    
	    List<PredetailVO> prescriptionList = service.prescriptionSelect(chartVO);
	    return prescriptionList;
	}
	/**
	 * 작성자: 이지은
	 * 주사 수행 메서드
	 * @param predrugDetailVO 처방번호, 약번호, 업데이트 할 수행상태를 가지고 있는 vo
	 * @return 성공하면 1, 실패하면 0
	 */
	@PostMapping("/predrugdetailstatusupdate")
	public int preDrugDetailStatusUpdate(@RequestBody PredrugDetailVO predrugDetailVO) {
		int result = service.preDrugDetailStatusUpdate(predrugDetailVO);
		return result;
	}
	/**
	 * 작성자: 이지은
	 * 환자 수납대기로 상태변경 메서드
	 * @param admissionNo 변경할 입원 접수번호
	 * @return 성공하면 1, 실패하면 0
	 */
	@PostMapping("/admissionstatusupdate")
	public int admissionStatusUpdate(@RequestBody AdmissionVO admissionVO) {
		int admissionNo = admissionVO.getAdmissionNo();
		int result = service.admissionStatusUpdate(admissionNo);
		return result;
	}
	/**
	 * 작성자: 이지은
	 * 간호기록지 등록 메서드
	 * @param chartVO 환자 혈압, 체온, 맥박, 식이, 기록 내용이 들어있는 vo
	 * @param 로그인한 사용자 정보
	 * @return 성공하면 1, 실패하면 0
	 */
	
	@PostMapping("/nursingchartinsert")
	public int nursingChartInsert(@RequestBody NursingChartVO chartVO, @AuthenticationPrincipal CustomEmployee customUser) {
		int employeeNo = customUser.getEmployee().getEmployeeNo();
		chartVO.setEmployeeNo(employeeNo);
		int result = service.nursingChartInsert(chartVO);
		return result;
	}
	/**
	 * 작성자: 이지은
	 * 간호기록지 출력 메서드
	 * @param chartNo 간호기록지를 가지고 올 차트 번호
	 * @return 간호기록지 리스트
	 */
	@GetMapping("/nursingchartselect")
	public List<NursingChartVO> nursingChartSelect(@RequestParam("chartNo") int chartNo){
		ChartVO chartVO = new ChartVO();
	    chartVO.setChartNo(chartNo);
	    List<NursingChartVO> chartList = service.nursingChartSelect(chartVO);
	    return chartList;
	}

}