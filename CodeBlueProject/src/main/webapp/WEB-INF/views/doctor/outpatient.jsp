<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.functions" prefix="fn" %>
<!DOCTYPE html>
<html lang="ko">

<head>
    <title>SB 병원 - 외래 진료</title>
    <%@ include file="/WEB-INF/views/common/include/link.jsp" %>
</head>

<body>
    <%@ include file="/WEB-INF/views/common/include/header.jsp" %>

    <div class="main-container">
        <%@ include file="/WEB-INF/views/common/include/left/left_doctor.jsp" %>

        <main class="main-content">
            <div class="grid grid-sidebar-lg grid-full-height">
                <div class="content-area flex flex-col h-full overflow-hidden">
                    <div class="box">
                        <h2 class="page-title">외래</h2>
                    </div>
                    <hr class="section-divider" />
                    <div class="box">
                        <h2 class="box-title">담당 환자 목록</h2>
                        <div class="form-group">
                            <label class="form-label">환자 검색</label>
                            <input type="text" id="search-input" class="input input-search" placeholder="검색어를 입력하세요">
                        </div>
                        <div class="tabs tabs-button mb-2" style="width: 100% !important;">
                            <button class="tab active w-full" onclick="switchTab(event, 'tab1')">전체 <span class="text-sm" id="count-total"></span></button>
                            <button class="tab w-full" onclick="switchTab(event, 'tab2')">대기 <span class="text-sm" id="count-wait"></span></button>
                            <button class="tab w-full" onclick="switchTab(event, 'tab3')">진료대기 <span class="text-sm" id="count-clinic-wait"></span></button>
                            <button class="tab w-full" onclick="switchTab(event, 'tab4')">진료중 <span class="text-sm" id="count-ing"></span></button>
                        </div>
                    </div>
                    <div class="flex-1 overflow-auto">
                        <div id="tab1" class="tab-content active">
                            <div class="card-group"></div>
                        </div>
                        <div id="tab2" class="tab-content">
                            <div class="card-group"></div>
                        </div>
                        <div id="tab3" class="tab-content">
                            <div class="card-group"></div>
                        </div>
                        <div id="tab4" class="tab-content">
                            <div class="card-group"></div>
                        </div>
                    </div>
                </div>

                <div class="content-area grid grid-1-2 h-full overflow-hidden">
                    <div id="patientInfo" class="content-area_left flex flex-col h-full overflow-hidden relative">
                        <div id="info-empty-state" class="empty-state empty-state-sm h-[100vh]">
                            <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
                            </svg>
                            <div class="empty-state-title">내용 없음</div>
                            <div class="empty-state-description">내용이 비어있습니다.</div>
                        </div>

                        <div id="info-content-wrap" class="hidden h-full flex flex-col overflow-hidden">
                            
                            <div class="box">
                                <div class="box-title-group flex justify-between ">
                                    <h2 class="box-title flex items-center gap-2">
                                        <span id="pt-no"></span> <strong id="pt-name"></strong> </h2>
                                    <div class="doctor-info flex items-center">
                                        <i class="icon icon-doctor icon-md icon-muted"></i>
                                        <span class="text-sm"><b id="pt-doc-name"></b> 의사</span>
                                        <button class="btn btn-icon btn-ghost" onclick="closeInfoView()">
                                            <i class="icon icon-x"></i>
                                        </button>
                                    </div>
                                </div>

                                <div class="list-horizontal list-horizontal-2">
                                    <div class="list-horizontal-item">
                                        <div class="list-horizontal-label">나이 / 성별</div>
                                        <div class="list-horizontal-value" id="pt-age-gen"></div>
                                    </div>
                                </div>
                                <div class="list-horizontal list-horizontal-1">
                                    <div class="list-horizontal-item">
                                        <div class="list-horizontal-label">생년월일</div>
                                        <div class="list-horizontal-value" id="pt-birth"></div>
                                    </div>
                                    <div class="list-horizontal-item">
                                        <div class="list-horizontal-label">주민등록번호</div>
                                        <div class="list-horizontal-value" id="pt-jumin"></div>
                                    </div>
                                    <div class="list-horizontal-item">
                                        <div class="list-horizontal-label">연락처</div>
                                        <div class="list-horizontal-value" id="pt-tel"></div>
                                    </div>
                                </div>
                                <div class="list-horizontal list-horizontal-1">
                                    <div class="list-horizontal-item">
                                        <div class="list-horizontal-label">주소</div>
                                        <div class="list-horizontal-value" id="pt-addr"></div>
                                    </div>
                                </div>
                            </div>

                            <div class="box box-bordered box-secondary mt-3">
                                <div class="list-horizontal list-horizontal-2">
                                    <div class="list-horizontal-item">
                                        <div class="list-horizontal-label">키/체중</div>
                                        <div class="list-horizontal-value" id="scr-hw"></div>
                                    </div>
                                    <div class="list-horizontal-item">
                                        <div class="list-horizontal-label">체온</div>
                                        <div class="list-horizontal-value" id="scr-bt"></div>
                                    </div>
                                    <div class="list-horizontal-item">
                                        <div class="list-horizontal-label">혈압</div>
                                        <div class="list-horizontal-value" id="scr-bp"></div>
                                    </div>
                                    <div class="list-horizontal-item">
                                        <div class="list-horizontal-label">맥박</div>
                                        <div class="list-horizontal-value" id="scr-pulse"></div>
                                    </div>
                                </div>
                                <div class="form-group mt-3">
                                    <label class="form-label"><i class=""></i> 환자메모</label>
                                    <textarea class="textarea textarea-sm" id="pt-memo"></textarea>
                                </div>
                            </div>

                            <hr class="section-divider" />
                            <div class="box">
                                <div class="flex justify-between items-center">
                                    <div class="tabs tabs-text">
                                        <button class="tab active" onclick="switchTab(event, 'tab11')">내원 이력</button>
                                        </div>
                                    <div>
                                        <button id="openPreBtn" class="btn btn-primary btn-sm" onclick="openPrescriptionView()" disabled>
                                            <i class="icon icon-edit-one"></i> 진료추가
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <hr class="section-divider" />
                            
                            <div id="" class="flex flex-col flex-1 overflow-hidden">
                                <div class="flex-1 overflow-y-auto" id="history-list-container">
                                </div>
                            </div>
                            
                            <div id="tab12" class="tab-content">
                                <div class="empty-state empty-state-sm h-[30vh]">
                                    <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <line x1="8" y1="6" x2="21" y2="6"></line>
                                        <line x1="8" y1="12" x2="21" y2="12"></line>
                                        <line x1="8" y1="18" x2="21" y2="18"></line>
                                        <line x1="3" y1="6" x2="3.01" y2="6"></line>
                                        <line x1="3" y1="12" x2="3.01" y2="12"></line>
                                        <line x1="3" y1="18" x2="3.01" y2="18"></line>
                                    </svg>
                                    <div class="empty-state-title">목록 없음</div>
                                    <div class="empty-state-description">등록된 검사결과가 없습니다.</div>
                                </div>
                            </div>

                        </div> 
                    </div>
                    <div id="preScriptionEmptyView" class="content-area_right flex flex-col h-full overflow-hidden ">
                        <div class="empty-state empty-state-sm h-[100vh]">
                            <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
                            </svg>
                            <div class="empty-state-title">내용 없음</div>
                            <div class="empty-state-description">내용이 비어있습니다.</div>
                        </div>
                    </div>
                    
                    <div id="preScriptionView" class="content-area_right flex flex-col h-full overflow-hidden hidden">
                        <div class="box-title-group flex justify-between">
                            <h2 class="box-title" id="preScriptionTime"></h2>
                            <div class="btn-group-right">
                                <button type="button" id="aiAssistantBtn" class="btn btn-ghost btn-icon-left" style="background-color: #EFF6FF">
                                    <span>🤖</span> AI 어시스턴트
                                </button>
                                <button onclick="openMacroModal()" class="btn btn-ghost btn-icon-left">나의 오더</button>
                                <div class="dropdown">
                                    <button class="btn btn-ghost" onclick="toggleDropdown(event, 'docToggle')">환자 서류 작성
                                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                            <polyline points="6 9 12 15 18 9"></polyline>
                                        </svg>
                                    </button>
                                    <div class="dropdown-menu" id="docToggle">
                                        <a href="javascript:void(0)" class="dropdown-item py-2.5 px-4 hover:bg-indigo-50 transition-all"
								            onclick="openIpDocModal('dx', currentChartNo)">
								            <span class="dropdown-item-text font-bold text-zinc-700">진단서 작성</span>
								        </a>
								        <a href="javascript:void(0)" class="dropdown-item py-2.5 px-4 hover:bg-indigo-50 transition-all"
								            onclick="openIpDocModal('op', currentChartNo)">
								            <span class="dropdown-item-text font-bold text-zinc-700">소견서 작성</span>
								        </a>
                                    </div>
                                </div>
                                <button class="btn btn-icon btn-ghost" onclick="closePrescriptionView()">
                                    <i class="icon icon-x"></i>
                                </button>
                            </div>
                        </div>
                        <div class="box flex-1 overflow-auto ">
                            <div class="content-group mt-3">
                                <div class="content-group-header">
                                    <svg class="content-header-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                                    </svg>
                                    <div class="content-header-title">진료 기록</div>

                                </div>
                                <div class="content-group-body">
                                    <textarea class="textarea textarea-sm" id="clinicNote" placeholder="진료 기록을 입력하세요." style="min-height: 120p; margin-bottom: var(--spacing-md);"></textarea>

                                </div>
                            </div>

                            <div class="content-group-divider">
                                <div class="content-header">
                                    <svg class="content-group-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="12" cy="12" r="10"></circle>
                                        <line x1="12" y1="16" x2="12" y2="12"></line>
                                        <line x1="12" y1="8" x2="12.01" y2="8"></line>
                                    </svg>
                                    <div class="content-group-title">상병</div>
                                    <div class="content-group-actions">
                                        <button class="btn btn-secondary btn-sm" onclick="openModal('modal-diagnosis')">
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <line x1="12" y1="5" x2="12" y2="19"></line>
                                                <line x1="5" y1="12" x2="19" y2="12"></line>
                                            </svg>
                                            상병 추가
                                        </button>
                                    </div>
                                </div>
                                <div class="table-wrapper">
                                    <table class="table">
                                        <thead>
                                            <tr class="bg-slate-50 border-b border-slate-200 text-slate-500 uppercase tracking-wider font-semibold">
                                                <th class="py-3 px-2 text-center w-14">No</th>
                                                <th class="py-3 px-2 text-center w-14">주</th>
                                                <th class="py-3 px-2 text-center w-14">부</th>
                                                <th class="py-3 px-2 text-center w-24">상병코드</th>
                                                <th class="py-3 px-2 text-left pl-4">상병 명</th>
                                                
                                                <th class="py-3 px-2 text-center w-24">
                                                    <button type="button" onclick="removeAll('diagnosis')" 
                                                            class="px-2 py-1 text-xs font-bold text-red-600 bg-red-50 border border-red-200 rounded-md hover:bg-red-100 hover:text-red-700 hover:border-red-300 transition-all shadow-sm">
                                                        전체삭제
                                                    </button>
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody id="dxTableBody"></tbody>
                                    </table>
                                </div>
                            </div>

                            <div class="content-group-divider">
                                <div class="content-header mt-3">
                                    <svg class="content-group-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="12" cy="12" r="10"></circle>
                                        <line x1="12" y1="16" x2="12" y2="12"></line>
                                        <line x1="12" y1="8" x2="12.01" y2="8"></line>
                                    </svg>
                                    <div class="content-group-title">치료/주사 처방</div>
                                    <div class="content-group-actions">
                                        <button class="btn btn-secondary btn-sm" onclick="openModal('modal-treatment')">
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <line x1="12" y1="5" x2="12" y2="19"></line>
                                                <line x1="5" y1="12" x2="19" y2="12"></line>
                                            </svg>
                                            치료 추가
                                        </button>
                                    </div>
                                </div>
                                <div class="table-wrapper">
                                    <table class="table table-input">
                                        <thead>
                                            <tr class="bg-slate-50 border-b border-slate-200 text-slate-500 uppercase tracking-wider font-semibold">
                                                <th class="py-3 px-2 text-center w-14">No</th>
                                                <th class="py-3 px-2 text-center w-20">처방타입</th>
                                                <th class="py-3 px-2 text-center w-24">처방코드</th>
                                                <th class="py-3 px-2 text-left pl-4">처방명칭</th>
                                                <th class="py-3 px-2 text-center w-16">1회량</th>
                                                <th class="py-3 px-2 text-center w-16">횟수</th>
                                                <th class="py-3 px-2 text-center w-14">일수</th>
                                                
                                                <th class="py-3 px-2 text-center w-24">
                                                    <button type="button" onclick="removeAll('treatment')" 
                                                            class="px-2 py-1 text-xs font-bold text-red-600 bg-red-50 border border-red-200 rounded-md hover:bg-red-100 hover:text-red-700 hover:border-red-300 transition-all shadow-sm">
                                                        전체삭제
                                                    </button>
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody id="txTableBody"></tbody>
                                    </table>
                                </div>
                            </div>

                            <div class="content-group-divider">
                                <div class="content-header mt-3">
                                    <svg class="content-group-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="12" cy="12" r="10"></circle>
                                        <line x1="12" y1="16" x2="12" y2="12"></line>
                                        <line x1="12" y1="8" x2="12.01" y2="8"></line>
                                    </svg>
                                    <!-- <i class="icon icon-drug"></i> -->
                                    <div class="content-group-title">약제처방</div>
                                    <div class="content-group-actions">
                                        <button class="btn btn-secondary btn-sm" onclick="openModal('modal-medication')">
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <line x1="12" y1="5" x2="12" y2="19"></line>
                                                <line x1="5" y1="12" x2="19" y2="12"></line>
                                            </svg>
                                            약제 추가
                                        </button>
                                    </div>
                                </div>
                                <div class="table-wrapper">
                                    <table class="table table-input">
                                        <thead>
                                            <tr class="bg-slate-50 border-b border-slate-200 text-slate-500 uppercase tracking-wider font-semibold">
                                                <th class="py-3 px-2 text-center w-14">No</th>
                                                <th class="py-3 px-2 text-left pl-4">약제명</th>
                                                <th class="py-3 px-2 text-center w-16">1회량</th>
                                                <th class="py-3 px-2 text-center w-16">횟수</th>
                                                <th class="py-3 px-2 text-center w-14">일수</th>
                                                <th class="py-3 px-2 text-center w-32">용법</th>
                                                
                                                <th class="py-3 px-2 text-center w-24">
                                                    <button type="button" onclick="removeAll('medication')" 
                                                            class="px-2 py-1 text-xs font-bold text-red-600 bg-red-50 border border-red-200 rounded-md hover:bg-red-100 hover:text-red-700 hover:border-red-300 transition-all shadow-sm">
                                                        전체삭제
                                                    </button>
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody id="rxTableBody"></tbody>
                                    </table>
                                </div>
                            </div>

                            <div class="content-group-divider">
                                <div class="content-header mt-3">
                                    <svg class="content-group-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="12" cy="12" r="10"></circle>
                                        <line x1="12" y1="16" x2="12" y2="12"></line>
                                        <line x1="12" y1="8" x2="12.01" y2="8"></line>
                                    </svg>
                                    <div class="content-group-title">수술 처방</div>
                                    <div class="content-group-actions">
                                        <button class="btn btn-secondary btn-sm" onclick="openModal('modal-operation')">
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <line x1="12" y1="5" x2="12" y2="19"></line>
                                                <line x1="5" y1="12" x2="19" y2="12"></line>
                                            </svg>
                                            수술 추가
                                        </button>
                                    </div>
                                </div>
                                <div class="table-wrapper">
                                    <table class="table table-input">
                                        <thead>
                                            <tr class="bg-slate-50 border-b border-slate-200 text-slate-500 uppercase tracking-wider font-semibold">
                                                <th class="py-3 px-2 text-center w-14">No</th>
                                                <th class="py-3 px-2 text-center w-32">수술코드</th>
                                                <th class="py-3 px-2 text-left pl-4">수술명</th>
                                                
                                                <th class="py-3 px-2 text-center w-24">
                                                    <button type="button" onclick="removeAll('operation')" 
                                                            class="px-2 py-1 text-xs font-bold text-red-600 bg-red-50 border border-red-200 rounded-md hover:bg-red-100 hover:text-red-700 hover:border-red-300 transition-all shadow-sm">
                                                        전체삭제
                                                    </button>
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody id="opTableBody"></tbody>
                                    </table>
                                </div>
                            </div>

                            <div class="content-group-divider">
                                <div class="content-header mt-3">
                                    <svg class="content-group-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline>
                                    </svg>
                                    <div class="content-group-title">영상/검사 처방</div>
                                    <div class="content-group-actions">
                                        <button class="btn btn-secondary btn-sm" onclick="openModal('modal-examination')">
                                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                                <line x1="12" y1="5" x2="12" y2="19"></line>
                                                <line x1="5" y1="12" x2="19" y2="12"></line>
                                            </svg>
                                            검사 추가
                                        </button>
                                    </div>
                                </div>
                                <div class="table-wrapper">
                                    <table class="table table-input">
                                        <thead>
                                            <tr class="bg-slate-50 border-b border-slate-200 text-slate-500 uppercase tracking-wider font-semibold">
                                                <th class="py-3 px-2 text-center w-14">No</th>
                                                
                                                <th class="py-3 px-2 text-left pl-4 w-40">검사명</th>
                                                
                                                <th class="py-3 px-2 text-left pl-4">환부</th>
                                                
                                                <th class="py-3 px-2 text-center w-24">좌우</th>
                                                
                                                <th class="py-3 px-2 text-center w-24">
                                                    <button type="button" onclick="removeAll('examination')" 
                                                            class="px-2 py-1 text-xs font-bold text-red-600 bg-red-50 border border-red-200 rounded-md hover:bg-red-100 hover:text-red-700 hover:border-red-300 transition-all shadow-sm">
                                                        전체삭제
                                                    </button>
                                                </th>
                                            </tr>
                                        </thead>
                                        <tbody id="exTableBody"></tbody>
                                    </table>
                                </div>
                            </div>

                        </div>

                        <div class="area-right_footer pt-3">
                            <div class="btn-group-justified">
                                <div class="btn-group-left">
                                </div>
                                <div class="btn-group-right">
                                    <button class="btn btn-primary" onclick="savePrescription()">진료완료</button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="box flex-1 overflow-auto hidden" id="preScriptionView2">
                        <div class="box-title-group flex justify-between">
                            <h2 class="box-title" id="preScriptionTime_view">2025-12-25</h2>
                            <div class="btn-group-right">
                                <button class="btn btn-ghost btn-icon-left">나의 오더</button>
                                <div class="dropdown">
								    <button class="btn btn-ghost btn-sm border border-zinc-200 flex items-center gap-2" 
								            onclick="toggleDropdown(event, 'docToggle')">
								        환자 서류
								        <i class="icon icon-chevron-down text-zinc-400 text-[10px]"></i>
								    </button>
								    <div class="dropdown-menu shadow-xl border border-zinc-100" id="docToggle">
								        <a href="javascript:void(0)" class="dropdown-item py-2.5 px-4 hover:bg-indigo-50 transition-all"
								            onclick="openIpDocModal('dx', currentChartNo)">
								            <span class="dropdown-item-text font-bold text-zinc-700">진단서 작성</span>
								        </a>
								        <a href="javascript:void(0)" class="dropdown-item py-2.5 px-4 hover:bg-indigo-50 transition-all"
								            onclick="openIpDocModal('op', currentChartNo)">
								            <span class="dropdown-item-text font-bold text-zinc-700">소견서 작성</span>
								        </a>
								    </div>
								</div>
                                <button class="btn btn-icon btn-ghost" onclick="closePrescriptionView2()">
                                    <i class="icon icon-x"></i>
                                </button>
                            </div>
                        </div>
                        <div class="box flex-1 overflow-auto ">
                            <div class="content-group mt-3">
                                <div class="content-group-header">
                                    <svg class="content-header-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"></path>
                                    </svg>
                                    <div class="content-header-title">진료 기록</div>
                                </div>
                                <div class="content-group-body">
                                    <textarea class="textarea textarea-sm bg-gray-50" id="clinicNote_view" readonly style="min-height: 120px; margin-bottom: var(--spacing-md);"></textarea>
                                </div>
                            </div>
    
                            <div class="content-group-divider">
                                <div class="content-header">
                                    <svg class="content-group-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="12" cy="12" r="10"></circle>
                                        <line x1="12" y1="16" x2="12" y2="12"></line>
                                        <line x1="12" y1="8" x2="12.01" y2="8"></line>
                                    </svg>
                                    <div class="content-group-title">상병</div>
                                </div>
                                <div class="table-wrapper">
                                    <table class="table">
                                        <thead>
                                            <tr class="bg-slate-50 border-b border-slate-200 text-slate-500 uppercase tracking-wider font-semibold">
                                                <th class="py-3 px-2 text-center w-14">No</th>
                                                
                                                <th class="py-3 px-2 text-center w-16">구분</th>
                                                
                                                <th class="py-3 px-2 text-center w-24">상병코드</th>
                                                
                                                <th class="py-3 px-2 text-left pl-4">상병명</th>
                                            </tr>
                                        </thead>
                                        <tbody id="dxTableBody_view">
                                            </tbody>
                                    </table>
                                </div>
                            </div>
    
                            <div class="content-group-divider">
                                <div class="content-header mt-3">
                                    <svg class="content-group-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="12" cy="12" r="10"></circle>
                                        <line x1="12" y1="16" x2="12" y2="12"></line>
                                        <line x1="12" y1="8" x2="12.01" y2="8"></line>
                                    </svg>
                                    <div class="content-group-title">치료/주사 처방</div>
                                </div>
                                <div class="table-wrapper">
                                    <table class="table">
                                        <thead>
                                            <tr class="bg-slate-50 border-b border-slate-200 text-slate-500 uppercase tracking-wider font-semibold">
                                                <th class="py-3 px-2 text-center w-14">No</th>
                                                
                                                <th class="py-3 px-2 text-center w-20">구분</th>
                                                
                                                <th class="py-3 px-2 text-center w-24">코드</th>
                                                
                                                <th class="py-3 px-2 text-left pl-4">치료명</th>
                                                
                                                <th class="py-3 px-2 text-center w-16">횟수</th>
                                                
                                                <th class="py-3 px-2 text-center w-16">일수</th>
                                                
                                                <th class="py-3 px-2 text-center w-24">상태</th>
                                            </tr>
                                        </thead>
                                        <tbody id="txTableBody_view">
                                            </tbody>
                                    </table>
                                </div>
                            </div>
    
                            <div class="content-group-divider">
                                <div class="content-header mt-3">
                                    <svg class="content-group-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="12" cy="12" r="10"></circle>
                                        <line x1="12" y1="16" x2="12" y2="12"></line>
                                        <line x1="12" y1="8" x2="12.01" y2="8"></line>
                                    </svg>
                                    <div class="content-group-title">약제 처방</div>
                                </div>
                                <div class="table-wrapper">
                                    <table class="table">
                                        <thead>
                                            <tr class="bg-slate-50 border-b border-slate-200 text-slate-500 uppercase tracking-wider font-semibold">
                                                <th class="py-3 px-2 text-center w-14">No</th>
                                                
                                                <th class="py-3 px-2 text-left pl-4">약제명</th>
                                                
                                                <th class="py-3 px-2 text-center w-16">1회량</th>
                                                
                                                <th class="py-3 px-2 text-center w-16">횟수</th>
                                                
                                                <th class="py-3 px-2 text-center w-16">일수</th>
                                                
                                                <th class="py-3 px-2 text-center w-32">용법</th>
                                            </tr>
                                        </thead>
                                        <tbody id="rxTableBody_view">
                                            </tbody>
                                    </table>
                                </div>
                            </div>
    
                            <div class="content-group-divider">
                                <div class="content-header mt-3">
                                    <svg class="content-group-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="12" cy="12" r="10"></circle>
                                        <line x1="12" y1="16" x2="12" y2="12"></line>
                                        <line x1="12" y1="8" x2="12.01" y2="8"></line>
                                    </svg>
                                    <div class="content-group-title">수술 처방</div>
                                </div>
                                <div class="table-wrapper">
                                    <table class="table">
                                        <thead>
                                            <tr class="bg-slate-50 border-b border-slate-200 text-slate-500 uppercase tracking-wider font-semibold">
                                                <th class="py-3 px-2 text-center w-14">No</th>
                                                
                                                <th class="py-3 px-2 text-center w-32">수술코드</th>
                                                
                                                <th class="py-3 px-2 text-left pl-4">수술명</th>
                                            </tr>
                                        </thead>
                                        <tbody id="opTableBody_view">
                                            </tbody>
                                    </table>
                                </div>
                            </div>

                            <div class="content-group-divider">
                                <div class="content-header mt-3">
                                    <svg class="content-group-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <circle cx="12" cy="12" r="10"></circle>
                                        <line x1="12" y1="16" x2="12" y2="12"></line>
                                        <line x1="12" y1="8" x2="12.01" y2="8"></line>
                                    </svg>
                                    <div class="content-group-title">검사 처방</div>
                                </div>
                                <div class="table-wrapper">
                                    <table class="table">
                                        <thead>
                                            <tr class="bg-slate-50 border-b border-slate-200 text-slate-500 uppercase tracking-wider font-semibold">
                                                <th class="py-3 px-2 text-center w-14">No</th>
                                                
                                                <th class="py-3 px-2 text-left pl-4 w-40">검사명</th>
                                                
                                                <th class="py-3 px-2 text-left pl-4">환부</th>
                                                
                                                <th class="py-3 px-2 text-center w-24">좌우</th>
                                                
                                                <th class="py-3 px-2 text-center w-16">파일</th>
                                                
                                                <th class="py-3 px-2 text-center w-24">상태</th>
                                            </tr>
                                        </thead>
                                        <tbody id="exTableBody_view">
                                            </tbody>
                                    </table>
                                </div>
                            </div>
                            
                        </div>

                    </div>
                    
                </div>
            </div>
        </main>
    </div>
    <jsp:include page="/WEB-INF/views/doctor/aiassistant.jsp" />
    <jsp:include page="/WEB-INF/views/doctor/prescriptionmodal2.jsp" />
    <jsp:include page="/WEB-INF/views/certificate/inc/modal.jsp" />
    <jsp:include page="/WEB-INF/views/doctor/myordermodal.jsp" />
    <jsp:include page="/WEB-INF/views/doctor/attachmodal.jsp" />

    <script>
        let originalPatientList = [];
        let targetPatient;
        let currentChartNo;
        let isNewChart = false;
        let globalChartList;

        function getToday() {
            var date = new Date();
            var year = date.getFullYear();
            var month = ("0" + (1 + date.getMonth())).slice(-2);
            var day = ("0" + date.getDate()).slice(-2);

            return year + "-" + month + "-" + day;
        }

        function test(){
            const headers = getApiHeaders();
            axios({
                method: 'post',
                url: '/commonws/api/receptionUpdate',
                data: {},
                headers: headers
            })
            .then(x=>console.log(x));
        }
        document.addEventListener('DOMContentLoaded', () => {
            loadPatientList();

            document.querySelector("#preScriptionTime").innerHTML = getToday();

            window.loadWaitingList = loadPatientList;
            // 검색창 이벤트 등록
            const searchInput = document.getElementById('search-input');
            if (searchInput) {
                searchInput.addEventListener('input', function(e) {
                    filterPatientList(e.target.value);
                });
            }
        });

        /* ==================================================================================
           [신규] 전체 삭제 함수 (테이블 바디를 비움)
           ================================================================================== */
        function removeAll(type) {
            let tbodyId = '';
            let label = '';

            if (type === 'diagnosis') {
                tbodyId = 'dxTableBody';
                label = '상병';
            } else if (type === 'treatment') {
                tbodyId = 'txTableBody';
                label = '치료 처방';
            } else if (type === 'medication') {
                tbodyId = 'rxTableBody';
                label = '약제 처방';
            } else if (type === 'operation') {
                tbodyId = 'opTableBody';
                label = '수술 처방';
            } else if (type ==='examination'){
                tbodyId = 'exTableBody';
                label = '검사 처방';
            }

            const tbody = document.getElementById(tbodyId);
            // 목록이 있을 때만 삭제 확인창 띄움
            if (tbody && tbody.children.length > 0) {

                sweetAlert("warning", `모든 \${label} 목록을 삭제하시겠습니까?`, "확인", "취소", true)
                    .then((flag) => {
                        if (flag.isConfirmed) {

                            tbody.innerHTML = '';
                        }
                    });

            } else {
                // 비어있으면 조용히 넘어감 (혹은 alert('삭제할 목록이 없습니다.');)
            }
        }

        /* ==================================================================================
           기본 API 및 유틸리티 함수
           ================================================================================== */
        function getApiHeaders() {
            const csrfMetaTag = document.querySelector('meta[name="_csrf"]');
            const csrfHeaderTag = document.querySelector('meta[name="_csrf_header"]');

            const csrfToken = (csrfMetaTag && csrfMetaTag.content) || '';
            const csrfHeader = (csrfHeaderTag && csrfHeaderTag.content) || '';
            const jwtToken = getCookie('ACCESS_TOKEN');

            const headers = {
                'Content-Type': 'application/json'
            };
            if (csrfToken && csrfHeader) headers[csrfHeader] = csrfToken;
            if (jwtToken) headers['Authorization'] = `Bearer \${jwtToken}`;

            return headers;
        }

        function getCookie(name) {
            const match = document.cookie.match(new RegExp('(^| )' + name + '=([^;]+)'));
            return match ? match[2] : null;
        }

        // 📡 1. 환자 리스트 가져오기
        async function loadPatientList() {
            const headers = getApiHeaders();
            try {
                const response = await axios({
                    method: 'post',
                    url: '/doctor/api/getOutPatientList',
                    data: {},
                    headers: headers
                });
                originalPatientList = response.data;
                renderAllTabs(originalPatientList);
            } catch (error) {
                console.error("리스트 불러오기 실패:", error);
            }
        }

        // 🔍 2. 검색 필터링
        function filterPatientList(keyword) {
            if (!keyword || keyword.trim() === '') {
                renderAllTabs(originalPatientList);
                return;
            }
            const lowerKeyword = keyword.toLowerCase();
            const isChosungSearch = /[ㄱ-ㅎ]/.test(keyword);

            const filteredList = originalPatientList.filter(patient => {
                const pName = (patient.patientName || '');
                const regNo = String(patient.registrationNo || '');
                const basicMatch = pName.includes(keyword) || regNo.includes(keyword);
                let chosungMatch = false;
                if (isChosungSearch) {
                    chosungMatch = getChosung(pName).includes(keyword);
                }
                return basicMatch || chosungMatch;
            });
            renderAllTabs(filteredList);
        }

        // 🎨 3. 탭 렌더링
        function renderAllTabs(list) {
            let htmlTotal = "",
                htmlWait = "",
                htmlClinicWait = "",
                htmlIng = "";
            let cntTotal = list.length,
                cntWait = 0,
                cntClinicWait = 0,
                cntIng = 0;

            list.forEach(item => {
                const cardHtml = makeCardHtml(item);
                htmlTotal += cardHtml;
                if (item.registrationStatus === '001') {
                    htmlWait += cardHtml;
                    cntWait++;
                } else if (item.registrationStatus === '002') {
                    htmlClinicWait += cardHtml;
                    cntClinicWait++;
                } else if (item.registrationStatus === '003') {
                    htmlIng += cardHtml;
                    cntIng++;
                }
            });

            updateText('count-total', cntTotal);
            updateText('count-wait', cntWait);
            updateText('count-clinic-wait', cntClinicWait);
            updateText('count-ing', cntIng);

            updateHtml('#tab1 .card-group', htmlTotal, '접수된 환자가 없습니다.');
            updateHtml('#tab2 .card-group', htmlWait, '대기중인 환자가 없습니다.');
            updateHtml('#tab3 .card-group', htmlClinicWait, '진료대기 환자가 없습니다.');
            updateHtml('#tab4 .card-group', htmlIng, '현재 진료중인 환자가 없습니다.');
        }

        // 💳 4. 카드 HTML 생성
        function makeCardHtml(patient) {
            let badgeClass = "bg-gray-100 text-gray-800";
            if (patient.insuranceName === '건강보험') badgeClass = "bg-blue-100 text-blue-800";
            else if (patient.insuranceName === '의료급여') badgeClass = "bg-green-100 text-green-800";
            else if (patient.insuranceName === '자동차보험' || patient.insuranceName === '산재') badgeClass = "bg-red-100 text-red-800";

            const statusCode = patient.registrationStatus;
            const pName = patient.patientName || '-';
            const pGen = patient.patientGenKr || '-';
            const pAge = patient.patientAge || 0;
            const pRegNo1 = patient.patientRegno1 || '000000';
            const pStatus = patient.statusName || '대기';
            const regNo = patient.registrationNo || '';
            const patientNo = patient.patientNo || '';
            const rawDate = patient.registrationRegdate;
            const date = new Date(rawDate);

            // 각 부분을 추출 (한국 시간 기준 자동 변환됨)
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작하므로 +1 필요
            const day = String(date.getDate()).padStart(2, '0');
            const hours = String(date.getHours()).padStart(2, '0');
            const minutes = String(date.getMinutes()).padStart(2, '0');

            // 원하는 포맷으로 조립
            const formattedDate = `\${hours}:\${minutes}`;

            let statusStyle = "";
            let statusClickAttr = "";

            if (statusCode === '003') statusStyle = "bg-emerald-50 text-emerald-600 border border-emerald-100";
            else statusStyle = "bg-gray-100 text-gray-600 border border-gray-200";

            // 진료대기(002) 상태일 때만 클릭 이벤트 바인딩
            if (statusCode === '002') {
                statusStyle += " cursor-pointer hover:bg-gray-200 hover:text-gray-800 transition-colors";
                statusClickAttr = `onclick="onStatusClick(event, '\${regNo}', '\${pName}')"`;
            }

            return `
            <div class="card bg-white border border-gray-200 rounded-lg shadow-sm overflow-hidden mb-2 cursor-pointer transition-colors hover:bg-gray-50" 
                onclick="detail('\${patientNo}','\${regNo}',true)">
                <div class="card-header bg-gray-50 px-4 py-2 border-b border-gray-100">
                    <h4 class="card-title text-sm text-gray-700 font-medium">환자번호 \${patientNo}</h4>
                    <span class="text-[11px] text-slate-400">접수 \${formattedDate}</span>
                </div>
                <div class="card-body p-4 flex justify-between items-center">
                    <div class="flex flex-col gap-2">
                        <div>
                            <h3 class="text-lg font-bold text-gray-900">\${pName}</h3>
                            <p class="text-sm text-gray-500 mt-0.5">\${pGen} / \${pAge}세 (\${pRegNo1})</p>
                        </div>
                        <div>
                            <span class="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium \${badgeClass}">
                                \${patient.insuranceName}
                            </span>
                        </div>
                    </div>
                    
                    <div class="flex flex-col items-center justify-center w-20 h-16 rounded-xl ml-4 \${statusStyle}" \${statusClickAttr}>
                        <span class="font-bold text-sm">\${pStatus}</span>
                    </div>
                </div>
            </div>
            `;


        }

        // 🛠 Helper Functions
        function updateText(id, text) {
            const el = document.getElementById(id);
            if (el) el.textContent = text;
        }

        function updateHtml(selector, html, emptyMsg) {
            const el = document.querySelector(selector);
            if (el) {
                el.innerHTML = html ? html : getEmptyHtml(emptyMsg);
            } else {
                console.warn("요소를 찾을 수 없음: " + selector);
            }
        }

        function getEmptyHtml(msg) {
            return `
            <div class="card">
                <div class="empty-state empty-state-list">
                    <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                        <circle cx="9" cy="7" r="4"></circle>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"></path>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"></path>
                    </svg>
                    <div class="empty-state-title">환자가 없습니다</div>
                    <div class="empty-state-description">
                        \${msg}
                    </div>
                </div>
            </div>
            `;
        }

        async function detail(patientNo, regNo, check) {
            let isColosed = document.querySelector("#empty-check");
            console.log(Boolean(isColosed));
            if(
                targetPatient != null && targetPatient.patientNo == patientNo && !isColosed && check
            ) return;
            let flag = await closePrescriptionView();
            if (!flag) return; 
            closePrescriptionView2(); // 뷰2도 안전하게 닫음
            isNewChart = false;
            let preScriptionView = document.querySelector("#preScriptionView");
            // openPrescriptionView();
            console.log("환자 번호 : ", patientNo);
            console.log("접수 번호 : ", regNo);
            const headers = getApiHeaders();
            const requestData = {
                patientVO: {
                    patientNo: patientNo
                },
                screeningVO: {
                    registrationNo: regNo
                }
            };

            try {
                const response = await axios({
                    method: 'post',
                    url: '/doctor/api/getPatientInfo',
                    data: requestData,
                    headers: headers
                });

                const data = response.data;
                console.log("chartlist : ", data);

                if (!data) {
                    sweetAlert("warning", "데이터 없음.", "확인");
                    return;
                }
                document.querySelector("#openPreBtn").disabled = true;
                
                // 전역으로 현재 클릭한 환자 차트번호를 저장
                currentChartNo = response.data.chartList[0].chartNo;
                // 여기에 상세 정보 뿌리는 로직 (updatePatientSideBar 등) 필요하면 추가
                targetPatient = originalPatientList.find(p => p.patientNo == patientNo);
                if (data.chartList[0].chartVO.predetailCnt == 0) {
                    isNewChart = true;
                    if(targetPatient.registrationStatus == '003'){
                        document.querySelector("#openPreBtn").disabled = false;
                    }
                }
                // 환자 정보 뿌리는 화면 엘리먼트
                const patientInfo = document.querySelector("#patientInfo");
                const patient = data.patientVO;
                const scr = data.screeningVO;
                const preList = data.preList;
                const chartList = data.chartList;
                globalChartList = data.chartList;
                console.log("chartList",chartList);

                genPatientInfoView(patient, targetPatient, scr, chartList)

            } catch (error) {
                console.error(error);
            }
        }

        function genPatientInfoView(patient, targetPatient, scr, chartList) {
            const emptyState = document.getElementById('info-empty-state');
            const contentWrap = document.getElementById('info-content-wrap');

            // 1. 데이터가 없으면 빈 화면 보여주기
            if (!patient) {
                if(emptyState) emptyState.classList.remove('hidden');
                if(contentWrap) contentWrap.classList.add('hidden');
                return;
            }

            // 2. 데이터가 있으면 내용 영역 보여주기
            if(emptyState) emptyState.classList.add('hidden');
            if(contentWrap) contentWrap.classList.remove('hidden');

            // 3. [기본 정보] ID로 요소 찾아서 값 넣기
            // setText는 아래에 정의한 헬퍼 함수입니다. (null 체크 포함)
            setText('pt-no', patient.patientNo);
            setText('pt-name', patient.patientName);
            setText('pt-doc-name', '${employee.employeeName}');
            setText('pt-age-gen', `\${targetPatient.patientAge}세 / \${targetPatient.patientGenKr}`);
            
            const birthDate = convertRrnToBirthDate(patient.patientRegno1, patient.patientRegno2);
            setText('pt-birth', birthDate);
            
            // 주민번호 마스킹 처리
            let rrnMask = (patient.patientRegno2 && patient.patientRegno2.length > 0) 
                          ? patient.patientRegno2.substring(0, 1) + "******" 
                          : "-";
            setText('pt-jumin', `\${patient.patientRegno1}-\${rrnMask}`);
            
            setText('pt-tel', patient.patientTel);
            setText('pt-addr', patient.patientAddr1);

            // 4. [바이탈 사인] (Screening)
            if (scr) {
                setText('scr-hw', `\${scr.screeningHeight || '-'} / \${scr.screeningWeight || '-'}`);
                setText('scr-bt', scr.screeningTemperature);
                setText('scr-bp', `\${scr.screeningSystolic || '-'} / \${scr.screeningDiastolic || '-'}`);
                setText('scr-pulse', scr.screeningPulse);
            } else {
                // 데이터가 없으면 초기화
                setText('scr-hw', '- / -');
                setText('scr-bt', '-');
                setText('scr-bp', '- / -');
                setText('scr-pulse', '-');
            }

            // 5. [메모] (Textarea는 value 속성)
            const memoEl = document.getElementById('pt-memo');
            if (memoEl) memoEl.value = patient.patientMemo || '';

            // 6. [내원 이력] 리스트 렌더링 (여기는 동적으로 그려야 함)
            const listHtml = genChartListView(chartList);
            const listContainer = document.getElementById('history-list-container');
            if(listContainer) {
                listContainer.innerHTML = listHtml;
            }
            
        }


        // 처방목록 화면 생성 함수
        function genChartListView(chartList) {
            if (!chartList || chartList.length === 0) {
                // 데이터 없을 때 표시할 HTML
                return `
                    <div class="empty-state empty-state-sm h-[30vh] flex flex-col items-center justify-center text-slate-400">
                        <svg class="w-10 h-10 mb-2 opacity-50" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path></svg>
                        <span class="text-xs">내원 이력이 없습니다.</span>
                    </div>
                `;
            }

            let html = "";
            chartList.forEach(x => {
                if(!x.chartVO.registrationNo || x.chartVO.registrationNo == 0) return;
                // 진료 완료 여부 뱃지
                let badges = x.chartVO.predetailCnt > 0 
                    ? '<span class="badge badge-success" data-flag="1">진료 완료</span>' 
                    : '<span class="badge badge-default" data-flag="0">진료 전</span>';
                
                let dateStr = x.chartVO.chartRegdate ? x.chartVO.chartRegdate.split("T")[0] : '-';

                html += `
                    <div class="list-item border-b border-slate-100 hover:bg-slate-50 transition-colors cursor-pointer p-3" 
                         data-chart-no="\${x.chartNo}" 
                         onclick="loadOrderDetail(this)">
                        <div class="flex justify-between items-center">
                            <div class="flex items-center gap-2">
                                <span class="font-bold text-slate-700">\${dateStr}</span>
                                \${badges}
                            </div>
                            <div class="flex items-center gap-1 text-xs text-slate-500">
                                <i class="icon icon-doctor"></i>
                                <span>\${x.employeeName}</span>
                            </div>
                        </div>
                    </div>
                `;
            });
            
            return html;
        }

        function convertRrnToBirthDate(front, backFirst) {
            if (!front || front.length !== 6 || !backFirst) return "-";

            const yy = front.substring(0, 2);
            const mm = front.substring(2, 4);
            const dd = front.substring(4, 6);
            const code = parseInt(backFirst.substring(0, 1));

            let prefix = "19"; // 기본값

            // 주민번호 뒷자리 첫 글자에 따른 세기(Century) 판별
            switch (code) {
                case 9:
                case 0:
                    prefix = "18";
                    break; // 1800년대생 (매우 드묾)
                case 1:
                case 2:
                case 5:
                case 6:
                    prefix = "19";
                    break; // 1900년대생 (내국인/외국인)
                case 3:
                case 4:
                case 7:
                case 8:
                    prefix = "20";
                    break; // 2000년대생 (내국인/외국인)
                default:
                    prefix = "19";
                    break; // 예외 시 1900년대 처리
            }

            return `\${prefix}\${yy}-\${mm}-\${dd}`;
        }

        function getChosung(str) {
            const chosung = ['ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'];
            let result = "";
            for (let i = 0; i < str.length; i++) {
                const code = str.charCodeAt(i) - 44032;
                if (code > -1 && code < 11172) result += chosung[Math.floor(code / 588)];
                else result += str.charAt(i);
            }
            return result;
        }

        /**
         * [복구 완료] 진료대기 상태 클릭 이벤트 (SweetAlert)
         */
        function onStatusClick(event, regNo, pName) {
            // 1. 부모(카드) 클릭 이벤트 방지
            // event.stopPropagation();

            // 2. SweetAlert 호출 (선생님 코드 복구)
            console.log(`[진료대기 클릭] \${pName}님(\${regNo})을 호출합니다.`);

            // sweetAlert("아이콘", "메시지", "확인버튼문구", "취소버튼문구", 취소버튼유무)
            sweetAlert("warning", `\${pName} 환자분을 호출하시겠습니까?`, "확인", "취소", true)
                .then(x => {
                    if (x.isConfirmed) {
                        changePatientStatus(regNo, '003', `\${pName} 님을 호출했습니다.`);
                        detail(targetPatient.patientNo, targetPatient.registrationNo,false);
                    }
                });
        }

        // Dropdown Toggle
        function toggleDropdown(event, id) {
            event.stopPropagation();
            const dropdown = document.getElementById(id);
            document.querySelectorAll('.dropdown-menu').forEach(d => {
                if (d.id !== id) d.classList.remove('show');
            });
            dropdown.classList.toggle('show');
        }

        document.addEventListener('click', function() {
            document.querySelectorAll('.dropdown-menu, .popover-menu').forEach(el => {
                el.classList.remove('show');
            });
        });

        // Accordion Toggle
        function toggleAccordion(button) {
            const item = button.closest('.accordion-item');
            const accordion = button.closest('.accordion');
            const isActive = item.classList.contains('active');
            accordion.querySelectorAll('.accordion-item').forEach(i => {
                i.classList.remove('active');
            });
            if (!isActive) item.classList.add('active');
        }

        // 탭 전환 함수
        function switchTab(event, tabId) {
            const clickedTab = event.currentTarget;
            const tabContainer = clickedTab.closest('.tabs');
            tabContainer.querySelectorAll('.tab').forEach(tab => tab.classList.remove('active'));
            clickedTab.classList.add('active');

            const targetContent = document.getElementById(tabId);
            if (targetContent) {
                const contentWrapper = targetContent.parentElement;
                contentWrapper.querySelectorAll('.tab-content').forEach(content => content.classList.remove('active'));
                targetContent.classList.add('active');
            }
        }


        function renderViewData(dataList,chart) {

            console.log(chart);
            document.querySelector("#preScriptionTime_view").innerHTML = chart.chartRegdate;
            // 1. 메모 초기화
            document.getElementById('clinicNote_view').value = "";

            // 2. HTML을 담을 변수 초기화 (바로 innerHTML에 넣지 않고 여기에 모읍니다)
            let dxHtml = ""; // 상병
            let txHtml = ""; // 치료+주사
            let rxHtml = ""; // 약제
            let opHtml = ""; // 수술
            let exHtml = "";
            let notes = chart.chartContent || '';  // 메모

            if (notes == '') {
                document.getElementById('clinicNote_view').placeholder = "등록된 진료 기록이 없습니다.";
            } else {
                document.getElementById('clinicNote_view').value = notes;
            }
            

            let dxIdx = 1, txIdx = 1, rxIdx = 1, opIdx = 1 , exIdx = 1;
            let diagList = chart.diagnosis;
            // (2) 상병 리스트
            if (diagList && diagList.length > 0) {
                // ★ [추가된 코드] 주상병('Y')이 위로 오도록 정렬
                diagList.sort((a, b) => {
                    if (a.diagnosisDetailYN === 'Y') return -1; // a가 '주'면 앞으로 보냄
                    if (b.diagnosisDetailYN === 'Y') return 1;  // b가 '주'면 b를 앞으로 보냄
                    return 0; // 둘 다 같으면 순서 유지
                });
                diagList.forEach(item => {
                    let type = (item.diagnosisDetailYN === 'Y') ? '주' : '부';
                    
                    // 폰트 관련 클래스 제거, 배경색/테두리만 유지
                    let badgeClass = (type === '주') 
                        ? 'bg-blue-50 text-blue-600 border border-blue-100' 
                        : 'bg-gray-50 text-gray-500 border border-gray-200';

                    dxHtml += `
                        <tr class="hover:bg-slate-50 border-b border-slate-100 transition-colors">
                            <td class="text-center py-3">\${dxIdx++}</td>
                            
                            <td class="text-center py-3">
                                <span class="inline-block px-2 py-0.5 rounded \${badgeClass}">
                                    \${type}
                                </span>
                            </td>
                            
                            <td class="text-center py-3">\${item.diagnosisCode}</td>
                            
                            <td class="text-left py-3 pl-4">\${item.diagnosisName}</td>
                        </tr>`;
                });
            }
            // 3. 데이터가 존재할 경우 루프 돌면서 HTML 생성
            if (dataList && dataList.length > 0) {
                dataList.forEach(data => {


                    // (3) 약제 리스트 (주사는 치료로 이동)
                    if (data.drugList && data.drugList.length > 0) {
                        data.drugList.forEach(item => {
                            let isInjection = (item.drugType === '주사' || item.predrugDetailType === 'N');
                            let status = item.predrugDetailStatus; 
                            let statusText = (status === '001') ? '완료' : '대기';
                            let statusClass = (status === '001') 
                                ? 'bg-green-50 text-green-600 border border-green-100' 
                                : 'bg-gray-50 text-gray-500 border border-gray-200';
                            if (isInjection) {
                                // [주사] -> 치료 테이블로
                                txHtml += `
                                    <tr class="hover:bg-slate-50 border-b border-slate-100 transition-colors">
                                        <td class="text-center py-3">\${txIdx++}</td>
                                        
                                        <td class="text-center py-3">
                                            <span class="inline-block px-2 py-0.5 rounded border bg-blue-50 text-blue-600 border-blue-100">
                                                주사
                                            </span>
                                        </td>
                                        
                                        <td class="text-center py-3">\${item.drugCode}</td>
                                        
                                        <td class="text-left py-3 pl-4">\${item.drugName}</td>
                                        
                                        <td class="text-center py-3">\${item.predrugDetailFreq || '-'}</td>
                                        
                                        <td class="text-center py-3">\${item.predrugDetailDay || '-'}</td>
                                        
                                        <td class="text-left py-3">
                                            <span class="inline-block px-2 py-0.5 rounded \${statusClass}">
                                                \${statusText}
                                            </span>
                                        </td>
                                    </tr>`;
                            } else {
                                // [내복약] -> 약제 테이블로
                                rxHtml += `
                                    <tr class="hover:bg-slate-50 border-b border-slate-100 transition-colors">
                                        <td class="text-center py-3">\${rxIdx++}</td>
                                        
                                        <td class="text-left py-3 pl-4" title="\${item.drugName}">
                                            \${item.drugName}
                                        </td>
                                        
                                        <td class="text-center py-3">\${item.predrugDetailDose || '-'}</td>
                                        
                                        <td class="text-center py-3">\${item.predrugDetailFreq || '-'}</td>
                                        
                                        <td class="text-center py-3">\${item.predrugDetailDay || '-'}</td>
                                        
                                        <td class="text-left py-3">\${item.predrugDetailMethod || '-'}</td>
                                    </tr>`;
                            }
                        });
                    }

                    // (4) 치료 리스트
                    if (data.treatList && data.treatList.length > 0) {
                        data.treatList.forEach(item => {
                            let status = item.pretreatmentDetailStatus;
                            let statusText = (status === '001') ? '완료' : '대기';
                            let statusClass = (status === '001') 
                                ? 'bg-green-50 text-green-600 border border-green-100' 
                                : 'bg-gray-50 text-gray-500 border border-gray-200';
                            txHtml += `
                                <tr class="hover:bg-slate-50 border-b border-slate-100 transition-colors">
                                    <td class="text-center py-3">\${txIdx++}</td>
                                    
                                    <td class="text-center py-3">
                                        <span class="inline-block px-2 py-0.5 rounded border bg-green-50 text-green-600 border-green-100">
                                            치료
                                        </span>
                                    </td>
                                    
                                    <td class="text-center py-3">\${item.treatmentCode}</td>
                                    
                                    <td class="text-left py-3 pl-4">\${item.treatmentName}</td>
                                    
                                    <td class="text-center py-3">\${item.pretreatmentDetailFreq || '-'}</td>
                                    
                                    <td class="text-center py-3">\${item.pretreatmentDetailDay || '-'}</td>
                                    
                                    <td class="text-left py-3">
                                        <span class="inline-block px-2 py-0.5 rounded \${statusClass}">
                                            \${statusText}
                                        </span>
                                    </td>
                                </tr>`;
                        });
                    }

                    // (5) 수술 리스트
                    if (data.operList && data.operList.length > 0) {
                        data.operList.forEach(item => {
                            opHtml += `
                                <tr class="hover:bg-slate-50 border-b border-slate-100 transition-colors">
                                    <td class="text-center py-3">\${opIdx++}</td>
                                    
                                    <td class="text-center py-3">\${item.operationCode}</td>
                                    
                                    <td class="text-left py-3 pl-4">\${item.operationName}</td>
                                </tr>`;
                        });
                    }

                    // 거지같은 영상검사
                    if (data.examList && data.examList.length > 0){
                        data.examList.forEach(item => {
                            let status = item.preexaminationDetailStatus;
                            let statusText = (status === '001') ? '완료' : '대기';
                            let statusClass = (status === '001') 
                                ? 'bg-green-50 text-green-600 border border-green-100' 
                                : 'bg-gray-50 text-gray-500 border border-gray-200';

                            // 2. 파일 아이콘 로직 (있으면 파랑, 없으면 회색)
                            let fileIcon = '';
                            if (item.attachmentNo) {
                                // 파일 있음: 파란색 아이콘
                                fileIcon = `
                                <a href="/\${item.attachmentDetailPath}" target="_blank">
                                    <svg class="w-4 h-4 text-blue-500 mx-auto cursor-pointer hover:text-blue-700" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                                    </svg>
                                </a>
                                    `;
                            } else {
                                // 파일 없음: 회색 아이콘 (비활성 느낌)
                                fileIcon = `
                                    <svg class="w-4 h-4 text-gray-300 mx-auto" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M19.5 14.25v-2.625a3.375 3.375 0 00-3.375-3.375h-1.5A1.125 1.125 0 0113.5 7.125v-1.5a3.375 3.375 0 00-3.375-3.375H8.25m3.75 9v6m3-3H9m1.5-12H5.625c-.621 0-1.125.504-1.125 1.125v17.25c0 .621.504 1.125 1.125 1.125h12.75c.621 0 1.125-.504 1.125-1.125V11.25a9 9 0 00-9-9z" />
                                        <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" opacity="0.3"/> 
                                    </svg>`;
                            }
                            let latVal = item.preexaminationDetailLaterality; 
                            let latClass = 'bg-gray-50 text-slate-600 border-slate-200'; // 기본값
                            let latText = latVal || '-'; 

                            // 값이 '좌'이거나 'L'이면 -> '좌(L)'로 변경하고 파란색
                            if (latVal === '좌' || latVal === 'L') {
                                latText = '좌(L)';
                                latClass = 'bg-blue-50 text-blue-600 border-blue-100';
                            } 
                            // 값이 '우'이거나 'R'이면 -> '우(R)'로 변경하고 빨간색
                            else if (latVal === '우' || latVal === 'R') {
                                latText = '우(R)';
                                latClass = 'bg-red-50 text-red-600 border-red-100';
                            } 

                            let latHtml = (latVal && latVal !== '-') 
                                ? `<span class="inline-block px-2 py-0.5 rounded border \${latClass}">\${latText}</span>` 
                                : '-';
                            exHtml += `
                                <tr class="hover:bg-slate-50 border-b border-slate-100 transition-colors">
                                    <td class="text-center py-3">\${exIdx++}</td>
                                    
                                    <td class="text-left py-3 pl-4">\${item.examinationName}</td>
                                    
                                    <td class="text-left py-3 pl-4">\${item.preexaminationDetailSite}</td>
                                    
                                    <td class="text-left py-3">
                                        \${latHtml}
                                    </td>
                                    
                                    <td class="text-center py-3">
                                        \${fileIcon}
                                    </td>
                                    
                                    <td class="text-left py-3">
                                        <span class="inline-block px-2 py-0.5 rounded \${statusClass}">
                                            \${statusText}
                                        </span>
                                    </td>
                                </tr>`;
                        });
                    }
                });
            }

            // 4. 최종 렌더링 (내용이 없으면 안내 메시지 출력)
            // 상병 (colspan=4)
            document.getElementById('dxTableBody_view').innerHTML = dxHtml || 
                `<tr><td colspan="4" class="text-center text-gray-400 py-8 text-sm bg-gray-50/50">조회하신 정보가 존재하지 않습니다.</td></tr>`;

            // 치료 (colspan=6)
            document.getElementById('txTableBody_view').innerHTML = txHtml || 
                `<tr><td colspan="7" class="text-center text-gray-400 py-8 text-sm bg-gray-50/50">조회하신 정보가 존재하지 않습니다.</td></tr>`;

            // 약제 (colspan=6)
            document.getElementById('rxTableBody_view').innerHTML = rxHtml || 
                `<tr><td colspan="6" class="text-center text-gray-400 py-8 text-sm bg-gray-50/50">조회하신 정보가 존재하지 않습니다.</td></tr>`;

            // 수술 (colspan=3)
            document.getElementById('opTableBody_view').innerHTML = opHtml || 
                `<tr><td colspan="3" class="text-center text-gray-400 py-8 text-sm bg-gray-50/50">조회하신 정보가 존재하지 않습니다.</td></tr>`;
                
            document.getElementById('exTableBody_view').innerHTML = exHtml || 
                `<tr><td colspan="6" class="text-center text-gray-400 py-8 text-sm bg-gray-50/50">조회하신 정보가 존재하지 않습니다.</td></tr>`;

        }

        function savePrescription() {
            console.log("저장 시작 - 차트번호:", currentChartNo);

            let content = document.querySelector("#clinicNote").value;

            // 전송할 전체 데이터 객체 (PredetailVO 구조)
            let predetailData = {
                chartNo: currentChartNo,
                predetailStatus: "Y",
                chartContent: content,
                diagList: [], // 상병 리스트
                drugList: [], // 약제 + 주사 리스트
                treatList: [], // 일반 치료 리스트
                examList: [], // 검사 리스트 (필요 시 추가)
                operList: [], // 수술 리스트
                examList: [] // 검사
            };

            /* -----------------------------------------------------------
            1. 상병 데이터 수집 (#dxTableBody)
            ----------------------------------------------------------- */
            document.querySelectorAll('#dxTableBody tr').forEach((row) => {
                // 체크된 라디오 버튼 찾기
                const checkedRadio = row.querySelector('input[type="radio"]:checked');

                // Value 값 가져오기 (Y: 주상병, N: 부상병)
                let typeVal = checkedRadio ? checkedRadio.value : 'N';

                let diagnosis = {
                    diagnosisNo: row.dataset.no,
                    diagnosisCode: row.dataset.code,
                    diagnosisDetailYN: typeVal,
                    chartNo: predetailData.chartNo
                };

                predetailData.diagList.push(diagnosis);
            });

            /* -----------------------------------------------------------
            2. 약제(내복약) 데이터 수집 (#rxTableBody)
            ----------------------------------------------------------- */
            document.querySelectorAll('#rxTableBody tr').forEach(row => {
                let inputs = row.querySelectorAll('input');
                let select = row.querySelector('select');

                let drug = {
                    drugNo: row.dataset.no,
                    drugCode: row.dataset.code,
                    predrugDetailDose: inputs[0].value, // 1회 투여량
                    predrugDetailFreq: inputs[1].value, // 횟수
                    predrugDetailDay: inputs[2].value, // 일수
                    predrugDetailMethod: select.value, // 용법 (식후 30분 등)
                    predrugDetailType: 'Y', // 타입 명시
                    predrugDetailStatus: '002',
                    predrugDetailPharmtype: 'Y'
                };

                predetailData.drugList.push(drug);
            });

            /* -----------------------------------------------------------
            3. [핵심] 치료 및 주사 데이터 수집 (#txTableBody)
            - data-group 속성에 따라 drugList(주사)와 treatList(치료)로 분기
            ----------------------------------------------------------- */
            document.querySelectorAll('#txTableBody tr').forEach(row => {
                let inputs = row.querySelectorAll('input');

                // ★ tr 태그에 심어둔 타입 읽기 ('treatment' 또는 'injection')
                let group = row.dataset.group;

                if (group === 'injection') {
                    // =======================================================
                    // [A] 주사 -> DrugVO 매핑하여 drugList에 추가
                    // =======================================================
                    let inject = {
                        drugNo: row.dataset.no,
                        drugCode: row.dataset.code, // 주사제 코드 (약품코드)
                        predrugDetailDose: inputs[0].value, // 1회량
                        predrugDetailFreq: inputs[1].value, // 횟수
                        predrugDetailDay: inputs[2].value, // 일수
                        predrugDetailType: 'N', // ★ 타입 명시 (주사)
                        predrugDetailMethod: '주사', // 용법 (주사는 용법이 보통 고정)
                        predrugDetailStatus: '002',
                        predrugDetailPharmtype: 'Y'

                    };

                    predetailData.drugList.push(inject);

                } else {
                    // =======================================================
                    // [B] 일반 치료 -> TreatmentVO 매핑하여 treatList에 추가
                    // =======================================================
                    let treat = {
                        treatmentNo: row.dataset.no,
                        treatmentCode: row.dataset.code, // 치료 코드

                        // 치료는 1회량 Input이 disabled 상태이므로 0 또는 1로 처리
                        pretreatmentDetailDose: 0,

                        pretreatmentDetailFreq: inputs[1].value, // 횟수
                        pretreatmentDetailDay: inputs[2].value, // 일수

                        pretreatmentDetailMethod: '',
                        pretreatmentDetailStatus: '002'
                    };

                    predetailData.treatList.push(treat);
                }
            });

            /* -----------------------------------------------------------
            4. 수술 데이터 수집 (#opTableBody) [추가]
            ----------------------------------------------------------- */
            document.querySelectorAll('#opTableBody tr').forEach((row, i) => {
                // VO 필드명에 맞춰서 객체 생성
                let operation = {
                    operationNo: row.dataset.no,
                    operationCode: row.dataset.code,
                    operationName: row.dataset.name,
                    preoperationStatus: '002', // 기본 상태
                    employeeNo: targetPatient.employeeNo
                    // predetailNo, chartNo 등은 서버나 상위에서 처리하거나 필요시 추가
                };
                predetailData.operList.push(operation);
            });

            /* -----------------------------------------------------------
            [신규] 검사 데이터 수집 (#exTableBody)
            ----------------------------------------------------------- */
            document.querySelectorAll('#exTableBody tr').forEach((row) => {
                let exam = {
                    examinationNo: row.dataset.modality,
                    preexaminationDetailSite: row.dataset.site,        // 환부
                    preexaminationDetailLaterality: row.dataset.laterality,   // 좌우구분
                    preexaminationDetailStatus: '002',                  // 상태 (기본값)
                    preexaminationDetailFreq : '1',
                    preexaminationDetailDay : '1'
                };
                predetailData.examList.push(exam);
            });

            console.log("📦 [최종 전송 데이터]", predetailData);
            
            if (!targetPatient) {
                sweetAlert("warning", "선택된 환자가 없습니다 환자를 선택해주세요", "확인");
                return;
            }
            
            if (targetPatient.registrationStatus != '003') {
                sweetAlert("warning", `\${targetPatient.patientName} 님은 진료중인 환자가 아닙니다.`, "확인");
                return;
            }
            if (!predetailData.chartNo) {
                sweetAlert("warning", "차트번호가 없습니다 환자를 선택해주세요", "확인");
                return;
            }
            // 최종 데이터 확인 및 전송
            if (!isNewChart) {
                sweetAlert("warning", "이미 처방된 환자입니다.", "확인");
                return
            }
            if (predetailData.diagList.length == 0) {
                sweetAlert("warning", "상병진단은 필수입니다. 상병을 선택해주세요", "확인");
                return;
            }
            // TODO: 서버로 전송 (Axios)
            // changePatientStatus(targetPatient.registrationNo,'004','진료가 완료되었습니다.')
            sweetAlert("warning", `진료를 완료하시겠습니까?`, "확인", "취소", true)
            .then(confirmRes => {
                if(confirmRes.isConfirmed){
                    axios.post('/doctor/api/insertPrescription', predetailData, {
                            headers: getApiHeaders()
                        })
                        .then(res => {
                    sweetAlert("success", '진료가 완료되었습니다.', "확인");
                    document.querySelector("#preScriptionEmptyView").classList.remove("hidden");
                    document.querySelector("#preScriptionView").classList.add("hidden");
                    document.querySelector("#preScriptionView2").classList.add("hidden");
                    detail(targetPatient.patientNo, targetPatient.registrationNo,false);
                    let arr = ['dxTableBody', 'txTableBody', 'rxTableBody', 'opTableBody','exTableBody']
                    arr.map(x => {
                        document.getElementById(x).innerHTML = "";
                    })
                    document.querySelector("#clinicNote").value = "";
                    targetPatient = null;
                    currentChartNo = null;
                    isNewChart = false;
                    })
                    .catch(err => console.error(err));
                }
            })
        }

        function changePatientStatus(regNo, status, msg) {
            let data = {
                registrationNo: regNo,
                registrationStatus: status
            }
            axios.post('/doctor/api/updatePatientStatus', data, {
                    headers: getApiHeaders()
                })
                .then(res => {
                    loadPatientList();
                    sweetAlert("success", msg, "확인");
                    targetPatient.registrationStatus = '003';
                })
                .catch(err => console.error(err));
        }

        function openPrescriptionView() {
            document.querySelector("#preScriptionEmptyView").classList.add("hidden");
            document.querySelector("#preScriptionView").classList.remove("hidden");
            document.querySelector("#preScriptionView2").classList.add("hidden");
        }

        async function closePrescriptionView() {

            // 이건 적당히 빡대가리
            if (document.querySelector("#preScriptionView").classList.contains("hidden")) return true;

            let result = await sweetAlert("warning", `저장되지 않은 기록은 삭제됩니다 진료창을 닫으시겠습니까?`, "확인", "취소", true)

            if (result.isConfirmed) {
                document.querySelector("#preScriptionEmptyView").classList.remove("hidden");
                document.querySelector("#preScriptionView").classList.add("hidden");
                document.querySelector("#preScriptionView2").classList.add("hidden");
                let arr = ['dxTableBody', 'txTableBody', 'rxTableBody', 'opTableBody','exTableBody']
                arr.map(x => {
                    document.getElementById(x).innerHTML = "";
                })
                document.querySelector("#clinicNote").value = "";
                return true;
            }
            return false;
        }


        function openPrescriptionView2(){
            document.querySelector("#preScriptionEmptyView").classList.add("hidden");
            document.querySelector("#preScriptionView").classList.add("hidden");
            document.querySelector("#preScriptionView2").classList.remove("hidden");
        }

        function closePrescriptionView2(){
            document.querySelector("#preScriptionEmptyView").classList.remove("hidden");
            document.querySelector("#preScriptionView").classList.add("hidden");
            document.querySelector("#preScriptionView2").classList.add("hidden");
        }

        async function closeInfoView() {
            // 작성 중인 처방이 있으면 확인창 띄우기 (기존 함수 재사용)
            let flag = await closePrescriptionView();
            if (flag) {
                // UI를 초기 상태(Empty State)로 전환
                const emptyState = document.getElementById('info-empty-state');
                const contentWrap = document.getElementById('info-content-wrap');
                
                if(emptyState) emptyState.classList.remove('hidden');
                if(contentWrap) contentWrap.classList.add('hidden');
                // 버튼 초기화
                document.querySelector("#openPreBtn").disabled = true;
                // 전역 변수 초기화
                targetPatient = null;
                currentChartNo = null;
            }
        }
        // [신규] 텍스트 안전하게 넣는 헬퍼 함수 (반복 줄이기용)
        function setText(id, text) {
            const el = document.getElementById(id);
            if (el) {
                el.textContent = text || '-'; // 값이 없으면 하이픈(-) 처리
            }
        }

        async function loadOrderDetail(ele){
            const chartNo = ele.dataset.chartNo;
            const flag = ele.querySelector(".badge").dataset.flag;
            if(flag == 0){
                console.log("처방정보 없음")
                return;
            }

            let currentChart = globalChartList.find(x=> x.chartNo == chartNo);
            console.log(chartNo);
            console.log(currentChart);
            let result = await axios.post('/doctor/api/selectChart', {chartNo}, {
                headers: getApiHeaders()
            });
            console.log(result.data);
            renderViewData(result.data,currentChart.chartVO);
            openPrescriptionView2();

        }
        
    	// 서류 모달 열기
    	async function openIpDocModal(type, chartNo) {
    	    const targetChartNo = chartNo || currentChartNo; 
    	    
    	    if (!targetChartNo) return Swal.fire("경고", "진료 차트를 먼저 선택해주세요!", "warning");

    	    const isDx = (type === 'dx');
    	    const modalId = isDx ? "#ipDxModal" : "#ipOpModal";
    	    const prefix = isDx ? "dx" : "op"; 
    	    const typeName = isDx ? "진단서" : "소견서";

			
			console.log("보내는 데이터:", { docType: 'CERT', certificateNo: isDx ? 1 : 2, chartNo: targetChartNo });
    	    document.getElementById(`\${prefix}Content`).value = "";
    	    document.getElementById(`\${prefix}Remark`).value = "";
    	    document.getElementById(`\${prefix}Purpose`).value = "";
    	    document.getElementById(`\${prefix}DxDate`).value = new Date().toISOString().substring(0, 10);

    	    try {
    	        const response = await axios.get('/certificate/api/patientDocDetail', {
    	            params: { 
    	            	docType: 'CERT', 
    	            	certificateNo: isDx ? 1 : 2, 
    	            	chartNo: targetChartNo 
    	            }
    	        });
    	        
    	        const d = (response.data && response.data.length > 0) ? response.data[0] : response.data;
    	        
    	        if (d && d.medicalCertificateContent) {
    	            return Swal.fire({
    	                icon: 'info',
    	                title: `이미 작성된 \${typeName}가 있습니다.`,
    	                text: "기존 문서를 수정하시거나 새로 출력해 주세요.",
    	                confirmButtonColor: '#4f46e5'
    	            });
    	        }
    	        
    	        document.querySelector(modalId).classList.remove("hidden");
    		    document.querySelector(modalId).classList.add("flex");
    	        
    	        const pName = d.patientName || (detail ? detail.patientName : "");
    	        const pReg1 = d.patientRegno1 || (detail ? detail.patientNo : ""); 
    	        const pAddr = d.patientAddr1 ? `\${d.patientAddr1} \${d.patientAddr2 || ''}` : "";
    	        const pTel  = d.patientTel || "";

    	        document.getElementById(`\${prefix}PatientName`).value = pName;
    	        document.getElementById(`\${prefix}Rrn`).value = pReg1 ? `\${pReg1}-*******` : "";
    	        document.getElementById(`\${prefix}Address`).value = pAddr;
    	        document.getElementById(`\${prefix}Phone`).value = pTel;
    	        
    	        document.getElementById(`\${prefix}Org`).value = d.hospitalName ? `\${d.hospitalName} (\${d.hospitalAddr})` : loginDoctor.org;
    	        document.getElementById(`\${prefix}Licence`).value = d.employeeDetailLicence || loginDoctor.licence;
    	        document.getElementById(`\${prefix}DoctorName`).value = d.employeeName || loginDoctor.name;

    	        const tbody = document.getElementById(`\${prefix}DxTbody`);
    	        tbody.innerHTML = "";
    	        
    	        let diagList = [];
    	        if (d && d.diagnosisList && d.diagnosisList.length > 0) {
    	            diagList = d.diagnosisList;
    	        } else if (detail && detail.diagnosis && detail.diagnosis.length > 0) {
    	            diagList = detail.diagnosis;
    	        }

    	        if (diagList.length > 0) {
    	            diagList.forEach((diag, idx) => {
    	                const ynValue = diag.diagnosisDetailYN || diag.diagnosisDetailYn;
    	                const typeText = ynValue === 'Y' ? '주' : '부';
    	                
    	                tbody.innerHTML += `
    	                    <tr class="border-b border-zinc-50 text-center">
    	                        <td class="p-3 text-zinc-500 font-bold">\${typeText}</td>
    	                        <td class="p-3 text-zinc-500 font-mono text-sm">\${diag.diagnosisCode}</td>
    	                        <td class="p-3 text-zinc-700 font-medium text-left px-4">\${diag.diagnosisName}</td>
    	                    </tr>`;
    	            });
    	        } else {
    	            tbody.innerHTML = '<tr><td colspan="3" class="p-10 text-center text-zinc-400">등록된 상병 정보가 없습니다.</td></tr>';
    	        }
    	    } catch (e) {
    	        console.error("모달 데이터 로딩 중 에러:", e);
    	    }
    	}

    	// 서류 모달 닫기
    	function closeIpDocModal(type) {
    	    const id = type === 'dx' ? "#ipDxModal" : "#ipOpModal";
    	    document.querySelector(id).classList.add("hidden");
    	    document.querySelector(id).classList.remove("flex");
    	}

    	// 진단서, 소견서 입력
    	async function insertCertificate(type) {
    	    const prefix = type;
    	    const certNo = (type === 'dx' ? 1 : 2);
    	    
    	    const formData = {
    	        certificateNo: certNo,
    	        chartNo: currentChartNo, 
    	        medicalCertificateOnset: certNo === 1 ? document.getElementById(`\${prefix}OnsetDate`).value : "",
    	        medicalCertificateDiagnosis: document.getElementById(`\${prefix}DxDate`).value,
    	        medicalCertificateContent: document.getElementById(`\${prefix}Content`).value,
    	        medicalCertificateRemark: document.getElementById(`\${prefix}Remark`).value,
    	        medicalCertificatePurpose: document.getElementById(`\${prefix}Purpose`).value
    	    };

    	    if (!formData.medicalCertificateContent) {
    	        return Swal.fire({ 
    	        	icon: 'info', 
    	        	title: '내용을 입력해주세요.' 
    	        });
    	    }

    	    try {
    	        const resp = await axios.post('/certificate/api/insertCertificate', formData);
    	        if (resp.data.status === "success") {
    	            Swal.fire({ 
    	            	icon: 'success', 
    	            	title: '저장 완료', 
    	            	timer: 1000, 
    	            	showConfirmButton: false 
    	            });
    	            closeIpDocModal(type);
    	        }
    	    } catch (e) {
    	        console.error("저장 중 오류 발생:", e);
    	    }
    	}
    </script>
</body>

</html>