package kr.or.ddit.cpr.vo;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChattingRoomVO {
	
	private Long chattingroomNo; 
	
	// --- 조회용 추가 필드 ---
	private String roomName;          // 방 이름 (참여자들 이름 조합)
	private String lastMessage;       // 마지막 대화 내용
	private LocalDateTime lastSendAt; // 마지막 대화 시간
	private int unreadCount;          // 안 읽은 메시지 개수
}
