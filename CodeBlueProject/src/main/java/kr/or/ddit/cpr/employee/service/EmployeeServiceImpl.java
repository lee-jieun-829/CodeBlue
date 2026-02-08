package kr.or.ddit.cpr.employee.service;

import java.io.File;
import java.io.IOException;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.regex.Pattern;

import org.apache.commons.io.FileUtils;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpServletResponse;
import kr.or.ddit.cpr.common.util.ExcelFileUtils;
import kr.or.ddit.cpr.common.util.ExcelResultHandler;
import kr.or.ddit.cpr.employee.EmployeeSearchVO;
import kr.or.ddit.cpr.employee.mapper.IEmployeeMapper;
import kr.or.ddit.cpr.execution.radiologist.controller.RadiologistWorkRestController;
import kr.or.ddit.cpr.vo.AttachmentDetailVO;
import kr.or.ddit.cpr.vo.AttachmentVO;
import kr.or.ddit.cpr.vo.EmployeeAuthVO;
import kr.or.ddit.cpr.vo.EmployeeVO;
import kr.or.ddit.cpr.vo.LocationVO;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Service
public class EmployeeServiceImpl implements IEmployeeService{

    private final RadiologistWorkRestController radiologistWorkRestController;
	
	@Autowired
	private IEmployeeMapper employeeMapper;
	
	@Autowired
	private PasswordEncoder passwordEncoder;
	
	@Value("${kr.or.ddit.upload.path}")
	private String uploadPath;
	
	@Autowired
	private ExcelFileUtils excelFileUtils;
	
	@Autowired
	private ExcelResultHandler excelResultHandler;
	
	// 이메일 검증
	private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");


    EmployeeServiceImpl(RadiologistWorkRestController radiologistWorkRestController) {
        this.radiologistWorkRestController = radiologistWorkRestController;
    }
	
	
	// 마이페이지 - 내꺼만 조회
	@Override
	public EmployeeVO selectMyPage(int employeeNo) {
		return employeeMapper.selectMyPage(employeeNo);
	}
	
	// 마이페이지 - 프로필 사진(파일) 상세 조회
	@Override
	public AttachmentDetailVO selectFileDetail(int detailNo) {
		return employeeMapper.selectFileDetail(detailNo);
	}

	// 관리자 - 계정 전체 조회 (페이징 & 검색)
	@Override
	public Page<EmployeeVO> selectEmployeeList(Pageable pageable, EmployeeSearchVO searchVO) {
		
		long startRow = pageable.getOffset() + 1;
		int endRow = (int) (pageable.getOffset() + pageable.getPageSize());

		Map<String, Object> map = new HashMap<>();
		map.put("startRow", startRow);
		map.put("endRow", endRow);
		
		map.put("keyword", searchVO.getKeyword());
		map.put("position", searchVO.getPosition());
		map.put("sort", searchVO.getSort());

		// DB에서 데이터 가져오기
		List<EmployeeVO> list = employeeMapper.selectEmployeeList(map);
		
		int totalCount = employeeMapper.countEmployeeList(map);

		return new PageImpl<>(list, pageable, totalCount);
	}

	// 관리자 - 계정 생성 모달 이용시 (트랜잭션 처리!!!)
	@Transactional
	@Override
	public int insertAcc(EmployeeVO employeeVO, MultipartFile profile) {
		
		// 비밀번호 암호화
		String rawPassword = "1234";
		String encodedPassword = passwordEncoder.encode(rawPassword);
        employeeVO.setEmployeePassword(encodedPassword);
        
        // 기본값 세팅 (허용, 재직중)
        if(employeeVO.getEnabled() == null) employeeVO.setEnabled("1");
        if(employeeVO.getEmployeeStatus() == null) employeeVO.setEmployeeStatus("001");
        
        // 프로필 사진 - 파일 처리
        if (profile != null && ! profile.isEmpty()) {
        	int createdFileNo = saveFileAndGetNo(profile);
        	employeeVO.setFileNo(createdFileNo);
        }
        // 직원 정보 인서트함..
        employeeMapper.insertAcc(employeeVO);
        
        // 권한 부여
		String code = employeeVO.getEmployeeCode();
		String role = getRoleByCode(code);
		
        // 인서트된 새 계정에게 권한 주기
        EmployeeAuthVO employeeAuthVO = new EmployeeAuthVO();
        employeeAuthVO.setEmployeeNo(employeeVO.getEmployeeNo());
        employeeAuthVO.setAuth(role);
		
		employeeMapper.insertAccAuth(employeeAuthVO);
		
        return employeeVO.getEmployeeNo();
        
	}
	
