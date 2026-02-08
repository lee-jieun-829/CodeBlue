package kr.or.ddit.cpr.inpatient.service;

import java.beans.Transient;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.cpr.billing.mapper.IReceptionMapper;
import kr.or.ddit.cpr.inpatient.mapper.IInpatientNurseMapper;
import kr.or.ddit.cpr.vo.BedVO;
import kr.or.ddit.cpr.vo.InpatientVO;
import kr.or.ddit.cpr.vo.LocationVO;
import kr.or.ddit.cpr.vo.PatientVO;

@Service
public class InpatientNurseServiceImpl implements IInpatientNurseService {
	@Autowired
	private IInpatientNurseMapper mapper;
	@Autowired
	private IReceptionMapper rmapper;

	@Override
	public List<InpatientVO> inPatientSelect() {
		List<InpatientVO> inpatientList = mapper.inPatientSelect();
		return inpatientList;
	}

	@Override
	public List<LocationVO> locationSelect() {
		List<LocationVO> locationList = mapper.locationSelect();
		return locationList;
	}
	
	@Transactional
	@Override
	public int bedUpdate(List<InpatientVO> inpatientVO) {
	    // 1. 리스트가 비어있으면 0 반환
	    if (inpatientVO == null || inpatientVO.isEmpty()) {
	        return 0;
	    }

	    // 2. 반복문으로 각 환자에 대해 3가지 쿼리 실행
	    for (InpatientVO patient : inpatientVO) {    
	      
	        int bedNo = patient.getBedNo();
	        int patientNo = patient.getPatientNo();
	        int oldBedNo = patient.getOldBedNo();
	        
	        mapper.bedUpdate(patientNo,bedNo);

	        // 기존 침상(oldBedNo) 상태 변경 -> '001' (사용가능)
	        // 기존 침상 번호가 있을 때만 실행 (0이 아닐 경우)
	        if (patient.getOldBedNo() > 0) {
	            BedVO oldBed = new BedVO();
	            oldBed.setBedNo(oldBedNo);
	            oldBed.setBedStatus("001"); 
	            mapper.updateBedStatus(oldBed);
	        }

	        // 새 침상(bedNo) 상태 변경 -> '002' (사용중)
	        BedVO newBed = new BedVO();
	        newBed.setBedNo(bedNo);
	        newBed.setBedStatus("002");
	        mapper.updateBedStatus(newBed);
	    }
	    
	    // 로직이 문제없이 끝났으면 1 반환
	    return 1;
	}
	
	@Override
	public int updateMemo(PatientVO patientvo) {
		try {
	        // 1. 업데이트 실행
	        rmapper.updatePatientMemo(patientvo);
	        
	        // 2. 에러 없이 여기까지 왔으면 성공으로 간주하고 1 리턴
	        return 1; 
	        
	    } catch (Exception e) {
	        // 3. DB 에러 발생 시 로그 찍고 0 리턴
	        e.printStackTrace();
	        return 0;
	    }
	}
}