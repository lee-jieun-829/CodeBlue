package kr.or.ddit.cpr.admin.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import kr.or.ddit.cpr.vo.StatsVO;

@Mapper
public interface IStatsMapper {

	public List<StatsVO> selectYearsStats(@Param("year") int year);
	
	public List<StatsVO> selectDemographicsStats(@Param("year") int year);

	public List<StatsVO> selectDailyPatientStats(@Param("year") int year, @Param("month") int month);

}