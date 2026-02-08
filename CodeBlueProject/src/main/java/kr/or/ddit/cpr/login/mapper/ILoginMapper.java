package kr.or.ddit.cpr.login.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import kr.or.ddit.cpr.vo.EmployeeVO;

@Mapper
public interface ILoginMapper {

	public EmployeeVO login(@Param("employeeNo") int employeeNo);

	public EmployeeVO checkPassword(@Param("employeeNo") int employeeNo);

	public void updatePassword(EmployeeVO updateVO);

	public int checkUserForReset(EmployeeVO employeeVO);

}