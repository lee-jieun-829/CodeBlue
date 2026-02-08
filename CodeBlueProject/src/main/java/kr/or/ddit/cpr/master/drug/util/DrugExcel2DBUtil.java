package kr.or.ddit.cpr.master.drug.util;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.apache.poi.EncryptedDocumentException;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;

import kr.or.ddit.cpr.vo.DrugVO;

/**
 * 약품정보 엑셀파일을 DB에 저장하기 위한 클래스
 */
public class DrugExcel2DBUtil {


	/**
	 * @author 장우석
	 * @param String FilePath 로컬엑셀파일 주소
	 * @return List<DrugVO> 엑셀에서 읽어온 약품정보
	 * @throws EncryptedDocumentException
	 * @throws IOException
	 * 
	 * 읽어온 약품 엑셀파일을 List<Drug> 형식으로 반환하는 함수
	 */
	public static List<DrugVO> readDrugExcelFile(String FilePath) throws EncryptedDocumentException, IOException {

		// 리턴 할 List<Drug> 생성
		List<DrugVO> drugList = new ArrayList<>();

		// 랜덤 재고 수량 배열
		int[] ranArr = { 0, 30, 50, 100, 100, 150, 150, 250, 250, 300, 300, 500 };

		// 파일 주소 생성
		File excelFile = new File(FilePath);

		// 엑셀 파일 열기
		Workbook workbook = WorkbookFactory.create(excelFile);
		Sheet sheet = workbook.getSheetAt(0);

		// 엑셀의 총 행 수 가져오기
		int lastRowNum = sheet.getLastRowNum();

		// i : 1부터 시작하여 엑셀의 0번째 ROW 정보를 건너 뜀 ( 헤더 정보 )
		for (int i = 1; i <= lastRowNum; i++) {

			// i값에 해당하는 행 정보 가져오기
			Row row = sheet.getRow(i);

			// 행 정보가 없다면 넘기기 (비어있는 행이 있을 수 있음)
			if (row == null)
				continue;

			// 랜덤 재고 수량 배열에 사용할 랜덤 숫자
			int ranNum = (int) (Math.random() * ranArr.length);

			// 컬럼 데이터 확인
			// 컬럼 데이터도 ROW와 마찬가지로 0번부터 시작
			int no = (int) row.getCell(0).getNumericCellValue(); // 엑셀 행
			String code = row.getCell(6).toString(); // 약품 코드
			String name = row.getCell(7).toString(); // 약품 명
			long amount = ranArr[ranNum]; // 재고
			String company = row.getCell(8).toString(); // 제조사
			long saftyStoke = 50; // 안전재고
			String route = row.getCell(1).toString(); // 투여 분류
			String spec = row.getCell(9).toString(); // 투여 규격
			String unit = row.getCell(10).toString(); // 단위

			// 가격 컬럼의 경우 숫자데이터 사이에 '산정불가' 라는 문자데이터가 섞여있어 전처리
			long price = 0; // 출고가 미정
			if (!(row.getCell(11).toString().equals("산정불가"))) {
				price = (long) row.getCell(11).getNumericCellValue();// 출고가
			}

			long cost = (long) (price * 0.8); // 매입가

			// DrugVO에 한 행 정보 담기
//			DrugVO drugVO = new DrugVO(no, code, name, amount, company, cost, price, saftyStoke, route, spec, unit);
			
			// 리스트에 DrugVO 담기
//			drugList.add(drugVO);
		}

		// drugList 반환
		return drugList;
	}

//	/**
//	 * @author 장우석
//	 * @param String FilePath 로컬엑셀파일 주소
//	 * @return List<DrugVO> 엑셀에서 읽어온 약품정보
//	 * @throws EncryptedDocumentException
//	 * @throws IOException
//	 * 
//	 * 읽어온 산정불가 약품만 가져오는 함수
//	 */
//	public static List<DrugVO> readDrugGood(String FilePath) throws EncryptedDocumentException, IOException {
//
//		// 리턴 할 List<Drug> 생성
//		List<DrugVO> drugList = new ArrayList<>();
//
//		// 랜덤 재고 수량 배열
//		int[] ranArr = { 0, 30, 50, 100, 100, 150, 150, 250, 250, 300, 300, 500 };
//
//		// 파일 주소 생성
//		File excelFile = new File(FilePath);
//
//		// 엑셀 파일 열기
//		Workbook workbook = WorkbookFactory.create(excelFile);
//		Sheet sheet = workbook.getSheetAt(0);
//
//		// 엑셀의 총 행 수 가져오기
//		int lastRowNum = sheet.getLastRowNum();
//
//		// i : 1부터 시작하여 엑셀의 0번째 ROW 정보를 건너 뜀 ( 헤더 정보 )
//		for (int i = 1; i <= lastRowNum; i++) {
//
//			// i값에 해당하는 행 정보 가져오기
//			Row row = sheet.getRow(i);
//
//			// 행 정보가 없다면 넘기기 (비어있는 행이 있을 수 있음)
//			if (row == null) continue;
//
//			// 랜덤 재고 수량 배열에 사용할 랜덤 숫자
//			int ranNum = (int) (Math.random() * ranArr.length);
//
//			// 컬럼 데이터 확인
//			// 컬럼 데이터도 ROW와 마찬가지로 0번부터 시작
//			int no = (int) row.getCell(0).getNumericCellValue(); // 엑셀 행
//			String code = row.getCell(6).toString(); // 약품 코드
//			String name = row.getCell(7).toString(); // 약품 명
//			long amount = ranArr[ranNum]; // 재고
//			String company = row.getCell(8).toString(); // 제조사
//			long saftyStoke = 50; // 안전재고
//			String route = row.getCell(1).toString(); // 투여 분류
//			String spec = row.getCell(9).toString(); // 투여 규격
//			String unit = row.getCell(10).toString(); // 단위
//
//			// 가격 컬럼의 경우 숫자데이터 사이에 '산정불가' 라는 문자데이터가 섞여있어 전처리
//			long price = 0; // 출고가 미정
//			if (!(row.getCell(11).toString().equals("산정불가"))) {
//				price = (long) row.getCell(11).getNumericCellValue();// 출고가
//			}
//
//			long cost = (long) (price * 0.8); // 매입가
//
//			// DrugVO에 한 행 정보 담기
//			DrugVO drugVO = new DrugVO(no, code, name, amount, company, cost, price, saftyStoke, route, spec, unit);
//			drugVO.setDrugCode(code);
//			drugVO.setDrugName(name);
//			drugVO.setDrugCompany(company);
//			drugVO.set
//			
//			// 리스트에 DrugVO 담기
//			drugList.add(drugVO);
//		}
//
//		// drugList 반환
//		return drugList;
//	}
}
