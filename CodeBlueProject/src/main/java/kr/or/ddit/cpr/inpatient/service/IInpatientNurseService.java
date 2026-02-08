package kr.or.ddit.cpr.inpatient.service;

import java.util.List;

import kr.or.ddit.cpr.vo.InpatientVO;
import kr.or.ddit.cpr.vo.LocationVO;
import kr.or.ddit.cpr.vo.PatientVO;

public interface IInpatientNurseService {
	/**
	 * 작성자: 이지은
	 * 입원 환자 리스트 셀렉트 메서드
	 * @return 입원 환자 리스트
	 */
	public List<InpatientVO> inPatientSelect();
	
	/**
	 * 작성자: 이지은
	 * 장소 리스트 셀렉트 메서드 
	 * @return 장소 리스트
	 */
	public List<LocationVO> locationSelect();
	/**
	 * 작성자: 이지은
	 * 전실 메서드
	 * @param inpatientVO 환자no, bed no 번호가 들어있는 객체
	 * @return 성공하면 1, 실패하면 0
	 */
	public int bedUpdate(List<InpatientVO> inpatientVO);
	/**
	 * 작성자: 이지은
	 * 환자메모 업데이트 메서드
	 * @param inpatientVO 환자 번호와 환자 메모가 들어있는 객체
	 * @return 성공하면 1, 실패하면 0
	 */
	public int updateMemo(PatientVO patientvo);

}