package kr.or.ddit.cpr.reservation.service;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.billing.mapper.IReceptionMapper;
import kr.or.ddit.cpr.reservation.mapper.IReservationMapper;
import kr.or.ddit.cpr.schedule.mapper.IScheduleMapper;
import kr.or.ddit.cpr.vo.AiDiagnosisVO;
import kr.or.ddit.cpr.vo.OpScheduleVO;
import kr.or.ddit.cpr.vo.PatientVO;
import kr.or.ddit.cpr.vo.ScheduleVO;
import lombok.extern.slf4j.Slf4j;
@Slf4j
@Service
public class ReservatiopnServiceImpl implements IReservationService{
	@Autowired
	private IReservationMapper mapper;	//예약관련
	@Autowired
	private IReceptionMapper rmapper;//환자관련
	
	@Transactional
	@Override
	public int reservationInsert(ScheduleVO scheduleVO) {		
		
		String scheduleType = scheduleVO.getScheduleType();
		String rawName = scheduleVO.getPatientName();
		String realName = rawName; // 기본값
		String scheduleTitle="";
		String scheduleContent = "";
		String backgroundColor = "";
		int result = 0;	
		// 괄호 '(' 가 있는지 확인하고 자르기
		if(rawName != null && rawName.contains("(")) {
		// 0번째부터 '(' 가 나오는 인덱스 전까지 자르고, 앞뒤 공백 제거(.trim)
		realName = rawName.substring(0, rawName.indexOf("(")).trim();
		}
		
		if("002".equals(scheduleType)) {	//진료예약	
			scheduleTitle = realName + " (외래)";													//제목
			scheduleContent = realName + " 환자 외래 예약 \n" + 									//내용
					"예약 시작 시간"+scheduleVO.getScheduleStart() +"\n" +
		            "예약 담당자: " + scheduleVO.getEmployeeName();		
			backgroundColor = "#AED6CF";														//일정색
		}else{	//입원예약
			scheduleTitle = realName + " (입원)";													//제목
			scheduleContent = realName + " 환자 입원 예약 \n" + 									//내용
		            "예약 시작 시간"+scheduleVO.getScheduleStart()+ "\n" +
		            "예약 담당자: " + scheduleVO.getEmployeeName();
			backgroundColor = "#F6F0D7";
		}
		
		scheduleVO.setBackgroundColor(backgroundColor);
		scheduleVO.setScheduleContent(scheduleContent);
		scheduleVO.setScheduleTitle(scheduleTitle);
		result = mapper.reservationInsert(scheduleVO);
		log.info("서비스vo:{}",scheduleVO);
		//예약 인서트 완료 후
		if(result >0) {
			String patientMemo = scheduleVO.getMemo();
			int patientNo = scheduleVO.getPatientNo();
			PatientVO patient = new PatientVO();
			patient.setPatientNo(patientNo);
			patient.setPatientMemo(patientMemo);
			rmapper.updatePatientMemo(patient);													//환자메모 업데이트
		}
		
		return result;
	}
	@Transactional
	@Override
	public int opReservationInsert(ScheduleVO schedulevo) {		
		if (schedulevo.getEmployeeNo() == 0 && schedulevo.getScheduleDoctorNo() != 0) {
	        schedulevo.setEmployeeNo(schedulevo.getScheduleDoctorNo());
	    }
		
		String scheduleTitle = schedulevo.getPatientName() + " (수술)";							//제목
		String scheduleContent = schedulevo.getPatientName() + " 환자" + 
									schedulevo.getOpSchedules().get(0).getOpScheduleContent()+" 수술 예약 \n" + 				//내용
									schedulevo.getScheduleStart() +"\n"+
									"예약 담당자: " + schedulevo.getEmployeeName();		
		String backgroundColor = "#C7D9DD";														//일정색

		schedulevo.setBackgroundColor(backgroundColor);
		schedulevo.setScheduleContent(scheduleContent);
		schedulevo.setScheduleTitle(scheduleTitle);
		int result = mapper.reservationInsert(schedulevo);
		
		List<OpScheduleVO> opList = schedulevo.getOpSchedules();		
		
		if (result > 0 && opList != null && !opList.isEmpty()) {
	        int scheduleNo = schedulevo.getScheduleNo(); // 방금 생성된 PK 가져오기	       

	        for (OpScheduleVO op : opList) {
	            // 부모 PK(일정번호) 세팅
	            op.setScheduleNo(scheduleNo);            
	           
	            // 수술 상세 테이블 INSERT
	            mapper.opReservationInsert(op);
	        }
	    }
	
		if(result >0) {
			String patientMemo = schedulevo.getMemo();
			int patientNo = schedulevo.getPatientNo();
			PatientVO patient = new PatientVO();
			patient.setPatientNo(patientNo);
			patient.setPatientMemo(patientMemo);
			rmapper.updatePatientMemo(patient);			
		}
		return result;
	}

	@Override
	public List<Integer> selectBusyDoctor(ScheduleVO scheduleVO) {		
		
	    Map<String, Object> paramMap = new HashMap<>();	    
	    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");	   
	    if (scheduleVO.getScheduleStart() != null) {
	        String startStr = scheduleVO.getScheduleStart().format(formatter);
	        paramMap.put("scheduleStart", startStr);
	    }	    
	    if (scheduleVO.getScheduleEnd() != null) {
	        String endStr = scheduleVO.getScheduleEnd().format(formatter);
	        paramMap.put("scheduleEnd", endStr);
	    }
	    return mapper.selectBusyDoctor(paramMap);
	}

	@Override
	public List<ScheduleVO> scheduleList() {
		List<ScheduleVO> scheduleList = mapper.scheduleList();
		return scheduleList;
	}

	

}
