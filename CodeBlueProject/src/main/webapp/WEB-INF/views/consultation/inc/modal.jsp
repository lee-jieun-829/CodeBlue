<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="chart-modal" class="fixed inset-0 z-[60] hidden flex items-center justify-center p-4">
 <div class="absolute inset-0 bg-zinc-900/60 backdrop-blur-sm" onclick="closeChartModal()"></div>
 <div class="bg-white w-full max-w-6xl h-[85vh] rounded-3xl shadow-2xl flex flex-col overflow-hidden relative z-10 animate-in fade-in zoom-in duration-200">
    <div class="px-8 py-5 border-b border-zinc-200 flex justify-between items-center bg-zinc-50">
       <div class="flex items-center gap-4">
          <h2 class="text-xl font-black tracking-tight text-zinc-900">진료 기록 조회 (Chart)</h2>
          <div class="flex items-center gap-3 p-2 bg-white rounded-xl border border-zinc-200 shadow-sm px-4">
            <span id="chart-patientName" class="font-bold text-zinc-800">-</span>
         	<span id="chart-patientDetail" class="text-xs text-zinc-400 font-medium tracking-widest">-</span>
          </div>
       </div>
       <button onclick="closeChartModal()" class="btn btn-icon btn-ghost text-xl">✕</button>
    </div>
    
    <div class="flex-1 overflow-hidden flex">
       <div class="w-80 border-r border-zinc-200 overflow-y-auto p-6 bg-zinc-50/50 space-y-8">
          <div>
             <h4 class="text-[10px] font-black text-zinc-400 uppercase tracking-widest mb-4">최근 바이탈 (Vitals)</h4>
             <div class="grid gap-3">
                <div class="p-4 bg-white rounded-2xl border shadow-sm flex justify-between items-center">
                   <span class="text-xs font-bold text-zinc-500">혈압</span>
                   <span id="chart-vitalsBP" class="font-black text-indigo-600 text-lg">-/-</span>
                </div>
                <div class="p-4 bg-white rounded-2xl border shadow-sm flex justify-between items-center">
                   <span class="text-xs font-bold text-zinc-500">체온</span>
                   <span id="chart-vitalsTemp" class="font-black text-indigo-600 text-lg">-</span>
                </div>
             </div>
          </div>
          <div>
             <h4 class="text-[10px] font-black text-zinc-400 uppercase tracking-widest mb-4">진단 히스토리</h4>
             <div id="chart-diagnosisHistory" class="p-4 bg-white border border-zinc-200 rounded-xl text-xs text-zinc-600 shadow-sm leading-relaxed font-medium">
                진단 정보가 없습니다.
             </div>
          </div>
       </div>
       
       <div class="flex-1 overflow-y-auto p-8 bg-white space-y-10">
          <div class="box-section">
             <h4 class="box-section-title border-b-2 border-zinc-900 pb-3 mb-6 font-black text-lg">상세 진료 기록</h4>
             <div id="chart-progressSummary" class="space-y-4 text-sm leading-relaxed text-zinc-700 bg-zinc-50 p-6 rounded-2xl border font-mono shadow-inner">
                진료 기록을 불러오는 중...
             </div>
          </div>
          
          <div class="box-section">
		    <h4 class="box-section-title border-b-2 border-zinc-900 pb-3 mb-6 font-black text-lg text-emerald-600 flex justify-between items-center">
		        <span>통합 처방 타임라인 (Order History)</span>
		    </h4>
		    
		    <div class="table-wrapper border rounded-lg overflow-hidden">
		        <table class="table table-sm table-striped">
		            <thead>
		                <tr>
		                    <th>처방일자</th>
		                    <th>명칭</th>
		                    <th class="table-center">1회량</th>
		                    <th class="table-center">횟수</th>
		                    <th class="table-center">일수</th>
		                    <th>구분</th>
		                    <th>상태</th>
		                </tr>
		            </thead>
		            <tbody id="chart-timeline-body">
		                </tbody>
		        </table>
		    </div>
		</div>
          <div class="box-section">
			  <h4 class="box-section-title border-b-2 border-zinc-900 pb-3 mb-6 font-black text-lg">영상 검사 결과 (Imaging)</h4>
			  
			  <div id="chart-imaging-grid" class="grid grid-cols-2 gap-6">
			      </div>
			
		 	  <div id="chart-imaging-empty" class="hidden py-20 text-center text-zinc-300 bg-zinc-50 rounded-2xl border-2 border-dashed border-zinc-200">
			      <i class="icon icon-image text-4xl mb-2 opacity-20"></i>
			      <p class="text-sm font-bold">등록된 영상 자료가 없습니다.</p>
			  </div>
		  </div>
	     </div>
	    </div>
		    <div class="p-6 border-t border-zinc-200 bg-zinc-50 flex justify-end shrink-0">
		       <button onclick="closeChartModal()" class="btn btn-secondary btn-lg px-12">닫기</button>
		    </div>
		 </div>
	  </div>


<div id="reject-modal" class="fixed inset-0 z-[70] hidden flex items-center justify-center p-4">
   <div class="absolute inset-0 bg-zinc-900/60 backdrop-blur-sm" onclick="closeRejectModal()"></div>
   <div class="bg-white w-[500px] rounded-2xl shadow-2xl p-6 relative z-10">
      <h3 class="text-lg font-black text-zinc-900 mb-4 tracking-tight">협진 거절 사유 입력</h3>
      <textarea id="reject-reason" class="textarea w-full h-32 mb-4 border-red-100 focus:border-red-500" placeholder="사유를 상세히 입력해 주세요."></textarea>
      <div class="flex justify-end gap-2">
          <button onclick="closeRejectModal()" class="btn btn-secondary">취소</button>
          <button onclick="confirmReject()" class="btn btn-primary bg-red-600 hover:bg-red-700 border-none px-6">거절 전송</button>
      </div>
   </div>
</div>


