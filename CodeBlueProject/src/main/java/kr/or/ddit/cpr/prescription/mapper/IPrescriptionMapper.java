package kr.or.ddit.cpr.prescription.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.vo.ChartListVO;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.PredetailVO;

@Mapper
public interface IPrescriptionMapper {

	public List<ChartListVO> selectChartList(int patientNo);

	public List<PredetailVO> selectPredetailList(ChartVO vo);
	
}
