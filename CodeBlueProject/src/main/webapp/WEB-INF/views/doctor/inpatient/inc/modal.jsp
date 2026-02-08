<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<sec:authorize access="isAuthenticated()">
    <sec:authentication property="principal" var="pinfo"/>
    <c:set var="loginUserNo" value="${pinfo.employee.employeeNo}" />
    <c:set var="loginJob" value="ETC" />
    <c:forEach items="${pinfo.employee.authList}" var="authVO">
        <c:choose>
            <c:when test="${authVO.auth eq 'ROLE_DOCTOR'}"><c:set var="loginJob" value="DOC" /></c:when>
            <c:when test="${loginJob ne 'DOC' and (authVO.auth eq 'ROLE_NURSE_IN' or authVO.auth eq 'ROLE_NURSE_OUT')}"><c:set var="loginJob" value="NUR" /></c:when>
            <c:when test="${loginJob ne 'DOC' and loginJob ne 'NUR' and authVO.auth eq 'ROLE_ADMIN'}"><c:set var="loginJob" value="ADM" /></c:when>
        </c:choose>
    </c:forEach>
</sec:authorize>
<sec:authorize access="isAnonymous()">
    <c:set var="loginUserNo" value="0" /><c:set var="loginJob" value="" />
</sec:authorize>