	// 직책 코드(employeeCode)에 맞는 권한명(한글) 부여하기
	private String getRoleByCode(String code) {
		// 코드가 없으면 에러 발생 (가입 중단 & 롤백)
		if (code == null || code.trim().isEmpty()) {
			throw new RuntimeException("직책 코드가 선택되지 않았습니다. 가입이 불가능합니다.");
		}

		switch (code) {
			case "0": return "ROLE_ADMIN";
			case "1": return "ROLE_DOCTOR";
			case "2": return "ROLE_NURSE_OUT";
			case "3": return "ROLE_NURSE_IN";
			case "4": return "ROLE_PHARMACIST";
			case "5": return "ROLE_RADIOLOGIST";
			case "6": return "ROLE_THERAPIST";
			case "7": return "ROLE_OFFICE";
			
			default: throw new RuntimeException("유효하지 않은 직책 코드입니다. [" + code + "]");
		}
	}

	// 관리자 - 계정 상세 조회
	@Override
	public EmployeeVO selectEmployeeDetail(int employeeNo) {
		return employeeMapper.selectEmployeeDetail(employeeNo);
	}

	// 관리자 - 계정 수정
	@Transactional
	@Override
	public int updateAcc(EmployeeVO employeeVO, MultipartFile profile) {
		// 프로필 사진은 수정될 때만 fileNo 쓰기
		if(profile != null && !profile.isEmpty()) {
			int newFileNo = saveFileAndGetNo(profile);
			employeeVO.setFileNo(newFileNo);
		}
		return employeeMapper.updateAcc(employeeVO);
	}

	// 관리자 - 계정 퇴사 처리
	@Transactional
	@Override
	public int retireAcc(int employeeNo) {
		return employeeMapper.retireAcc(employeeNo);
	}
	
