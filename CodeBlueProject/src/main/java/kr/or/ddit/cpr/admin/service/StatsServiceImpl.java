package kr.or.ddit.cpr.admin.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.or.ddit.cpr.admin.mapper.IStatsMapper;
import kr.or.ddit.cpr.vo.StatsVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class StatsServiceImpl implements IStatsService{
	
	@Autowired
	private IStatsMapper statsMapper;
	
	@Override
	public List<StatsVO> selectYearsStats(int year) {
		return statsMapper.selectYearsStats(year);
	}

	@Override
	public List<StatsVO> selectDemographicsStats(int year) {
		return statsMapper.selectDemographicsStats(year);
	}

	@Override
	public List<StatsVO> selectDailyPatientStats(int year, int month) {
		return statsMapper.selectDailyPatientStats(year, month);
	}
}