<div id="macro-modal" class="fixed inset-0 z-[60] hidden">
  <div class="absolute inset-0 bg-zinc-900/60 backdrop-blur-sm transition-opacity" onclick="closeMacroModal()"></div>
  <div class="absolute inset-0 flex items-center justify-center p-4">
    <div class="flex h-[750px] w-[1100px] flex-col rounded-3xl bg-white shadow-2xl ring-1 ring-black/5 overflow-hidden animate-in fade-in zoom-in duration-200 relative">
      <div class="flex flex-1 overflow-hidden">
        
        <div class="flex w-[320px] flex-col border-r border-zinc-200 bg-zinc-50/50">
            <div class="p-6 flex justify-between items-center border-b border-zinc-200 bg-white">
                <h2 class="text-lg font-black text-zinc-900 tracking-tight">나의 오더 목록</h2>
                <span id="macro-role-badge" class="text-[10px] px-2 py-0.5 rounded font-bold
                    <c:choose>
                        <c:when test="${loginJob eq 'DOC'}">bg-blue-50 text-blue-600</c:when>
                        <c:when test="${loginJob eq 'NUR'}">bg-green-50 text-green-600</c:when>
                        <c:otherwise>bg-zinc-100 text-zinc-500</c:otherwise>
                    </c:choose>">
                    <c:choose>
                        <c:when test="${loginJob eq 'DOC'}">의사 (Doctor)</c:when>
                        <c:when test="${loginJob eq 'NUR'}">간호사 (Nurse)</c:when>
                        <c:otherwise>일반 (Staff)</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div class="p-4 bg-white border-b border-zinc-100">
                <div class="input-group">
                    <input type="text" id="macro-modal-search" onkeyup="filterModalMacros()" placeholder="오더 검색..." class="input input-search w-full font-bold">
                </div>
            </div>
            <div id="macro-modal-list" class="flex-1 overflow-y-auto p-3 space-y-2"></div>
        </div>

        <div class="flex-1 flex flex-col bg-white relative">
            <div class="px-8 py-6 border-b border-zinc-200 flex justify-between items-center bg-white sticky top-0 z-10">
                <div>
                    <h2 class="text-xl font-black text-zinc-900 tracking-tight">나의 오더 상세</h2>
                    <p class="text-[10px] text-zinc-400 font-black tracking-widest mt-1 uppercase">MACRO CONFIGURATION</p>
                </div>
                <div class="px-8 py-6 border-b border-zinc-200 flex justify-start items-center gap-4 bg-white sticky top-0 z-10">
			    
			    <div class="flex items-center gap-2">
			      <button id="btn-modal-new-macro" onclick="initModalNewMacro()" class="btn btn-secondary btn-sm px-4 font-bold hidden">
			          <i class="icon icon-plus mr-1"></i>신규 작성
			      </button>
			      <button onclick="saveModalMacro()" class="btn btn-primary btn-sm px-6 shadow-lg shadow-indigo-100 font-black">
			          <i class="icon icon-save mr-1"></i>저장
			      </button>
			    </div>
			</div>
            </div>

            <div id="macro-edit-form" class="flex-1 overflow-y-auto p-10 bg-white">
                <input type="hidden" id="macro-modal-no" value="0">
                <div class="max-w-4xl mx-auto space-y-8">
                    <div class="grid grid-cols-2 gap-8">
                        <div>
                            <label class="block text-[11px] font-black uppercase text-zinc-400 tracking-wider mb-2">역할 선택</label>
                            <select id="macro-modal-type" class="select w-full h-12 font-bold bg-zinc-50 text-zinc-700" disabled>
                                <option value="001">의사 (처방/상병 포함)</option>
                                <option value="002">간호사 (기록 전용)</option>
                            </select>
                        </div>
                        <div>
                            <label class="block text-[11px] font-black uppercase text-zinc-400 tracking-wider mb-2">나의 오더 명칭</label>
                            <input type="text" id="macro-modal-name" class="input w-full h-12 font-bold" placeholder="예: 발목 염좌 세트">
                        </div>
                    </div>

                    <div id="macro-doctor-panel" class="space-y-8">
                        <div class="grid grid-cols-2 gap-8">
                            <div>
                                <label class="block text-[11px] font-black uppercase text-primary tracking-wider mb-2 flex justify-between">
                                    <span>상병코드 세트</span>
                                    <button onclick="openMacroSearch('DIAGNOSIS')" class="text-blue-600 hover:underline cursor-pointer">+ 추가</button>
                                </label>
                                <div id="macro-diag-list" class="space-y-1 mb-2 hidden"></div>
                                <div id="macro-diag-empty" onclick="openMacroSearch('DIAGNOSIS')" class="h-28 border-2 border-dashed border-indigo-100 rounded-2xl flex items-center justify-center cursor-pointer hover:border-primary hover:bg-indigo-50/30 transition-all text-zinc-400 text-xs font-bold">
                                    <i class="icon icon-plus mr-1"></i> 클릭하여 상병코드 추가
                                </div>
                            </div>
                            <div>
                                <label class="block text-[11px] font-black uppercase text-primary tracking-wider mb-2 flex justify-between">
                                    <span>약제처방 세트</span>
                                    <button onclick="openMacroSearch('DRUG')" class="text-blue-600 hover:underline cursor-pointer">+ 추가</button>
                                </label>
                                <div id="macro-drug-list" class="space-y-1 mb-2 hidden"></div>
                                <div id="macro-drug-empty" onclick="openMacroSearch('DRUG')" class="h-28 border-2 border-dashed border-indigo-100 rounded-2xl flex items-center justify-center cursor-pointer hover:border-primary hover:bg-indigo-50/30 transition-all text-zinc-400 text-xs font-bold">
                                    <i class="icon icon-plus mr-1"></i> 클릭하여 약제 추가
                                </div>
                            </div>
                        </div>
                        <div class="grid grid-cols-2 gap-8">
                            <div>
                                <label class="block text-[11px] font-black uppercase text-zinc-400 tracking-wider mb-2 flex justify-between">
                                    <span>치료항목</span>
                                    <button onclick="openMacroSearch('TREATMENT')" class="text-zinc-500 hover:text-blue-600 cursor-pointer">+ 추가</button>
                                </label>
                                <div id="macro-treat-list" class="space-y-1 mb-2 hidden"></div>
                                <div id="macro-treat-empty" onclick="openMacroSearch('TREATMENT')" class="h-28 border-2 border-dashed border-zinc-200 rounded-2xl flex items-center justify-center cursor-pointer hover:border-zinc-400 hover:bg-zinc-50 transition-all text-zinc-400 text-xs font-bold">
                                    <i class="icon icon-plus mr-1"></i> 클릭하여 치료 추가
                                </div>
                            </div>
                        </div>
                    </div>

                    <div>
                        <label class="block text-[11px] font-black uppercase text-zinc-400 tracking-wider mb-2">나의 오더 멘트 (내용)</label>
                        <textarea id="macro-modal-content" class="textarea w-full h-48 font-mono text-sm leading-relaxed p-5 shadow-inner bg-zinc-50 focus:bg-white transition-colors" placeholder="기록 내용을 작성하세요."></textarea>
                    </div>
                </div>
            </div>

            <div id="macro-limit-message" class="hidden flex-col items-center justify-center h-full w-full bg-zinc-50 text-center p-8 absolute inset-0 z-20 mt-[80px]">
                <div class="w-20 h-20 bg-zinc-200 rounded-full flex items-center justify-center mb-6 text-zinc-400">
                    <svg class="w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" /></svg>
                </div>
                <h3 class="text-xl font-black text-zinc-700 mb-2">나의 오더 생성 한도 초과</h3>
                <p class="text-sm text-zinc-500 mb-8 font-bold">
                    개인 오더는 최대 3개까지만 생성할 수 있습니다.<br>
                    좌측 목록에서 기존 오더를 수정하거나 삭제 후 이용해주세요.
                </p>
            </div>

            <button onclick="closeMacroModal()" class="absolute top-6 right-6 btn btn-icon btn-ghost text-xl z-30">✕</button>
        </div>
      </div>
    </div>
  </div>
</div>

