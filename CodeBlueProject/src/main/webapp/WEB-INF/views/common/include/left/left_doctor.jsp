<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

	<!-- 
	======================================================================================
	 기존 style-guide의 sidebar가 수정이 되었습니다. 다음 사항을 참고하세요.
	 * 웹 표준 및 명확성을 위해 'gnb' 클래스 추가
	 * css 유지를 위해 'sidebar' 클래스 제거 절대 금지
	 * common.js에 메뉴 활성화를 위해 각 메뉴에 id가 추가되었으며, 연결되는 body에 dataset이
	   추가되었습니다. 형식을 지켜 사용해주세요.
	   
	   menu : id="[body 태그의 data-gnb 이름]"
	   page : body data-gnb="gnb-[페이지이름]"
	======================================================================================  
	-->
	
    <aside class="sidebar sidebar-vertical">
	    <nav class="gnb sidebar-nav">
	        <!-- 상단 메뉴 -->
	        <div class="sidebar-nav-group">
	            <%-- <a href="${pageContext.request.contextPath }/doctor/dashboard" class="gnb-item sidebar-nav-item" id="gnb-dashboard">
	                <i class="sidebar-nav-icon icon icon-desktop"></i>
	                <span class="sidebar-nav-label">대시보드</span>
	            </a>
	             --%>
	            <a href="${pageContext.request.contextPath }/doctor/outpatient" class="gnb-item sidebar-nav-item" id="gnb-dashboard">
	            	<i class="sidebar-nav-icon icon icon-doctor-bag"></i>
	                <span class="sidebar-nav-label">외래 진료</span>
	            </a>
	
	            <a href="${pageContext.request.contextPath }/doctor/inpatient/main" class="gnb-item sidebar-nav-item" id="gnb-inpatient">
	            	<i class="sidebar-nav-icon icon icon-bed"></i>
	                <span class="sidebar-nav-label">입원 진료</span>
	            </a>
	            
	            <a href="${pageContext.request.contextPath }/consultation/main" class="gnb-item sidebar-nav-item" id="gnb-consult">
	            	<i class="sidebar-nav-icon icon icon-users"></i>
	                <span class="sidebar-nav-label">협진</span>
	            </a>
	            
	            <a href="${pageContext.request.contextPath }/certificate/main" class="gnb-item sidebar-nav-item" id="gnb-certificate">
	            	<i class="sidebar-nav-icon icon icon-file"></i>
	                <span class="sidebar-nav-label">환자 서류</span>
	            </a>
	            
	            <a href="${pageContext.request.contextPath }/macro/shared" class="gnb-item sidebar-nav-item" id="gnb-macro">
	            	<i class="sidebar-nav-icon icon icon-folder"></i>
	                <span class="sidebar-nav-label">나의 오더</span>
	            </a>
	            
	             <a href="${pageContext.request.contextPath }/order/drug" class="gnb-item sidebar-nav-item" id="gnb-order">
	            	<i class="sidebar-nav-icon icon icon-box"></i>
	                <span class="sidebar-nav-label">물품 발주</span>
	            </a>
	
	        </div>
	
		
	        <!-- 하단 메뉴 -->
	        <div class="sidebar-nav-group">
            	<a href="${pageContext.request.contextPath }/notice/main" class="gnb-item sidebar-nav-item" id="gnb-notice">
                	<i class="sidebar-nav-icon icon icon-megaphone"></i>
                    <span class="sidebar-nav-label">공지사항</span>
                </a>
                
            	<a href="${pageContext.request.contextPath }/schedule/main" class="gnb-item sidebar-nav-item" id="gnb-schedule">
                	<i class="sidebar-nav-icon icon icon-calendar"></i>
                    <span class="sidebar-nav-label">일정</span>
                </a>
                
            	<a href="#" class="gnb-item sidebar-nav-item unique-item" id="gnb-messenger" onclick="messengerOpen(event)">
                	<i class="sidebar-nav-icon icon icon-chat-messages"></i>
                    <span class="sidebar-nav-label">메신저</span>
                </a>
                
            </div>
        </nav>
    </aside>
    
    <!-- 메신저 -->
    <div id="messengerContainer" class="messenger_container">
    	<%@ include file="/WEB-INF/views/common/include/messenger.jsp" %>
    </div>