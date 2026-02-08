package kr.or.ddit.cpr.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ChartListVO {
	
	private int chartNo;
	private String employeeName;
	private ChartVO chartVO;
}
