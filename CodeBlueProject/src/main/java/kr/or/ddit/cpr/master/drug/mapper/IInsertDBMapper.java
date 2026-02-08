package kr.or.ddit.cpr.master.drug.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.master.diagnosis.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.DrugVO;

@Mapper
public interface IInsertDBMapper {

	public void insertDrug(List<DrugVO> list);

	public void insertDiagnosis(List<DiagnosisVO> list);

}
