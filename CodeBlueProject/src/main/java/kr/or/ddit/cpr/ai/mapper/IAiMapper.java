package kr.or.ddit.cpr.ai.mapper;

import java.util.ArrayList;
import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.vo.AiDiagnosisVO;
import kr.or.ddit.cpr.vo.AiDrugVO;
import kr.or.ddit.cpr.vo.aiVO;
import kr.or.ddit.cpr.vo.aifunVO;


@Mapper
public interface IAiMapper {
	
	public List<aifunVO> searchDiseaseByKeywords(List<String> keywords);
	public List<aifunVO> searchDrugByIngredients(List<String> ingredients);
	//insert
	public void aiInsert(aiVO aiVO);
	public void insertAiDiagnosis(AiDiagnosisVO diag);
	public void insertAiDrug(AiDrugVO drug);
	//select
	public ArrayList<aiVO> aiSelect(String ptNo);
	//아래는 안씀_혹시 프로세스 수정될 수 있으니 살려놨어요
	public List<aifunVO> searchDrugs(aifunVO vo);
	public List<aifunVO> searchDiagnosis(aifunVO vo);
	public List<aifunVO> searchTreatments(aifunVO vo);
	
	
	
	
}
