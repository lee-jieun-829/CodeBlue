<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html>
<head>
<!-- ===== Head 시작 ===== -->
<%@ include file="/WEB-INF/views/common/include/link.jsp" %>
<!-- ===== Head 끝 ===== -->

<!-- 카카오 주소 API -->
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script src="${pageContext.request.contextPath}/resources/assets/js/reception.js"></script>

<style>
	/* SweetAlert2 아이콘 및 정렬 깨짐 강제 수정 */
	.swal2-title {
	    display: block !important;
	    text-align: center !important;
	}
	.swal2-actions {
	    justify-content: center !important;
	} */
	
	/* 초기 로딩 시 탭 깜빡임 방지 */
	.tab-panel {
	    display: none !important;
	}
	
	/* active 상태인 패널만 보이게 설정 */
	.tab-panel:not(.hidden) {
	    display: flex !important;
	}
	
	/* [외래/입원]접수 검색 드롭다운 */
	.search-dropdown {
	    position: absolute;
	    top: 100%;
	    left: 0;
	    width: 100%;
	    max-height: 250px;
	    overflow-y: auto;
	    background-color: #ffffff;
	    border: 1px solid #e2e8f0;
	    border-top: none;
	    border-radius: 0 0 0.5rem 0.5rem;
	    box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1); 
	    z-index: 1000;
	}
	
	.search-item {
	    padding: 10px 15px;
	    border-bottom: 1px solid #f1f5f9;
	    cursor: pointer;
	    transition: all 0.2s ease;
	}
	
	.search-item:last-child {
	    border-bottom: none;
	}
	
	.search-item:hover {
	    background-color: #f8fafc; 
	}
	
	.search-item .p-name {
	    font-size: 0.9rem;
	    font-weight: 600;
	    color: #1e293b; 
	}
	
	.search-item .p-info {
	    font-size: 0.75rem;
	    color: #64748b; 
	    margin-left: 8px;
	}
	
	/* 스크롤바 커스텀 */
	.search-dropdown::-webkit-scrollbar {
	    width: 6px;
	}
	.search-dropdown::-webkit-scrollbar-thumb {
	    background-color: #cbd5e1;
	    border-radius: 10px;
	}
	
	/* 제증명 발급요청 긴급여부 토글 */
	.peer-checked\:bg-red-500 {
	    position: relative;
	    display: flex;
	    align-items: center;
	}
	
	.peer ~ div::after {
	    content: '';
	    position: absolute;
	    top: 50% !important; 
	    transform: translateY(-50%) !important;
	    left: 2px;
	    background-color: white;
	    border-radius: 9999px;
	    height: 1.25rem; /* 20px */
	    width: 1.25rem;  /* 20px */
	    transition: all 0.3s;
	}
	
	/* 체크되었을 때 오른쪽으로 이동  */
	.peer:checked ~ div::after {
	    left: calc(100% - 22px) !important; 
	    transform: translateY(-50%) !important;
	}
