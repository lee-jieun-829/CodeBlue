<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
    <aside class="sidebar sidebar-vertical">
	    <nav class="gnb sidebar-nav">
	        <!-- 상단 메뉴 -->
	        <div class="sidebar-nav-group">
	            <a href="${pageContext.request.contextPath }/radiologist/dashboard" class="gnb-item sidebar-nav-item" id="gnb-dashboard">
	                <i class="sidebar-nav-icon icon icon-desktop"></i>
	                <span class="sidebar-nav-label">대시보드</span>
	            </a>
	            
	            <a href="${pageContext.request.contextPath }/radiologist/workview" class="gnb-item sidebar-nav-item" id="gnb-workview">
	            	<i class="sidebar-nav-icon icon icon-doctor-bag"></i>
	                <span class="sidebar-nav-label">영상 검사</span>
	            </a>
	
				<a href="${pageContext.request.contextPath }/certificate/main" class="gnb-item sidebar-nav-item" id="gnb-certificate">
	            	<i class="sidebar-nav-icon icon icon-file"></i>
	                <span class="sidebar-nav-label">환자 서류</span>
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