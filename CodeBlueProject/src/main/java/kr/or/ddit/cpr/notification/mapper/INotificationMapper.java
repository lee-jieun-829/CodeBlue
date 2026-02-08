package kr.or.ddit.cpr.notification.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.vo.AlertVO;

@Mapper
public interface INotificationMapper {

	// 수신자별 안읽은 알림 조회
	public List<AlertVO> selectNotificationList(int employeeNo);

	// 알림 개별 읽음 처리
	public void updateNotificationRead(int alertNo);

	// 전체 알림 일괄 읽음 처리
	public void updateAllNotificationRead(int employeeNo);

	// 새로운 알림 생성(알림 보낼 때 사용)
	public int insertNotification(AlertVO alertVO);

	// 전체 알림 저장
	public int insertNotificationToAll(AlertVO alertVO);

	// 특정 부서(직원 구분) 전체에게 알림 생성
	public List<Integer> selectEmpNoListByDept(String employeeCode);

}