</style>
<title>Insert title here</title>
</head>
<body data-gnb="gnb-reception">
	<!-- ===== Header 시작 ===== -->
	<%@ include file="/WEB-INF/views/common/include/header.jsp" %>
	<!-- ===== Header 끝 ===== -->
	
	<div class="main-container">
		<!-- ===== Sidebar 시작 (각 액터에 따라 sidebar jsp 교체)  ===== -->
		<%@ include file="/WEB-INF/views/common/include/left/left_reception.jsp" %>
		<!-- ===== Sidebar 끝 ===== -->

		<!-- ===== Main 시작 ===== -->
		<main class="main-content flex-1 flex flex-col min-h-0 overflow-hidden">
			<div class="grid grid-cols-[1fr_350px] h-full min-h-0 overflow-hidden gap-4">
				<!-- 콘텐츠 영역 -->
				<div class="content-area flex flex-col h-full min-h-0 overflow-hidden">
					<div class="box h-full flex flex-col p-0 min-h-0 overflow-hidden">
						<div class="tabs tabs-underline border-b shrink-0 bg-white">
						    <button class="tab active" onclick="showTab(event, 'tab-outpatient')">외래접수/수납</button>
						    <button class="tab" onclick="showTab(event, 'tab-inpatient')">입원접수/수납</button>
						    <button class="tab" onclick="showTab(event, 'tab-reservation')">진료/입원예약등록</button>
						    <button class="tab" onclick="showTab(event, 'tab-certificate')">제증명 관리</button>
						</div>
		                <div class="flex-1 min-h-0 overflow-hidden" id="main-tab-content">
		                	<!-- 외래접수/수납 시작 -->
	    					<div id="tab-outpatient" class="tab-panel split-inner split-inner-2 flex gap-md py-4 h-full min-h-0 overflow-hidden">
        
						        <div class="w-1/2 h-full flex flex-col min-h-0">
						            <div class="box h-full flex flex-col">
						                <div class="flex items-center justify-between mb-6 shrink-0">
						                    <h3 class="text-xl font-bold flex items-center gap-2 text-blue-700 py-1">
						                        <span class="w-1.5 h-6 bg-blue-600 rounded-full"></span>외래 환자 접수
						                    </h3>
						                    <button type="button" onclick="openModal('modal-new-patient')" class="btn btn-light btn-sm btn-icon-left">
						                    	<i class="icon icon-sm icon-plus"></i>신규 환자 등록
						                    </button>
						                </div>
						
						                <div class="flex-1 overflow-y-auto scroll-content space-y-6 pr-2">
						                    <div class="form-group">
						                        <label class="form-label font-bold text-slate-700 mb-2">접수 환자 검색</label>
						                        <div class="relative">
						                            <input type="text" id="outSearch" placeholder="검색어를 입력하세요" autocomplete="off"
						                                   class="input input-search h-11" onkeyup="showSearchDropdown(this.value, 'OUT')"
						                                   onkeypress="if(event.keyCode==13) { window.executePatientSearch(this.value); }">
						                            <div id="outSearchDropdown" class="search-dropdown hidden"></div>
						                        </div>
						                    </div>
						                    
						                    <div class="form-group">
						                        <label class="form-label font-bold text-slate-700 mb-2">환자 성명</label>
											    <div class="flex gap-2">
											       <input type="text" id="outPatientName" readonly placeholder="접수 환자 검색 후 환자를 선택헤주세요." 
											               class="input cursor-not-allowed">
											    </div>
						                    </div>	
						
						                    <div class="form-row form-row-2 md-0">
						                        <div class="form-group">
												    <label class="form-label font-bold text-slate-700 mb-2">진료실/담당의</label>
												   <select id="outEmployeeChange" class="select h-11 w-full border-purple-100 focus:border-purple-500">
												    <option value="">담당의를 선택하세요</option>
												    
												</select>
												</div>
						                        <div class="form-group">
											        <label class="form-label font-bold text-slate-700 mb-2">보험 유형</label>
											        <select id="outInsurance" class="select h-11">
											            <option value="001">건강보험</option>
											            <option value="002">차상위1종</option>
											            <option value="003">차상위2종</option>
											            <option value="004">급여1종</option>
											            <option value="005">급여2종</option>
											            <option value="006">산재</option>
											            <option value="007">산재100</option>
											            <option value="008">후유장해</option>
											            <option value="009">자보</option>
											            <option value="010">자보100</option>
											            <option value="011">일반</option>
											            <option value="012">일반100</option>
											        </select>
											    </div>
						                    </div>
						
						                    <div class="form-group">
						                        <label class="form-label font-bold text-slate-700 mb-2">환자 메모</label>
						                        <textarea id="outSearchPatientMemo" rows="1.5" class="textarea resize-none p-4" placeholder="알러지, 복용약 등 주의사항 입력"></textarea>
						                    </div>
						
						                </div>
					                    <div class="pt-4">
					                    	<!-- 초진 데이터 전송 -->
               								<input type="hidden" id="registrationVisittype" value="002">
					                    	<!-- 재진 데이터 전송 -->
					                    	<input type="hidden" id="outVisittype" value="003">
					                        <button class="btn btn-primary w-full btn-lg" onclick="completeRegistration()">
					                            외래 접수 완료
					                        </button>
					                    </div>
						            </div>
						        </div>
						
						        <div class="w-1/2 h-full flex flex-col min-h-0">
						            <div class="box h-full flex flex-col">
						                <h3 class="text-xl font-bold flex items-center gap-2 text-emerald-700 mb-6 shrink-0 py-1">
						                    <span class="w-1.5 h-6 bg-emerald-600 rounded-full"></span>외래 수납 및 결제
						                </h3>
						                
						                <div class=" mb-6 h-60 flex flex-col">
						                    <div class="flex items-center justify-between mb-2 shrink-0">
						                        <p class="font-bold uppercase tracking-widest">Waiting List</p>
						                        <div class="relative w-1/3">
						                            <input type="text" placeholder="검색어를 입력하세요" class="input input-search input-sm" 						            
						                            	onkeyup="executeSettlementSearch(this.value.trim(), 'OUT')">
						                        </div>
						                    </div>
						                    <div class="bg-slate-50 border border-slate-200 rounded-md p-3 flex-1 overflow-y-auto scroll-content space-y-3" id="outpatient-waiting-list">
                							</div>
						                </div>
						
						                <div class="flex-1 flex flex-col overflow-hidden">
											<div class="content-header">
												<h4 class="content-header-title py-1"><span id="outpatient-bill-target-name">환자</span> 님 상세 정산서</h4>
												<span class="badge badge-info" id="outpatient-bill-target-no">-</span>
											</div>
										
											<div class="flex-1 overflow-y-auto scroll-content flex flex-col">
												<div class="flex-1 table-wrapper mb-6 rounded-lg border border-slate-100">
													<table class="table">
														<thead class="bg-slate-50">
															<tr>
																<th class="text-left py-3 px-4 text-slate-500 font-semibold">항목</th>
																<th class="text-right py-3 px-4 text-blue-600 font-semibold">본인부담금</th>
															</tr>
														</thead>
														<tbody id="outpatient-bill-items" class="divide-y divide-slate-100">
															<tr>
																<td colspan="2" class="py-4 text-center text-secondary">대상자를 선택해주세요.</td>
															</tr>
														</tbody>
													</table>
												</div>
										
												<div class="bg-emerald-600 rounded-md p-4 text-white flex justify-between items-center mb-4">
													<svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" class="opacity-20"> 
														<rect x="2" y="4" width="20" height="16" rx="2"></rect>
														<line x1="2" y1="10" x2="22" y2="10"></line>
													</svg>
													<div class="flex flex-col">
														<span class="text-[10px] font-bold opacity-70 uppercase tracking-widest">Total Amount </span>
														<span class="text-xl font-black text-right" id="outpatient-total-price">0원</span>
													</div>
												</div>
										
											</div>
											<div class="grid grid-cols-2 gap-2">
												<button onclick="completePayment('CASH')" 
									                    class="btn btn-light btn-lg">
									                <span class="">현금 결제</span>
									            </button>
									
									            <button onclick="completePayment('CARD')" 
									                    class="btn btn-success-light btn-lg">
									                <span class="">카드 결제</span>
									            </button>
											</div>
										</div>
						                
						            </div>
						        </div>
						    </div>
    
							    
		                	<!-- 외래접수/수납 끝 -->
		                	<!-- 입원접수/수납 시작 -->
		                	<div id="tab-inpatient" class="tab-panel split-inner split-inner-2 flex gap-md py-4 pt-5 h-full min-h-0 overflow-hidden hidden">
    
							    <div class="w-1/2 h-full flex flex-col min-h-0">
							        <div class="box h-full flex flex-col">
							            <div class="flex items-center justify-between mb-6 shrink-0">
							                <h3 class="text-xl font-bold flex items-center gap-2 text-blue-700">
							                    <span class="w-1.5 h-6 bg-blue-600 rounded-full"></span>입원 환자 접수
							                </h3>
							            </div>
							
							            <div class="flex-1 overflow-y-auto scroll-content space-y-6 pr-2">
							                <div class="form-group">
							                    <label class="form-label mb-2">입원 대상 환자 검색</label>
							                    <div class="relative">
							                        <input type="text" id="inSearch" placeholder="검색어를 입력하세요" 
							                               class="input input-search" 
							                               onkeyup="showSearchDropdown(this.value, 'IN')" autocomplete="off"
							                               onkeypress="if(event.keyCode==13) { window.executeInpatientSearch(this.value); }">
							                    	<div id="inSearchDropdown" class="search-dropdown hidden"></div>
							                    </div>
							                </div>
							                
							                <div class="form-group">
							                    <label class="form-label mb-2">입원 환자 성명</label>
							                    <input type="text" id="inPatientName" readonly placeholder="접수 환자 검색 후 환자를 선택헤주세요." class="input">
							                </div>
							                						
							                <div class="form-row form-row-2 gap-6">
											    <div class="form-group mb-0">
												    <label class="form-label mb-2">진료실/담당의</label>
												    <select id="inEmployeeChange" class="select">
												        <option value="">담당의를 선택하세요</option>
														  
												    </select>
												    <input type="hidden" id="inEmployeeNo"> 
    												<input type="hidden" id="inLocationNo">
												</div>
											
												<div class="form-group">
												    <label class="form-label mb-2">보험 유형</label>
												    <select id="inInsurance" class="select">
												        <option value="001">건강보험</option>
											            <option value="002">차상위1종</option>
											            <option value="003">차상위2종</option>
											            <option value="004">급여1종</option>
											            <option value="005">급여2종</option>
											            <option value="006">산재</option>
											            <option value="007">산재100</option>
											            <option value="008">후유장해</option>
											            <option value="009">자보</option>
											            <option value="010">자보100</option>
											            <option value="011">일반</option>
											            <option value="012">일반100</option>
												    </select>
												</div>
											</div>
							                <div class="box box-border">
							                    <div class="flex justify-between items-center">
							                        <span class="font-semibold flex items-center">
							                            <i class="icon icon-bed icon-md mr-2"></i> 병동 및 병상 배정
							                        </span>
							                        <button onclick="openWardModal()" class="btn btn-secondary btn-sm">
							                            병동 현황 조회
							                        </button>
							                    </div>
							                    <div class="text-secondary p-3 font-medium mt-2 rounded-md bg-slate-50">
							                        배정 상태: <span class="font-bold ml-1 text-blue" id="selectedBedInfo">조회 후 배정해주세요</span>
							                    </div>
							                </div>
							
							                <div class="form-group">
							                    <label class="form-label mb-2">환자 메모</label>
							                    <textarea rows="1.5" id="inMemo" class="textarea resize-none p-4 focus:border-purple-500" placeholder="특이사항 및 메모 입력"></textarea>
							                </div>
							
							            </div>
						                <div class="pt-4">
						                    <button type="button" id="inpatientBtn" onclick="completeInpatientRegistration()" class="btn btn-primary btn-lg w-full">
						                        입원 접수 및 처리 완료
						                    </button>
						                </div>
							        </div>
							    </div>
							
							    <div class="w-1/2 h-full flex flex-col min-h-0">
							        <div class="box h-full flex flex-col">
							            <h3 class="text-xl font-bold flex items-center gap-2 text-emerald-700 mb-6 shrink-0">
							                <span class="w-1.5 h-6 bg-emerald-600 rounded-full"></span>퇴원 정산 및 승인
							            </h3>
							            
							            <div class="mb-6 h-60 flex flex-col">
							                <div class="flex items-center justify-between mb-4 shrink-0">
							                    <p class="font-bold uppercase tracking-widest">Discharge Waiting List</p>
							                    <div class="relative w-1/3">
							                       <input type="text" id="inpatient-settle-search" placeholder="검색어를 입력하세요" 
								                           class="input input-search input-sm" onkeyup="executeSettlementSearch(this.value, 'IN')">								                    
							                    </div>
							                </div>
							                <div class="bg-slate-50 border border-slate-200 rounded-md p-3 flex-1 overflow-y-auto scroll-content space-y-3" id="inpatient-waiting-list">							                  
							                    <div class="p-4 text-center text-slate-400 text-xs">퇴원 대기 환자가 없습니다.</div>
							                </div>
							            </div>
							
							            <div class="flex-1 flex flex-col overflow-hidden">
							               <div class="content-header">
								                <h4 class="content-header-title py-1"><span id="inpatient-bill-name">환자</span> 님 상세 정산서</h4>
								                <span class="badge badge-warning" id="inpatient-stay-days">입원일수: -일</span>
								            </div>
							
							                <div class="flex-1 overflow-y-auto scroll-content">
							                    <div class="table-wrapper">
							                        <table class="table">
								                        <thead class="bg-slate-50 text-slate-500">
								                            <tr>
								                                <th class="text-left py-3 px-4">진료 항목</th>
								                                <th class="text-right py-3 px-4 text-blue-600">본인부담금</th>
								                            </tr>
								                        </thead>
								                        <tbody id="inpatient-bill-items" class="divide-y divide-slate-100 text-sm">
								                            <tr><td colspan="2" class="py-4 text-center text-slate-400">대상자를 선택해주세요.</td></tr>
								                        </tbody>
								                    </table>
							                    </div>
											</div>
						                    <div class="bg-emerald-600 rounded-md p-4 text-white flex justify-between items-center mb-4">
						                        <i class="icon icon-file-text" style="width: 42px; height: 42px; opacity: 0.2;"></i>
						                        <div class="flex flex-col">
							                        <span class="text-[10px] font-bold opacity-60 uppercase tracking-widest">Total Settlement</span>
							                        <span class="text-xl font-black text-right" id="inpatient-total-amount">0 원</span>
							                    </div>
						                    </div>
							                
							            </div>
					                    <div class="grid grid-cols-2 gap-2">
					                       <button onclick="completePayment('CASH')" 
													class="btn btn-lg btn-light">
												<span class="">현금 결제</span>
											</button>
											
											<button onclick="completePayment('CARD')" 
													class="btn btn-lg btn-success-light">
												<span class="">카드 결제</span>
											</button>
					                    </div>
							        </div>
							    </div>
							</div>
		                	<!-- 입원접수/수납 끝 -->
		                	<!-- 진료/수술 예약 등록 시작 -->
		                	<div id="tab-reservation" class="tab-panel flex flex-col h-full min-h-0 overflow-hidden py-4 pt-5">
    
							    <div class="flex justify-between items-center mb-4 shrink-0 px-2">
							        <div class="flex flex-col gap-1">
							            <h3 class="text-xl font-bold flex items-center gap-3 text-slate-800">
							                <span class="w-1.5 h-7 bg-blue-600 rounded-full"></span>진료 및 수술 예약 현황
							            </h3>
							            <p class="text-sm text-slate-500 ml-5">전체적인 진료 및 수술 일정을 한눈에 확인하고 관리하세요.</p>
							        </div>
							        
							        <button type="button" 
							                onclick="openModal('modalBookingRegister'); if(typeof switchBookingType === 'function') switchBookingType('clinic');" 
							                class="btn btn-primary btn-icon-left">
							            <i class="icon icon-plus"></i> 예약 직접 등록
							        </button>
							    </div>
							
							    <div class="flex-1 box box-bordered bg-white p-6 shadow-sm border border-slate-200 rounded-2xl overflow-hidden">
							        <div id="calendar" class="h-full"></div>
							    </div>
							</div>
		                	<!-- 진료/수술 예약 등록 끝 -->
		                	<!-- 제증명 관리 시작 -->
		                	<div id="tab-certificate" class="tab-panel split-inner split-inner-2 flex gap-md py-4 h-full min-h-0 overflow-hidden">
    
							    <div class="w-1/2 h-full flex flex-col">
								    <div class="box h-full flex flex-col min-h-0">
								        
								        <div class="flex items-center justify-between mb-6 shrink-0">
								            <h3 class="text-xl font-bold flex items-center gap-2 text-blue-700 py-1">
								                <span class="w-1.5 h-6 bg-blue-600 rounded-full"></span>제증명 발급 및 출력
								            </h3>
								        </div>
								
								        <div class="flex-1 overflow-y-auto scroll-content space-y-6 pr-2">
								            <div class="form-group">
								                <label class="form-label mb-2">발급 대상 환자 검색</label>
								                <div class="relative">
								                    <input type="text" id="certSearch" placeholder="검색어를 입력하세요" autocomplete="off"
								                           class="input input-search" onkeyup="showSearchDropdown(this.value, 'CERT')"
								                           onkeypress="if(event.keyCode==13) { window.executePatientSearch(this.value); }">
								                    <div id="certSearchDropdown" class="search-dropdown hidden"></div>
								                </div>
								            </div>
								            
								            <div id="certSelectedPatientInfo" class="hidden p-4 bg-blue-50 border border-blue-200 rounded-xl mb-6 shadow-sm flex items-center justify-between">
											    <div class="flex items-baseline gap-2">
											        <span id="certPatientNameDisplay" class="text-lg font-black text-blue-800">-</span>
											        <span id="certPatientNoDisplay" class="text-sm font-bold text-blue-400">(-)</span>
											    </div>
											    <button type="button" onclick="resetCertSelection()" class="text-xs text-slate-400 hover:text-red-500 font-bold transition-colors">선택 취소</button>
											</div>
								
								            <div class="space-y-3">
								                <div class="flex items-center justify-between">
								                    <label class="form-label">증명서 내역</label>
								                    <div class="flex bg-slate-100 p-1 rounded-lg gap-1">
								                        <button type="button" id="btn-filter-today" onclick="filterCertHistory('today')" 
								                                class="px-3 py-1 text-sm font-bold rounded-md text-slate-500 hover:bg-white transition">오늘</button>
								                        <button type="button" id="btn-filter-week" onclick="filterCertHistory('week')" 
								                                class="px-3 py-1 text-sm font-bold rounded-md text-slate-500 hover:bg-white transition">1주일</button>
								                        <button type="button" id="btn-filter-all" onclick="filterCertHistory('all')" 
								                                class="px-3 py-1 text-sm font-bold rounded-md text-blue hover:bg-white transition">전체</button>
								                    </div>
								                </div>
								                
								                <div class="table-wrapper">
												    <table class="table table-center w-full" style="table-layout: fixed !important;">
												        <colgroup>
												            <col style="width: 40px;">  
												            <col style="width: 200px;"> 
												            <col style="width: 120px;"> 
												            <col style="width: 100px;"> 
												            <col style="width: 100px;">  
												        </colgroup>
												        <thead class="bg-slate-50 text-slate-500 border-b">
												            <tr>
												                <th class="py-3 px-2 text-center">
												                    <input type="checkbox" id="certCheckAll" onchange="toggleCertAll(this)" class="accent-blue-600 cursor-pointer">
												                </th>
												                <th class="py-3 px-3" style="text-align: left;">증명서 종류</th>
												                <th class="py-3 px-3 text-center">발급일</th>
												                <th class="py-3 px-3 text-center">상태</th>
												                <th class="py-3 px-3 text-center">조회</th>
												            </tr>
												        </thead>
												        <tbody id="certDoctorListBody">
												        	<tr>
														        <td colspan="5" class="py-16 text-center text-slate-400">
														            환자를 검색하면 작성된 문서가 표시됩니다.
														        </td>
														    </tr>
												        </tbody>
												    </table>
								                </div>
								                <p class="text-sm text-secondary">* 수납할 항목을 체크하면 오른쪽 결제 영역에 자동으로 담깁니다.</p>
								            </div>
								
								        </div>
							            <div class="bg-slate-50/80 p-5 rounded-xl border border-slate-100">
							            	<div class="flex items-center mb-4">
								                <h4 class="text-md font-semibold w-1/2 mr-6">신규 증명서 발급 요청</h4>
							                	<div class="flex gap-3 w-full">
								                    <select id="certTypeRequest" class="select" style="flex: 1;">
								                        <option value="">발급할 증명서를 선택하세요</option>
								                        <option value="DIAG">진단서</option>
								                        <option value="OPIN">소견서</option>
								                    </select>
								                    
								                    <label class="relative inline-flex items-center cursor-pointer group">
												        <input type="checkbox" id="certUrgentCheck" class="sr-only peer">
												        <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-red-500"></div>
												        <span class="ml-2 text-xs font-bold text-slate-500 peer-checked:text-red-600">긴급</span>
												    </label>
							                    </div>
							                </div>
						                    <button type="button" onclick="requestCertificate(this)" class="btn btn-primary w-full">
						                        발급 요청
						                    </button>
							                <p class="text-sm text-secondary mt-3 flex items-center gap-1">
							                    <i class="icon icon-sm icon-info-circle"></i> 요청 시 담당 의사에게 실시간 알림이 전송됩니다.
							                </p>
							            </div>
								    </div>
								</div>
							
							    <div class="w-1/2 h-full flex flex-col">
							        <div class="box h-full flex flex-col">
							            <h3 class="text-xl font-bold flex items-center gap-2 text-emerald-700 mb-6 shrink-0">
							                <span class="w-1.5 h-6 bg-emerald-600 rounded-full"></span>제증명 수납 및 결제
							            </h3>
							
							            <div class="flex-1 flex flex-col min-h-0 overflow-hidden">
							                <div class="content-header">
							                    <h4 class="content-header-title py-1"><span id="certBillName">환자</span> 님 수납 내역</h4>
							                </div>
							
							                <div class="flex-1 overflow-y-auto scroll-content">
							                    <div class="table-wrapper">
							                        <table class="table">
							                            <thead class="bg-slate-50">
							                                <tr>
							                                    <th class="text-left py-3 px-4">항목명</th>
							                                    <th class="text-right py-3 px-4 text-blue-600">금액</th>
							                                </tr>
							                            </thead>
							                            <tbody id="cert-bill-items" class="divide-y divide-slate-100">
							                                <tr><td colspan="2" class="py-4 text-center text-slate-400">문서를 선택해주세요.</td></tr>
							                            </tbody>
							                        </table>
							                    </div>
							                </div>
							
						                    <div class="bg-slate-900 rounded-xl p-4 text-white flex justify-between items-center mb-6">
						                        <span class="text-2xl opacity-30">💳</span>
						                        <div class="flex flex-col">
						                            <span class="text-[10px] font-bold opacity-60 uppercase tracking-widest">Total Pay</span>
						                            <span class="text-xl font-black text-right" id="cert-total-amount">0 원</span>
						                        </div>
						                    </div>
						
							            </div>
					                    <div class="grid grid-cols-2 gap-2">
					                       <button onclick="completeCertPayment('CASH')" 
													class="btn btn-lg btn-light">
												<span class="">현금 결제</span>
											</button>
											
											<button onclick="completeCertPayment('CARD')" 
													class="btn btn-lg btn-success-light">
												<span class="">카드 결제</span>
											</button>
					                    </div>
							        </div>
							    </div>
							</div>
		                	<!-- 제증명 관리 끝 -->
		                </div>
					</div>
				</div>
				
				<div class="content-area flex flex-col h-full overflow-hidden min-h-0">
                    <div class="box flex-1 flex flex-col min-h-0 overflow-hidden">
                        <div class="flex justify-between items-center">
						    <h2 class="box-title">대기 환자 목록</h2>
						    <span id="waiting-list-notice" class="text-[10px] text-blue-500 font-bold hidden animate__animated animate__fadeIn"></span>
						</div>
                        <div class="form-group mb-0">
	                        <input type="text" id="waitingListSearch" onkeyup="filterWaitingList()" 
	                        	class="input input-search" placeholder="검색어를 입력하세요">
	                    </div>
	                    <p class="text-sm text-secondary my-2 flex items-center gap-2">
                            <i class="icon icon-sm icon-info-circle"></i> 환자 상태 관리 : <b>대기 -> 진료대기 -> 진료중</b>
                        </p>
                        <div class="tabs tabs-button mb-2 shrink-0" style="width: 100% !important;">
                            <button class="tab active w-full" onclick="switchTab(event, '전체')">전체 <span class="text-sm" id="wait-total-count"></span></button>
                            <button class="tab w-full" onclick="switchTab(event, '001')">대기 <span class="text-sm" id="wait-count"></span></button>
                            <button class="tab w-full" onclick="switchTab(event, '002')">진료대기 <span class="text-sm" id="exam-wait-count"></span></button>
                            <button class="tab w-full" onclick="switchTab(event, '003')">진료중 <span class="text-sm" id="ing-count"></span></button>
                        </div>
                        <div class="flex-1 overflow-auto scroll-content"> 
	                        <div class="card-group" id="waiting-list-body">
	                        	
	                        </div>
	                    </div>
                    </div>
				</div>
				
			</div>
		</main>
		<!-- ===== Main 끝 ===== -->
	</div>
	<!-- 모달 include -->
	<jsp:include page="receptionModal.jsp" />
	<jsp:include page="reservation.jsp" />
</body>
</html>