package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class DrugVO {
	
	private Long chartNo; // 차트번호

	private Long drugNo; // 약품 번호
	private String drugCode; // 약품 코드
	private String drugName; // 약품명
	private Long drugAmount; // 약재고량
	private String drugCompany; // 제조사
	private Long drugCost; // 매입가
	private Long drugPrice; // 출고가
	private Long drugSaftyStoke; // 안전재고
	private String drugType; // 투여분류(내복/외복/주사)
	private String drugSpec; // 규격
	private String drugUnit; // 단위
    	
	private Long predetailNo; // 처방상세번호
	private Long predrugDetailDose; // 1회 투여량
	private Long predrugDetailFreq; // 횟수
	private Long predrugDetailDay; // 일수
	private String predrugDetailMethod; // 방법
	private String predrugDetailPharmtype; // 원외
	private String predrugDetailStatus; // 상태
	private String predrugDetailRemark; // 비고
	private String predrugDetailType; // 약품/주사구분
	
	private String predetailRegdate;

	// 재고 상태 체크
	private Long drugTotal; // 총 투여량
    private String stockStatus;  // 재고 상태
}
