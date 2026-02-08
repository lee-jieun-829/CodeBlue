package kr.or.ddit.cpr.master.drug.util;

import java.io.IOException;
import java.util.List;

import org.apache.poi.EncryptedDocumentException;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

import kr.or.ddit.cpr.master.drug.mapper.IInsertDBMapper;
import kr.or.ddit.cpr.vo.DrugVO;

/**
 * 스프링 시큐리티로 url이 아직 막혀있어서 임시로 작성한 테스트
 * 여기서 실제로 DB에 입력함
 */

@SpringBootTest
public class DrugInsert {
	
	@Autowired
	private IInsertDBMapper insertDB;
	
	@Test
	void test() {
		System.out.println("=== [스프링 부트] 엑셀 업로드 시작 ===");
		String excelFilePath = "D:/data.xlsx";
		
		try {
			List<DrugVO> drugList = DrugExcel2DBUtil.readDrugExcelFile(excelFilePath);
			// 총 약품 수 
			int totalSize = drugList.size();
            System.out.println("가져온 데이터 개수: " + totalSize + "건");
			// 리스트에서 분할 할 데이터 수
			int splitSize = 1000;
			
			for(int i=0;i<totalSize;i += splitSize) {
				
				//마지막 부분 처리 로직
				int end = Math.min(totalSize, i + splitSize);
				
				// 리스트 자르기
				List<DrugVO> subList = drugList.subList(i, end);
				
				// DB 저장
				try {
					insertDB.insertDrug(subList);

				} catch (Exception e) {
					e.printStackTrace();
				}
			
			}
		
		
		} catch (EncryptedDocumentException | IOException e) {
			e.printStackTrace();
			System.err.println("================================");
			System.err.println("엑셀 파일을 읽는 도중 에러가 발생하였습니다.");
			System.err.println("================================");
		}
		
	}
}
