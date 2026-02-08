package kr.or.ddit.cpr.vo;

import java.util.List;

import lombok.Data;

@Data
public class AlertVO {

	 private int alertNo;			// 알림번호
	 private String alertType;		// 알림구분
	 private String alertContent;	// 알림내용
	 private String alertReadYn;	// 수신확인여부
	 private int employeeNo;		// 사번
	 private String alertName;		// 알림명
	 private String alertDate;		// 알림생성일
	 private String alertUrl;		// URL주소
	 private String alertUrgent;	// 긴급여부
	 
	 private List<Integer> empNoList; // 사번 리스트
	 private String employeeCode;	  // 단일 부서 코드(직원 구분)
	 private int senderNo;			// 발신자
	 private List<String> deptCodeList; // 부서 코드 리스트
}
