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
            <nav class="sidebar-nav">
                <!-- 상단 메뉴 -->
                <div class="sidebar-nav-group">
                    <a href="#" class="sidebar-nav-item">
                        <div class="sidebar-nav-icon">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <rect x="3" y="3" width="7" height="7"></rect>
                                <rect x="14" y="3" width="7" height="7"></rect>
                                <rect x="14" y="14" width="7" height="7"></rect>
                                <rect x="3" y="14" width="7" height="7"></rect>
                            </svg>
                        </div>
                        <div class="sidebar-nav-label">대시보드</div>
                    </a>

                    <a href="#" class="sidebar-nav-item active">
                        <div class="sidebar-nav-icon">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor">
                                <rect x="7" y="7" width="10" height="10" rx="2"></rect>
                            </svg>
                        </div>
                        <div class="sidebar-nav-label">외래 진료</div>
                    </a>

                    <a href="#" class="sidebar-nav-item">
                        <div class="sidebar-nav-icon">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path>
                                <polyline points="9 22 9 12 15 12 15 22"></polyline>
                            </svg>
                        </div>
                        <div class="sidebar-nav-label">입원 진료</div>
                    </a>

                    <a href="#" class="sidebar-nav-item">
                        <div class="sidebar-nav-icon">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                                <circle cx="9" cy="7" r="4"></circle>
                                <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                                <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                            </svg>
                        </div>
                        <div class="sidebar-nav-label">협진</div>
                    </a>

                    <a href="#" class="sidebar-nav-item">
                        <div class="sidebar-nav-icon">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                                <polyline points="14 2 14 8 20 8"></polyline>
                                <line x1="16" y1="13" x2="8" y2="13"></line>
                                <line x1="16" y1="17" x2="8" y2="17"></line>
                                <polyline points="10 9 9 9 8 9"></polyline>
                            </svg>
                        </div>
                        <div class="sidebar-nav-label">환자 서류</div>
                    </a>

                    <a href="#" class="sidebar-nav-item">
                        <div class="sidebar-nav-icon">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5">
                                <rect x="3" y="3" width="7" height="7"></rect>
                                <rect x="14" y="3" width="7" height="7"></rect>
                                <rect x="14" y="14" width="7" height="7"></rect>
                                <rect x="3" y="14" width="7" height="7"></rect>
                            </svg>
                        </div>
                        <div class="sidebar-nav-label">나의 세트</div>
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