package kr.or.ddit.cpr.outpatient;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import kr.or.ddit.cpr.outpatient.service.IPatientService;
import kr.or.ddit.cpr.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.OutPatientListVO;
import lombok.extern.slf4j.Slf4j;

@SpringBootTest
@Slf4j
public class ServiceTest {
	
	@Autowired
	IPatientService patientService;
	
	@Test
	void selectDiagnosisListTest(){
		List<DiagnosisVO> selectDiagnosisList = patientService.selectDiagnosisList("");
		log.info("selectDiagnosisList : {}" , selectDiagnosisList);
	}
	
	@Test
	void selectDrugList() {
		List<DrugVO> selectDrugList = patientService.selectDrugList("토피");
		log.info("selectDrugList : {}", selectDrugList);
	}
	
	@Test
	void selectOutPatientList() {
		EmployeeVO employeeVO = new EmployeeVO();
		
		employeeVO.setEmployeeNo(25121902);
		
		List<OutPatientListVO> list = patientService.selectOutPatientList(employeeVO);
		log.info("selectOutPatientList : {}", list.size());
	}
}
