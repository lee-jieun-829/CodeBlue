package kr.or.ddit.cpr.prescription.service;

import java.util.List;

import kr.or.ddit.cpr.vo.ChartListVO;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.ExaminationVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.TreatmentVO;

public interface IPrescriptionService {

	/**
	 * <p>환자번호로 차트리스트를 가져오는 함수</p>
	 * @author 장우석
	 * @param patientNo
	 * @return List<ChartVO>
	 */
	public List<ChartListVO> selectChartList(int patientNo);

	/**
	 * <p>차트번호로 처방 리스트를 가져오는 함수</p>
	 * @author 장우석
	 * @param patientNo
	 * @return List<PredetailVO>
	 */
	public List<PredetailVO> selectPredetailList(ChartVO vo);
	
	/**
	 * <p>
	 * 	차트번호로 처방정보를 가져오는 함수
	 * 	처방에 있는 구분으로 각 처방을 가져옴
	 * 	ex) 차트번호 64, 처방번호 50 처방구분 003 = 50번 처방번호의 치료(List<TreatmentVO>) 정보가져옴
	 * </p>
	 * @author 장우석
	 * @param  PredetailVO vo
	 * @return List<PredetailVO> 처방정보
	 */
	public List<PredetailVO> selectPrescriptionList(PredetailVO vo);
	
	/**
	 * <p> 처방번호를 가지고 약품처방 리스트를 가져오는 함수 약품정보 X 약품처방 O</p>
	 * @author 장우석
	 * @param PredetailVO vo
	 * @return List<DrugVO> 약품처방 정보
	 */
	public List<DrugVO> selectDrugDetailList(PredetailVO vo);
	
	/**
	 * <p> 처방번호를 가지고 치료처방 리스트를 가져오는 함수 치료정보 X 치료처방 O</p>
	 * @author 장우석
	 * @param PredetailVO vo
	 * @return List<TreatmentVO> 치료처방 정보
	 */
	public List<TreatmentVO> selectTreatmentDetailList(PredetailVO vo);
	
	/**
	 * <p> 처방번호를 가지고 검사처방 리스트를 가져오는 함수</p>
	 * @author 장우석
	 * @param PredetailVO vo
	 * @return List<ExaminationVO> 치료처방 정보
	 */
	public List<ExaminationVO> selectExamDetailList(PredetailVO vo);
}
