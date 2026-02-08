package kr.or.ddit.cpr.vo;

import java.util.Date;
import java.util.List;

import org.springframework.format.annotation.DateTimeFormat;

import lombok.Data;

@Data
public class EmployeeVO {
	private int employeeNo;					// 사번
	private String employeeName;			// 직원 이름
	private String employeePassword;		// 비밀번호
	private String employeeGen;				// 성별
	private String employeeRegno1;			// 주민번호1
	private String employeeRegno2;			// 주민번호2
	private String employeeTel;				// 전화번호
	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private Date employeeRegdate;			// 입사일
	private Date employeeRetdate;			// 퇴사일
	private String employeeStatus;			// 직원 상태
	private String employeeBirth;			// 생년월일
	private String employeeCode;			// 직원 구분
	private String employeeEmail;			// 이메일
	private int fileNo;						// 프로필 사진
	private String enabled;					// 허용
	private int hospitalNo;					// 병원번호
	private String employeeDetailLicence;	// 직원 면허 번호
	
	private String locationNo;			// 장소 번호
	private String pwTempYn;				// 임시 비밀번호 사용여부
	
	private List<EmployeeAuthVO> authList;	// 권한 리스트
	
	// 토큰 운반용 필드
	private String token;
	
	private String hospitalName; // 병원명
	private String hospitalAddr; // 병원주소
	
	// 실시간 채팅 직원 검색 온오프라인 상태 확인 필드
	private boolean isOnline;
}