package kr.or.ddit.cpr.inpatient.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.inpatient.service.IInpatientNurseService;
import kr.or.ddit.cpr.reservation.service.IReservationService;
import kr.or.ddit.cpr.vo.InpatientVO;
import kr.or.ddit.cpr.vo.LocationVO;
import kr.or.ddit.cpr.vo.PatientVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/nurse")
public class NurseInpatientRestController {
	
	@Autowired
	private IInpatientNurseService service;	
	
	/**
	 * 작성자: 이지은
	 * 입원 환자 리스트 셀렉트 메서드
	 * @return 입원 환자 리스트
	 */
	@GetMapping("/inPatientSelect")
	public List<InpatientVO> inPatientSelect(){
		List<InpatientVO> inPatientList = service.inPatientSelect();
		return inPatientList;
	}	
	
	/**
	 * 작성자: 이지은
	 * 장소 리스트 셀렉트 메서드 
	 * @return 장소 리스트
	 */
	@GetMapping("/locationSelect")
	public List<LocationVO> locationSelect() {
		List<LocationVO> locationList = service.locationSelect();
		return locationList;
	}
	/**
	 * 작성자: 이지은
	 * 전실 메서드
	 * @param inpatientVO 환자no, bed no 번호가 들어있는 객체
	 * @return 성공하면 1, 실패하면 0
	 */
	@PostMapping("/bedupdate")
	public int bedUpdate(@RequestBody List<InpatientVO> inpatientVO) {
		int result = service.bedUpdate(inpatientVO);
		return result;
		
	}
	/**
	 * 작성자: 이지은
	 * 환자메모 업데이트 메서드
	 * @param inpatientVO 환자 번호와 환자 메모가 들어있는 객체
	 * @return 성공하면 1, 실패하면 0
	 */
	@PostMapping("/updatememo")
	private int updateMemo(PatientVO patientvo) {
		int result = service.updateMemo(patientvo);
		return result;
	}
	
}