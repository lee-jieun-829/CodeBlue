package kr.or.ddit.cpr.master.diagnosis.util;

import java.util.List;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import kr.or.ddit.cpr.master.diagnosis.vo.DiagnosisVO;
import kr.or.ddit.cpr.master.drug.mapper.IInsertDBMapper;

@SpringBootTest
public class DiagnosisInsert {
	
	@Autowired
	IInsertDBMapper insertDB;
	
	@Test
	void test() {
		
		int totalCount = DiagnosisApiUtil.getTotalCount();
		
		int rowsPerPage = 1000;
		int totalPages = (int) Math.ceil((double) totalCount / rowsPerPage);
		System.out.println("총 데이터: " + totalCount + "건");
        System.out.println("총 페이지: " + totalPages + "페이지 (페이지당 " + rowsPerPage + "건)");
        
        for(int i=1; i<=totalPages;i++) {
        	System.out.println(">>> 진행률 [" + i + " / " + totalPages + "] 페이지 요청 중...");
        	
        	// API 호출
            List<DiagnosisVO> list = DiagnosisApiUtil.getDiagnosisList(i, rowsPerPage);
            if (list.isEmpty()) {
                System.out.println("   (경고) 데이터가 비어있습니다. 다음 페이지로...");
                continue;
            }
            
            try {
				
            	insertDB.insertDiagnosis(list);
			} catch (Exception e) {
				System.err.println("디비저장실패");
				e.printStackTrace();
			}

        }
		
	}
	
	@Test
	void totalCount() {
		System.out.println(DiagnosisApiUtil.getTotalCount());
	}
}
