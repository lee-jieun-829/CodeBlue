package kr.or.ddit.cpr.messenger.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import kr.or.ddit.cpr.common.security.CustomEmployee;
import kr.or.ddit.cpr.messenger.service.IMessengerService;
import kr.or.ddit.cpr.vo.ChattingDetailVO;
import kr.or.ddit.cpr.vo.ChattingRoomVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/chat")
public class MessengerRestController {

	@Autowired
	private IMessengerService service;

	/**
	 * 이전 메시지 리스트 가져오기
	 * @param roomNo
	 * @return 리스트 반환
	 */
	@GetMapping("/messages")
	public List<ChattingDetailVO> getMessage(@RequestParam long roomNo){
		return service.getMessageListWithUnreadCount(roomNo);
	}
	
	/**
	 * 직원 목록 가져오기
	 * @return 직원 목록
	 */
	@GetMapping("/employees")
    public List<EmployeeVO> getEmployeeList() {
        // 1. DB에서 전체 직원 목록 조회 (서비스에 새로 만들어야 함)
        List<EmployeeVO> empList = service.getEmployeeList();
        
        // 2. 리스너에 있는 온라인 사용자 세트 가져오기
        // (MessengerEventListener에 만든 getOnlineUsers() 메서드 활용)
        Set<String> onlineUserIds = MessengerEventListener.getOnlineUsers();
        
        log.info("### 현재 온라인 사번들: {}", onlineUserIds);
        
        // 3. 온라인 여부 매칭 (EmployeeVO에 isOnline 필드가 있다고 가정)
        for (EmployeeVO emp : empList) {
        	String empNoStr = String.valueOf(emp.getEmployeeNo());
            if (onlineUserIds != null && onlineUserIds.contains(empNoStr)) {
                emp.setOnline(true);
                log.info("### 매칭 성공! 온라인 처리된 사번: {}", empNoStr);
            } else {
                emp.setOnline(false);
            }
        }
        
        return empList;
    }
	
	@GetMapping("/onlineUsers")
	public Set<String> getOnlineUsers() {
	    // EventListener에 있는 명단 가져오기
	    return MessengerEventListener.getOnlineUsers();
	}
	
	/**
	 * 방만들기
	 * @param userIds
	 * @return map
	 */
	@PostMapping("/room")
	public Map<String, Object> createChatRoom(@RequestBody List<String> userIds) {
	    // userIds: 참여할 사번 리스트 (본인 포함)
	    log.info("채팅방 생성 요청 : 참여자 수 {}", userIds.size());
	    
	    // 서비스 호출하여 방 생성 후 방 번호 리턴
	    Long roomNo = service.createChatRoom(userIds);
	    
	    Map<String, Object> response = new HashMap<>();
	    response.put("success", true);
	    response.put("roomNo", roomNo);
	    response.put("roomName", "새로운 채팅방"); // 필요 시 로직 추가
	    
	    return response;
	}
	
	
	/**
	 * 채팅방 목록
	 * @param loginUser
	 * @return 채팅룸목록_사람이름
	 */
	@GetMapping("/rooms")
	public List<ChattingRoomVO> getMyChatRooms(@AuthenticationPrincipal CustomEmployee loginUser) {
		
		String employeeNo = String.valueOf(loginUser.getEmployee().getEmployeeNo());
	    // 로그인한 사용자의 사번으로 목록 조회
	    return service.getMyChatRoomList(employeeNo);
	}
	
}
