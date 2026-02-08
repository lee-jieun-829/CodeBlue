package kr.or.ddit.cpr.vo;

import java.time.LocalDateTime;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChattingDetailVO {
	
	// ===== DB 컬럼 매핑 =====
    private Long chattingDetailNo;          // PK (시퀀스)
    private String chattingDetailContent;   // 메시지 내용
    private String chattingDetailSender;    // 발신자 ID
    private LocalDateTime chattingDetailSendAt; // 전송 시간
    private Long chattingroomNo;            // FK
    
    // ===== 화면/전송용 =====
    private String type;                    // "ENTER", "TALK", "LEAVE", "READ"
    private String senderName;              // 발신자 이름 (화면 표시용)
    private String deptName;				// 근무 부서 이름
    
    // ===== 읽음 처리용 =====
    private Integer unreadCount;   // 안 읽은 사람 수 (1:N 대응)
}
