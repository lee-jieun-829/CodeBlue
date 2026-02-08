package kr.or.ddit.cpr.vo;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChattingPeopleVO  {
	
	private Long chattingroomNo;           // FK
    private String chattingPeopleId;       // 참여자 ID
    private String chattingPeopleFavorite; // 즐겨찾기 (Y/N)
    private Long chattingPeopleRead;       // 마지막 읽은 메시지 번호
}
