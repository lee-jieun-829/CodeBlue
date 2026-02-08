package kr.or.ddit.cpr.certificate.mapper;

import java.util.List;
import java.util.Map;

import org.apache.ibatis.annotations.Mapper;

import kr.or.ddit.cpr.vo.DiagnosisVO;

@Mapper
public interface IReceptionCertificateMapper {

	// 증명서 내역 조회
	public List<Map<String, Object>> selectMedicalCertificateList(int patientNo);

	// 증명서 발급 요청
	public int insertCertificateRequest(Map<String, Object> params);

	// 증명서 상세 조회 
	public Map<String, Object> selectCertificateDetail(String printNo);

	// 특정 차트의 상병 리스트 조회
	public List<DiagnosisVO> selectDiagnosisList(int chartNo);
	
	// 증명서 발급 요청 해당 환자 담당의 사번 조회
	public int selectCurrentDoctorNo(int patientNo);


}
