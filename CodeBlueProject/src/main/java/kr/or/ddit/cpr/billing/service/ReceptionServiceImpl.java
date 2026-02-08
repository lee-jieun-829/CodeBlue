package kr.or.ddit.cpr.billing.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.billing.mapper.IReceptionMapper;
import kr.or.ddit.cpr.vo.AdmissionVO;
import kr.or.ddit.cpr.vo.BedVO;
import kr.or.ddit.cpr.vo.ChartVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.PatientVO;
import kr.or.ddit.cpr.vo.RegistrationVO;
import lombok.extern.slf4j.Slf4j;

/**
 * <p>원무 접수 및 등록 비즈니스 로직 구현 클래스</p>
 * @author 강지현
 */
@Slf4j
@Service
public class ReceptionServiceImpl implements IReceptionService {

	@Autowired
	private IReceptionMapper receptionMapper;
	
	// 웹소켓 메시지 전송 도구
	@Autowired
	private SimpMessagingTemplate messagingTemplate;
	
	/**
	 * <p>신규 환자 등록 및 외래 접수 등록과 차트 생성</p>
	 * @author 강지현
	 * @param patientVO 환자 정보 
	 * @return 처리 결과 상태, 생성된 차트 번호, 환자명 포함한 Map 객체
	 */
	@Transactional
	@Override
	public Map<String, Object> insertPatient(PatientVO patientVO) {
	
		//신규 환자 중복 체크 (성명 + 주민번호)
		int count = receptionMapper.selectPatientDuplicate(patientVO);
		
		if (count > 0) {
	        Map<String, Object> result = new HashMap<>();
	        result.put("status", "duplicate");
	        return result;
	    }
		
		// 신규 환자 등록
		receptionMapper.insertPatient(patientVO);
		
		// 환자 번호 RegistrationVO에 세팅
		RegistrationVO registrationVO = patientVO.getRegistrationVO();
		registrationVO.setPatientNo(patientVO.getPatientNo());
		
		// 외래 접수
		receptionMapper.insertRegistration(registrationVO);
		
		// 신규는 admissionNo에 0 전달
		Map<String, Object> result = saveChart(patientVO.getPatientNo(), registrationVO.getRegistrationNo(), 0, registrationVO.getEmployeeNo(), patientVO.getPatientName());

		if ("success".equals(result.get("status"))) {
            log.info("신규 환자 접수 완료: 리액트 대기열 갱신 신호 발송");
            messagingTemplate.convertAndSend("/topic/waitingList", "REFRESH"); 
        }

        return result;
	}

	
	/**
	 * <p>대기 중인 환자 목록 조회 로직 구현</p>
	 * @author 강지현
	 * @return mapper를 통해 조회된 대기 환자 리스트
	 */
	@Override
	public List<PatientVO> getWaitingList() {
		
		return receptionMapper.selectWaitingList();
	}


	/**
     * <p>외래 접수 환자 검색 로직</p>
     * @author 강지현
     * @param keyword 환자명 또는 번호
     * @return PatientVO
     */
	@Override
	public List<PatientVO> retrievePatientList(String keyword) {
		return receptionMapper.selectPatientList(keyword);
	}

	
	/**
     * <p>재진 환자 외래 접수 등록 및 차트 생성 및 환자 메모 업데이트</p>
     * @author 강지현
     * @param patientVO 접수 정보를 포함한 환자 객체 
     * @return 처리 결과 상태, 생성된 차트 번호, 환자명 포함한 Map 객체
     */
	@Transactional
	@Override
	public Map<String, Object> createOutpatientRegistration(PatientVO patientVO) {
		RegistrationVO regVO = patientVO.getRegistrationVO();
        
        // 전달받은 환자 번호를 접수 정보로 설정
        regVO.setPatientNo(patientVO.getPatientNo());
        
        // 신규환자 접수 쿼리를 호출하여 '재진'으로 저장함
        receptionMapper.insertRegistration(regVO);
        
        // 접수 시 입력한 환자 메모 환자 테이블에 저장
        if(patientVO.getPatientMemo() != null && !patientVO.getPatientMemo().trim().isEmpty()) {
            receptionMapper.updatePatientMemo(patientVO);
        }
        
	    // 외래는 admissionNo에 0 전달
	    Map<String, Object> result = saveChart(patientVO.getPatientNo(), regVO.getRegistrationNo(), 0, regVO.getEmployeeNo(), patientVO.getPatientName());
	
	    // 재진 접수 성공 시에도 신호 발송
	    if ("success".equals(result.get("status"))) {
	        log.info("재진 환자 접수 완료: 리액트 대기열 갱신 신호 발송");
	        messagingTemplate.convertAndSend("/topic/waitingList", "REFRESH");
	    }
	
	    return result;
	}