	// 프로필 사진 저장 로직 
	// 파일 저장 후 DB 에 등록한뒤 디테일번호 리턴
	private int saveFileAndGetNo(MultipartFile profile) {
		
		try {
			// 파일 업로드 및 경로 세팅
			String path = uploadPath + "profile";
			File folder = new File(path);
			if(!folder.exists()) {folder.mkdirs();}
			
			// 파일 이름 만들기, UUID 로 중복 방지
			String originalName = profile.getOriginalFilename();
            String uuid = UUID.randomUUID().toString();
            
            // 확장자 추출
            String extension = "";
			if(originalName != null && originalName.contains(".")) {
				extension = originalName.substring(originalName.lastIndexOf("."));
			}
			
			// 저장될 이름: UUID + 확장자
			String savedName = uuid + extension;
            
            // 실제 저장되게 하기
            File saveDest = new File(path, savedName);
            profile.transferTo(saveDest);
            
            // 첨부파일(부모) 테이블에 저장
            AttachmentVO attachmentVO = new AttachmentVO();
            employeeMapper.insertAttachment(attachmentVO);
            int attachmentNo = attachmentVO.getAttachmentNo();
            
            // DB 저장
            AttachmentDetailVO attachmentDetailVO = new AttachmentDetailVO();
            attachmentDetailVO.setAttachmentNo(attachmentNo);
            
            // 사용자에게 보여줄 '진짜 이름'
 			attachmentDetailVO.setAttachmentDetailName(originalName); 
 			attachmentDetailVO.setAttachmentDetailMime(profile.getContentType());
 			
 			// 저장 경로: 실제 저장된 파일명(UUID)으로 저장
 			attachmentDetailVO.setAttachmentDetailPath(saveDest.getAbsolutePath());
 			
 			// 확장자
 			attachmentDetailVO.setAttachmentDetailExt(extension.replace(".", "")); 
 			
 			attachmentDetailVO.setAttachmentDetailSize((int) profile.getSize());
 			attachmentDetailVO.setAttachmentDetailFancysize(FileUtils.byteCountToDisplaySize(profile.getSize()));
 			
 			employeeMapper.insertAttachmentDetail(attachmentDetailVO);
 			
 			return attachmentDetailVO.getAttachmentDetailNo();
            
		} catch (Exception e) {
			e.printStackTrace();
			throw new RuntimeException("파일 저장중 오류 발생~" + e.getMessage());
		}
	}

	
	// 관리자 - 엑셀 일괄 등록 (일괄 가입 시키기)
	@Override
	public Map<String, Object> uploadBulkExcel(MultipartFile file) {
		
		// null 값인 파일일시
		if (file == null || file.isEmpty()) {
			throw new IllegalArgumentException("엑셀 파일이 비어있습니다.");
		}
		
		// 핸들러 - 서비스에서 성공&실패&실패사유 변수 관리함
		int successCount = 0;
		int failCount = 0;
		List<Map<String, Object>> failDetails = new ArrayList<>();
		
		// 
		try(Workbook workbook = WorkbookFactory.create(file.getInputStream())) {
			Sheet sheet = workbook.getSheetAt(0);
			
			// 0행 : 헤더, 이후의 1행부터는 데이터
			for(int i=1; i<=sheet.getLastRowNum(); i++) {
				Row row = sheet.getRow(i);
				if (row == null) continue;
				
				// 사용자에게 보여줄 행 번호
				int displayRowNo = i+1;
				
		// =======================================================================================================================
		//	사번은 등록시 부여되니까 패스 ~
		// 엑셀 파일에 잇어야할거 : 0-이름, 1-코드, 2-전화번호, 3-입사일, 4-주민등록번호 앞자리, 5-주민등록번호 뒷자리, 6-이메일, 7-면허번호(없으면 null 값)
		// 없어도 되는거 : 사번(자동부여), 생년월일(주민등록번호 활용), 성별(주민등록번호 활용)
		// =======================================================================================================================
				try {
					// 이름
					String name = excelFileUtils.getCellValue(row.getCell(0));
						// 만약 빈줄이면 스킵함
						if(name.isEmpty()) continue;
					// 직원 코드
					String code = excelFileUtils.getCellValue(row.getCell(1));
					// 전화번호
					String telRaw = excelFileUtils.getCellValue(row.getCell(2));
					// 입사일
					Date regDate = excelFileUtils.getCellDateOrToday(row.getCell(3));
					// 주민등록번호 앞자리
					String regNo1 = toDigits(excelFileUtils.getCellValue(row.getCell(4)));
					// 주민등록번호 뒷자리
					String regNo2 = toDigits(excelFileUtils.getCellValue(row.getCell(5)));
					// 이메일
					String email = excelFileUtils.getCellValue(row.getCell(6));
					// 면허번호
					String licence = excelFileUtils.getCellValue(row.getCell(7));
					
					
					// 필수값 & 형식 검증
					String error = validateRow(name, code, telRaw, regNo1, regNo2, email);
					
						// 실패시 실패사유 리스트에 누적
						if(error != null) {
							excelResultHandler.addFail(failDetails, displayRowNo, error);
							failCount++;
							continue;
						}
					
					// 전화번호 정규화
					String tel = normalizePhone(telRaw);
					
						// 전화번호 등록 실패시
						if(tel == null) {
							excelResultHandler.addFail(failDetails, displayRowNo, 
									"전화번호 형식이 올바르지 않습니다 (" + telRaw + ") - 010 또는 02 필수");
							failCount++;
							continue;
						}
					
					// 생년월일, 성별 파싱 (재료 : 주민등록번호)
					BirthGen bg = parseBirthAndGen(regNo1, regNo2);
						
						if(bg == null) {
							excelResultHandler.addFail(failDetails, displayRowNo, "주민등록번호가 유효하지 않습니다");
							failCount++;
							continue;
						}
						
					// 헤더에 맞는 데이터 세팅
					EmployeeVO employeeVO = new EmployeeVO();
					
					employeeVO.setEmployeeName(name);
					employeeVO.setEmployeeCode(code);
					employeeVO.setEmployeeTel(tel);
					employeeVO.setEmployeeRegdate(regDate);
					employeeVO.setEmployeeRegno1(regNo1);
					employeeVO.setEmployeeRegno2(regNo2);
					employeeVO.setEmployeeBirth(bg.birth);
					employeeVO.setEmployeeGen(bg.gen);
					employeeVO.setEmployeeEmail(email);
					
					// 면허번호는 원무과 or 관리자만 null 값 허용함
					if(licence == null || licence.trim().isEmpty()) {
						employeeVO.setEmployeeDetailLicence("해당 없음");
					}else {
						employeeVO.setEmployeeDetailLicence(licence.trim());
					}
					
					// 기본값은 강제 세팅한당
					employeeVO.setHospitalNo(1);
					employeeVO.setEmployeeStatus("001");
					employeeVO.setEnabled("1");
					
					insertAcc(employeeVO, null);
					successCount++;
					
				}catch(Exception rowEx) {
					log.info("엑셀 업로드 행 처리 실패: {}행", displayRowNo, rowEx);
					excelResultHandler.addFail(failDetails, displayRowNo, rowEx);
					failCount++;
					}
				}
			}catch(Exception e) {
			throw new RuntimeException("엑셀 처리 중 오류가 발생했습니다: " + e.getMessage(), e);
		}
		return excelResultHandler.printExcelResult(successCount, failCount, failDetails);
	}
	
