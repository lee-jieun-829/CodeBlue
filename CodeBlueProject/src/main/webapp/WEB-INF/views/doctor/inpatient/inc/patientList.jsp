<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>

<section class="box box-bordered flex flex-col h-full overflow-hidden bg-white shadow-sm">
  
  <div class="flex-shrink-0 px-6 pt-6 pb-4">
    <h2 class="page-title">
        입원진료
    </h2>
  </div>
  
  <div class="px-6 pb-4 space-y-3">
    <div class="relative">
      <select id="ward-select" onchange="loadInpatientList()" class="select w-full bg-zinc-50 border-zinc-200 focus:bg-white transition-all font-bold text-sm">
        <option value="">병동 선택 (전체)</option>
        <option value="10">1병동</option>
        <option value="11">2병동</option>
        <option value="12">4병동</option>
        <option value="13">6병동</option>
      </select>
    </div>

    <div class="input-group">
       <input type="text" id="patient-search" onkeydown="if(event.key === 'Enter') loadInpatientList()"
              placeholder="환자명, 환자번호 검색" value="${keyword }" class="input input-search w-full font-medium" />
    </div>
  </div>

  <div class="flex items-center justify-between px-6 py-3 bg-zinc-50/80 border-y border-zinc-100">
    <div class="flex items-center gap-1.5">
        <span class="text-[11px] font-black text-zinc-400 uppercase tracking-wider">Total</span>
        <span id="total-count" class="text-sm font-black text-primary">0</span>
        <span class="text-[11px] font-bold text-zinc-400">명</span>
    </div>
    <div class="flex gap-3">
      <div class="flex items-center gap-1.5">
        <span class="h-2 w-2 rounded-full bg-green-500 shadow-[0_0_5px_rgba(34,197,94,0.5)]"></span>
        <span class="text-[11px] font-bold text-zinc-500">재원중</span>
      </div>
    </div>
  </div>

  <ul id="patient-list-container" class="flex-1 overflow-y-auto px-4 py-4 space-y-2 bg-white shadow-inner">
      <li class="py-20 text-center text-zinc-300 italic text-xs">
          검색 결과가 없습니다.
      </li>
  </ul>
</section>