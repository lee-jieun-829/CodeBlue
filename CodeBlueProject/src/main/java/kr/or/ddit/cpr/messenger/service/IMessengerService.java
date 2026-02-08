package kr.or.ddit.cpr.messenger.service;

import java.util.List;

import kr.or.ddit.cpr.vo.ChattingDetailVO;
import kr.or.ddit.cpr.vo.ChattingRoomVO;
import kr.or.ddit.cpr.vo.EmployeeVO;

public interface IMessengerService {

	public int saveMessage(ChattingDetailVO message);
	public int updateReadStatus(String userId, Long roomNo, Long lastReadNo);
	public List<ChattingDetailVO> getMessageListWithUnreadCount(Long roomNo);
	public int leaveChatRoom(Long roomNo, String userId);
	public List<EmployeeVO> getEmployeeList();
	public Long createChatRoom(List<String> userIds);
	public List<ChattingRoomVO> getMyChatRoomList(String employeeNo);
}
