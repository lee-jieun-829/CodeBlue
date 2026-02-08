package kr.or.ddit.cpr.vo;

import com.fasterxml.jackson.annotation.JsonInclude;

import lombok.Data;

@Data
@JsonInclude
public class aifunVO {
	//검색용 필드
	public String searchKeyword;
	
	//상병 리스트 조회를 위한 vo
	public int diagnosisNo;
	public String diagnosisCode; //상병코드
	public String diagnosisName; //상병명
	//치료 리스트 조회를 위한 vo
	public String treatmentCode; //치료코드
	public String treatmentName; //치료명
	//약품 리스트 조회를 위한 vo
	public String drugCode; //약품코드
	public String drugName; //약품명
	public String drugType; //투여구분
	public String drugSpec; //용량	
	public String drugCompany;//제조사
	private int drugNo;	//약품번호
}
