package kr.or.ddit.cpr.common.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Component;

import lombok.extern.slf4j.Slf4j;

/**
 * <p>ExcelResultHandler</p>
 * 
 * <pre>
 * 1. 엑셀 파일에 접근할때마다 성공&실패 기록 :: 동시성 오염 낮춤
 * 2. DB 에러메시지 변역
 * 3. 엑셀 파일에 대한 결과 Map 포장 
 * 
 * 주의사항 : 핸들러가 아닌 서비스에서 변수를 저장함!! 여기는 공통 계산기 (메모리 효율)
 * </pre>
 * 
 * @author 김경희
 *
 */

@Slf4j
@Component
public class ExcelResultHandler {
	
	// 실패 1건씩 발생할 때마다 failDetails 리스트에 추가함
    public void addFail(List<Map<String, Object>> failDetails, int rowNo, String reason) {
        
    	if (failDetails == null) {
            throw new IllegalArgumentException("failDetails(list)가 null 입니다.");
        }
    	
        if (reason == null || reason.trim().isEmpty()) {
            reason = "등록 실패 : 알 수 없는 오류";
        }

        Map<String, Object> failMap = new HashMap<>();
        failMap.put("rowNo", rowNo);
        failMap.put("reason", reason);
        failDetails.add(failMap);
    }
    
    // 예외 메세지 출력 - 오버로딩
    public void addFail(List<Map<String, Object>> failDetails, int rowNo, Exception ex) {
    	addFail(failDetails, rowNo, classifyException(ex));
    }
    
    
    // 예외를 사용자에게 맞춰 변환시킴
    public String classifyException(Exception ex) {
        if (ex == null) return "등록 실패 : 알 수 없는 오류";

        // 중복된 데이터일 경우
        if (ex instanceof DuplicateKeyException) {
            return "이미 존재하는 정보 (중복됨)";
        }
        
        // 데이터가 없을때
        String msg = ex.getMessage();
        if (msg == null || msg.trim().isEmpty()) {
            return "등록 실패 : 알 수 없는 오류";
        }

        // 에러 고정 손님ㅎ
        if (msg.contains("ORA-00001")) return "이미 존재하는 정보(중복)";
        if (msg.contains("ORA-02291")) return "참조하는 데이터가 존재하지 않습니다 (FK 오류)";
        if (msg.contains("ORA-12899")) return "입력 가능한 글자 수를 초과했습니다";

        // 너무 길어서 자름
        String trimmed = msg.trim();
        int maxLen = 120;
        String safe = trimmed.length() > maxLen ? trimmed.substring(0, maxLen) + "..." : trimmed;

        log.debug("엑셀 처리중 예외: {}", trimmed);

        return "등록 실패 : " + safe;
    }
    
    
    // 엑셀 파일 처리에 대한 결과들을 Map 으로 포장
    public Map<String, Object> printExcelResult(int successCount, int failCount, List<Map<String, Object>> failDetails){
    	
    	Map<String, Object> result = new HashMap<>();
    	
    	result.put("successCount", Math.max(0, successCount));
    	result.put("failCount",  Math.max(0, failCount));
    	result.put("failDetails", failDetails != null ? failDetails : new ArrayList<>());
    	
    	return result;
    }
}