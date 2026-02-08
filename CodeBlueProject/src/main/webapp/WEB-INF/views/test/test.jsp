<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt"  prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	<h1>테스트 페이지 입니다.</h1>
	 <table border="1">
	 	<tbody>
	 		<tr style="text-align: right;">
	 			<td>ROW</td>
	 			<td>공통 번호</td>
	 			<td>공통 코드</td>
	 			<td>코멘트</td>
	 			<td>생성 날짜</td>
	 			<td>상세 번호</td>
	 			<td>상세 코드</td>
	 			<td>상세 코멘트</td>
	 		</tr>
	 		
	 		<c:forEach items="${testVO}" var="testVO" varStatus="vs">
		 		<tr style="text-align: right;">
		 			<td>${vs.count }</td>
		 			<td>${testVO.commonNo }</td>
		 			<td>${testVO.commonComment }</td>
		 			<td>${testVO.commonName }</td>
		 			<td><fmt:formatDate value="${testVO.commonRegdate }" pattern="yyyy-MM-dd일 hh:mm분" /> </td>
		 			<td>${testVO.commonDetailNo }</td>
		 			<td>${testVO.commonDetailName }</td>
		 			<td>${testVO.commonDetailComment }</td>
		 		</tr>
	 		</c:forEach>
	 	</tbody>
	 </table>
</body>
</html>