	// 생년월일 & 성별 클래스
	private static class BirthGen {
		String birth;
		String gen;
	}

	// 생년월일 & 성별 은 주민등록번호로 해결한다!
	private BirthGen parseBirthAndGen(String regNo1, String regNo2) {
		
		if (regNo1 == null || regNo1.length() != 6 || regNo2 == null || regNo2.length() != 7) return null;

        char g = regNo2.charAt(0);
        
        String prefix; String gen;
        
        // 1900 년대는 1,2,5,6만 해당하고 그 중 남자는 1,5
        if(g == '1' || g == '2' || g == '5' || g == '6') {
        	prefix = "19";
        	gen = (g == '1' || g == '5') ? "M" : "F";
        // 2000 년대는 3, 4, 7, 8만 해당하고 그 중 남자는 3,7
        }else if(g == '3' || g == '4' || g == '7' || g == '8') {
        	prefix = "20";
        	gen = (g == '3' || g == '7') ? "M" : "F";
        }else {
        	return null;
        }

        BirthGen bg = new BirthGen();
        
        bg.birth = prefix + regNo1.substring(0, 2) + "-" + regNo1.substring(2, 4) + "-" + regNo1.substring(4, 6);
        bg.gen = gen;
        
        return bg;
	}


	// 전화번호 하이픈 넣기 (11자리,10자리 허용)
	private String normalizePhone(String telRaw) {
		
		String d = toDigits(telRaw);
		
		// 전화번호는 11자리니까..
        if (d.length() == 11) {
            return d.substring(0, 3) + "-" + d.substring(3, 7) + "-" + d.substring(7);
        } else if (d.length() == 10) {
        	// 02는 10자리니까..
            if (d.startsWith("02")) {
                return "02-" + d.substring(2, 6) + "-" + d.substring(6);
            }
            return d.substring(0, 3) + "-" + d.substring(3, 6) + "-" + d.substring(6);
        }
        return null;
	}

	// 필수값 & 형식 검증
	private String validateRow(String name, String code, String telRaw, String regNo1, String regNo2, String email) {
		if (name == null || name.trim().isEmpty()) return "이름이 없습니다.";
		if (code == null || code.trim().isEmpty()) return "직책 코드가 없습니다.";
		if (telRaw == null || telRaw.trim().isEmpty()) return "전화번호가 없습니다.";
		
		// 주민등록번호(앞자리 6개, 뒤자리 7개)
		if (regNo1 == null || regNo1.length() != 6) return "주민번호 앞자리는 6자리여야 합니다.";
		if (regNo2 == null || regNo2.length() != 7) return "주민번호 뒷자리는 7자리여야 합니다.";
		
		if (email == null || email.trim().isEmpty()) return "이메일이 없습니다.";
		if (!EMAIL_PATTERN.matcher(email.trim()).matches()) return "이메일 형식이 올바르지 않습니다 (" + email + ")";
		
		return null;
	}

	// 숫자 이외는 다 제거하도록 해서 숫자만 남겨준다..                                                                                                                                                                                                                                                                                            
	private String toDigits(String cellValue) {
		if(cellValue == null) return "";
		return cellValue.replaceAll("[^0-9]", "");
	}

