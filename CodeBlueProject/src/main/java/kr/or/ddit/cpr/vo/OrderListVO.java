package kr.or.ddit.cpr.vo;

import java.util.List;

import lombok.Data;

@Data
public class OrderListVO extends InpatientVO {

	private Long chartNo; // 차트 번호
	
	private List<DietVO> diet; // 식이VO 리스트
	private List<OperationVO> operation; // 수술VO 리스트
	private List<DrugVO> drug; // 처방VO 리스트
	private List<TreatmentVO> treatment; // 치료VO 리스트
	private List<ExaminationVO> examination; // 검사VO 리스트
	
}