<div id="macro-search-modal" class="fixed inset-0 z-[70] hidden flex items-center justify-center bg-zinc-900/40 backdrop-blur-sm">
    <div class="bg-white w-[600px] h-[700px] rounded-2xl shadow-2xl flex flex-col overflow-hidden animate-in fade-in zoom-in duration-200">
        <div class="px-6 py-4 border-b border-zinc-100 flex justify-between items-center bg-white">
            <h3 id="macro-search-title" class="text-lg font-bold text-zinc-800">검색</h3>
            <button onclick="closeMacroSearch()" class="text-zinc-400 hover:text-zinc-600"><svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg></button>
        </div>
        <div class="p-4 bg-zinc-50 border-b border-zinc-100">
            <div class="relative">
                <input type="text" id="macro-search-input" onkeydown="if(event.key==='Enter') executeMacroSearch()" class="w-full pl-10 pr-20 py-3 border border-zinc-200 rounded-xl text-sm font-bold focus:ring-2 focus:ring-blue-500 outline-none" placeholder="검색어 입력..." autofocus>
                <div class="absolute left-3 top-1/2 -translate-y-1/2 text-zinc-400"><svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/></svg></div>
                <button onclick="executeMacroSearch()" class="absolute right-2 top-1/2 -translate-y-1/2 px-4 py-1.5 bg-blue-600 text-white text-xs font-bold rounded-lg hover:bg-blue-700">검색</button>
            </div>
        </div>
        <div id="macro-search-results" class="flex-1 overflow-y-auto p-4 space-y-2 bg-white">
            <div class="text-center py-10 text-zinc-400 text-sm">데이터를 불러오는 중...</div>
        </div>
        <div class="p-4 border-t border-zinc-100 bg-white">
            <button id="btn-add-search-items" onclick="addMacroSearchItems()" disabled class="w-full py-3 bg-blue-600 hover:bg-blue-700 disabled:bg-zinc-200 disabled:text-zinc-400 disabled:cursor-not-allowed text-white rounded-xl text-sm font-bold transition-all shadow-lg shadow-indigo-100/50">
                선택한 항목 추가하기
            </button>
        </div>
    </div>
</div>

<div id="regular-order-modal" class="fixed inset-0 z-[70] hidden">
    <div class="absolute inset-0 bg-zinc-900/60 backdrop-blur-sm transition-opacity" onclick="closeRegularOrderModal()"></div>
    <div class="absolute inset-0 flex items-center justify-center p-4">
        <div class="flex h-[750px] w-[1000px] flex-col rounded-3xl bg-white shadow-2xl ring-1 ring-black/5 overflow-hidden animate-in fade-in zoom-in duration-200">
            
            <div class="flex items-center justify-between border-b border-zinc-200 px-8 py-5 bg-zinc-50 shrink-0">
                <div>
                    <h2 class="text-xl font-black text-zinc-900 tracking-tight">정규 처방 변경 <span class="text-xs text-zinc-400 font-medium ml-2 uppercase">Regular Order Change</span></h2>
                    <p class="text-xs text-primary font-bold mt-1" id="reg-modal-header-info">
                       <i class="icon icon-user-check mr-1"></i>대상 환자 정보를 불러오는 중...
                    </p>	
                </div>
                <button onclick="closeRegularOrderModal()" class="btn btn-icon btn-ghost text-xl">✕</button>
            </div>

            <div class="flex flex-1 overflow-hidden bg-white">
                <div class="flex w-1/2 flex-col border-r border-zinc-100 bg-white">
                    <div class="px-6 py-4 bg-zinc-50/50 border-b border-zinc-200 flex justify-between items-center">
                        <h3 class="text-[10px] font-black text-zinc-400 uppercase tracking-widest">현재 진행 중인 처방 (Current)</h3>
                        <span class="badge badge-default">Active</span>
                    </div>
                    <div class="flex-1 overflow-y-auto p-6 space-y-3 shadow-inner bg-zinc-50/10" id="current-order-list-modal">
                        </div>
                </div>
                
                <div class="flex w-1/2 flex-col bg-zinc-50/30">
                    <div class="px-6 py-4 bg-white border-b border-zinc-200 flex gap-3 shadow-sm">
                        <button id="btn-modal-dc" onclick="switchModalTab('DC')" 
                            class="btn btn-outline-danger flex-1 py-3 text-xs font-black rounded-xl">DC (처방 중단)</button>
                        <button id="btn-modal-change" onclick="switchModalTab('CHANGE')" 
                            class="btn btn-outline-primary flex-1 py-3 text-xs font-black rounded-xl active">Change (처방 변경)</button>
                    </div>
                    <div class="flex-1 p-8 flex flex-col overflow-y-auto" id="selected-action-list">
                        <div class="flex flex-col justify-center items-center text-center h-full opacity-30">
                            <div class="h-16 w-16 rounded-full bg-zinc-200 flex items-center justify-center mb-4">
                                <i class="icon icon-clipboard-text text-3xl text-zinc-400"></i>
                            </div>
                            <p class="text-sm font-black text-zinc-800">선택된 처방이 없습니다.</p>
                        </div>
                    </div>
                </div>
            </div>

            <div class="flex items-center justify-end gap-3 border-t border-zinc-200 bg-zinc-50 px-8 py-5 shrink-0">
                <button onclick="closeRegularOrderModal()" class="btn btn-secondary px-8 font-bold">취소</button>
                <button onclick="insertRegularOrderChanges()" class="btn btn-primary px-10 font-black shadow-lg shadow-indigo-100">변경사항 저장</button>
            </div>
        </div>
    </div>
