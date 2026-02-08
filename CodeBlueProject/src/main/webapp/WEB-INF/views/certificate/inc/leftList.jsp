<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<section class="w-[28rem] shrink-0 flex flex-col gap-4 overflow-hidden">
    <div class="box box-bordered bg-white p-5 shadow-sm">
        <h2 class="page-title">
	        환자 서류
	    </h2>
        <div class="input-group">
            <input type="text" id="patient-search" 
                   onkeydown="if(event.key === 'Enter') loadInpatientList()"
                   placeholder="환자명, 환자번호 검색" class="input input-search" />
        </div>
        <div id="selectedPtCompact" class="mt-3 p-3 rounded-lg bg-zinc-100 border border-zinc-200 transition-all">
            <div class="flex justify-between items-center text-sm">
                <span id="compactName" class="font-bold text-zinc-400">환자를 선택해주세요</span>
                <span id="compactInfo" class="text-zinc-400 font-medium">-</span>
            </div>
        </div>
    </div>

    <div class="box box-bordered bg-white flex-1 flex flex-col overflow-hidden shadow-sm">
        <div class="p-5 border-b border-neutral-100 bg-white">
            <h2 class="text-lg font-bold mb-4">DOCUMENT</h2>
            <input id="document-search" type="text" class="input input-sm input-search w-full" placeholder="서류명 검색" />
        </div>

        <div id="accordionList" class="flex-1 overflow-y-auto bg-zinc-50/30">
            <div class="accordion-item border-b border-zinc-200" data-category="DIAGNOSIS">
                <button type="button" class="accordion-header w-full flex items-center justify-between p-4 bg-white hover:bg-zinc-50" 
                        onclick="this.parentElement.classList.toggle('active')">
                    <span class="font-bold text-zinc-700 flex items-center gap-2">
                        <i class="icon icon-file-text text-primary"></i> 진단서
                    </span>
                    <i class="icon icon-chevron-down text-zinc-400"></i>
                </button>
                <div class="accordion-content bg-white">
                    <ul class="doc-item-list divide-y divide-zinc-50">
                        <li class="p-8 text-center text-zinc-400 text-xs">환자를 먼저 선택해주세요.</li>
                    </ul>
                </div>
            </div>

            <div class="accordion-item border-b border-zinc-200" data-category="OPINION">
                <button type="button" class="accordion-header w-full flex items-center justify-between p-4 bg-white hover:bg-zinc-50" 
                        onclick="this.parentElement.classList.toggle('active')">
                    <span class="font-bold text-zinc-700 flex items-center gap-2">
                        <i class="icon icon-file-text text-primary"></i> 소견서
                    </span>
                    <i class="icon icon-chevron-down text-zinc-400"></i>
                </button>
                <div class="accordion-content bg-white">
                    <ul class="doc-item-list divide-y divide-zinc-50">
                        <li class="p-8 text-center text-zinc-400 text-xs">환자를 먼저 선택해주세요.</li>
                    </ul>
                </div>
            </div>
            
            <div class="accordion-item border-b border-zinc-200" data-category="PROGRESS">
		        <button type="button" class="accordion-header w-full flex items-center justify-between p-4 bg-white hover:bg-zinc-50" 
		                onclick="this.parentElement.classList.toggle('active')">
		            <span class="font-bold text-zinc-700 flex items-center gap-2">
		                <i class="icon icon-file-text text-primary"></i> 진료 경과 기록
		            </span>
		            <i class="icon icon-chevron-down text-zinc-400"></i>
		        </button>
		        <div class="accordion-content bg-white">
		            <ul id="prog-item-list" class="doc-item-list divide-y divide-zinc-50">
		                <li class="p-8 text-center text-zinc-400 text-xs">환자를 먼저 선택해주세요.</li>
		            </ul>
		        </div>
		    </div>
        </div>
    </div>
</section>