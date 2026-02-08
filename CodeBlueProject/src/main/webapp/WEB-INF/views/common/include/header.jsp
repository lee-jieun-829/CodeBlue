<%@page import="kr.or.ddit.cpr.vo.EmployeeVO"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
    <!-- header는 공통 영역이기 때문에 수정할 경우 전체에 영향이 갈 수 있음 -->
    <!-- header와 관련된 javascript는 common.js 확인 -->
    <!-- 실시간 알림 등의 구현은 common.js에서 수행 -->
	<header>
        <div class="header-inner">
            <!-- 좌측: 로고/타이틀 -->
            <h1 class="header-title">
                <span class="header-title-highlight">SB</span> 정형외과
            </h1>
            
            <!-- 우측: 액션 버튼들 -->
            <div class="header-actions">
                <!-- 홈 버튼 -->
                <button class="header-icon-btn" aria-label="홈" onclick="location.href= location.protocol + '//' + location.hostname + ':5173'">
                    <i class="icon icon-home icon-lg"></i>
                </button>
                
                <!-- Dropdown UI -->
                <div class="dropdown">
                	<!-- 알림 -->
                	<jsp:include page="/WEB-INF/views/notification/notification.jsp" />
	            </div>
                
                <!-- 프로필 + dropdown -->
                <div class="dropdown">
                
                	<!-- 프로필 이미지 -->
	                <div class="header-profile" data-dropdown="profileDropdown">
	                	<div class="user-info text-sm">
	                		<span class="user-info-name">
	                			<b>${not empty employee ? employee.employeeName : '이철희'}</b> 님                				                			
	                		</span>
	                		<p>반갑습니다!</p>
	                	</div>
	                    <img src="https://placehold.co/36x36" alt="프로필" class="header-profile-img">
	                </div>
	                
	                <!-- 프로필 드롭다운 -->
	                <div id="profileDropdown" class="dropdown-menu">
	                    <div class="dropdown-header">계정</div>
	                    <a href="${pageContext.request.contextPath }/employee/mypage" class="dropdown-item">
	                        <i class="icon icon-user icon-md"></i>
	                        <span class="dropdown-item-text">마이페이지</span>
	                    </a>
	                    <div class="dropdown-divider"></div>
	                    <a href="#" class="dropdown-item dropdown-item-danger"
	                       onclick="document.getElementById('logoutForm')?.submit(); return false;">
	                        <i class="icon icon-logout icon-md icon-danger"></i>
	                        <span class="dropdown-item-text">로그아웃</span>
	                    </a>
                    </div>
                </div>
            </div>
        </div>
    </header>
    
    <form id="logoutForm" action="${pageContext.request.contextPath}/logout" method="post" hidden></form>