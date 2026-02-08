package kr.or.ddit.cpr.vo;

import java.util.Date;
import java.util.List;

import lombok.Data;

@Data
public class MacroVO {
	
	private int macroNo; 			/* 매크로번호 */
	private String macroName; 		/* 매크로이름 */
	private String macroType; 		/* 유형 */
	private String macroContent; 	/* 내용 */
	private Date macroRegdate; 		/* 등록및수정일자 */
	private int employeeNo; 		/* 사번 */
	
	private List<MacroDetailVO> macroDetails;/*매크로 디테일 리스트*/
	
	private List<DiagnosisVO> diagnosisList;
	private List<DrugVO> drugList;          
	private List<TreatmentVO> treatmentList;
	
	public String getMacroYn() {
		return null;
	}
	public void setMacroYn(String string) {
	} 
}