<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>공지 상세 - SB 정형외과</title>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<style>
/* [초기화 및 공통 레이아웃] */
* {
	box-sizing: border-box;
	margin: 0;
	padding: 0;
}

a {
	text-decoration: none;
	color: inherit;
}

body {
	font-family: 'Noto Sans KR', 'Malgun Gothic', sans-serif;
	background-color: #f5f6f8;
	height: 100vh;
	display: flex;
	flex-direction: column;
	overflow: hidden;
}

/* [헤더] */
header {
	height: 60px;
	background-color: #fff;
	border-bottom: 1px solid #ddd;
	display: flex;
	align-items: center;
	justify-content: space-between;
	padding: 0 20px;
	flex-shrink: 0;
	z-index: 10;
}

.logo {
	font-size: 20px;
	font-weight: bold;
	color: #333;
}

.logo span {
	color: #2962ff;
}

.header-icons i {
	margin-left: 20px;
	font-size: 18px;
	color: #555;
	cursor: pointer;
}

/* [메인 컨테이너] */
.container {
	display: flex;
	flex: 1;
	height: calc(100vh - 60px);
}

/* [1. 사이드바] */
.sidebar {
	width: 80px;
	background-color: #fff;
	border-right: 1px solid #ddd;
	display: flex;
	flex-direction: column;
	align-items: center;
	padding-top: 20px;
	flex-shrink: 0;
}

.menu-item {
	width: 100%;
	height: 70px;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;
	color: #666;
	cursor: pointer;
	transition: 0.2s;
	font-size: 12px;
}

.menu-item i {
	font-size: 24px;
	margin-bottom: 5px;
}

.menu-item:hover, .menu-item.active {
	background-color: #e3f2fd;
	color: #2962ff;
	border-left: 3px solid #2962ff;
}

/* [콘텐츠 영역] - 3단 구조 (서브메뉴 | 리스트 | 상세) */
.content-area {
	flex: 1;
	padding: 20px;
	display: flex;
	gap: 15px;
	overflow: hidden; /* 내부 패널만 스크롤 */
}

/* 공통 패널 스타일 */
.panel {
	background: #fff;
	border-radius: 12px;
	box-shadow: 0 2px 10px rgba(0, 0, 0, 0.03);
	display: flex;
	flex-direction: column;
	overflow: hidden;
}

/* [2. 서브 메뉴 패널] */
.sub-menu-panel {
	width: 220px;
	flex-shrink: 0;
	padding: 20px;
}

.sub-title {
	font-size: 16px;
	font-weight: bold;
	margin-bottom: 15px;
	border-left: 4px solid #2962ff;
	padding-left: 10px;
	color: #333;
}

.sub-nav-item {
	padding: 12px 15px;
	border-radius: 8px;
	margin-bottom: 5px;
	cursor: pointer;
	font-size: 14px;
	color: #333;
}

