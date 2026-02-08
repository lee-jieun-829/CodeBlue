package kr.or.ddit.cpr.notification.service;

import java.util.List;

import kr.or.ddit.cpr.vo.AlertVO;

public interface INotificationService {

	/**
	 * 수신자별 안읽은 알림 조회
	 * @param employeeNo 사번
	 * @return 안 읽은 알림(alertReadYn='N')리스트
	 */
	public List<AlertVO> selectNotificationList(int employeeNo);

	/**
	 * 알림 개별 읽음 처리
	 * @param alertNo 알림 고유 번호
	 */
	public void updateNotificationRead(int alertNo);

	/**
	 * 전체 알림 일괄 읽음 처리
	 * @param employeeNo 사번
	 */
	public void updateAllNotificationRead(int employeeNo);

	/**
	 * 새로운 알림 생성(알림 보낼 때 사용)
	 * @param alertVO 생성할 알림 정보
	 */
	public void insertNotification(AlertVO alertVO);

	/**
	 * 전체 알림 발송
	 * @param alertVO 전송할 알림 데이터 객체
	 */
	public void insertNotificationToAll(AlertVO alertVO);

	/**
	 * 다수 사용자에게 알림 생성
	 * @param alertVO
	 */
	public void insertManyNotifications(AlertVO alertVO);


}
