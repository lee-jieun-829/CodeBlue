package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class PredrugDetailVO {
	 private int drugNo;
	 private int predetailNo;
	 private int predrugDetailDose;
	 private int predrugDetailFreq;
	 private int predrugDetailDay;
	 private String predrugDetailMethod;
	 private String predrugDetailPharmtype;
	 private String predrugDetailStatus;
	 private String predrugDetailRemark;
	 private String predrugDetailType;
}
