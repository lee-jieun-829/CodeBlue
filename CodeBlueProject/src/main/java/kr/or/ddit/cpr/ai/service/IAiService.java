package kr.or.ddit.cpr.ai.service;

import java.util.ArrayList;
import java.util.Map;

import kr.or.ddit.cpr.vo.aiVO;


public interface IAiService {
	/**
	 * 작성자: 이지은
     * ai어시스턴트 메인메서드
     * @param userPrompt web speech api 인식 결과
     * @param patientAge 환자 나이
     * @param patientGender 환자 성별
     * @return ai어시스턴트 결과
     */
	public Map<String, Object> aiAssistant(String dialogueText, String patientAge, String patientGender);
	
	 /**
	  * 작성자: 이지은
	  * ai어시스턴트 등록 기능
	  * @param aiVO ai어시스턴트 결과
	  */
	public void aiInsert(aiVO aiVO);
	
	/**
	 * 작성자: 이지은
	 * ai어시스턴트 리스트 출력
	 * @param aiVO ai어시스턴트 결과 리스트
	 */
	public ArrayList<aiVO> aiSelect(String ptNo);
	
}
