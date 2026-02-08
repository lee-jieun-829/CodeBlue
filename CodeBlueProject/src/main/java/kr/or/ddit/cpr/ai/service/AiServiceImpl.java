package kr.or.ddit.cpr.ai.service;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.ai.mapper.IAiMapper;
import kr.or.ddit.cpr.vo.AiDiagnosisVO;
import kr.or.ddit.cpr.vo.AiDrugVO;
import kr.or.ddit.cpr.vo.aiVO;
import kr.or.ddit.cpr.vo.aifunVO;


@Service
public class AiServiceImpl implements IAiService {
	
	 private final ChatClient chatClient;	
	 private final IAiMapper mapper; // MyBatis Mapper	 
	 
	  public AiServiceImpl(ChatClient.Builder builder, IAiMapper mapper) {
	        this.chatClient = builder.build();
	        this.mapper = mapper;
	    }

	@Override
	public Map<String, Object> aiAssistant(String userPrompt, String patientAge, String patientGender) {
		// 대화 분석 후 증상요약, 검색키워드 추출		
        AnalysisResult analysis = analyzeDialogue(userPrompt); 
        
        //db에 있는 상병 검색
        List<aifunVO> diagnosisList = mapper.searchDiseaseByKeywords(analysis.keywords);
        if(diagnosisList.isEmpty()) return Map.of("status", "FAIL", "msg", "상병 검색 실패");
        
        //상병 검색 결과 리스트 중 대화 요약과 매칭되는 상병 선택
        List<aifunVO> selectDiagnosis = selectBestDisease(analysis.summary, diagnosisList);
        
        //매칭된 상병으로 해당 상병에 많이 사용하는 성분 추출
        String diagnosisNames = selectDiagnosis.stream()
                .map(aifunVO::getDiagnosisName)
                .collect(Collectors.joining(", "));
        //약성분 list
        List<String> drugIngredient = extractIngredients(diagnosisNames);
        
        //db에 있는 약품 검색
        List<aifunVO> drugList = mapper.searchDrugByIngredients(drugIngredient);
        
        //약품 검색 결과 리스트 중 환자 정보, 증상에 의거해 적절한 약품 선택
        List<aifunVO> selectedDrugs = selectBestDrugs(analysis.summary, patientAge, patientGender, drugList);
        
        Map<String, Object> aiResult = new HashMap<>();         
        aiResult.put("aiDrug", selectedDrugs);     // 약품 VO 리스트
        aiResult.put("aiDiagnosis", selectDiagnosis); // 상병 vo리스트
        aiResult.put("aiContent", analysis.summary); //대화 요약
        
		return aiResult;
	}
	
	
	/**
	 * 대화 분석 메소드
	 * @param userPrompt web speech api 인식 결과
	 * @return userPrompt 증상요약 및 검색키워드 추출 (예시: summary="무릎 통증", keywords=["무릎", "슬관절"])
	 */
	private AnalysisResult analyzeDialogue(String userPrompt) {
		//
        String prompt = """
            당신은 병원의 숙련된 의료 서기입니다. 
            아래 [대화 내용]을 분석하여 다음 두 가지 정보를 JSON 형식으로 추출하세요.
            
            1. summary: 환자의 주호소(Chief Complaint)와 증상을 의학적으로 간결하게 요약한 문장.
            2. keywords: 데이터베이스 검색을 위해 필요한 '핵심 증상 명사' 및 '신체 부위' 리스트 (동의어 포함, 3~5개).
            
            [대화 내용]
            %s
            """.formatted(userPrompt);

        // .entity(AnalysisResult.class)를 쓰면 AI가 알아서 JSON을 파싱해서 자바 객체 보낸다.
        return chatClient.prompt()
                .user(prompt)
                .call()
                .entity(AnalysisResult.class);
    }
	
