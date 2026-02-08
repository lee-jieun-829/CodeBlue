<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<section class="w-[24rem] shrink-0 box box-bordered bg-white flex flex-col overflow-hidden shadow-sm">
  <div class="px-5 py-4 border-b border-zinc-200 bg-white">
      <h2 class="page-title">
	      협진 목록
	  </h2>
  </div>
  
  <div class="grid grid-cols-2 border-b border-zinc-100">
      <button id="tab-sent" onclick="switchList('sent')" class="tab-btn py-3 text-sm font-bold transition">보낸 협진 (Sent)</button>
      <button id="tab-received" onclick="switchList('received')" class="tab-btn active py-3 text-sm font-bold transition">받은 협진 (Received)</button>
  </div>

  <div id="list-received" class="list-section active flex-1 overflow-y-auto divide-y divide-zinc-100">
      <div onclick="openDetail('received', 1)" class="p-4 cursor-pointer hover:bg-zinc-50 border-l-4 border-red-500 bg-red-50/10 transition">
          <div class="flex justify-between items-start mb-2">
          </div>
          <div class="flex justify-between text-xs text-zinc-500">
          </div>
      </div>
  </div>

  <div id="list-sent" class="list-section flex-1 overflow-y-auto divide-y divide-zinc-100">
      <div onclick="openDetail('sent', 1)" class="p-4 cursor-pointer hover:bg-zinc-50 border-l-4 border-primary bg-indigo-50/30 transition">
          <div class="flex justify-between items-start mb-2">
          </div>
          <div class="flex justify-between text-xs text-zinc-500">
          </div>
      </div>
  </div>
  
  <div class="p-4 border-t border-zinc-200 bg-zinc-50">
      <button onclick="openWriteForm()" class="btn btn-primary w-full btn-lg flex justify-center items-center gap-2">
          <i class="icon icon-plus"></i> 새 협진 요청 작성
      </button>
  </div>
</section>