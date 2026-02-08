package kr.or.ddit.cpr.macro.mapper;

import java.util.List;
import java.util.Map;
import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.MacroVO;
import kr.or.ddit.cpr.vo.TreatmentVO;

@Mapper
public interface IMacroMapper {

	// 1. 매크로 기본 CRUD
	public List<MacroVO> selectMacroList(int employeeNo);
	public MacroVO selectMacro(int macroNo);
	public int insertMacro(MacroVO macroVO);
	public int updateMacro(MacroVO macroVO);
	public int deleteMacro(int macroNo);

	// 2. 매크로 상세 (통합 테이블 사용)
	public int insertMacroDetail(Map<String, Object> map); // 상세 등록 통합
	public int deleteMacroDetail(int macroNo);             // 상세 삭제 통합

	// 3. 검색용 메서드 (검사 제외)
	public List<DiagnosisVO> selectDiagnosisList(String keyword);
	public List<DrugVO> selectDrugList(String keyword);
	public List<TreatmentVO> selectTreatmentList(String keyword);
	public List<MacroVO> selectNurseMacroList(Map<String, Object> map);
}