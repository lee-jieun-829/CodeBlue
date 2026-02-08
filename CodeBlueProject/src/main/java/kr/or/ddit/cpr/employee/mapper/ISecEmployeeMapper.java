package kr.or.ddit.cpr.employee.mapper;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.vo.EmployeeVO;

@Mapper
public interface ISecEmployeeMapper {
	
	// 인증
	public EmployeeVO readByUserInfo(int employeeNo);
	
	
}