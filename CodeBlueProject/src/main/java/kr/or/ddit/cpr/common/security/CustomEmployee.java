package kr.or.ddit.cpr.common.security;

import java.util.Collection;
import java.util.stream.Collectors;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.User;

import kr.or.ddit.cpr.vo.EmployeeVO;
import lombok.Getter;

@Getter
public class CustomEmployee extends User{
	
	// 직원 정보
	private EmployeeVO employee;
	
	public CustomEmployee(String username, String password,
						  Collection<? extends GrantedAuthority> authorities) {
		super(username, password, authorities);
	}
	
	public CustomEmployee(EmployeeVO employee) {
		super(String.valueOf(employee.getEmployeeNo()),			// 사번
							 employee.getEmployeePassword(),	// 암호화된 비밀번호
							 employee.getAuthList().stream()
							 		 .map(role -> new SimpleGrantedAuthority(role.getAuth()))
							  		 .collect(Collectors.toList()));
		this.employee = employee;
	}
}