	// 관리자 - 엑셀 일괄 다운로드
	@Override
	public void downloadBulkExcel(HttpServletResponse response, EmployeeSearchVO searchVO) {
		
		// 일괄 다운로드를 하기위해선 페이징처리 없이 진행해야함
		Map<String, Object> map = new HashMap<>();
		
		map.put("keyword", searchVO.getKeyword());
		map.put("position", searchVO.getPosition());
		map.put("sort", searchVO.getSort());
		
		try {
			List<EmployeeVO> list = employeeMapper.downloadEmployeeExcelFile(map);
			
			try(Workbook workbook = new XSSFWorkbook()){
				Sheet sheet = workbook.createSheet("직원계정목록");
				
				// 헤더 스타일
				CellStyle headerStyle = workbook.createCellStyle();
				Font headerFont = workbook.createFont();
				
				headerFont.setBold(true);
				headerStyle.setFont(headerFont);
				headerStyle.setAlignment(HorizontalAlignment.CENTER);
				
				// 헤더 행 생성
				Row headerRow = sheet.createRow(0);
				
				String[] headers = {"사번", "이름", "직책", "전화번호", "이메일", "생년월일", "성별", "입사일"};
				
				for (int i = 0; i < headers.length; i++) {
	                Cell cell = headerRow.createCell(i);
	                cell.setCellValue(headers[i]);
	                cell.setCellStyle(headerStyle);
	            }
				
				// 데이터 행 생성
				int rowNum = 1;
				SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
				
				for(EmployeeVO employeeVO : list) {
					Row row = sheet.createRow(rowNum++);
					
					row.createCell(0).setCellValue(employeeVO.getEmployeeNo());
					row.createCell(1).setCellValue(employeeVO.getEmployeeName());
	                row.createCell(2).setCellValue(convertCodeToName(employeeVO.getEmployeeCode()));
	                row.createCell(3).setCellValue(employeeVO.getEmployeeTel());
	                row.createCell(4).setCellValue(employeeVO.getEmployeeEmail());
	                row.createCell(5).setCellValue(employeeVO.getEmployeeBirth());
	                row.createCell(6).setCellValue(employeeVO.getEmployeeGen());
	                String regDateStr = "";
	                if (employeeVO.getEmployeeRegdate() != null) {regDateStr = dateFormat.format(employeeVO.getEmployeeRegdate());}
	                row.createCell(7).setCellValue(regDateStr);
				}
				// 컬럼 너비 조절
				for(int i=0; i<headers.length; i++) {sheet.autoSizeColumn(i);}
				
				// 응답 헤더 세팅
				response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
				response.setCharacterEncoding("UTF-8");
				
				// 출력할 파일명 세팅
				String dateStr = new SimpleDateFormat("yyyy-MM-dd").format(new Date());
				String fileName = "직원계정목록_" + dateStr + ".xlsx";
				String encoded = URLEncoder.encode(fileName, StandardCharsets.UTF_8).replace("+", "%20");
				
				response.setHeader("Content-Disposition", "attachment; filename=\"" + encoded + "\"; filename*=UTF-8''" + encoded);

				
				// 출력
				try (OutputStream os = response.getOutputStream()) {
	                workbook.write(os);
	                os.flush();
	            }
			}
			
		} catch (Exception e) {
			log.error("엑셀 다운로드 중 에러 발생", e);
			writeJsonError(response, "엑셀 다운로드 처리 중 오류가 발생했습니다.");
		}
	}

	// 엑셀 다운로드 - 직책코드를 직책명으로 변환하는 메소드
	private String convertCodeToName(String employeeCode) {
		if (employeeCode == null) 
			return "";
		
		switch (employeeCode) {
			case "0": return "관리자";
			case "1": return "의사";
			case "2": return "외래간호사";
			case "3": return "입원간호사";
			case "4": return "약사";
			case "5": return "방사선사";
			case "6": return "물리치료사";
			case "7": return "원무과";
			default: return "";
		}
	}

	// 엑셀 다운로드 - 에러 시 JSON 응답
	private void writeJsonError(HttpServletResponse response, String msg) {
		try {
			if(!response.isCommitted()) {
		        response.reset();
		        response.setStatus(500);
		        response.setContentType("application/json;charset=UTF-8");
		        String safeMsg = (msg == null ? "서버 오류" : msg).replace("\"", "\\\"");
		        response.getWriter().write("{\"msg\":\"" + safeMsg + "\"}");
		        response.getWriter().flush();
		    }
		}catch (IOException ioEx) {
	        log.error("에러 응답 작성 실패", ioEx);
	    }
	}

	
	// 배정관리 전체 조회
	@Override
	public List<LocationVO> selectLocationList() {
		return employeeMapper.selectLocationList();
	}


	// 특정 계정 배정관리 조회
	@Override
	public List<LocationVO> selectEmployeeLocation(int employeeNo) {
		return employeeMapper.selectEmployeeLocation(employeeNo);
	}


	// 배정 수정 & 저장
	@Transactional
	@Override
	public void saveEmployeeLocation(LocationVO locationVO) {
		
		// 최소 검증(선택)
	    if (locationVO == null) {
	        throw new IllegalArgumentException("locationVO is null");
	    }
	    if (locationVO.getLocationNo() <= 0) {
	        throw new IllegalArgumentException("장소가 올바르지 않습니다.");
	    }
	    if (locationVO.getEmployeeNo() <= 0) {
	        throw new IllegalArgumentException("사번이 올바르지 않습니다.");
	    }

	    int updated = employeeMapper.updateLocationManager(locationVO);

	    if (updated == 0) {
	        // 업데이트 실패시
	        throw new RuntimeException("배정 저장 실패 (업데이트된 행 없음)");
	    }
	} 
}