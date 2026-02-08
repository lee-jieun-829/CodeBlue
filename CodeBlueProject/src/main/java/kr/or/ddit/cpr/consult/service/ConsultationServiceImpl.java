package kr.or.ddit.cpr.consult.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.consult.mapper.IConsultationMapper;
import kr.or.ddit.cpr.notification.service.INotificationService;
import kr.or.ddit.cpr.vo.AlertVO;
import kr.or.ddit.cpr.vo.ConsultationVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.PatientVO;

@Service
public class ConsultationServiceImpl implements IConsultationService {

	@Autowired
	private IConsultationMapper consultationMapper;
	
	@Autowired
	private INotificationService notificationService;
	
	@Override
	public List<ConsultationVO> selectReqConsultPatient(int employeeNo,Integer patientNo) {
		return consultationMapper.selectReqConsultPatient(employeeNo, patientNo);
	}

	@Override
	public ConsultationVO selectConsultationDetail(int consultationNo) {
		return consultationMapper.selectConsultationDetail(consultationNo);
	}
	
	@Override
	public List<ConsultationVO> searchPatient(String keyword) {
		return consultationMapper.searchPatient(keyword);
	}
	
	@Override
	public List<EmployeeVO> selectDoctorList() {
		return consultationMapper.selectDoctorList();
	}

	@Transactional
	@Override
	public Map<String, Object> insertReqConsultation(ConsultationVO vo) {
		Map<String, Object> resultMap = new HashMap<>();
		
		int result = consultationMapper.insertReqConsultation(vo);
		
		if(result > 0) {
			AlertVO alert = new AlertVO();
			
			alert.setEmployeeNo(vo.getConsultationRespdoctor());
			
			alert.setAlertName("신규 협진 요청");
			alert.setAlertContent(vo.getReqDoctorName() + "원장님의 협진 요청이 있습니다.");
			alert.setAlertType("005");
			alert.setAlertUrl("/consultation/main");
			alert.setAlertUrgent("N");
			
			notificationService.insertNotification(alert);
			
            resultMap.put("status", "success");
            resultMap.put("message", "등록 성공");
        } else {
            resultMap.put("status", "fail");
        }
		
		return resultMap;
	}

	@Transactional
	@Override
	public Map<String, Object> updateRespConsultation(ConsultationVO vo) {
		Map<String, Object> resultMap = new HashMap<>();
		
		int result = consultationMapper.updateRespConsultation(vo);
		
		if(result > 0) {
			AlertVO alert = new AlertVO();
			
			alert.setEmployeeNo(vo.getConsultationReqdoctor());
			
			alert.setAlertName("협진 회신");
			alert.setAlertContent(vo.getRespDoctorName() + "원장님의 협진 회신이 있습니다.");
			alert.setAlertType("005");
			alert.setAlertUrl("/consultation/main");
			alert.setAlertUrgent("N");
			
			notificationService.insertNotification(alert);
			
            resultMap.put("status", "success");
            resultMap.put("message", "등록 성공");
        } else {
            resultMap.put("status", "fail");
        }
		
		return resultMap;
	}

	@Transactional
	@Override
	public Map<String, Object> updateRejectConsultation(ConsultationVO vo) {
		Map<String, Object> resultMap = new HashMap<>();
		
		int result = consultationMapper.updateRejectConsultation(vo);
		
		if(result > 0) {
			AlertVO alert = new AlertVO(); 
			
			alert.setEmployeeNo(vo.getConsultationReqdoctor());
			
			alert.setAlertName("협진 거절");
			alert.setAlertContent(vo.getRespDoctorName() + "원장님의 협진 거절이 있습니다.");
			alert.setAlertType("005");
			alert.setAlertUrl("/consultation/main");
			alert.setAlertUrgent("N");
			
			notificationService.insertNotification(alert);
            resultMap.put("status", "success");
            resultMap.put("message", "등록 성공");
        } else {
            resultMap.put("status", "fail");
        }
		
		return resultMap;
	}

	@Override
	public ConsultationVO selectChartDetail(int chartNo) {
		return consultationMapper.selectChartDetail(chartNo);
	}


}
