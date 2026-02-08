package kr.or.ddit.cpr.vo;

import java.util.Date;
import java.util.List;

import org.springframework.web.multipart.MultipartFile;

import lombok.Data;

/**
 * ================================
 * - 치료 오더 VO
 * - auth : Been daye
 * - date : 2026.01.12
 * ================================
 */

@Data
public class TreatmentOrderVO {
	
	private int chartNo;
	 
	// 처방 정보
	private int patientNo;
	private int predetailNo;
	private Date predetailRegdate;
	private String predetailType;
	private String predetailStatus;
	 
	private List<TreatmentVO> treatmentVO;
	
	// 커스텀
	private String orderDate;      // TO_CHAR로 만든 날짜 문자열
	private int examCount;         // COUNT로 만든 건수
	private String isCurrentOrder; // 'Y' 또는 'N'
}
