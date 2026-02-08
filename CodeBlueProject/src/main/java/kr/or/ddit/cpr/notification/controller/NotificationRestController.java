package kr.or.ddit.cpr.notification.controller;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.notification.service.INotificationService;
import kr.or.ddit.cpr.vo.AlertVO;
import lombok.extern.slf4j.Slf4j;

/**
 * <p> 알림 처리 비동기 컨트롤러</p>
 * @author 강지현
 */
@Slf4j
@RestController
@RequestMapping("/notification")
//@CrossOrigin(origins = "http://localhost:5173") // 리액트 서버 주소 허용
@CrossOrigin(originPatterns = "*") // 모든 도메인과 IP 허용
public class NotificationRestController {

	@Autowired
	private INotificationService service;
	
	/**
	 * 현재 로그인한 사용자의 읽지 않은 알림 목록 조회
	 * @param employeeVO 사용자 정보
	 * @return 수신자별 안 읽은 알림 리스트
	 */
	@GetMapping("/list")
	public List<AlertVO> notificationList(@AuthenticationPrincipal CustomEmployee customEmployee){
		
		if(customEmployee == null) {
			log.warn("인증된 사용자 정보가 없습니다.");
			return null;
		}
		
		// 사번 추출
		int employeeNo = customEmployee.getEmployee().getEmployeeNo();
		log.info("조회 요청 사번: {}", employeeNo);
		
		return service.selectNotificationList(employeeNo);
		
	}
	
	/**
	 * 특정 알림 항목에 대한 개별 읽음 처리(확인 버튼 클릭 시 호출)
	 * @param alertNo 처리할 알림의 고유 번호
	 * @return 성공 여부 메세지
	 */
	@PostMapping("/read")
	public String updateNotificationRead(@RequestParam int alertNo) {
		service.updateNotificationRead(alertNo);
		return "success";
	}
	
	/**
	 * 모든 안 읽은 알림에 대한 일괄 읽음 처리(모두 확인 클릭 시 호출)
	 * @param employeeVO 사용자 정보
	 * @return 성공 여부 메세지
	 */
	@PostMapping("/readAll")
	public String updateAllNotificationRead(@AuthenticationPrincipal CustomEmployee customEmployee) {
		if( customEmployee == null) return "fail";
		int employeeNo = customEmployee.getEmployee().getEmployeeNo();
		
		service.updateAllNotificationRead(employeeNo);
		return "success";
	} 
	
	/**
	 * 새로운 알림 생성(알림 보낼 때 사용)
	 * @param employeeVO 사용자 정보
	 * @return 성공 여부 메세지
	 */
	@PostMapping("/insert")
	public String insertNotification(@RequestBody AlertVO alertVO, @AuthenticationPrincipal CustomEmployee customEmployee) {

		log.info("알림 insert 요청 수신 - 대상 : {}, 발신자 정보: {}", alertVO.getEmployeeNo(), customEmployee);
		
		// 발신자 사번 세팅
		alertVO.setSenderNo(customEmployee.getEmployee().getEmployeeNo());
		
		// 로그인 여부 체크
		if(customEmployee == null || customEmployee.getEmployee() == null) {
			log.warn("인증되지 않은 사용자의 알림 생성 시도 차단");
			return "fail";
		}
		
		// 누가(sender) 누구에게(receiver) 보냈는지 확인
		int senderNo = customEmployee.getEmployee().getEmployeeNo();
		int receiverNo = alertVO.getEmployeeNo();
		
		log.info("[알림 발생] 발신자: {} -> 수신자: {}, 내용: {}", senderNo, receiverNo, alertVO.getAlertContent());
	
		try {
	        service.insertNotification(alertVO);
	        return "success";
	    } catch (Exception e) {
	        log.error("알림 저장 및 전송 중 오류 발생", e);
	        return "fail";
	    }
	}
	
	/**
	 * 전체 알림 전송
	 * @param alertVO 알림 정보 객체
	 * @param customEmployee 현재 로그인한 발신자 정보
	 * @return 성공 시 "success", 실패 시 "fail" 
	 */
	@PostMapping("/broadcast")
	public String broadcastNotification(@RequestBody AlertVO alertVO, @AuthenticationPrincipal CustomEmployee customEmployee) {
		// 발신자 사번 세팅
		alertVO.setSenderNo(customEmployee.getEmployee().getEmployeeNo());
		
		// 보안 체크(로그인 안한 사람은 전체 알림 못 보냄)
		if(customEmployee == null || customEmployee.getEmployee() == null) {
			log.warn("권한 없는 사용자의 전체 알림 시도");
			return "fail";
		}
		
		try {
			
			if(alertVO.getAlertName() == null || alertVO.getAlertName().isEmpty()) {
				alertVO.setAlertName("전체 공지"); // 기본값 설정
			}
			
			// 서비스 호출(웹소켓 핸들러 sendNotificationToAll 호출)
			service.insertNotificationToAll(alertVO);
			log.info("전체 알림 발송 성공 - 타입: {}, 발신자: {}", alertVO.getAlertType(), alertVO.getAlertName());
			return "success";
		}catch(Exception e) {
			log.error("전체 알림 발송 실패", e);
			return "fail";
		}
	}
	
	/**
	 * 다수 사용자에게 알림 생성
	 * @param alertVO 알림 정보 (empNoList 포함)
	 * @return 성공 여부
	 */
	@PostMapping("/insertMany")
	public String insertManyNotifications(@RequestBody AlertVO alertVO, @AuthenticationPrincipal CustomEmployee customEmployee) {
		if(customEmployee == null) return "fail"; // 로그인 정보 없을 때
		
		// 발신자 사번 세팅
		alertVO.setSenderNo(customEmployee.getEmployee().getEmployeeNo());
		
		// 사번 리스트 AND 단일 부서 AND 여러 부서 리스트가 모두 없을 때만 fail
	    if ((alertVO.getEmpNoList() == null || alertVO.getEmpNoList().isEmpty()) && 
	        (alertVO.getEmployeeCode() == null || alertVO.getEmployeeCode().isEmpty()) &&
	        (alertVO.getDeptCodeList() == null || alertVO.getDeptCodeList().isEmpty())) { // ★ 이 조건이 핵심!
	        return "fail";
	    }
	    
	    try {
	        service.insertManyNotifications(alertVO);
	        return "success";
	    } catch (Exception e) {
	        log.error("다수 알림 생성 중 오류 발생", e);
	        return "fail";
	    }
	}
	
}
