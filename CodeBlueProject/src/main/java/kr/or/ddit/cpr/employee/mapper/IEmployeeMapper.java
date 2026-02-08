package kr.or.ddit.cpr.employee.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import kr.or.ddit.cpr.vo.AttachmentDetailVO;
import kr.or.ddit.cpr.vo.AttachmentVO;
import kr.or.ddit.cpr.vo.EmployeeAuthVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.LocationVO;

@Mapper
public interface IEmployeeMapper {

	// 전직원 - 마이페이지 조회
	public EmployeeVO selectMyPage(int employeeNo);

	// 관리자 - 계정 관리 메인화면
	public List<EmployeeVO> selectEmployeeList(Map<String, Object> map);
	
	// 관리자 - 계정관리 페이징
	public int countEmployeeList(Map<String, Object> map);

	// 관리자 - 계정 생성 
	public void insertAcc(EmployeeVO employeeVO);
	
	// 관리자 - 계정 생성시 첨부파일
	public void insertAttachment(AttachmentVO attachmentVO);
	
	// 관리자 - 계정 생성시 첨부파일의 상세정보
	public void insertAttachmentDetail(AttachmentDetailVO attachmentDetailVO);
	
	// 관리자 - 새 계정에게 권한 부여
	public void insertAccAuth(EmployeeAuthVO employeeAuthVO);
	
	// 마이페이지 - 프로필 사진 (파일) 상세 조회
	public AttachmentDetailVO selectFileDetail(int detailNo);

	// 관리자 - 계정 상세 조회
	public EmployeeVO selectEmployeeDetail(int employeeNo);

	// 관리자 - 계정 수정
	public int updateAcc(EmployeeVO employeeVO);

	// 관리자 - 계정 퇴사 처리
	public int retireAcc(int employeeNo);
	
	// 엑셀 일괄 등록 - 중복&유효성 체크
	public int countByEmail(@Param("employeeEmail") String employeeEmail);
	public int countByTel(@Param("employeeTel") String employeeTel);
	public int countByRegNo(@Param("employeeRegno1") String employeeRegno1, @Param("employeeRegno2") String employeeRegno2);

	// 엑셀 일괄 다운로드
	public List<EmployeeVO> downloadEmployeeExcelFile(Map<String, Object> map);

	// 배정관리 전체 조회
	public List<LocationVO> selectLocationList();

	// 특정 계정 배정관리 조회
	public List<LocationVO> selectEmployeeLocation(int employeeNo);

	// 배정 수정 & 저장
	public int updateLocationManager(LocationVO locationVO);

}