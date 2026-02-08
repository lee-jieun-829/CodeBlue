package kr.or.ddit.cpr.macro.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.macro.mapper.IMacroMapper;
import kr.or.ddit.cpr.vo.DiagnosisVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.MacroVO;
import kr.or.ddit.cpr.vo.TreatmentVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class MacroServiceImpl implements IMacroService {

	@Autowired
	private IMacroMapper macroMapper;

	@Override
	public List<MacroVO> retrieveMacroList(int employeeNo) {
		return macroMapper.selectMacroList(employeeNo);
	}

	@Override
	public MacroVO retrieveMacro(int macroNo) {
		return macroMapper.selectMacro(macroNo);
	}
	
	@Override
	public List<MacroVO> retrieveNurseMacroList(Map<String, Object> map) {
	    return macroMapper.selectNurseMacroList(map);
	}

	@Override
	public int createMacro(MacroVO macroVO) {
		
		// 1. macroYn 값 확인 (Null 방지, 기본값 'N' 설정)
		String macroYn = macroVO.getMacroYn();
		if (macroYn == null || macroYn.isEmpty()) {
			macroYn = "N"; 
			macroVO.setMacroYn("N"); // VO에도 확실히 세팅
		}

		// 2. '개인(N)' 매크로인 경우에만 개수 제한(3개) 체크
		if ("N".equals(macroYn)) {
			// 현재 사원의 매크로 전체 목록 조회 (이때 DB에서 MACRO_YN 값을 가져와야 함)
			List<MacroVO> myMacros = macroMapper.selectMacroList(macroVO.getEmployeeNo());
			
			long privateCount = 0;
			if (myMacros != null) {
				// 내 것 중에서 macroYn이 'N'인 것만 카운트
				privateCount = myMacros.stream()
					.filter(m -> "N".equals(m.getMacroYn())) 
					.count();
			}

			// 3. 이미 3개 이상이면 예외 발생 (Controller에서 400 에러로 처리됨)
			if (privateCount >= 3) {
				throw new RuntimeException("개인 매크로는 최대 3개까지만 생성할 수 있습니다.");
			}
		}
		log.info("▶▶▶ 매크로 등록 시작: {}", macroVO.getMacroName());
		
		// 1. 매크로 기본 정보 저장
		int result = macroMapper.insertMacro(macroVO);
		int newMacroNo = macroVO.getMacroNo();

		// 2. 상세 내역 저장 (의사 전용: 상병, 약제, 치료)
		// (1) 상병 (DIAGNOSIS)
		if (macroVO.getDiagnosisList() != null) {
			for (DiagnosisVO item : macroVO.getDiagnosisList()) {
				String name = item.getDiagnosisName(); 
				String code = item.getDiagnosisCode();
				
				if (name == null || name.isEmpty()) name = code;
				if (name == null || name.isEmpty()) name = "상병명없음";
				
				insertDetail(newMacroNo, "DIAGNOSIS", name); 
			}
		}

		// (2) 약품 (DRUG)
		if (macroVO.getDrugList() != null) {
			for (DrugVO item : macroVO.getDrugList()) {
				String name = item.getDrugName(); 
				String code = item.getDrugCode();
				
				if (name == null || name.isEmpty()) name = code;
				if (name == null || name.isEmpty()) name = "약품명없음";
				
				insertDetail(newMacroNo, "DRUG", name);
			}
		}

		// (3) 처치 (TREATMENT)
		if (macroVO.getTreatmentList() != null) {
			for (TreatmentVO item : macroVO.getTreatmentList()) {
				String name = item.getTreatmentName(); 
				String code = item.getTreatmentCode();
				
				if (name == null || name.isEmpty()) name = code;
				if (name == null || name.isEmpty()) name = "처치명없음";
				
				insertDetail(newMacroNo, "TREATMENT", name);
			}
		}

		return result;
	}
	
	@Override
	@Transactional
	public void modifyMacro(Map<String, Object> paramMap) {
		int macroNo = Integer.parseInt(String.valueOf(paramMap.get("macroNo")));
		
		MacroVO macroVO = new MacroVO();
		macroVO.setMacroNo(macroNo);
		macroVO.setMacroName((String) paramMap.get("macroName"));
		macroVO.setMacroType((String) paramMap.get("macroType"));
		macroVO.setMacroContent((String) paramMap.get("macroContent"));
		
		macroMapper.updateMacro(macroVO);
		macroMapper.deleteMacroDetail(macroNo);

		// 수정 시에도 동일하게 처리
		insertDetailsFromMapList(paramMap.get("diagnosisList"), macroNo, "DIAGNOSIS", "diagnosisName");
		insertDetailsFromMapList(paramMap.get("drugList"), macroNo, "DRUG", "drugName");
		insertDetailsFromMapList(paramMap.get("treatmentList"), macroNo, "TREATMENT", "treatmentName");
	}

	@Override
	public int removeMacro(int macroNo) {
		macroMapper.deleteMacroDetail(macroNo);
		return macroMapper.deleteMacro(macroNo);
	}

	// --- [Helper Methods] ---
	
	private void insertDetail(int macroNo, String type, String value) {
		Map<String, Object> map = new HashMap<>();
		map.put("macroNo", macroNo);
		map.put("type", type);
		
		// 최종 확인: 값이 진짜 없으면 경고 출력 후 저장
		if (value == null) {
		    log.error("!!! 경고: {} 타입의 저장 값이 NULL 입니다 !!!", type);
		    value = ""; 
		}
		
		// Mapper의 #{code}에 들어갈 값을 'value(이름)'로 설정
		map.put("code", value); 
		
		macroMapper.insertMacroDetail(map);
	}

	private void insertDetailsFromMapList(Object listObj, int macroNo, String type, String keyName) {
		if (listObj != null) {
			List<Map<String, Object>> list = (List<Map<String, Object>>) listObj;
			for (Map<String, Object> itemMap : list) {
				Object val = itemMap.get(keyName);
				String strVal = (val != null) ? String.valueOf(val) : "";
				
				// 수정 시에도 값이 비어있으면 대체 텍스트 처리 (선택사항)
				if(strVal.isEmpty()) strVal = "수정값없음";
				
				insertDetail(macroNo, type, strVal);
			}
		}
	}
	
	// --- 검색 메서드 ---
	@Override public List<DiagnosisVO> retrieveDiagnosisList(String keyword) { return macroMapper.selectDiagnosisList(keyword); }
	@Override public List<DrugVO> retrieveDrugList(String keyword) { return macroMapper.selectDrugList(keyword); }
	@Override public List<TreatmentVO> retrieveTreatmentList(String keyword) { return macroMapper.selectTreatmentList(keyword); }
}