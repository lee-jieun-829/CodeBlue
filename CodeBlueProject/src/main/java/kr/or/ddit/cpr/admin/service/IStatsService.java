package kr.or.ddit.cpr.admin.service;

import java.util.List;

import kr.or.ddit.cpr.vo.StatsVO;

public interface IStatsService {

	public List<StatsVO> selectYearsStats(int year);

	public List<StatsVO> selectDemographicsStats(int year);

	public List<StatsVO> selectDailyPatientStats(int year, int month);

}