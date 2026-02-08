<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
  <head>
	<%@ include file="/WEB-INF/views/common/include/link.jsp" %>
	<style type="text/css">
	    .vital-fixed-table {
	        table-layout: fixed !important;
	        width: 100% !important;
	        border-collapse: collapse !important;
	    }
	
	    .vital-fixed-table th, 
	    .vital-fixed-table td {
	        text-align: left !important;
	        padding: 10px 5px !important;
	        vertical-align: middle !important;
	        overflow: hidden;
	        text-overflow: ellipsis;
	        white-space: nowrap;
	    }
	
	    .col-date { width: 25% !important; }
	    .col-time { width: 25% !important; }
	    .col-val  { width: 16.6% !important; }
	</style>
  </head>
  <body data-gnb="gnb-inpatient">
	<%@ include file="/WEB-INF/views/common/include/header.jsp" %>

      <div class="main-container flex h-full">
        
		<%@ include file="/WEB-INF/views/common/include/left/left_doctor.jsp" %>

        <!-- ===== Main 시작 ===== -->
		<main class="main-content flex-1 p-4 bg-neutral-100 overflow-hidden" style="height: calc(100vh - 4rem);">
		    <div class="grid h-full w-full" style="grid-template-columns: 320px 1fr 380px; gap: 1rem;"> 
		        
		        <div class="flex flex-col h-full overflow-hidden shrink-0">
		            <jsp:include page="/WEB-INF/views/doctor/inpatient/inc/patientList.jsp" />
		        </div>
		
		        <div id="detail-section" class="flex flex-col h-full overflow-hidden min-w-0 bg-white rounded-3xl shadow-md">
		            <div id="detail-empty-view" class="flex flex-col h-full items-center justify-center">
		                <div class="empty-state">
		                    <svg class="w-16 h-16 text-zinc-200 mb-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
		                        <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
		                    </svg>
		                    <p class="text-zinc-400 font-bold text-lg">내용 없음</p>
		                    <p class="text-zinc-300 text-sm">환자를 선택해주세요.</p>
		                </div>
		            </div>
		            <div id="detail-content-view" class="hidden h-full overflow-hidden flex flex-col">
		                <jsp:include page="/WEB-INF/views/doctor/inpatient/inc/clinicalDetail.jsp" />
		            </div>
		        </div>
		
		        <div id="order-section" class="flex flex-col h-full overflow-hidden shrink-0 bg-white rounded-3xl shadow-md">
		            <div id="order-empty-view" class="flex flex-col h-full items-center justify-center">
		                <div class="empty-state text-center">
		                    <svg class="w-16 h-16 text-zinc-200 mb-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
		                        <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
		                    </svg>
		                    <p class="text-zinc-400 font-bold text-lg">처방 내역 없음</p>
		                    <p class="text-zinc-300 text-sm">환자를 선택해주세요.</p>
		                </div>
		            </div>
		            <div id="order-content-view" class="hidden h-full overflow-hidden">
		                <jsp:include page="/WEB-INF/views/doctor/inpatient/inc/orderList.jsp" />
		            </div>
		        </div>
		
		    </div>
		</main>
        <!-- ===== Main 끝 ===== -->
        
      </div>
    
    <jsp:include page="/WEB-INF/views/doctor/inpatient/inc/modal.jsp" />
    <jsp:include page="/WEB-INF/views/certificate/inc/modal.jsp" />
    <jsp:include page="/WEB-INF/views/doctor/inpatient/inc/script.jsp" />

  </body>
</html>