</div>

<div id="order-modal" class="fixed inset-0 z-50 hidden">
  <div class="absolute inset-0 bg-zinc-900/60 backdrop-blur-sm transition-opacity" onclick="closeModal()"></div>
  <div class="absolute inset-0 flex items-center justify-center p-4">
    <div class="flex h-[88vh] w-full max-w-6xl flex-col rounded-3xl bg-white shadow-2xl ring-1 ring-black/5 overflow-hidden animate-in fade-in zoom-in duration-200">
      
      <div class="flex items-center justify-between border-b border-zinc-200 px-8 py-5 bg-white shrink-0">
        <div>
          <h2 class="text-xl font-black text-zinc-900 tracking-tight">처방 추가 <span class="text-xs text-zinc-400 font-medium ml-1 uppercase">Order Entry</span></h2>
          <p id="modal-order-patient-info" class="text-xs text-zinc-500 mt-1 font-bold">
             환자 정보를 불러오는 중...
          </p>
        </div>
        <button onclick="closeModal()" class="btn btn-icon btn-ghost text-xl">✕</button>
      </div>

      <div class="flex flex-1 overflow-hidden">
        <div class="flex w-[340px] flex-col border-r border-zinc-200 bg-zinc-50/50">
          <div class="p-6 border-b border-zinc-200 bg-white space-y-4 shadow-sm">
            <div class="form-group">
                <label class="form-label font-black text-[10px] text-zinc-400 uppercase tracking-widest mb-2 ml-1">Order Category</label>
                <select id="order-category-select" class="select w-full h-11 font-bold text-zinc-700 shadow-sm">
                  <option value="001">약 / 주사 (Drug)</option>
                  <option value="002">검사 (Examination)</option>
                  <option value="003">치료 / 처치 (Treatment)</option>
                  <option value="005">수술 (Surgery)</option>
                  <option value="004">식이 (Diet)</option>
                </select>
            </div>
            <div class="form-group">
              <label class="form-label font-black text-[10px] text-zinc-400 uppercase tracking-widest mb-2 ml-1">Search Database</label>
              <input type="text" id="order-search-input" placeholder="검색어를 입력하세요" class="input input-search h-11 w-full font-bold">
            </div>
          </div>
          <div class="flex-1 overflow-y-auto bg-zinc-50/30 p-2" id="order-search-result"></div>
        </div>

        <div class="flex flex-1 flex-col bg-white overflow-hidden">
            <div class="px-6 py-4 border-b border-zinc-200 flex justify-between items-center bg-zinc-50/30">
                <h3 class="text-sm font-black text-zinc-900 tracking-tight flex items-center gap-2">
                    <i class="icon icon-shopping-cart text-primary"></i> 선택된 처방 (Selected Orders)
                </h3>
                <button onclick="clearSelectedOrders()" class="text-xs text-red-500 underline font-bold">전체 삭제</button>
            </div>
            <div class="grid grid-cols-12 gap-1 border-b border-zinc-100 bg-zinc-50/50 px-4 py-3 shrink-0">
			    <div class="col-span-1 text-[11px] font-black text-zinc-400 text-center">Pick</div>
			    <div class="col-span-1 text-[11px] font-black text-zinc-400 text-center">처방타입</div>
			    <div class="col-span-3 text-[11px] font-black text-zinc-400">명칭</div> 
			    <div class="col-span-1 text-[11px] font-black text-zinc-400 text-center">1회량</div>
			    <div class="col-span-1 text-[11px] font-black text-zinc-400 text-center">횟수</div>
			    <div class="col-span-1 text-[11px] font-black text-zinc-400 text-center">일수</div>
			    <div class="col-span-2 text-[11px] font-black text-zinc-400 text-center">용법</div> 
			    <div class="col-span-1 text-[11px] font-black text-red-400 text-center font-bold">주사구분</div> 
			    <div class="col-span-1 text-[11px] font-black text-zinc-400 text-center">삭제</div>
			</div>
            <div class="flex-1 overflow-y-auto p-2 bg-white" id="selected-order-list"></div>
            <div class="mx-6 mb-6 p-4 bg-amber-50 border border-amber-100 rounded-2xl flex items-start gap-3 shadow-sm animate-pulse">
                 <i class="icon icon-alert-triangle text-amber-600 mt-0.5 text-lg"></i>
                 <p class="text-[11px] font-bold text-amber-700/80 leading-relaxed">트라마돌 주사제와 경구약 동시 처방 시 보험 삭감 가능성이 있습니다.</p>
            </div>
        </div>
      </div>

      <div class="flex items-center justify-end gap-3 border-t border-zinc-200 bg-zinc-50 px-8 py-5 shrink-0">
        <button onclick="closeModal()" class="btn btn-secondary px-8 font-bold">취소</button>
        <button onclick="insertPrescription()" class="btn btn-primary px-12 font-black shadow-lg shadow-indigo-100 flex items-center gap-2">처방 적용</button>
      </div>
    </div>
  </div>
</div>


