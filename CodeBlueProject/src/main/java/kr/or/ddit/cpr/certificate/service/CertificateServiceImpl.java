package kr.or.ddit.cpr.certificate.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.certificate.mapper.ICertificateMapper;
import kr.or.ddit.cpr.vo.CertificateVO;
import kr.or.ddit.cpr.vo.ChartVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class CertificateServiceImpl implements ICertificateService {

	@Autowired
	private ICertificateMapper certificateMapper;
	
	@Override
	public List<CertificateVO> searchPatient(String keyword) {
		return certificateMapper.searchPatient(keyword);
	}

	@Override
	public List<ChartVO> selectPatientChart(int patientNo) {
		return certificateMapper.selectPatientChart(patientNo);
	}

	@Override
	public List<CertificateVO> selectPatientDoc(int patientNo) {
		return certificateMapper.selectPatientDoc(patientNo);
	}

	@Override
	public List<CertificateVO> selectDocDetail(String docType, int certificateNo, int chartNo, String clickDate) {
		return certificateMapper.selectDocDetail(docType, certificateNo, chartNo, clickDate);
	}

	@Transactional
	@Override
	public Map<String, Object> insertCertificate(CertificateVO vo) {
		Map<String, Object> resultMap = new HashMap<>();
		
		int result = certificateMapper.insertCertificate(vo);
		
		if(result > 0) {
            resultMap.put("status", "success");
            resultMap.put("message", "등록 성공");
        } else {
            resultMap.put("status", "fail");
        }
		
		return resultMap;
	}

}
