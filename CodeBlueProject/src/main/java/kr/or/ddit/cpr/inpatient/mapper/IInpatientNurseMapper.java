package kr.or.ddit.cpr.inpatient.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.web.bind.annotation.RequestParam;

import kr.or.ddit.cpr.vo.BedVO;
import kr.or.ddit.cpr.vo.InpatientVO;
import kr.or.ddit.cpr.vo.LocationVO;

@Mapper
public interface IInpatientNurseMapper {
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
	 * 전실 입원접수 테이블 환자 병실 수정 메서드
	 * @param inpatientVO 환자no, bed no 번호가 들어있는 객체
	 * @return 성공하면 1, 실패하면 0
	 */
	public int bedUpdate(int patientNo,int bedNo);
	/**
	 * 작성자: 이지은
	 * 전실 침상테이블 상태값 변경 메서드
	 * @param bedVO	침상번호와 상태값이 들어있는 객체
	 * @return 성공하면 1, 실패하면 0
	 */
	public int updateBedStatus(BedVO bedVO);


}