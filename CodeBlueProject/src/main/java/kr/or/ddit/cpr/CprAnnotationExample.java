package kr.or.ddit.cpr;

/**
 * <p>[클래스 설명]</p>
 * 
 * <pre>
 * 1. 환자 도메인의 핵심 로직을 담당
 * 2. 주요 기능: 환자 등록, 수정, 조회
 * 3. 주의사항: 삭제는 논리 삭제(Update)로 처리
 * </pre>
 * 
 * @author 담당자
 *
 */

public class CprAnnotationExample {
	
	/**
	 * <p>메소드 주석 예시</p>
	 * 
	 * @param patientVO 입력받은 환자 정보
	 * @return 등록 성공 시 1, 실패 시 0
	 * @throws 던져버려~
	 */
	public int insertPatient(/*PatientVO patientVO*/) throws Exception {
		// 필드 내부는 라인 주석으로~
		return 0;
	}
}