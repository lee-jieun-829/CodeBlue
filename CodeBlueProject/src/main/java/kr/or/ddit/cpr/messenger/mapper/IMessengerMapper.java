package kr.or.ddit.cpr.messenger.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.springframework.data.repository.query.Param;

import kr.or.ddit.cpr.vo.ChattingDetailVO;
import kr.or.ddit.cpr.vo.ChattingPeopleVO;
import kr.or.ddit.cpr.vo.ChattingRoomVO;
import kr.or.ddit.cpr.vo.EmployeeVO;

@Mapper
public interface IMessengerMapper {

	public int insertMessage(ChattingDetailVO message);
	public int updateReadStatus(ChattingPeopleVO peopleVO);
	public List<ChattingDetailVO> getMessageListWithUnreadCount(Long roomNo);
	public int deleteChattingPeople(@Param("roomNo") Long roomNo, @Param("userId") String userId);
	public List<EmployeeVO> getEmployeeList();
	public void insertChatRoom(ChattingRoomVO roomVO);
	public void insertChatPeople(ChattingPeopleVO peopleVO);
	public List<ChattingRoomVO> selectMyChatRoomList(String employeeNo);
}
