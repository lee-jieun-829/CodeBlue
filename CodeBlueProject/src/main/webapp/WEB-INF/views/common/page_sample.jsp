<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<!-- ===== Head 시작 ===== -->
<%@ include file="/WEB-INF/views/common/include/link.jsp" %>
<!-- ===== Head 끝 ===== -->
<title>Insert title here</title>
</head>
<body data-gnb="dashboard">
	<!-- ===== Header 시작 ===== -->
	<%@ include file="/WEB-INF/views/common/include/header.jsp" %>
	<!-- ===== Header 끝 ===== -->
	
	<div class="main-container">
		<!-- ===== Sidebar 시작 (각 액터에 따라 sidebar jsp 교체)  ===== -->
		<%@ include file="/WEB-INF/views/common/include/left/left_default.jsp" %>
		<!-- ===== Sidebar 끝 ===== -->
		
		<!-- ===== Main 시작 ===== -->
		<main class="main-content">
			<div class="grid grid-full-height"> <!-- main이 2분할 이상일 경우 grid 사이즈 클래스 추가 필요 -->
				<!-- 콘텐츠 영역 -->
				<div class="content-area flex">
					<div class="box">
                        <h2 class="box-title">콘텐츠 제목</h2>
                        <div>콘텐츠 내용</div>
                    </div>
				</div>
			</div>
		</main>
		<!-- ===== Main 끝 ===== -->
	</div>
	
</body>
</html>