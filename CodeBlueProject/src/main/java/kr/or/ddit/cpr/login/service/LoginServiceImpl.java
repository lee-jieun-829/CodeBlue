package kr.or.ddit.cpr.login.service;

import java.time.Duration;
import java.util.Random;

import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.MailException;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.common.security.jwt.JwtTokenProvider;
import kr.or.ddit.cpr.common.util.SecurityUtils;
import kr.or.ddit.cpr.login.mapper.ILoginMapper;
import kr.or.ddit.cpr.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class LoginServiceImpl implements ILoginService{
	
	@Autowired
	private ILoginMapper loginMapper;
	
	@Autowired
	private PasswordEncoder passwordEncoder;
	
	@Autowired
	private JwtTokenProvider jwtTokenProvider;
	
	@Autowired
	private JavaMailSender javaMailSender;
	
	// 로그인
	@Override
	public EmployeeVO login(EmployeeVO employeeVO) {
		// 권한까지 가져와서 DB 조회
		EmployeeVO employee = loginMapper.login(employeeVO.getEmployeeNo());
		
		// 비번 검사
		if(employee != null && passwordEncoder.matches(employeeVO.getEmployeePassword(), employee.getEmployeePassword())) {
			String token = jwtTokenProvider.generateToken(employee, Duration.ofMinutes(30));
			employee.setToken(token);
			
			return employee;
		
		}else {
			throw new RuntimeException("ID 또는 비밀번호가 틀렸습니다.");
		}
	}

	// 현재 비번 체크
	@Override
	public boolean checkPassword(String inputPw) {
		
		int employeeNo = SecurityUtils.getCurrentEmployeeNo();
		
		EmployeeVO employeeVO = loginMapper.checkPassword(employeeNo);
		
		if(employeeVO == null) return false;

		return passwordEncoder.matches(inputPw, employeeVO.getEmployeePassword());
	}

	// 인증번호 이메일 발송
	@Override
	public String sendAuthCodeMail() {
		// 사번으로 이메일 찾기
		int employeeNo = SecurityUtils.getCurrentEmployeeNo();
		
		EmployeeVO employee = loginMapper.checkPassword(employeeNo);
		try {
			
			if(employee == null) throw new RuntimeException("회원 정보 없음");
			
			String employeeEmail = employee.getEmployeeEmail();
			if(employeeEmail == null || employeeEmail.isEmpty()) throw new RuntimeException("등록된 이메일 없음");

			// 인증번호 랜덤으로 제작
			Random random = new Random();
			int authCode = random.nextInt(888888) + 111111;
			String codeStr = String.valueOf(authCode);
			log.info("발급된 인증 번호 :{}", codeStr);

			// 이메일 보내기
			SimpleMailMessage message = new SimpleMailMessage();
			message.setTo(employeeEmail);
			message.setSubject("[CodeBlue EMR] 비밀번호 변경 인증번호");
			message.setText("인증번호는 [" + codeStr + "] 입니다.\n 3분 이내에 입력해주세요.");
			
			javaMailSender.send(message);

			return codeStr;
			
		} catch (Exception e) {
			e.printStackTrace();
			throw new RuntimeException("메일 발송 중 오류가 발생했습니다.");
		}
	}

	// 비밀번호 변경 및 DB에 업데이트
	@Transactional(rollbackFor = Exception.class)
	@Override
	public void updatePassword(String newPw) {
		int employeeNo = SecurityUtils.getCurrentEmployeeNo();
		
		String encodedPw = passwordEncoder.encode(newPw);
		
		EmployeeVO updateVO = new EmployeeVO();
		updateVO.setEmployeeNo(employeeNo); 
		updateVO.setEmployeePassword(encodedPw);
		
		updateVO.setPwTempYn("N");
		
		loginMapper.updatePassword(updateVO);
	}


	@Override
	public void verifyAuthCode(String inputCode, String sessionCode, Long expiryTime, Integer retryCount) {
		// 필수 값 체크
		if (sessionCode == null || expiryTime == null || retryCount == null) {
			throw new IllegalArgumentException("인증번호가 만료되었거나 발송되지 않았습니다.");
		}

		// 시간 초과 체크 -> IllegalStateException (상태 이상 - 세션 삭제용)
		if (System.currentTimeMillis() > expiryTime) {
			throw new IllegalStateException("인증 시간이 초과되었습니다. 다시 발송해주세요.");
		}

		// 횟수 초과 체크 -> IllegalStateException (상태 이상 - 세션 삭제용)
		if (retryCount >= 5) {
			throw new IllegalStateException("인증 시도 횟수 초과. 재발송해주세요.");
		}

		// 일치 여부 체크 -> IllegalArgumentException (입력 오류 - 재시도 횟수 증가용)
		if (!sessionCode.equals(inputCode)) {
			throw new IllegalArgumentException("인증번호가 일치하지 않습니다.");
		}
	}

	// 비밀번호 찾기에서 임시 비번 발급
	@Transactional(rollbackFor = Exception.class)
	@Override
	public void processFindPassword(EmployeeVO employeeVO) {
		// 1. 사용자 존재 확인
		int count = loginMapper.checkUserForReset(employeeVO);
		if (count == 0) {
			throw new IllegalArgumentException("입력하신 정보와 일치하는 사용자가 없습니다.");
		}
		
		// 임시 비밀번호 생성
		String tempPw = RandomStringUtils.randomAlphanumeric(10);
		log.info("발급된 임시 비밀번호 :{}", tempPw);
		
		// 암호화 및 DB 업데이트
		String encodedPw = passwordEncoder.encode(tempPw);
		
		// 보안 : 업데이트니까 오염 막기위해 아예 객체를 새로 만들어서 값 세팅하기
		EmployeeVO updateVO = new EmployeeVO();
		updateVO.setEmployeeNo(employeeVO.getEmployeeNo());
		updateVO.setEmployeePassword(encodedPw);
		updateVO.setPwTempYn("Y");
		
		loginMapper.updatePassword(updateVO);
		
		// 4. 메일 발송
		try {
			SimpleMailMessage message = new SimpleMailMessage();
			message.setTo(employeeVO.getEmployeeEmail());
			message.setSubject("[CodeBlue EMR] 임시 비밀번호 안내");
			message.setText("안녕하세요. 요청하신 임시 비밀번호는 [" + tempPw + "] 입니다.\n로그인 후 반드시 비밀번호를 변경해주세요.");
			
			javaMailSender.send(message);
			
		} catch (MailException e) {
			e.printStackTrace();
			throw new RuntimeException("메일 발송 실패로 인해 처리가 취소되었습니다.");
		}	
	}
}