.sub-nav-item.active {
	background-color: #e3f2fd;
	color: #2962ff;
	font-weight: bold;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

/* [3. 리스트 패널 (중간)] */
.list-panel {
	width: 350px;
	flex-shrink: 0;
	border-right: 1px solid #eee;
}

.list-header {
	padding: 15px 20px;
	border-bottom: 1px solid #eee;
}

.list-header h2 {
	font-size: 16px;
	font-weight: bold;
	color: #333;
}

.list-content {
	flex: 1;
	overflow-y: auto;
	padding: 10px;
}

.post-card {
	padding: 15px;
	border-radius: 8px;
	margin-bottom: 8px;
	cursor: pointer;
	border: 1px solid transparent;
	transition: 0.2s;
	background: #fff;
}

.post-card:hover {
	background-color: #f9f9f9;
}

/* 현재 보고 있는 게시물 활성화 스타일 */
.post-card.active {
	background-color: #e3f2fd;
	border-color: #2962ff;
}

.post-card.active .post-title {
	color: #2962ff;
	font-weight: bold;
}

.post-title {
	font-size: 14px;
	margin-bottom: 5px;
	color: #333;
	line-height: 1.4;
}

.post-date {
	font-size: 12px;
	color: #999;
}

/* [4. 상세 패널 (우측 메인)] */
.detail-panel {
	flex: 1;
	min-width: 500px;
	display: flex;
	flex-direction: column;
}

/* 상세 헤더 */
.detail-header {
	padding: 30px 40px;
	border-bottom: 1px solid #eee;
}

.badge {
	display: inline-block;
	font-size: 11px;
	padding: 4px 8px;
	border-radius: 4px;
	background-color: #ffe0b2;
	color: #f57c00;
	font-weight: bold;
	margin-bottom: 10px;
}

.detail-title {
	font-size: 22px;
	font-weight: bold;
	color: #333;
	margin-bottom: 15px;
	line-height: 1.4;
}

.detail-meta {
	display: flex;
	gap: 20px;
	font-size: 13px;
	color: #888;
}

.detail-meta i {
	margin-right: 5px;
}

/* 상세 본문 */
.detail-body {
	flex: 1;
	padding: 40px;
	overflow-y: auto;
	font-size: 15px;
	line-height: 1.8;
	color: #444;
}

.detail-content {
	white-space: pre-wrap; /* 줄바꿈 유지 */
}

/* 파일 첨부 영역 */
.file-box {
	margin-top: 40px;
	padding: 15px 20px;
	background-color: #f8f9fa;
	border: 1px solid #e9ecef;
	border-radius: 8px;
	display: flex;
	align-items: center;
}

.file-label {
	font-weight: bold;
	font-size: 13px;
	color: #555;
	margin-right: 15px;
}

.file-link {
	font-size: 14px;
	color: #2962ff;
	text-decoration: none;
	display: flex;
	align-items: center;
	gap: 5px;
}

.file-link:hover {
	text-decoration: underline;
}

/* 하단 버튼 그룹 */
.detail-footer {
	padding: 20px 40px;
	border-top: 1px solid #eee;
	background-color: #fafafa;
	display: flex;
	justify-content: space-between;
	align-items: center;
}

.btn {
	padding: 10px 20px;
	border-radius: 6px;
	font-size: 13px;
	font-weight: bold;
	cursor: pointer;
	border: none;
	transition: 0.2s;
	display: inline-flex;
	align-items: center;
	gap: 5px;
}

/* 목록 버튼 (좌측) */
.btn-list {
	background-color: #fff;
	border: 1px solid #ddd;
	color: #666;
}

.btn-list:hover {
	background-color: #f0f0f0;
}

/* 수정/삭제 버튼 (우측) */
.btn-right-group {
	display: flex;
	gap: 10px;
}

.btn-edit {
	background-color: #2962ff;
	color: #fff;
}

.btn-edit:hover {
	background-color: #1e4bd1;
}

.btn-delete {
	background-color: #fff;
	border: 1px solid #ff5252;
	color: #ff5252;
}

.btn-delete:hover {
	background-color: #ffebee;
}

/* 스크롤바 커스텀 */
::-webkit-scrollbar {
	width: 6px;
}

::-webkit-scrollbar-thumb {
	background: #ccc;
	border-radius: 10px;
}

::-webkit-scrollbar-track {
	background: transparent;
}
</style>
</head>
<body>

	<header>
		<div class="logo">
			<span>SB</span> 정형외과
		</div>
		<div class="header-icons">
			<i class="fas fa-home"></i> <i class="fas fa-search"></i> <i
				class="fas fa-bell"></i>
		</div>
	</header>

	<div class="container">

		<aside class="sidebar">
			<div class="menu-item">
				<i class="fas fa-chart-bar"></i>통계
			</div>
			<div class="menu-item">
				<i class="fas fa-user-md"></i>계정
			</div>
			<div class="menu-item">
				<i class="fas fa-keyboard"></i>매크로
			</div>
			<div class="menu-item active">
				<i class="fas fa-bullhorn"></i>공지사항
			</div>
			<div class="menu-item">
				<i class="fas fa-calendar-alt"></i>일정
			</div>
		</aside>

		<main class="content-area">

			<section class="panel sub-menu-panel">
				<h3 class="sub-title">게시판 관리</h3>
				<div class="sub-nav-item active">공지사항 관리</div>
			</section>

			<section class="panel list-panel">
				<div class="list-header">
					<h2>목록</h2>
				</div>
				<div class="list-content">
					<c:forEach items="${noticeList}" var="item">
						<div
							class="post-card ${item.noticeNo == param.noticeNo ? 'active' : ''}"
							onclick="location.href='detail?noticeNo=${item.noticeNo}'">

							<div class="post-title">
								<c:if
									test="${item.noticeImportant eq 'Y' or item.noticeImportant eq 'IMP'}">
									<i class="fas fa-star"
										style="color: #ffb300; font-size: 12px; margin-right: 3px;"></i>
								</c:if>
								<c:out value="${item.noticeTitle}" />
							</div>
							<div class="post-date">
								<fmt:formatDate value="${item.noticeRegDate}"
									pattern="yyyy.MM.dd" />
							</div>
						</div>
					</c:forEach>
				</div>
			</section>

			<section class="panel detail-panel">

				<div class="detail-header">
					<c:if
						test="${notice.noticeImportant eq 'Y' or notice.noticeImportant eq 'IMP'}">
						<span class="badge"><i class="fas fa-bullhorn"></i> 중요 공지</span>
					</c:if>

					<div class="detail-title">
						<c:out value="${notice.noticeTitle}" />
					</div>

					<div class="detail-meta">
						<span><i class="far fa-calendar"></i> <fmt:formatDate
								value="${notice.noticeRegDate}" pattern="yyyy.MM.dd HH:mm" /></span> <span><i
							class="far fa-user"></i> 관리자</span> <span><i class="far fa-eye"></i>
							조회수 0</span>
					</div>
				</div>

				<div class="detail-body">
					<div class="detail-content">
						<c:out value="${notice.noticeContent}" />
					</div>

					<c:if test="${notice.fileNo > 0}">
						<div class="file-box">
							<span class="file-label">첨부파일</span> <a
								href="${pageContext.request.contextPath}/admin/download?fileNo=${notice.fileNo}"
								class="file-link"> 첨부파일 다운로드 </a> 
						</div>
					</c:if>
				</div>

				<div class="detail-footer">
					<button type="button" class="btn btn-list"
						onclick="location.href='list'">
						<i class="fas fa-list"></i> 목록으로
					</button>

					<div class="btn-right-group">
						<button type="button" class="btn btn-edit"
							onclick="location.href='updateForm?noticeNo=${notice.noticeNo}'">
							<i class="fas fa-edit"></i> 수정
						</button>

						<form action="delete" method="post"
							onsubmit="return confirm(' 정말 삭제하시겠습니까?');" style="margin: 0;">
							<input type="hidden" name="noticeNo" value="${notice.noticeNo}">
							<button type="submit" class="btn btn-delete">
								<i class="fas fa-trash-alt"></i> 삭제
							</button>
						</form>
					</div>
				</div>

			</section>

		</main>
	</div>
</body>
</html>