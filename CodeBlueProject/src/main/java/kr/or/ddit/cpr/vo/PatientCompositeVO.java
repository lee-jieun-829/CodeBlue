package kr.or.ddit.cpr.vo;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class PatientCompositeVO {
	
	private PatientVO patientVO;
	private ScreeningVO screeningVO;
	
	private List<ChartListVO> chartList;
	private List<PredetailVO> preList;
	
}