<div id="consult-result-modal" class="fixed inset-0 z-[70] hidden flex items-center justify-center p-4">
    <div class="absolute inset-0 bg-zinc-900/60 backdrop-blur-sm" onclick="closeConsultResultModal()"></div>
    <div class="bg-white w-full max-w-2xl rounded-3xl shadow-2xl flex flex-col overflow-hidden relative z-10 animate-in fade-in zoom-in duration-200">
        <div class="px-8 py-5 border-b border-zinc-200 flex justify-between items-center bg-zinc-50">
            <h2 class="text-xl font-black text-zinc-900">협진 내역 및 결과 확인</h2>
            <button onclick="closeConsultResultModal()" class="btn btn-icon btn-ghost text-xl">✕</button>
        </div>

        <div id="consult-result-list" class="p-6 overflow-y-auto max-h-[65vh] bg-zinc-50/50 space-y-4">
            <div class="text-center py-10 text-zinc-400">내역을 불러오는 중...</div>
        </div>

        <div class="p-6 border-t border-zinc-200 bg-zinc-50 flex justify-end">
            <button onclick="closeConsultResultModal()" class="btn btn-secondary px-10">닫기</button>
        </div>
    </div>
</div>

<div id="diagSearchBackdrop" class="modal-backdrop hidden" style="display: none; align-items: center; justify-content: center; position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 2000;">
  <div class="modal modal-lg bg-white rounded-xl shadow-2xl" style="width: 850px; max-height: 85vh; display: flex; flex-direction: column;">
    
    <div class="modal-header p-5 border-b flex justify-between items-center bg-white rounded-t-xl">
        <h3 class="modal-title font-bold text-xl text-zinc-800">상병(진단명) 검색</h3>
        <button type="button" class="btn btn-icon btn-ghost text-2xl" onclick="closeDiagModal()">×</button>
    </div>

    <div class="modal-body p-8 overflow-hidden flex flex-col">
      <div class="mb-6">
          <label class="block text-xs font-bold text-zinc-400 mb-2 uppercase tracking-widest">상병명 또는 상병코드 입력</label>
          <div class="relative">
              <input type="text" id="modal-diag-search-input" 
                     onkeydown="if(event.key === 'Enter') searchDiagnosisInModal(this.value)"
                     placeholder="검색어를 입력하고 Enter를 누르세요 (예: 골절, S02)" 
                     class="input input-search w-full py-4 text-lg border-2 focus:border-indigo-500 transition-all" />
              <div class="absolute right-4 top-1/2 -translate-y-1/2 text-zinc-300">
                  <i class="icon icon-search text-xl"></i>
              </div>
          </div>
      </div>
      
      <div id="modalDiagSearchResult" class="flex-1 overflow-y-auto min-h-[400px] border-2 border-dashed border-zinc-100 rounded-2xl p-4 bg-zinc-50/30 custom-scrollbar">
          <div class="h-full flex flex-col items-center justify-center text-zinc-400">
              <i class="icon icon-search-doc text-5xl mb-4 opacity-20"></i>
              <p class="font-medium">상병명을 검색하면 결과가 여기에 표시됩니다.</p>
          </div>
      </div>
    </div>

    <div class="modal-footer p-5 border-t flex justify-end bg-white rounded-b-xl gap-3">
        <button type="button" class="btn btn-secondary px-8 py-2.5 rounded-xl font-bold" onclick="closeDiagModal()">닫기</button>
    </div>
  </div>
