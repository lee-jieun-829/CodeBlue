package kr.or.ddit.cpr.inpatient.service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.inpatient.mapper.IInpatientMapper;
import kr.or.ddit.cpr.notification.service.INotificationService;
import kr.or.ddit.cpr.vo.AlertVO;
import kr.or.ddit.cpr.vo.ClinicalDetailVO;
import kr.or.ddit.cpr.vo.DietVO;
import kr.or.ddit.cpr.vo.DrugVO;
import kr.or.ddit.cpr.vo.InpatientVO;
import kr.or.ddit.cpr.vo.OperationVO;
import kr.or.ddit.cpr.vo.OrderListVO;
import kr.or.ddit.cpr.vo.OrderSearchVO;
import kr.or.ddit.cpr.vo.PredetailVO;
import kr.or.ddit.cpr.vo.ProgressNoteVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class InpatientServiceImpl implements IInpatientService {
	
	@Autowired
	private IInpatientMapper inpatientMapper;
	
	@Autowired
    private INotificationService notificationService;

	@Override
	public List<InpatientVO> selectInpatientList(Map<String, Object> dataMap) {
		return inpatientMapper.selectInpatientList(dataMap);
	}

	@Override
	public ClinicalDetailVO selectClinicalDetail(Long patientNo) {
		return inpatientMapper.selectClinicalDetail(patientNo);
	}

	@Override
	public OrderListVO selectOrderList(Long patientNo) {
		return inpatientMapper.selectOrderList(patientNo);
	}

	@Override
	public List<OrderSearchVO> searchOrder(String category, String keyword) {
		return inpatientMapper.searchOrder(category, keyword);
	}

	@Transactional
	@Override
	public Map<String, Object> insertProgressNote(ProgressNoteVO noteVO) {
		Map<String, Object> resultMap = new HashMap<>();
	    
	    int result = inpatientMapper.insertProgressNote(noteVO);
	    
	    if (result > 0) {
	        resultMap.put("status", "success");
	        resultMap.put("message", "경과기록이 성공적으로 등록되었습니다.");
	    } else {
	        resultMap.put("status", "fail");
	        resultMap.put("message", "등록 중 오류가 발생했습니다.");
	    }
	    
	    return resultMap;
	}

	@Transactional
	@Override
	public Map<String, Object> insertPrescription(List<PredetailVO> predetailList) {
		Map<String, Object> result = new HashMap<>();
		try {
			for (PredetailVO predetail : predetailList) {
				savePrescription(predetail); 
			}
			result.put("status", "success");
		} catch (Exception e) {
			log.error("처방 저장 중 에러: ", e);
			throw new RuntimeException("저장 실패");
		}
		return result;
	}

	@Transactional
	@Override
	public Map<String, Object> updatePrescription(List<Map<String, Object>> updateList) {
	    Map<String, Object> result = new HashMap<>();
	    try {
	    	
	    	AlertVO alert = new AlertVO();
	        alert.setAlertUrgent("Y");
	        alert.setAlertUrl("/nurse/inpatientnurse");
	    	
	        for (Map<String, Object> map : updateList) {
	        	String actionType = (String) map.get("actionType");
	        	String category = (String) map.get("categoryCode");
	            
	            if ("CONFIRM".equals(actionType)) {
	                inpatientMapper.updatePreOperationStatus(map); 
	            }else {
	                inpatientMapper.updatePreStatusDC(map);
	            }
	        }

	        Map<String, List<Map<String, Object>>> groupedChanges = new HashMap<>();
	        
	        for (Map<String, Object> map : updateList) {
	            if ("CHANGE".equals(map.get("actionType"))) {
	                String category = map.get("categoryCode").toString();
	                groupedChanges.computeIfAbsent(category, k -> new ArrayList<>()).add(map);
	            }
	        }

	        for (String category : groupedChanges.keySet()) {
	            List<Map<String, Object>> items = groupedChanges.get(category);
	            if (items.isEmpty()) continue;

	            PredetailVO newPre = new PredetailVO();
	            newPre.setPredetailType(category);
	            newPre.setChartNo((int) Long.parseLong(items.get(0).get("chartNo").toString()));
	            newPre.setEmployeeNo(Integer.parseInt(items.get(0).get("employeeNo").toString()));
	            
	            alert.setAlertName("처방 정보 변경");
	            alert.setAlertContent("정규 처방 내용이 변경되었습니다. 새로운 오더를 확인하세요.");
	            alert.setAlertUrl("/nurse/inpatientnurse");
	            alert.setEmployeeCode("3");
	            alert.setAlertType("001");

	            inpatientMapper.insertPreDetail(newPre); 
	            long newNo = newPre.getPredetailNo();

	            for (Map<String, Object> item : items) {
	                if ("001".equals(category)) { 
	                    DrugVO drug = new DrugVO();
	                    drug.setPredetailNo(newNo);
	                    drug.setDrugNo(Long.parseLong(item.get("itemNo").toString()));
	                    drug.setPredrugDetailDose(Long.parseLong(item.get("dose").toString()));
	                    drug.setPredrugDetailFreq(Long.parseLong(item.get("freq").toString()));
	                    drug.setPredrugDetailDay(Long.parseLong(item.get("days").toString()));
	                    drug.setPredrugDetailMethod("PO");
	                    inpatientMapper.insertPreDrug(drug);
	                    
	                    alert.setEmployeeCode("4"); 
	                    notificationService.insertManyNotifications(alert);
	                } 
	                else if ("004".equals(category)) { 
	                    DietVO diet = new DietVO();
	                    diet.setPredetailNo(newNo);
	                    diet.setDietNo(Long.parseLong(item.get("itemNo").toString()));
	                    diet.setPredietDose(Long.parseLong(item.get("dose").toString()));
	                    diet.setPredietFreq(Long.parseLong(item.get("freq").toString()));
	                    diet.setPredietDay(Long.parseLong(item.get("days").toString()));
	                    inpatientMapper.insertPreDiet(diet);
	                    
	                    alert.setEmployeeCode("3"); 
	                    notificationService.insertManyNotifications(alert);
	                }
	            }
	        }
	        result.put("status", "success");
	    } catch (Exception e) {
	        log.error("정규 처방 변경 중 에러: ", e);
	        throw new RuntimeException("변경 처리 중 오류 발생");
	    }
	    return result;
	}

	private void savePrescription(PredetailVO predetail) {
	    String type = predetail.getPredetailType();
	    
	    AlertVO alert = new AlertVO();
	    alert.setAlertUrgent("N"); 

	    if ("005".equals(type) && predetail.getOperList() != null) {
	        for (OperationVO o : predetail.getOperList()) {
	            if (o.getPredetailNo() != 0) {
	                Map<String, Object> param = new HashMap<>();
	                param.put("predetailNo", o.getPredetailNo());
	                param.put("operationNo", o.getOperationNo());
	                param.put("employeeNo", predetail.getEmployeeNo());
	                inpatientMapper.updatePreOperationStatus(param);
	            } 
	            else {
	                inpatientMapper.insertPreDetail(predetail); 
	                o.setPredetailNo((long) predetail.getPredetailNo());
	                inpatientMapper.insertPreOperation(o);
	            }
	        }
	    } 
	    else {
	        inpatientMapper.insertPreDetail(predetail); 
	        long newNo = predetail.getPredetailNo();

	        if ("001".equals(type) && predetail.getDrugList() != null) {
	            predetail.getDrugList().forEach(d -> { d.setPredetailNo(newNo); inpatientMapper.insertPreDrug(d); });
	            
	            alert.setEmployeeCode("4"); 
	            alert.setAlertName("신규 약/주사 처방");
	            alert.setAlertContent("병동 환자의 신규 약/주사 처방이 등록되었습니다.");
	            alert.setAlertUrl("/pharmacist/workview");
	            alert.setAlertType("004"); 
	            notificationService.insertManyNotifications(alert);

	        } else if ("002".equals(type) && predetail.getExamList() != null) {
	            predetail.getExamList().forEach(e -> { e.setPredetailNo(newNo); inpatientMapper.insertPreExamination(e); });
	            
	            alert.setEmployeeCode("5");
	            alert.setAlertName("검사 오더 알림");
	            alert.setAlertContent("신규 검사 처방이 발생했습니다.");
	            alert.setAlertUrl("/radiologist/workview");
	            alert.setAlertType("003"); 
	            notificationService.insertManyNotifications(alert);

	        } else if ("003".equals(type) && predetail.getTreatList() != null) {
	            predetail.getTreatList().forEach(t -> { t.setPredetailNo(newNo); inpatientMapper.insertPreTreatment(t); });
	            
	            alert.setEmployeeCode("6");
	            alert.setAlertName("치료 오더 알림");
	            alert.setAlertContent("재활/물리 치료 처방이 등록되었습니다.");
	            alert.setAlertUrl("/therapist/workview");
	            alert.setAlertType("002"); 
	            notificationService.insertManyNotifications(alert);

	        } else if ("004".equals(type) && predetail.getDietList() != null) {
	            predetail.getDietList().forEach(d -> { d.setPredetailNo(newNo); inpatientMapper.insertPreDiet(d); });
	            
	            alert.setEmployeeCode("3");
	            alert.setAlertName("식이 변경 알림");
	            alert.setAlertContent("환자의 식이 처방이 변경되었습니다.");
	            alert.setAlertType("001");
	            notificationService.insertManyNotifications(alert);
	        }
	    }
	}

	@Transactional
	@Override
	public Map<String, Object> updateDischarge(Map<String, Object> dischargeMap) {
		Map<String, Object> result = new HashMap<>();
		try {
			int updateResult = inpatientMapper.updateDischarge(dischargeMap);
			if(updateResult > 0) {
				
				AlertVO alert = new AlertVO();
	            alert.setEmployeeCode("3"); 
	            alert.setAlertName("퇴원 심사 요청");
	            alert.setAlertContent("새로운 퇴원 심사 요청건이 있습니다. 내역을 확인해 주세요.");
	            alert.setAlertType("001"); 
	            alert.setAlertUrl("/nurse/inpatient/main"); 
	            alert.setAlertUrgent("N");
	            
	            notificationService.insertManyNotifications(alert);
	            
				result.put("status", "success");
				result.put("message", "퇴원대기 상태로 변경되었습니다.");
			}else {
				result.put("status", "fail");
				result.put("message", "이미 처리되었거나 환자 정보를 찾을 수 없습니다.");
			}
		} catch (Exception e) {
			log.error("처방 저장 중 에러: ", e);
			throw new RuntimeException("저장 실패");
		}
		return result;
	}

	@Transactional
	@Override
	public int insertDiagnosisDetail(Map<String, Object> params) {
		return inpatientMapper.insertDiagnosisDetail(params);
	}


}
