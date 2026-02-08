package kr.or.ddit.cpr.certificate.service;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import kr.or.ddit.cpr.certificate.mapper.IReceptionCertificateMapper;
import kr.or.ddit.cpr.vo.DiagnosisVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class ReceptionCertificateServiceImpl implements IReceptionCertificateService {

	@Autowired
	private IReceptionCertificateMapper mapper;
	
	// 증명서 내역 조회
	@Override
	public List<Map<String, Object>> selectMedicalCertificateList(int patientNo) {		
		return mapper.selectMedicalCertificateList(patientNo);
	}

	// 증명서 발급 요청
	@Override
	public int requestCertificate(Map<String, Object> params) {
		return mapper.insertCertificateRequest(params);
	}

	// 증명서 상세 조회
	@Override
	public Map<String, Object> selectCertificateDetail(String printNo) {
		return mapper.selectCertificateDetail(printNo);
	}

	// 특정 차트의 상병 리스트 조회
	@Override
	public List<DiagnosisVO> selectDiagnosisList(int chartNo) {
		return mapper.selectDiagnosisList(chartNo);
	}
	
	// 증명서 발급 요청 해당 환자 담당의 사번 조회
	@Override
	public int selectCurrentDoctorNo(int patientNo) {		
		return mapper.selectCurrentDoctorNo(patientNo);
	}

}
