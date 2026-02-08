package kr.or.ddit.cpr.master.diagnosis.util;

import java.net.URI;
import java.util.ArrayList;
import java.util.List;

import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import kr.or.ddit.cpr.master.diagnosis.vo.DiagnosisVO;
/**
 * 질병목록 ( 상병코드 ) 조회를 위한 유틸 클래스
 */
public class DiagnosisApiUtil {
	
	// 요청 URL 엔드포인트
	private static final String API_URL = "https://apis.data.go.kr/B551182/diseaseInfoService1/getDissNameCodeList1";
	
	// 소중한 내 서비스 키
	private static final String SERVICE_KEY = "849b0fa75e9f32ab04b5987a43be6d2cfa8aac75c69522c0ea79324b37e98062";
	
	private static final ObjectMapper objectMapper = new ObjectMapper();
	/**
	 * @author 장우석
	 * @param pageNo 페이지 번호
	 * @param numOfRows 한 페이지에 출력될 질병목록
	 * @return List<DiagnosisVO> 질병목록 리스트
	 * 페이지 번호와 출력할 번호를 입력하여 질병목록을 리스트 형식으로 반환하는 메서드
	 */
	@SuppressWarnings("deprecation")
	public static List<DiagnosisVO> getDiagnosisList(int pageNo, int numOfRows) {
		// 반환 할 리스트
		List<DiagnosisVO> list = new ArrayList<>();
		
		
		
		try {
			// 요청 URL 생성
			URI uri = UriComponentsBuilder.fromHttpUrl(API_URL)
					.queryParam("serviceKey", SERVICE_KEY)
					.queryParam("pageNo", pageNo)
					.queryParam("numOfRows", numOfRows)
					.queryParam("sickType", "2") // 상병코드
					.queryParam("medTp", "1")  // 
					.build()
					.toUri();
			
			System.out.println(uri.toString());
			// API 호출
			RestTemplate restTemplate = new RestTemplate();
			String jsonString = restTemplate.getForObject(uri, String.class);
			
			JsonNode root = objectMapper.readTree(jsonString);
			// 확인용 
			System.out.println("=-=-=-==-=-성공=-=-=-=-=-=-=-=-=-");
			System.out.println(jsonString);
			System.out.println("=-=-=-==-=-=-=-=-=-=-=-=-=-=-");
			
			JsonNode itemsNode = root.path("response").path("body").path("items").path("item");
            
			
			
         // 5. 데이터 추출
			if (itemsNode.isArray()) {
                for (JsonNode node : itemsNode) {
                    DiagnosisVO vo = new DiagnosisVO();
                    
                    // 상병코드 먼저 꺼내기
                    String code = node.path("sickCd").asText();

                    // 3단 상병코드 스킵
                    if (code.length() == 3) {
                        continue; 
                    }
                    
                    // JsonNode에서 값 꺼내서 VO에 담기
                    // .path("필드명").asText() : 값이 없으면 null 대신 빈 문자열 반환 (안전함)
                    vo.setDiagnosisCode(code);
                    vo.setDiagnosisName(node.path("sickNm").asText());
                    
                    list.add(vo);
                }
            }			
		} catch (Exception e) {
			System.err.println("💥 API 호출 중 에러 발생!");
	        System.err.println("에러 메시지: " + e.getMessage());
	        e.printStackTrace(); // 스택 트레이스 전체 출력
		}
		return list;
	}
	
    
    /**
     * @author 장우석
     * @return 카운트 수
     * 
     * 총 데이터 개수(totalCount)만 먼저 가져오는 함수
     */
    @SuppressWarnings("deprecation")
	public static int getTotalCount() {
        try {
            URI uri = UriComponentsBuilder.fromHttpUrl(API_URL)
                    .queryParam("serviceKey", SERVICE_KEY)
                    .queryParam("pageNo", 1)
                    .queryParam("numOfRows", 1) // 1개만 요청해서 헤더 정보만 봄
                    .queryParam("sickType", "2")
                    .queryParam("medTp", "1")
                    .build().toUri();

            RestTemplate restTemplate = new RestTemplate();
            String jsonString = restTemplate.getForObject(uri, String.class);
            
            JsonNode root = objectMapper.readTree(jsonString);
            
            return root.path("response").path("body").path("totalCount").asInt(0);
            
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0; // 실패 시 0 리턴
    }
    
}
