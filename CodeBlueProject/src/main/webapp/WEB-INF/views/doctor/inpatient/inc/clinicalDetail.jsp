<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<section class="box box-bordered flex flex-col h-full overflow-hidden bg-white shadow-md">
  
  <div class="flex items-center justify-between px-6 py-5 border-b border-zinc-200 bg-white">
    <div class="flex items-center gap-5">
      <div class="flex flex-col">
        <h2 class="text-2xl font-black text-zinc-900 tracking-tight leading-none mb-2">
          <span id="det-patientName">${patient.patientName}</span> 
          <span class="text-sm font-medium text-zinc-400 ml-1">
            <span id="det-patientGen">${patient.patientGen}</span> / <span id="det-patientAge">${patient.patientAge}</span>
          </span>
        </h2>
        <div id="det-tags" class="flex gap-2">
          </div>
      </div>
      <div class="h-8 w-px bg-zinc-100 mx-2"></div>
      <div class="text-sm font-medium text-zinc-500">
        <p class="tracking-widest uppercase text-[10px] text-zinc-300 font-bold mb-0.5">환자 번호</p>
        <span id="det-patientNo" class="text-zinc-700 font-bold font-mono">${patient.patientNo}</span>
      </div>
    </div>
    
    <div class="flex items-center gap-3">
       
       <div class="dropdown">
		    <button class="btn btn-ghost btn-sm border border-zinc-200 flex items-center gap-2" 
		            onclick="toggleDropdown(event, 'consultToggle')">
		        협진 
		        <i class="icon icon-chevron-down text-zinc-400 text-[10px]"></i>
		    </button>
		    <div class="dropdown-menu shadow-xl border border-zinc-100" id="consultToggle">
		        <a href="javascript:void(0)" class="dropdown-item py-2.5 px-4 hover:bg-indigo-50 transition-all" onclick="requestConsultation()">
		            <span class="dropdown-item-text font-bold text-zinc-700">협진 의뢰</span>
		        </a>
		        <a href="javascript:void(0)" class="dropdown-item py-2.5 px-4 hover:bg-indigo-50 transition-all" onclick="openConsultResultModal()">
		            <span class="dropdown-item-text font-bold text-zinc-700">회신 결과 확인</span>
		        </a>
		    </div>
		</div>
		
		<div class="dropdown">
		    <button class="btn btn-ghost btn-sm border border-zinc-200 flex items-center gap-2" 
		            onclick="toggleDropdown(event, 'docToggle')">
		        환자 서류 
		        <i class="icon icon-chevron-down text-zinc-400 text-[10px]"></i>
		    </button>
		    <div class="dropdown-menu shadow-xl border border-zinc-100" id="docToggle">
		        <!-- <a href="javascript:void(0)" class="dropdown-item py-2.5 px-4 hover:bg-indigo-50 transition-all"
		            onclick="openChartModal()">
		            <span class="dropdown-item-text font-bold text-zinc-700">진료 기록</span>
		        </a> -->
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
    </div>
  </div>

  <div class="grid grid-cols-4 divide-x divide-zinc-100 border-b border-zinc-200 bg-zinc-50/50">
    <div class="p-4 text-center group hover:bg-white transition-all cursor-default">
        <span class="block text-[10px] font-black text-zinc-400 mb-1 uppercase tracking-widest">혈압 (BP)</span>
        <span id="det-v-bp" class="text-xl font-black text-zinc-800 font-mono">-</span>
    </div>
    <div class="p-4 text-center group hover:bg-white transition-all cursor-default">
        <span class="block text-[10px] font-black text-zinc-400 mb-1 uppercase tracking-widest">맥박 (PR)</span>
        <span id="det-v-pr" class="text-xl font-black text-zinc-800 font-mono">-</span>
    </div>
    <div class="p-4 text-center group hover:bg-white transition-all cursor-default">
        <span class="block text-[10px] font-black text-zinc-400 mb-1 uppercase tracking-widest">체온 (BT)</span>
        <span id="det-v-bt" class="text-xl font-black text-zinc-800 font-mono">-</span>
    </div>
    <div class="p-4 text-center group hover:bg-white transition-all cursor-default">
        <span class="block text-[10px] font-black text-zinc-400 mb-1 uppercase tracking-widest">통증 (NRS)</span>
        <span id="det-v-nrs" class="text-xl font-black text-amber-500 font-mono">-</span>
    </div>
  </div>

  <div class="flex-1 min-h-0 flex flex-col overflow-hidden">
    <div class="tabs tabs-underline flex border-b border-zinc-200 bg-white px-6 shrink-0">
      <button id="btn-progress" onclick="switchTab('progress')" class="tab-btn active px-6 py-4 text-sm font-bold transition-all relative">경과 기록</button>
      <button id="btn-nursingVital" onclick="switchTab('nursingVital')" class="tab-btn px-6 py-4 text-sm font-bold transition-all relative">간호기록/바이탈</button>
      <button id="btn-orderHistory" onclick="switchTab('orderHistory')" class="tab-btn px-6 py-4 text-sm font-bold transition-all relative">처방 내역</button>
      <button id="btn-examResult" onclick="switchTab('examResult')" class="tab-btn px-6 py-4 text-sm font-bold transition-all relative">검사 결과</button>
    </div>

    <div id="content-progress" class="tab-content active flex flex-col flex-1 overflow-hidden">
        <div id="diagnosis-info-area" class="flex-none px-6 py-3 bg-indigo-50/30 border-b border-indigo-100 flex items-center gap-3">
            </div>
        
        <div id="progress-note-list" class="flex-1 overflow-y-auto p-6 space-y-4 bg-white scroll-smooth shadow-inner">
            </div>

        <div class="p-5 bg-zinc-50 border-t border-zinc-200">
            <div class="flex gap-4">
               <textarea id="progress-input" 
                  class="textarea flex-1 min-h-[100px] border-zinc-300 focus:ring-2 focus:ring-primary/20 transition-all text-sm leading-relaxed" 
                  placeholder="경과 기록을 입력하세요 (SOAP 형식 권장)"></textarea>
               <div class="flex flex-col gap-2 shrink-0">
                  <button onclick="openMacroModal()" class="btn btn-secondary w-24 flex items-center justify-center gap-1 text-xs font-bold h-[45px]">
                     <i class="icon icon-zap text-amber-500"></i> 나의 오더
                  </button>
                  <button id="btn-save-progress" onclick="insertProgressNote()" 
                    class="btn btn-primary w-24 flex items-center justify-center font-black h-[45px] text-base shadow-lg">저장</button>
               </div>
            </div>
        </div>
    </div>

    <div id="content-nursingVital" class="tab-content flex flex-col flex-1 hidden overflow-hidden min-h-0 bg-white">
        <div class="flex-1 min-h-0 border-b border-zinc-200 overflow-hidden flex flex-col">
            <h5 class="px-4 py-2 bg-zinc-50 text-[11px] font-black text-zinc-400 uppercase tracking-wider border-b">Vital Sign History</h5>
            <div class="table-wrapper flex-1 overflow-y-auto">
                <table class="table table-sm vital-fixed-table">
				    <colgroup>
				        <col class="col-date"> 
				        <col class="col-time"> 
				        <col class="col-val">  
				        <col class="col-val"> 
				         <col class="col-val">  
				    </colgroup>
				    <thead class="sticky top-0 z-10 bg-white shadow-sm">
				        <tr class="text-zinc-400 text-[11px] uppercase tracking-tighter">
				            <th>일자</th>
				            <th>시간</th>
				            <th class="text-indigo-500">BP</th>
				            <th>PR</th>
				            <th class="text-rose-500">BT</th>
				        </tr>
				    </thead>
				    <tbody id="vital-history-list"></tbody>
				</table>
            </div>
        </div>
        <div class="flex-1 min-h-0 overflow-hidden flex flex-col">
            <h5 class="px-4 py-2 bg-zinc-50 text-[11px] font-black text-zinc-400 uppercase tracking-wider border-b">Nursing Records</h5>
            <div class="table-wrapper flex-1 overflow-y-auto">
                <table class="table table-sm w-full text-left">
                    <thead class="sticky top-0 z-10 bg-white shadow-sm">
                        <tr>
	                        <th class="w-32">일시</th>
	                        <th class="w-24">작성자</th>
	                        <th>기록 내용</th>
                        </tr>
                    </thead>
                    <tbody id="nursing-note-list"></tbody>
                </table>
            </div>
        </div>
    </div>

    <div id="content-orderHistory" class="tab-content flex flex-col flex-1 hidden overflow-hidden min-h-0 bg-white">
        <div class="table-wrapper flex-1 overflow-y-auto">
            <table class="table table-sm table-striped w-full text-left">
                <thead class="sticky top-0 z-10 bg-zinc-50 shadow-sm">
                    <tr class="text-[11px]">
                        <th class="w-28">처방일</th>
                        <th>명칭</th>
                        <th class="w-16">1회량</th>
                        <th class="w-16">횟수</th>
                        <th class="w-16">일수</th>
                        <th class="w-20">구분</th>
                        <th class="w-20">상태</th>
                    </tr>
                </thead>
                <tbody id="chart-history-body"></tbody>
            </table>
        </div>
    </div>

    <div id="content-examResult" class="tab-content flex flex-col flex-1 hidden overflow-hidden min-h-0 bg-white">
	    <div class="table-wrapper flex-1 overflow-y-auto">
	        <table class="table table-sm table-striped w-full table-fixed">
	            <thead>
				    <tr>
				        <th class="w-16 text-center">NO</th> 
				        <th class="w-32 text-left">처방일자</th>
				        <th class="w-32 text-left">환부(부위)</th> 
				        <th class="text-left">검사명</th>
				        <th class="w-32 text-center">상태</th> 
				        <th class="w-20 text-center">파일</th>
				    </tr>
				</thead>
	            <tbody id="exam-result-history-body">
	                </tbody>
	        </table>
	    </div>
	</div>
  </div>
</section>