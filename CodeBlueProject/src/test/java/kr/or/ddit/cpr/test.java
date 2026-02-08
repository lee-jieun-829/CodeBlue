package kr.or.ddit.cpr;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import kr.or.ddit.cpr.prescription.service.IPrescriptionService;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import lombok.extern.slf4j.Slf4j;

@SpringBootTest
@Slf4j
public class test {

	@Autowired
	IPrescriptionService prescriptionService;
	
	
	@Test
	void test() {
		ChartVO chartVO = new ChartVO();
		chartVO.setChartNo(69);
		List<PredetailVO> list = prescriptionService.selectPredetailList(chartVO);
		log.info("testsetstsetsetsetsetst {}", list);
	}
}
