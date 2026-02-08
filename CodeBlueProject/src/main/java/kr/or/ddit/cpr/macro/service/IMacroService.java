package kr.or.ddit.cpr.macro.service;

import java.util.List;
import java.util.Map;

import kr.or.ddit.cpr.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.MacroVO;
import kr.or.ddit.cpr.vo.TreatmentVO;

public interface IMacroService {
	public List<MacroVO> retrieveMacroList(int employeeNo);
	public MacroVO retrieveMacro(int macroNo);
	public int createMacro(MacroVO macroVO);
	public int removeMacro(int macroNo);
	public void modifyMacro(Map<String, Object> paramMap);

	public List<DiagnosisVO> retrieveDiagnosisList(String keyword);
	public List<DrugVO> retrieveDrugList(String keyword);
	public List<TreatmentVO> retrieveTreatmentList(String keyword);
	public List<MacroVO> retrieveNurseMacroList(Map<String, Object> map);
}