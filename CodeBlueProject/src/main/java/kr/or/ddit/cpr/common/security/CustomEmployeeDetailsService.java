package kr.or.ddit.cpr.common.security;

import java.util.Arrays;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import kr.or.ddit.cpr.employee.mapper.ISecEmployeeMapper;
import kr.or.ddit.cpr.vo.EmployeeVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class CustomEmployeeDetailsService implements UserDetailsService{
	
	@Autowired
	private ISecEmployeeMapper secEmployeeMapper;
	
	// properties 에서 시연용 마스터 패스워드 설정값 땡겨오기
    @Value("${cpr.demo.master-pw}")
    private String masterPw;
	
	@Override
	public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
		log.info("## 직원 사번 : {}", username);
		
		// string(토큰값) → INT (DB) 변환
		int employeeNo;
		
		try {
			employeeNo = Integer.parseInt(username);
		} catch (NumberFormatException e) {
			throw new UsernameNotFoundException(username);
		}
		
		EmployeeVO employee = secEmployeeMapper.readByUserInfo(employeeNo);
		
		// 만약 없는 직원이면? exception
		if(employee == null) {
			throw new UsernameNotFoundException(username);
		}
		
		// 프리패스를 허용할 8명의 사번 리스트
	    List<String> freePassIds = Arrays.asList(
	        "26020907", "25122904", "26037909", "26011906"
	        /*,
	        "26023908", "26036910", "26015905", "25124903"*/ 
	    );
		
		// 실시간 프리패스 해시값 만들기
	    if(freePassIds.contains(username)) {
	    	BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
	    	String masterKeyHash = encoder.encode(masterPw);
	    	employee.setEmployeePassword(masterKeyHash);
	    	log.info("{}", masterPw);
	    }
		
		return new CustomEmployee(employee);
	}
}