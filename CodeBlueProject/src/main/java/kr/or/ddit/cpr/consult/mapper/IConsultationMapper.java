package kr.or.ddit.cpr.consult.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import kr.or.ddit.cpr.vo.ConsultationVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.PatientVO;

@Mapper
public interface IConsultationMapper {

	public List<ConsultationVO> selectReqConsultPatient(int employeeNo, Integer patientNo);
	public ConsultationVO selectConsultationDetail(int consultationNo);
	public List<ConsultationVO> searchPatient(String keyword);
	public List<EmployeeVO> selectDoctorList();
	public int insertReqConsultation(ConsultationVO vo);
	public int updateRespConsultation(ConsultationVO vo);
	public int updateRejectConsultation(ConsultationVO vo);
	public ConsultationVO selectChartDetail(int chartNo);

}