	/**
	 * 상병 매칭 메소드
	 * @param summary web speech api 인식 결과 요약
	 * @param diagnosisList db에서 추출해온 상병 
	 * @return 매칭된 최종 상병 진단 리스트
	 */
    private List<aifunVO> selectBestDisease(String summary, List<aifunVO> diagnosisList) {
        // aifunVO 리스트를 문자열로 변환 (AI가 읽기 좋게)
        String diagnosisStr = diagnosisList.stream()
                .map(vo -> String.format("- CODE: %s, NAME: %s", vo.getDiagnosisCode(), vo.getDiagnosisName()))
                .collect(Collectors.joining("\n"));

        String prompt = """
                [환자 증상] %s
                [상병 후보군]
                %s
                
               위 후보군 중 증상과 가장 일치하는 상병의 'CODE'를 1개 또는 2개 선택해.
	            반드시 쉼표(,)로 구분해서 코드만 출력해. (예: M17.1, S80)
	            적절한 게 없으면 NONE 출력.
                """.formatted(summary, diagnosisStr);
        
        String result = chatClient.prompt().user(prompt).call().content().trim();
        
        if("NONE".equalsIgnoreCase(result)) {            
            return List.of(diagnosisList.get(0));
        }        
        
        List<String> codes = Arrays.stream(result.split(","))
                .map(String::trim) 
                .toList();
        return diagnosisList.stream()
                .filter(vo -> codes.contains(vo.getDiagnosisCode()))
                .limit(2) //최대 리스트갯수 설정
                .collect(Collectors.toList());
    }
	/**
	 * 상병명을 통해 약물 성분 추출 메소드
	 * @param diagnosisName 상병명 
	 * @return 약품 성분명
	 */
    private List<String> extractIngredients(String diagnosisName) {
        String prompt = """
            진단명: %s
            
            위 질환을 치료하기 위해 임상적으로 가장 널리 쓰이는 약물의 '주성분 한글명(Generic Name)'을 2~3개만 나열해주세요.
            (예: 록소프로펜, 아세트아미노펜, 가바펜틴 등)
            제품명(Brand Name)이 아닌 성분명이어야 합니다.
            
            결과를 JSON String List로 반환하세요. 예: ["성분1", "성분2"]
            """.formatted(diagnosisName);
        
        return chatClient.prompt()
                .user(prompt)
                .call()
                .entity(new ParameterizedTypeReference<List<String>>() {});
    }
    
    /**
     * 약품 매칭 메소드
     * @param summary 
     * @param age 환자나이
     * @param gender 환자 성별
     * @param drugList db에서 추출해온 약품 
	 * @return 매칭된 최종 약품 진단 리스트
     */
    private List<aifunVO> selectBestDrugs(String summary, String age, String gender, List<aifunVO> drugList) {
        // 약품 리스트 문자열 변환
        String drugListStr = drugList.stream()
                .map(vo -> String.format("- CODE: %s, NAME: %s, SPEC: %s", vo.getDrugCode(), vo.getDrugName(), vo.getDrugSpec()))
                .collect(Collectors.joining("\n"));

        String prompt = """
                환자 정보: %s세 %s
                증상: %s
                
                [약품 후보군]
                %s
                
                위 후보군 중 환자에게 가장 적절한 약품 2~3개를 골라 'CODE'만 쉼표(,)로 구분해 출력해.
                같은 종류의 약은 중복되면 안돼
                """.formatted(age, gender, summary, drugListStr);

        String result = chatClient.prompt().user(prompt).call().content(); // 예: "D001, D050"
        
        // AI가 준 코드들로 필터링해서 리스트 만들기
        List<String> pickedCodes = Arrays.asList(result.split(","));
        
        return drugList.stream()
                .filter(vo -> pickedCodes.stream().anyMatch(c -> c.trim().equals(vo.getDrugCode())))
                .collect(Collectors.toList());
    }

	//분석결과 기록용 class
	 public record AnalysisResult(String summary, List<String> keywords) {}
	 
	 
	
	 @Transactional
	 @Override
	 public void aiInsert(aiVO aiVO) {
		mapper.aiInsert(aiVO);
		// 생성된 PK 가져오기
		int aiNo = aiVO.getAiNo();
		
		if (aiVO.getAiDiagnosis() != null) {
            for (AiDiagnosisVO diag : aiVO.getAiDiagnosis()) {
                diag.setAiNo(aiNo); // 부모 키(FK) 주입
                mapper.insertAiDiagnosis(diag);
            }
        }
		
		if (aiVO.getAiDrug() != null) {
            for (AiDrugVO drug : aiVO.getAiDrug()) {
                drug.setAiNo(aiNo); //부모 키(FK) 주입
                mapper.insertAiDrug(drug);
            }
        }
	
		
	 }

	 
	 @Override
	 public ArrayList<aiVO> aiSelect(String ptNo) {
		 ArrayList<aiVO> aiList = new ArrayList<>();
		 aiList=mapper.aiSelect(ptNo);
		return aiList;
	 }

}
