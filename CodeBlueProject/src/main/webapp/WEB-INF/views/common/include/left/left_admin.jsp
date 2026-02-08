<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<aside class="sidebar sidebar-vertical">
    <nav class="gnb sidebar-nav">
        <div class="sidebar-nav-group">
            <a href="http://localhost:5173/admin/employees" class="gnb-item sidebar-nav-item" id="gnb-employees">
                <i class="sidebar-nav-icon icon icon-users"></i>
                <span class="sidebar-nav-label">계정관리</span>
            </a>

            <a href="http://localhost:5173/admin/macro" class="gnb-item sidebar-nav-item" id="gnb-macro">
                <i class="sidebar-nav-icon icon icon-folder"></i>
                <span class="sidebar-nav-label">나의 오더</span>
            </a>
            
            <a href="http://localhost:5173/admin/stats" class="gnb-item sidebar-nav-item" id="gnb-stats">
                <i class="sidebar-nav-icon icon icon-chart-graph"></i>
                <span class="sidebar-nav-label">통계</span>
            </a>
            
            <a href="http://localhost:5173/admin/orders" class="gnb-item sidebar-nav-item" id="gnb-order">
                <i class="sidebar-nav-icon icon icon-box"></i>
                <span class="sidebar-nav-label">물품 발주</span>	
            </a>
        </div>
    
        <div class="sidebar-nav-group">
            <a href="http://localhost:8060/admin/notice/list" class="gnb-item sidebar-nav-item" id="gnb-notice">
                <i class="sidebar-nav-icon icon icon-megaphone"></i>
                <span class="sidebar-nav-label">공지사항</span>
            </a>
            
            <a href="http://localhost:5173/calendar" class="gnb-item sidebar-nav-item" id="gnb-calendar">
                <i class="sidebar-nav-icon icon icon-calendar"></i>
                <span class="sidebar-nav-label">일정</span>
            </a>
            
            <a href="javascript:void(0);" onclick="toggleMessenger()" class="gnb-item sidebar-nav-item unique-item" id="gnb-messenger">
                <i class="sidebar-nav-icon icon icon-chat-messages"></i>
                <span class="sidebar-nav-label">메신저</span>
            </a>
        </div>
    </nav>
</aside>

<div id="messengerContainer" class="messenger_container">
    <%@ include file="/WEB-INF/views/common/include/messenger.jsp" %>
</div>