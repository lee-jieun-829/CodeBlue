<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<section class="box box-bordered flex flex-col h-full overflow-hidden bg-white">
   
   <div class="flex items-center justify-between px-5 py-4 border-b border-zinc-200 bg-zinc-50/80">
      <div class="flex items-center gap-2">
        <i class="icon icon-clipboard-text text-primary"></i>
        <h3 class="font-black text-zinc-900 tracking-tight text-base">재원 처방 <span class="text-[10px] text-zinc-400 font-medium ml-1 uppercase">Active Orders</span></h3>
      </div>
      <button onclick="openModal()" class="btn btn-ghost btn-xs font-bold text-primary hover:bg-indigo-50 transition-all">
        <i class="icon icon-plus-circle mr-1"></i>처방 추가
      </button>
   </div>
   
   <div class="flex-1 overflow-y-auto p-5 space-y-7 bg-white">
      
      <div class="order-category">
        <div class="flex items-center justify-between mb-3 pb-1 border-b border-zinc-100">
           <div class="flex items-center gap-2">
              <span class="flex h-5 w-5 items-center justify-center rounded bg-zinc-900 text-[10px] font-black text-white shadow-sm">1</span>
              <span class="text-xs font-black text-zinc-800 uppercase tracking-wider">식이 (Diet)</span>
           </div>
        </div>
        <div id="diet-items-area" class="space-y-2">
            <div class="text-center py-8 rounded-xl border border-dashed border-zinc-100 bg-zinc-50/30 text-zinc-300 text-[11px] italic">
                환자를 선택해 주세요.
            </div>
        </div>
     </div>
      
      <div class="order-category">
        <div class="flex items-center justify-between mb-3 pb-1 border-b border-zinc-100">
           <div class="flex items-center gap-2">
              <span class="flex h-5 w-5 items-center justify-center rounded bg-zinc-900 text-[10px] font-black text-white shadow-sm">2</span>
              <span class="text-xs font-black text-zinc-800 uppercase tracking-wider">약 / 주사 (Medication)</span>
           </div>
        </div>
        <div id="drug-items-area" class="space-y-2">
            <div class="text-center py-8 text-zinc-300 text-[11px] italic border border-dashed border-zinc-50">기록 없음</div>
        </div>
     </div>

      <div class="order-category">
        <div class="flex items-center justify-between mb-3 pb-1 border-b border-zinc-100">
           <div class="flex items-center gap-2">
              <span class="flex h-5 w-5 items-center justify-center rounded bg-zinc-900 text-[10px] font-black text-white shadow-sm">3</span>
              <span class="text-xs font-black text-zinc-800 uppercase tracking-wider">치료 / 처치 (Treatment)</span>
           </div>
        </div>
        <div id="treatment-items-area" class="space-y-2">
            <div class="text-center py-8 text-zinc-300 text-[11px] italic">기록 없음</div>
        </div>
      </div>

      <div id="test-section-area" class="order-category">
        <div class="flex items-center justify-between mb-3 pb-1 border-b border-zinc-100">
           <div class="flex items-center gap-2">
              <span class="flex h-5 w-5 items-center justify-center rounded bg-zinc-900 text-[10px] font-black text-white shadow-sm">4</span>
              <span class="text-xs font-black text-zinc-800 uppercase tracking-wider">검사 (Test)</span>
           </div>
        </div>
        <div id="test-items-area" class="space-y-2">
            <div class="text-center py-8 text-zinc-300 text-[11px] italic">기록 없음</div>
        </div>
    </div>

      <div id="surgery-section-area" class="order-category">
        <div class="flex items-center justify-between mb-3 pb-1 border-b border-zinc-100">
           <div class="flex items-center gap-2">
              <span class="flex h-5 w-5 items-center justify-center rounded bg-zinc-900 text-[10px] font-black text-white shadow-sm">5</span>
              <span class="text-xs font-black text-zinc-800 uppercase tracking-wider">수술 / 시술 (Surgery)</span>
           </div>
        </div>
        <div id="surgery-items-area" class="space-y-2">
            <div class="text-center py-8 text-zinc-300 text-[11px] italic">기록 없음</div>
        </div>
    </div>

   </div>

   <div class="p-5 border-t border-zinc-200 bg-zinc-50 space-y-2">
      <button onclick="openRegularOrderModal()" class="btn btn-secondary w-full py-3 font-bold shadow-sm transition-all hover:shadow-md active:scale-[0.98]">
         정규 처방 변경
      </button>
      <button onclick="chageAdmissionStatus()" class="btn btn-outline-danger w-full py-2.5 font-bold border-red-200 text-red-600 hover:bg-red-50 transition-all flex items-center justify-center gap-2">
        퇴원 심사 요청
      </button>
   </div>
</section>