	/**
     * <p>입원 접수가 가능한 외래 환자를 검색한다.</p>
     * <pre>
     * - 의사의 진료가 완료되고 '입원 지시' 상태인 환자만 필터링한다.
     * - 검색된 환자의 최근 주치의와 진료실 정보를 함께 반환한다.
     * </pre>
     * @author 강지현
     * @param keyword 환자명 또는 번호
     * @return 입원 대상 환자 목록
     */
	@Override
	public List<PatientVO> searchInpatient(String keyword) {
		return receptionMapper.selectInpatientSearch(keyword);
	}

	/**
     * <p>입원 정보를 등록하고 배정된 침상을 사용 중으로 변경 및 차트 생성, 환자 메모 업데이트</p>
     * <pre>
     * 1. ADMISSION 테이블에 입원 기록 INSERT
     * 2. 성공 시, 해당 침상(BED)의 상태를 '사용중'으로 UPDATE
     * 3. 입원 번호와 환자 번호를 연동하여 입원 전용 차트 생성
     * </pre>
     * @author 강지현
     * @param admissionVO 입원 접수 정보
     * @return 처리 결과 상태, 생성된 차트 번호, '입원중' 표시명을 포함한 Map 객체
     */
	@Transactional
	@Override
	public Map<String, Object> registerAdmission(AdmissionVO admissionVO) {
		
		// 입원 등록
	    receptionMapper.insertAdmission(admissionVO);
	    
	    // 입원 접수 시 적은 환자 메모 저장
	    PatientVO patientVO = new PatientVO();
	    patientVO.setPatientNo(admissionVO.getPatientNo());
	    patientVO.setPatientMemo(admissionVO.getAdmissionMemo()); 
	    receptionMapper.updatePatientMemo(patientVO);
	    
        // 해당 침상의 상태를 '사용중'으로 변경
        receptionMapper.updateBedStatusOccupied(admissionVO.getBedNo());
        
        // 차트 생성 - 입원은 registrationNo에 0 전달
	    return saveChart(admissionVO.getPatientNo(), 0, admissionVO.getAdmissionNo(), admissionVO.getEmployeeNo(), admissionVO.getPatientName());
	}

	/**
	 * <p>공통 차트 데이터 생성 및 저장</p>
	 * <pre>
	 * - 외래 접수 시 : registrationNo 포함, admissionNo는 0
	 * - 입원 접수 시 : admissionNo 포함, registrationNo는 0
	 * </pre>
	 * @param pNo 환자번호
	 * @param rNo 외래접수번호(없으면 0)
	 * @param aNo 입원접수번호(없으면 0)
	 * @param eNo 담당의 사번
	 * @param pName 환자명
	 * @return 처리결과 및 생성퇸 차트번호가 담긴 Map
	 */
	private Map<String, Object> saveChart(int pNo, int rNo, int aNo, int eNo, String pName){
		ChartVO chartVO = new ChartVO();
		chartVO.setPatientNo(pNo);
		chartVO.setEmployeeNo(eNo);
		
		if(rNo != 0) chartVO.setRegistrationNo(rNo);
		if(aNo != 0) chartVO.setAdmissionNo(aNo);
		
		receptionMapper.insertChart(chartVO); // 차트 생성
		
		Map<String, Object> result = new HashMap<>();
		result.put("status", "success");
		result.put("chartNo", chartVO.getChartNo());
		result.put("patientName", pName);
		return result;
	}

	/**
	 * <p>병상 전체 목록 조회</p>
	 */
	@Override
	public List<BedVO> selectBedList() {
		return receptionMapper.selectBedList();
	}


	/**
	 * <p>접수 시 의사 조회</p>
	 */
	@Override
	public List<EmployeeVO> getDoctorList() {
		return receptionMapper.selectDoctorList();
	}
	
}
