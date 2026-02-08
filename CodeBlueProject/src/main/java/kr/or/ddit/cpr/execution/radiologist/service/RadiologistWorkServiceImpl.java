package kr.or.ddit.cpr.execution.radiologist.service;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import kr.or.ddit.cpr.admin.vo.AttachmentVO;
import kr.or.ddit.cpr.execution.radiologist.mapper.IRadiologistMapper;
import kr.or.ddit.cpr.vo.AttachmentDetailVO;
import kr.or.ddit.cpr.vo.ExamOrderVO;
import kr.or.ddit.cpr.vo.PatientDetailVO;
import kr.or.ddit.cpr.vo.PatientVO;
import kr.or.ddit.cpr.vo.PredetailWatingListVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class RadiologistWorkServiceImpl implements IRadiologistWorkService {

	@Autowired
	private IRadiologistMapper mapper;
	
	// application.properties 설정 경로
	@Value("${kr.or.ddit.upload.path}")
	private String basePath; // C:/upload/
	
	@Override
	public List<PredetailWatingListVO> getWaitingList() {
		return mapper.getWaitingList();
	}

	@Transactional(rollbackFor = Exception.class)
	@Override
	public void updateWaitingStatus(int predetailNo, String preExamdetailStatus) throws Exception {
		int updated = mapper.updateWaitingStatus(predetailNo, preExamdetailStatus);
	    
		try {
			if(updated == 0) {
				throw new Exception("상태 변경에 실패했습니다.");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	@Override
	public List<PatientDetailVO> getPatientDetail(Integer patientNo) {
		return mapper.getPatientDetail(patientNo);
	}

	@Override
	public List<ExamOrderVO> getOrderList(int patientNo) {
		return mapper.getOrderList(patientNo);
	}

	@Override
	public List<ExamOrderVO> getOrderDetail(int predetailNo) {
		return mapper.getOrderDetail(predetailNo);
	}

	@Transactional(rollbackFor = Exception.class)
	@Override
	public int updatePatientMemo(PatientVO patientVO) {
		return mapper.updatePatientMemo(patientVO);
	}

	/**
	 * 검사 완료 처리 (항목별 파일 업로드)
	 * - 각 검사 항목마다 개별 첨부파일 번호 생성
	 * - 항목별로 파일 저장 및 DB 업데이트
	 * 
	 * @param orderVO - predetailNo, chartNo, preExamdetailStatus
	 * @param filesByExamItem - 검사 항목별 파일 맵 { examItemId: [파일들] }
	 * @return 업데이트된 검사 항목 개수
	 * @throws Exception
	 */
	@Transactional(rollbackFor = Exception.class)
    @Override
    public int updateCompleteExam(ExamOrderVO orderVO, Map<Integer, List<MultipartFile>> filesByExamItem) throws Exception {
        
        log.info("=== 검사 완료 처리 시작 ===");
        
        // 롤백 시 삭제할 파일 목록 추적용
        List<File> savedFiles = new ArrayList<>();
        
        try {
            // 1. 환자 정보 불러오기
            ExamOrderVO patientInfo = mapper.getPatientInfoByChartNo(orderVO.getChartNo());
            if (patientInfo == null) {
                throw new Exception("환자 정보를 찾을 수 없습니다.");
            }
            
            // 2. 경로 설정 (보안: 이름에 특수문자 제거)
            String safeName = patientInfo.getPatientName().replaceAll("[^a-zA-Z0-9가-힣]", "");
            String patientFolder = patientInfo.getPatientNo() + "_" + safeName;
            String orderInfo = "ch" + Integer.toString(patientInfo.getChartNo()) 
            						+ "_" + Integer.toString(orderVO.getPredetailNo());
            
            String dynamicPath = "execution" + File.separator
                    			+ patientFolder + File.separator
                    			+ orderInfo + File.separator;
            String baseFilePath = basePath + dynamicPath;
            
            int totalUpdatedItems = 0;
            
            // 3. 각 검사 항목별(PK) 처리
            for (Map.Entry<Integer, List<MultipartFile>> entry : filesByExamItem.entrySet()) {
                int preExamdetailNoPK = entry.getKey(); // JSP에서 보낸 PK
                List<MultipartFile> files = entry.getValue();
                
                if (files == null || files.isEmpty()) continue;
                
                // 3-1. 첨부파일 마스터 생성
                AttachmentVO attachmentVO = new AttachmentVO();
                mapper.insertAttachment(attachmentVO);
                
                int fileNo = attachmentVO.getAttachmentNo();
                // 3-2. 검사 항목별 폴더
                String examItemPathStr = baseFilePath + preExamdetailNoPK + File.separator;
                File examItemPath = new File(examItemPathStr);
                if (!examItemPath.exists()) examItemPath.mkdirs();
                
                // 3-3. 파일 저장
                for (MultipartFile file : files) {
                    if (!file.isEmpty()) {
                        String originalName = file.getOriginalFilename();
                        String ext = originalName.substring(originalName.lastIndexOf(".") + 1);
                        String saveName = UUID.randomUUID().toString() + "." + ext;
                        
                        File saveFile = new File(examItemPath, saveName);
                        file.transferTo(saveFile);
                        
                        // [중요] 저장 성공 시 리스트에 추가 (롤백 대비)
                        savedFiles.add(saveFile);
                        
                        // 상세 정보 DB 저장
                        AttachmentDetailVO detail = new AttachmentDetailVO();
                        detail.setAttachmentNo(fileNo);
                        detail.setAttachmentDetailName(saveName);
                        detail.setAttachmentDetailMime(originalName);
                        detail.setAttachmentDetailPath(examItemPathStr + saveName);
                        detail.setAttachmentDetailExt(ext);
                        detail.setAttachmentDetailSize((int) file.getSize());
                        
                        mapper.insertAttachmentDetail(detail);
                    }
                }
                
                // 3-4. 개별 검사 항목 업데이트
                ExamOrderVO updateVO = new ExamOrderVO();
                // [주의] SQL에서 WHERE PREEXAMINATION_DETAIL_NO = #{examinationNo} 로 매핑됨
                updateVO.setPreexaminationNo(preExamdetailNoPK); 
                updateVO.setAttachmentNo(fileNo);
                updateVO.setPreExamdetailStatus("001"); // 완료
                
                int result = mapper.updateCompleteExam(updateVO);
                if (result > 0) totalUpdatedItems++;
            }
            
            return totalUpdatedItems;
            
        } catch (Exception e) {
            log.error("검사 완료 처리 중 에러 발생. 파일 롤백을 수행합니다.", e);
            
            // [파일 롤백 수행]
            for (File f : savedFiles) {
                if (f.exists()) {
                    if (f.delete()) {
                        log.info("롤백: 파일 삭제 완료 - {}", f.getName());
                    } else {
                        log.warn("롤백: 파일 삭제 실패 - {}", f.getName());
                    }
                }
            }
            // 예외를 다시 던져서 DB 트랜잭션 롤백 트리거
            throw e;
        }
    }
	/*
	@Override
	public PatientDetailVO getPatientDetail(int patientNo, int chartNo) {
		return mapper.getPatientDetail(patientNo, chartNo);
	}
	*/

}
