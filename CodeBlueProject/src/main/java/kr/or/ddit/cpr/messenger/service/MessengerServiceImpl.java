package kr.or.ddit.cpr.messenger.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.messenger.mapper.IMessengerMapper;
import kr.or.ddit.cpr.vo.ChattingDetailVO;
import kr.or.ddit.cpr.vo.ChattingPeopleVO;
import kr.or.ddit.cpr.vo.ChattingRoomVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class MessengerServiceImpl implements IMessengerService{
	
	@Autowired
	private IMessengerMapper mapper;

	@Override
	@Transactional
	public int saveMessage(ChattingDetailVO message) {
		log.info("메시지 저장 : roomNo={}, sender={}",
				message.getChattingroomNo(), // 채팅룸
				message.getChattingDetailSender()); // 발신자 ID
		
		int result = mapper.insertMessage(message); // 메시지 저장
		
		if(result > 0) {
			log.info("메시지 저장 성공: detailNo={}", message.getChattingDetailNo());
			
			// 발신자 자신의 읽음 처리
			ChattingPeopleVO senderReadStatus = new ChattingPeopleVO();
			senderReadStatus.setChattingroomNo(message.getChattingroomNo());
			senderReadStatus.setChattingPeopleId(message.getChattingDetailSender());
			senderReadStatus.setChattingPeopleRead(message.getChattingDetailNo());
			
			// 발신자 자신 상태 업데이트
			int readResult = mapper.updateReadStatus(senderReadStatus);
			
			if(readResult > 0) {
				log.info("발신자 읽음 처리 완료 : sender={}", message.getChattingDetailSender());
			} else {
				log.warn("발신자 읽음 처리 실패(이미 최신 상태일 수 있음!)");
			}
			
		} else {
			log.error("메시지 저장 실패: roomNo={}, sender={}", 
	                message.getChattingroomNo(), 
	                message.getChattingDetailSender());
		}
		
		return result;
	}

	@Override
	@Transactional
	public int updateReadStatus(String userId, Long roomNo, Long lastReadNo) {
		log.info("읽음 처리 : userId={}, roomNo={}, lastReadNo={}",
				userId, roomNo, lastReadNo);
		
		ChattingPeopleVO peopleVO = new ChattingPeopleVO();
		peopleVO.setChattingroomNo(roomNo);
		peopleVO.setChattingPeopleId(userId);
		peopleVO.setChattingPeopleRead(lastReadNo);
		
		int result = mapper.updateReadStatus(peopleVO);
		
		if(result > 0) {
			log.info("읽음 처리 성공");
		} else {
			log.error("읽음 처리 실패 : userId={},roomNo={}", userId, roomNo);
		}
		
		return result;
	}

	@Override
	public List<ChattingDetailVO> getMessageListWithUnreadCount(Long roomNo) {
		log.info("채팅  내역 조회 시작 : roomNo={}", roomNo);
		return mapper.getMessageListWithUnreadCount(roomNo);
	}
	
	@Override
	@Transactional // DB삭제와 알림이 꼬이지 않게 트랜잭션 처리
	public int leaveChatRoom(Long roomNo, String userId) {
		int result = mapper.deleteChattingPeople(roomNo, userId);
	    log.info("### DB 삭제 결과: {}건 삭제됨 (방번호: {}, 유저: {})", result, roomNo, userId);
	    return result;
	}

	@Override
	public List<EmployeeVO> getEmployeeList() {
		return mapper.getEmployeeList();
	}

	@Transactional
	@Override
	public Long createChatRoom(List<String> userIds) {
		// 1. 채팅방 생성 (CHATTINGROOM INSERT)
	    ChattingRoomVO roomVO = new ChattingRoomVO();
	    mapper.insertChatRoom(roomVO); // insert 후 roomVO.chattingroomNo에 시퀀스 값이 담김
	    
	    Long roomNo = roomVO.getChattingroomNo();
	    
	    // 2. 참여자 등록 (CHATTING_PEOPLE INSERT)
	    for (String userId : userIds) {
	        ChattingPeopleVO peopleVO = new ChattingPeopleVO();
	        peopleVO.setChattingroomNo(roomNo);
	        peopleVO.setChattingPeopleId(userId);
	        peopleVO.setChattingPeopleFavorite("N");
	        peopleVO.setChattingPeopleRead(0L); // 초기값
	        
	        mapper.insertChatPeople(peopleVO);
	    }
	    
	    return roomNo;
	}

	@Override
	public List<ChattingRoomVO> getMyChatRoomList(String employeeNo) {
		return mapper.selectMyChatRoomList(employeeNo);
	}


}