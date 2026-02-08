package kr.or.ddit.cpr.login.service;

import kr.or.ddit.cpr.vo.EmployeeVO;

public interface ILoginService {

	// 로그인용
	public EmployeeVO login(EmployeeVO employeeVO);

	// 마이페이지 비밀번호 변경 - 현재 비밀번호 일치하는지!!
	public boolean checkPassword(String inputPw);
	
	// 마이페이지 비밀번호 변경 - 인증번호 생성 및 이메일 발송
	public String sendAuthCodeMail();

	// 마이페이지 비밀번호 변경
	public void updatePassword(String newPw);

	public void verifyAuthCode(String inputCode, String sessionCode, Long expiryTime, Integer retryCount);

	public void processFindPassword(EmployeeVO employeeVO);


}