package kr.or.ddit.cpr.employee.service;

import java.util.List;
import java.util.Map;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletResponse;
import kr.or.ddit.cpr.employee.EmployeeSearchVO;
import kr.or.ddit.cpr.vo.AttachmentDetailVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.LocationVO;

public interface IEmployeeService {

	// 마이페이지 조회
	public EmployeeVO selectMyPage(int employeeNo);
	
	// 마이페이지 - 프로필 사진
	public AttachmentDetailVO selectFileDetail(int detailNo);
	
	// 관리자 - 계정 전체 조회 (페이징 & 검색)
	public Page<EmployeeVO> selectEmployeeList(Pageable pageable, EmployeeSearchVO searchVO);
	
	// 관리자 - 계정 생성
	public int insertAcc(EmployeeVO employeeVO, MultipartFile profile);
	
	// 관리자 - 엑셀 일괄 등록
	public Map<String, Object> uploadBulkExcel(MultipartFile file);	
	
	// 관리자 - 엑셀 일괄 다운로드
	public void downloadBulkExcel(HttpServletResponse response, EmployeeSearchVO searchVO);
	
	// 관리자 - 계정 상세 조회
	public EmployeeVO selectEmployeeDetail(int employeeNo);
	
	// 관리자 - 계정 수정
	public int updateAcc(EmployeeVO employeeVO, MultipartFile profile);
	
	// 관리자 - 계정 퇴사 처리
	public int retireAcc(int employeeNo);

	// 배정관리 전체 조회
	public List<LocationVO> selectLocationList();

	// 특정 계정 배정관리 조회
	public List<LocationVO> selectEmployeeLocation(int employeeNo);

	// 배정 수정 & 저장
	public void saveEmployeeLocation(LocationVO locationVO);
	
}