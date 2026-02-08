package kr.or.ddit.cpr.vo;

import lombok.Data;

@Data
public class EmployeeAuthVO{
	private int employeeNo;		// 사번 
	private String auth;		// 권한코드
}