</div>
<script>
    const MACRO_API = '${pageContext.request.contextPath}/api/macro';
    const LOGIN_USER_NO = Number("${loginUserNo}") || 0; 
    
    // [문제 1 해결] 변수 오타 수정 (${employee} -> ${loginJob})
    // 이 부분이 틀려서 목록이 안 나왔던 겁니다.
    const LOGIN_JOB_CODE = "${loginJob}"; 

    let modalMacros = []; 
    let modalCurrentData = { diagnosisList: [], drugList: [], treatmentList: [] }; 
    let modalSearchType = ''; 
    let modalSelectedItems = []; 
    let currentViewingMacroNo = 0; // 0이면 신규 작성 모드

    // 1. 모달 열기 (열자마자 목록 로드)
    function openMacroModal() {
    	console.log("openMacroModal() 실행...!, modal");
        if(LOGIN_USER_NO === 0) { Swal.fire("오류", "로그인 정보가 없습니다.", "error"); return; }
        
        document.getElementById('macro-modal').classList.remove('hidden');
        
        // 목록 자동 로드 실행
        currentViewingMacroNo = 0;
        loadModalMacroList(true); 
    }

    function closeMacroModal() {
        document.getElementById('macro-modal').classList.add('hidden');
    }

    // 2. 목록 불러오기 로직
    async function loadModalMacroList(shouldReset = false) {
        try {
            const res = await axios.get(`\${MACRO_API}/list`, { params: { employeeNo: LOGIN_USER_NO } });
            modalMacros = res.data || [];
            
            // 리스트 그리기
            renderModalMacroList(modalMacros);
            
            // 버튼 상태 업데이트
            updateUIState();

            // 초기화가 필요하거나, 현재 보고 있던 글이 목록에서 사라졌으면(삭제됨) -> 신규 작성 모드로
            if (shouldReset || (currentViewingMacroNo > 0 && !modalMacros.some(m => m.macroNo === currentViewingMacroNo))) {
                initModalNewMacro(false);
            }
        } catch(err) {
            console.error(err);
        }
    }

    // 3. [문제 2 해결] 신규 작성 버튼 클릭 시 입력폼 강제 표시
    function initModalNewMacro(shouldLoadList = false) {
        currentViewingMacroNo = 0; // 신규 상태로 변경

        // 입력폼 초기화
        document.getElementById('macro-modal-no').value = 0;
        document.getElementById('macro-modal-name').value = '';
        document.getElementById('macro-modal-content').value = '';
        
        // 내 직업에 맞게 타입 선택
        let myType = (LOGIN_JOB_CODE === 'NUR') ? '002' : '001';
        document.getElementById('macro-modal-type').value = myType;

        // [핵심] 의사라면 '숨겨진 입력 패널'을 강제로 보이게 함!
        const doctorPanel = document.getElementById('macro-doctor-panel');
        if(myType === '001') {
            doctorPanel.classList.remove('hidden'); 
            doctorPanel.style.display = 'block';
        } else {
            doctorPanel.classList.add('hidden');
            doctorPanel.style.display = 'none';
        }

        // [핵심] 3개 제한 메시지는 숨기고, 입력 폼을 보이게 함
        document.getElementById('macro-limit-message').classList.add('hidden');
        document.getElementById('macro-limit-message').style.display = 'none'; // 확실하게 숨김
        document.getElementById('macro-edit-form').classList.remove('hidden');
        document.getElementById('macro-edit-form').style.display = 'block'; // 확실하게 보임

        modalCurrentData = { diagnosisList: [], drugList: [], treatmentList: [] };
        renderModalDataItems();
        renderModalMacroList(modalMacros);
        updateUIState(); // 버튼 상태 다시 체크
        
        if(shouldLoadList) loadModalMacroList(); 
    }

    // UI 상태 관리 (버튼 및 제한메시지)
    function updateUIState() {
        const myType = (LOGIN_JOB_CODE === 'NUR') ? '002' : '001';
        const myCount = modalMacros.filter(m => m.macroType === myType).length;
        
        const btnNew = document.getElementById('btn-modal-new-macro');
        const formDiv = document.getElementById('macro-edit-form');
        const limitDiv = document.getElementById('macro-limit-message');

        // 1. 신규 버튼: 3개 꽉 찼으면 숨김, 아니면 보임
        if(myCount >= 3) btnNew.classList.add('hidden');
        else btnNew.classList.remove('hidden');

        // 2. 화면 표시: '신규 작성 모드(0)'이면서 '3개 꽉 찼을 때'만 제한 메시지 표시
        if (currentViewingMacroNo === 0 && myCount >= 3) {
            formDiv.classList.add('hidden');
            limitDiv.classList.remove('hidden');
            limitDiv.style.display = 'flex';
        } 
        // 그 외에는 폼이 보여야 함 (initModalNewMacro에서 이미 처리하지만 안전장치)
    }

    // 상세 조회
    async function loadModalDetail(macroNo) {
        try {
            const res = await axios.get(`\${MACRO_API}/detail/\${macroNo}`);
            const data = res.data;
            
            currentViewingMacroNo = data.macroNo;

            document.getElementById('macro-edit-form').classList.remove('hidden');
            document.getElementById('macro-limit-message').classList.add('hidden');

            document.getElementById('macro-modal-no').value = data.macroNo;
            document.getElementById('macro-modal-name').value = data.macroName;
            document.getElementById('macro-modal-type').value = data.macroType;
            document.getElementById('macro-modal-content').value = data.macroContent || '';

            // 상세 볼 때도 의사면 패널 보여주기
            const doctorPanel = document.getElementById('macro-doctor-panel');
            if(data.macroType === '001') {
                doctorPanel.classList.remove('hidden');
                doctorPanel.style.display = 'block';
            } else {
                doctorPanel.classList.add('hidden');
                doctorPanel.style.display = 'none';
            }

            modalCurrentData = { diagnosisList: [], drugList: [], treatmentList: [] };
            if(data.macroDetails) {
                data.macroDetails.forEach(d => {
                    if(d.macroDetailType === 'DIAGNOSIS') modalCurrentData.diagnosisList.push({ diagnosisCode: d.macroDetailPrename, diagnosisName: d.macroDetailPrename });
                    else if(d.macroDetailType === 'DRUG') modalCurrentData.drugList.push({ drugCode: d.macroDetailPrename, drugName: d.macroDetailPrename });
                    else if(d.macroDetailType === 'TREATMENT') modalCurrentData.treatmentList.push({ treatmentCode: d.macroDetailPrename, treatmentName: d.macroDetailPrename });
                });
            }
            renderModalDataItems(); 
            renderModalMacroList(modalMacros);
            updateUIState();
        } catch(err) { console.error(err); }
    }

    // 리스트 렌더링
    function renderModalMacroList(list) {
        const container = document.getElementById('macro-modal-list');
        container.innerHTML = '';
        if(list.length === 0) { 
            container.innerHTML = '<div class="text-center py-8 text-zinc-400 text-xs font-bold">등록된 나의 오더가 없습니다.</div>'; 
            return; 
        }
        
        list.forEach(m => {
            const isActive = m.macroNo === currentViewingMacroNo;
            const item = document.createElement('div');
            item.className = `p-4 cursor-pointer rounded-2xl transition-all border \${isActive ? 'bg-white border-blue-500 ring-1 ring-blue-500 shadow-sm' : 'bg-white border-zinc-200 hover:border-blue-300 hover:bg-zinc-50'}`;
            item.onclick = () => loadModalDetail(m.macroNo);
            item.innerHTML = `
                <div class="flex justify-between items-start mb-2">
                    <span class="text-[10px] font-black uppercase tracking-wider \${m.macroType === '001' ? 'text-blue-500' : 'text-green-500'}">\${m.macroType === '001' ? '의사 세트' : '간호사 세트'}</span>
                    <button onclick="event.stopPropagation(); deleteModalMacro(\${m.macroNo})" class="text-zinc-300 hover:text-red-500 p-1 -mt-1 -mr-1"><i class="icon icon-trash"></i></button>
                </div>
                <p class="text-sm font-black text-zinc-800 leading-tight">\${m.macroName}</p>
            `;
            container.appendChild(item);
        });
        if(window.lucide) lucide.createIcons();
    }

    function filterModalMacros() {
        const keyword = document.getElementById('macro-modal-search').value.toLowerCase();
        const filtered = modalMacros.filter(m => m.macroName.toLowerCase().includes(keyword));
        renderModalMacroList(filtered);
    }

    function renderModalDataItems() {
        const types = ['diagnosis', 'drug', 'treatment'];
        const mapIds = { diagnosis: 'diag', drug: 'drug', treatment: 'treat' };
        types.forEach(type => {
            const list = modalCurrentData[type + 'List'];
            const listEl = document.getElementById(`macro-\${mapIds[type]}-list`);
            const emptyEl = document.getElementById(`macro-\${mapIds[type]}-empty`);
            if(list.length > 0) {
                listEl.classList.remove('hidden'); emptyEl.classList.add('hidden');
                listEl.innerHTML = list.map((item, idx) => {
                    let name = type==='diagnosis' ? item.diagnosisName : type==='drug' ? item.drugName : item.treatmentName;
                    return `<div class="flex justify-between items-center bg-zinc-50 px-3 py-2 rounded-lg border border-zinc-200"><span class="text-xs font-bold text-zinc-700 truncate">\${name}</span><button onclick="removeModalDataItem('\${type}', \${idx})" class="text-zinc-300 hover:text-red-500"><i class="icon icon-trash"></i></button></div>`;
                }).join('');
            } else { listEl.classList.add('hidden'); emptyEl.classList.remove('hidden'); }
        });
        if(window.lucide) lucide.createIcons();
    }
    function removeModalDataItem(type, idx) { modalCurrentData[type + 'List'].splice(idx, 1); renderModalDataItems(); }

    async function saveModalMacro() {
        if(LOGIN_USER_NO === 0) { Swal.fire("오류", "로그인 세션 만료", "error"); return; }
        const macroNo = Number(document.getElementById('macro-modal-no').value);
        const name = document.getElementById('macro-modal-name').value;
        const content = document.getElementById('macro-modal-content').value;
        let type = document.getElementById('macro-modal-type').value; 
        if (!type || type === "") type = (LOGIN_JOB_CODE === 'NUR') ? '002' : '001';

        if(!name.trim()) { Swal.fire("알림", "오더 명칭을 입력해주세요.", "warning"); return; }

        const payload = { macroNo, macroName: name, macroType: type, macroContent: content, employeeNo: LOGIN_USER_NO, diagnosisList: modalCurrentData.diagnosisList, drugList: modalCurrentData.drugList, treatmentList: modalCurrentData.treatmentList };
        try {
            await axios.post(macroNo === 0 ? `\${MACRO_API}/add` : `\${MACRO_API}/update`, payload);
            Swal.fire({ title: "저장 완료", icon: "success", timer: 1000, showConfirmButton: false });
            loadModalMacroList(false); 
        } catch(err) { Swal.fire("저장 실패", "오류가 발생했습니다.", "error"); }
    }

    async function deleteModalMacro(macroNo) {
        // 1. 삭제 확인 질문
        const result = await Swal.fire({ 
            title: '삭제하시겠습니까?', 
            icon: 'warning', 
            showCancelButton: true,
            confirmButtonText: '삭제',
            cancelButtonText: '취소'
        });

        if (result.isConfirmed) {
            try { 
                // 2. API 삭제 요청
                await axios.post(`\${MACRO_API}/delete/\${macroNo}`); 
                
                // 3. [추가됨] 삭제 완료 성공 알림
                await Swal.fire("삭제 완료", "정상적으로 삭제되었습니다.", "success");

                // 4. 목록 새로고침
                loadModalMacroList(false); 
            } catch(err) { 
                // 5. 에러 알림
                Swal.fire("오류", "삭제 실패", "error"); 
            }
        }
    }
    
    // 검색 모달 관련 함수
    function openMacroSearch(type) {
        modalSearchType = type; modalSelectedItems = []; 
        document.getElementById('macro-search-title').innerText = (type==='DIAGNOSIS'?'상병':type==='DRUG'?'약제':'치료') + ' 검색';
        document.getElementById('macro-search-input').value = '';
        document.getElementById('macro-search-results').innerHTML = '<div class="text-center py-10 text-zinc-400 text-sm">데이터를 불러오는 중...</div>';
        document.getElementById('btn-add-search-items').disabled = true; document.getElementById('btn-add-search-items').innerText = '선택한 항목 추가하기';
        document.getElementById('macro-search-modal').classList.remove('hidden'); document.getElementById('macro-search-input').focus();
        executeMacroSearch();
    }
    function closeMacroSearch() { document.getElementById('macro-search-modal').classList.add('hidden'); }
    async function executeMacroSearch() {
        const keyword = document.getElementById('macro-search-input').value;
        let endpoint = modalSearchType === 'DIAGNOSIS' ? '/diagnosis/search' : modalSearchType === 'DRUG' ? '/drug/search' : '/treatment/search';
        try { const res = await axios.get(MACRO_API + endpoint, { params: { keyword } }); renderSearchResults(res.data || []); } 
        catch(err) { document.getElementById('macro-search-results').innerHTML = '<div class="text-center py-10 text-red-400">오류 발생</div>'; }
    }
    function renderSearchResults(list) {
        const container = document.getElementById('macro-search-results'); container.innerHTML = '';
        if(list.length === 0) { container.innerHTML = '<div class="text-center py-10 text-zinc-400">데이터가 없습니다.</div>'; return; }
        list.forEach(item => {
            let codeKey = modalSearchType === 'DIAGNOSIS' ? 'diagnosisCode' : modalSearchType === 'DRUG' ? 'drugCode' : 'treatmentCode';
            let nameVal = modalSearchType === 'DIAGNOSIS' ? item.diagnosisName : modalSearchType === 'DRUG' ? item.drugName : item.treatmentName;
            const isChecked = modalSelectedItems.some(i => i[codeKey] === item[codeKey]);
            const div = document.createElement('div');
            div.className = `flex items-center p-3 border rounded-xl cursor-pointer transition-all mb-2 \${isChecked ? 'bg-blue-50 border-blue-500' : 'bg-white border-zinc-100 hover:bg-zinc-50'}`;
            div.onclick = () => toggleSearchItem(item, codeKey, div);
            div.innerHTML = `<div class="mr-3 \${isChecked ? 'text-blue-600' : 'text-zinc-300'} check-icon"><i class="icon icon-check-circle"></i></div><div><div class="text-xs font-bold text-zinc-500">\${item[codeKey]}</div><div class="text-sm font-bold text-zinc-800">\${nameVal}</div></div>`;
            container.appendChild(div);
        });
        if(window.lucide) lucide.createIcons();
    }
    function toggleSearchItem(item, key, divEl) {
        const exists = modalSelectedItems.some(i => i[key] === item[key]);
        const iconContainer = divEl.querySelector('.check-icon');
        if(exists) { modalSelectedItems = modalSelectedItems.filter(i => i[key] !== item[key]); divEl.classList.remove('bg-blue-50', 'border-blue-500'); divEl.classList.add('bg-white', 'border-zinc-100'); iconContainer.classList.replace('text-blue-600','text-zinc-300'); } 
        else { modalSelectedItems.push(item); divEl.classList.remove('bg-white', 'border-zinc-100'); divEl.classList.add('bg-blue-50', 'border-blue-500'); iconContainer.classList.replace('text-zinc-300','text-blue-600'); }
        const btn = document.getElementById('btn-add-search-items'); btn.disabled = modalSelectedItems.length === 0; btn.innerText = modalSelectedItems.length > 0 ? `선택한 \${modalSelectedItems.length}개 추가` : '선택한 항목 추가하기';
    }
    function addMacroSearchItems() {
        if(modalSearchType === 'DIAGNOSIS') modalCurrentData.diagnosisList.push(...modalSelectedItems.filter(n => !modalCurrentData.diagnosisList.some(e => e.diagnosisCode === n.diagnosisCode)));
        else if(modalSearchType === 'DRUG') modalCurrentData.drugList.push(...modalSelectedItems.filter(n => !modalCurrentData.drugList.some(e => e.drugCode === n.drugCode)));
        else modalCurrentData.treatmentList.push(...modalSelectedItems.filter(n => !modalCurrentData.treatmentList.some(e => e.treatmentCode === n.treatmentCode)));
        renderModalDataItems(); closeMacroSearch();
    }
</script>