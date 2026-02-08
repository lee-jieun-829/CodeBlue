package kr.or.ddit.cpr.certificate.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import kr.or.ddit.cpr.vo.CertificateVO;
import kr.or.ddit.cpr.vo.ChartVO;

@Mapper
public interface ICertificateMapper {

	public List<CertificateVO> searchPatient(String keyword);
	public List<ChartVO> selectPatientChart(int patientNo);
	public List<CertificateVO> selectPatientDoc(int patientNo);
	public List<CertificateVO> selectDocDetail(
		    @Param("docType") String docType, 
		    @Param("certificateNo") int certificateNo, 
		    @Param("chartNo") int chartNo, 
		    @Param("clickDate") String clickDate 
		);
	
	public int insertCertificate(CertificateVO vo);

}
