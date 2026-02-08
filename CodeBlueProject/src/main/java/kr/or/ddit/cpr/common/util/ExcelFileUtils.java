package kr.or.ddit.cpr.common.util;

import java.net.URLEncoder;
import java.util.Date;
import java.util.List;
import java.util.function.BiConsumer;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.DateUtil;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Component;

import jakarta.servlet.http.HttpServletResponse;
import lombok.extern.slf4j.Slf4j;

/**
 * <p>ExcelFileUtils :: 엑셀 파일 처리에 대한 기술들</p>
 * 
 * <pre>
 * 1. 엑셀 파일의 셀 값을 읽기
 * 2. 엑셀 파일 다운로드 처리
 * 
 * 주의사항 : 
 * </pre>
 * 
 * @author 김경희
 *
 */
@Slf4j
@Component
public class ExcelFileUtils {
	
    private final DataFormatter dataFormatter = new DataFormatter();

    // 등록 - 셀 값 문자열로 꺼내기
    public String getCellValue(Cell cell) {
        if (cell == null) return "";
        return dataFormatter.formatCellValue(cell).trim();
    }

    // 등록 - 입력된 날짜들을 DB에 저장할때
    public Date getCellDateOrToday(Cell cell) {
        try {
            if (cell != null && DateUtil.isCellDateFormatted(cell)) {
                return cell.getDateCellValue();
            }
        } catch (Exception e) {
        	// 엑셀 업로드하는 날짜로 대체함
        }
        return new Date();
    }

    // 다운로드 공통 기능
    public <T> void downloadExcel(HttpServletResponse response, String fileName,
    							  String[] headers, List<T> list, BiConsumer<Row, T> writer) {
    	// null 을 전달할 경우의 예외
    	if (response == null) throw new IllegalArgumentException("HttpServletResponse가 설정되어야 엑셀 다운로드가 가능합니다.");
    	if (fileName == null) throw new IllegalArgumentException("파일명이 설정되어야 엑셀 다운로드가 가능합니다.");
    	if (headers == null) throw new IllegalArgumentException("헤더 행(headers)을 설정 해야 다운로드가 가능합니다.");
    	if (list == null) throw new IllegalArgumentException("엑셀에 출력할 데이터(list)를 설정 해야 다운로드가 가능합니다.");
    	if (writer == null) throw new IllegalArgumentException("엑셀에 출력할 로직(writer)을 설정 해야 다운로드가 가능합니다.");
    	
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Sheet1");
            Row headerRow = sheet.createRow(0);
            for (int i = 0; i < headers.length; i++) headerRow.createCell(i).setCellValue(headers[i]);

            int rowNum = 1;
            
            for (T item : list) {
                Row row = sheet.createRow(rowNum++);
                writer.accept(row, item);
            }

            String encoded = URLEncoder.encode(fileName, "UTF-8").replaceAll("\\+", "%20");
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + encoded + "\"");
            workbook.write(response.getOutputStream());
        } catch (Exception e) {
        	log.error("엑셀 다운로드 실패, fileName={}", fileName, e);
            throw new RuntimeException("엑셀 다운로드 실패", e);
        }
    }
}