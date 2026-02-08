package kr.or.ddit.cpr.employee;

import lombok.Data;

@Data
public class EmployeeSearchVO {
	// DB 컬럼 아님!!! 그냥 리액트가 보낸거 받을 변수 모음집임!!!
	private String position;	// 리액트에서 보낸 직책
	private String sort;		// 리액트에서 보낸 정렬 기준 
	private String keyword;		// 리액트에서 보낸 직원 검색어
}