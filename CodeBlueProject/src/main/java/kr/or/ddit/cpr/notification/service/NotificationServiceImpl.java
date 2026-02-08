package kr.or.ddit.cpr.notification.service;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;

import kr.or.ddit.cpr.notification.handler.NotificationWebSocketHandler;
import kr.or.ddit.cpr.notification.mapper.INotificationMapper;
import kr.or.ddit.cpr.vo.AlertVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class NotificationServiceImpl implements INotificationService {

	@Autowired
	private INotificationMapper mapper;
	
	// 알림 웹소켓
	@Autowired
	private NotificationWebSocketHandler handler;
	
	// 수신자별 안읽은 알림 조회
	@Override
	public List<AlertVO> selectNotificationList(int employeeNo) {
		
		return mapper.selectNotificationList(employeeNo);
	}

	// 알림 개별 읽음 처리
	@Override
	public void updateNotificationRead(int alertNo) {
		mapper.updateNotificationRead(alertNo);

	}

	// 전체 알림 일괄 읽음 처리
	@Override
	public void updateAllNotificationRead(int employeeNo) {
		mapper.updateAllNotificationRead(employeeNo);

	}

	// 새로운 알림 생성(알림 보낼 때 사용)
	@Override
	public void insertNotification(AlertVO alertVO) {
		// 발신자 본인은 알림을 생성하거나 쏘지 않음
		if(alertVO.getEmployeeNo() == alertVO.getSenderNo()) return;
		
		// DB에 알림 저장
		int result = mapper.insertNotification(alertVO);
		
		if(result > 0) {
			// 실시간 전송: 수신자 사번이 온라인이라면 즉시 메세지 보냄
			try {
				// ObjectMapper를 사용하여 alertVO 객체를 JSON 문자열로 변환
				ObjectMapper objectMapper = new ObjectMapper();
				String jsonMsg = objectMapper.writeValueAsString(alertVO);
				
				// 상세 정보 담긴 jsonMsg 보냄
				handler.sendNotification(alertVO.getEmployeeNo(), jsonMsg);
				log.info("[WebSocket] 대상: {}, 데이터: {}", alertVO.getEmployeeNo(), jsonMsg);
			}catch(Exception e) {
				log.error("[WebSocket] 웹소켓 메세지 변환 중 에러 발생", e);
				handler.sendNotification(alertVO.getEmployeeNo(), "NEW_ALARM");
			}
		}
	}

	// 전체 알림 발송
	@Override
	public void insertNotificationToAll(AlertVO alertVO) {
		try {
			
			// 실시간 전송 데이터에 현재 시간 세팅 (날짜 null 방지) 
	        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm");
	        alertVO.setAlertDate(sdf.format(new java.util.Date()));
			
			ObjectMapper objectMapper = new ObjectMapper();
			String jsonMsg = objectMapper.writeValueAsString(alertVO);
			
			handler.sendNotificationToAll(jsonMsg); // 핸들러에서 만든 전체 전송 메서드 호출(실시간 전송)
			log.info("[WebSocket Broadcast] 데이터: {}", jsonMsg);
			
			// 'RECEPTION_UPDATE'(대기 환자 목록)는 본인 포함 모두에게, 그 외 전체 알림은 본인 제외
			if("RECEPTION_UPDATE".equals(alertVO.getAlertType())) {
				// 대기 환자 목록은 나를 포함한 모두에게 전송
				handler.sendNotificationToAll(jsonMsg);
			}else {
				// 전체 알림은 나를 제외하고 전송
				handler.sendNotificationToAll(jsonMsg, alertVO.getSenderNo());
			}
			
			// 'RECEPTION_UPDATE'(대기 환자 목록) 제외한 전체 알림 디비 저장 로직
			if(!"RECEPTION_UPDATE".equals(alertVO.getAlertType())) {
				int result = mapper.insertNotificationToAll(alertVO);
				log.info("발신자(No:{})를 제외한 전체 알림 {}건 저장 완료", alertVO.getSenderNo(), result);
			}
			
		}catch(Exception e) {
			log.error("[WebSocket] 전체 알림 메세지 변환 중 에러 발생", e);
			
		}
		
	}

	// 다수 사용자에게 알림 생성
	@Transactional
	@Override
	public void insertManyNotifications(AlertVO alertVO) {
		Set<Integer> receivers = new HashSet<>(); // 중복 방지 위한 Set 사용
		
		// 여러 부서 코드가 들어온 경우(우선순위 1)
		if(alertVO.getDeptCodeList() != null && !alertVO.getDeptCodeList().isEmpty()) {
			for(String deptCode : alertVO.getDeptCodeList()) {
				List<Integer> deptEmps = mapper.selectEmpNoListByDept(deptCode);
				if(deptEmps != null) receivers.addAll(deptEmps);
			}
		}
		// 단일 부서 코드만 들어온 경우(우선순위 2)
		else if(alertVO.getEmployeeCode() != null && !alertVO.getEmployeeCode().isEmpty()){
			List<Integer> deptEmps = mapper.selectEmpNoListByDept(alertVO.getEmployeeCode());
			if(deptEmps != null) receivers.addAll(deptEmps);
		}
		// 사번 리스트가 직접 들어온 경우 (우선순위 3)
		else if(alertVO.getEmpNoList() != null && !alertVO.getEmpNoList().isEmpty()) {
			receivers.addAll(alertVO.getEmpNoList());
		}
		
		if(receivers == null || receivers.isEmpty()) return;

		ObjectMapper objectMapper = new ObjectMapper();
		
		// DB 저장 및 실시간 전송
		for (int receiverNo : receivers) {
			// 발신자 제외 알림 발송
			if(receiverNo == alertVO.getSenderNo()) continue;
			
	        // 각 수신자별로 사번 세팅 후 저장
	        alertVO.setEmployeeNo(receiverNo);
	        int result = mapper.insertNotification(alertVO); 
	        
	        // 실시간 웹소켓 전송
	        try {
                String jsonMsg = objectMapper.writeValueAsString(alertVO);
                handler.sendNotification(receiverNo, jsonMsg);
            } catch (Exception e) {
            	log.error("알림 전송 중 에러", e);
                handler.sendNotification(receiverNo, "NEW_ALARM");
            }
		}
		
		
	}

}