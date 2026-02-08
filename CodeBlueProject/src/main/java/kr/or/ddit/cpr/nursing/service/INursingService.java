package kr.or.ddit.cpr.nursing.service;

import java.util.List;

import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.ClinicalDetailVO;
import kr.or.ddit.cpr.vo.NursingAssessmentVO;
import kr.or.ddit.cpr.vo.NursingChartVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.PredrugDetailVO;

public interface INursingService {
	/**
	 * 작성자: 이지은
	 * 간호정보 조사지 가져오기 메서드
	 * @param admissionNo
	 * @return 간호정보 조사지 정보 list
	 */
	public List<NursingAssessmentVO> assessmentSelect(int admissionNo);
	/**
	 * 작성자: 이지은
	 * 간호정보 조사지 등록 메서드	 * 
	 * @param clinicalDetailVO 차트번호.입원경로.통증점수,통증부위,낙상위험도,욕창위험도,흡연,음주,키,체중,과거병력및알레르기 내용이 들어있는 vo
	 * @return 성공하면 1, 실패하면 0
	 */
	public int assessmentInsert(NursingAssessmentVO assessmentVO);
	
	/**
	 * 작성자: 이지은
	 * 간호정보 조사지 수정 메서드	 
	 * @param clinicalDetailVO 차트번호.입원경로.통증점수,통증부위,낙상위험도,욕창위험도,흡연,음주,키,체중,과거병력및알레르기 내용이 들어있는 vo
	 * @return 성공하면 1, 실패하면 0
	 */
	public int assessmentUpdate(NursingAssessmentVO assessmentVO);
	/**
	 * 작성자: 이지은
	 * 처방 가져오는 메서드
	 * @param chartNo 클릭한 환자에 해당하는 차트 번호
	 * @return 차트번호에 해당하는 처방 리스트
	 */
	public List<PredetailVO> prescriptionSelect(ChartVO chartVO);
	/**
	 * 작성자: 이지은
	 * 주사 수행 메서드
	 * @param predrugDetailVO 처방번호, 약번호, 업데이트 할 수행상태를 가지고 있는 vo
	 * @return 성공하면 1, 실패하면 0
	 */
	public int preDrugDetailStatusUpdate(PredrugDetailVO predrugDetailVO);
	/**
	 * 작성자: 이지은
	 * 환자 수납대기로 상태변경 메서드
	 * @param admissionNo 변경할 입원 접수번호
	 * @return 성공하면 1, 실패하면 0
	 */
	public int admissionStatusUpdate(int admissionNo);
	/**
	 * 작성자: 이지은
	 * 간호기록지 등록 메서드
	 * @param chartVO 환자 혈압, 체온, 맥박, 식이, 기록 내용이 들어있는 vo
	 * @return 성공하면 1, 실패하면 0
	 */
	public int nursingChartInsert(NursingChartVO chartVO);
	/**
	 * 작성자: 이지은
	 * 간호기록지 출력 메서드
	 * @param chartNo 간호기록지를 가지고 올 차트 번호
	 * @return 간호기록지 리스트
	 */
	public List<NursingChartVO> nursingChartSelect(ChartVO chartVO);

}
