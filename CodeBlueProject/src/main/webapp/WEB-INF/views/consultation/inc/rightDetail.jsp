<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<section class="min-w-0 flex-1 box box-bordered bg-white flex flex-col overflow-hidden shadow-md relative">
	<div id="view-empty" class="view-section active items-center justify-center text-zinc-400 py-40">
		<i class="icon icon-file-text text-6xl opacity-20 mb-4"></i>
		<p>좌측 목록에서 협진 내역을 선택하거나</p>
		<p>'새 협진 요청'을 작성하세요.</p>
	</div>
	
	<div id="view-received" class="view-section hidden overflow-hidden">
		<div class="px-6 py-4 border-b border-zinc-200 flex justify-between items-center bg-zinc-50/50">
			<div>
				<h3 class="text-lg font-bold text-zinc-900 font-black">받은 협진 요청서</h3>
				<p class="text-xs text-zinc-500 mt-1">
                    보낸 사람: <span id="det-reqDoctor"></span> | <span id="det-reqDate"></span>
                </p>
			</div>
			<span id="det-statusBadge" class="badge badge-danger">답변 대기중</span>
		</div>
		<div class="flex-1 overflow-y-auto p-8 space-y-8">
			<div class="callout callout-info">
				<div class="flex justify-between items-center mb-3">
					<div class="flex gap-4">
						<span class="font-bold text-zinc-700 w-12 text-xs uppercase tracking-wider">Patient</span>
						<span id="det-patientName" class="font-bold text-primary">-</span>
					</div>
					<button onclick="openChartModal()" class="btn btn-secondary btn-xs">환자 차트 열기 ↗</button>
				</div>
				<div class="flex gap-4">
                    <span class="font-bold text-zinc-700 w-12 text-xs uppercase tracking-wider">Chart No</span>
                    <span id="det-chartNo" class="text-zinc-900 font-medium">-</span>
                </div>
			</div>
			
			<div class="box-section">
				<h4 class="box-section-title">협진 요청 내용 (Request Content)</h4>
				<div id="det-reqContent" class="bg-zinc-50 p-6 rounded-2xl border border-zinc-100 font-mono text-sm leading-relaxed text-zinc-700 shadow-inner whitespace-pre-wrap">
                    내용을 불러오는 중입니다...
                </div>
			</div>
			
			<div id="reply-write-area" class="box-section hidden animate-in slide-in-from-top-4 duration-300">
	            <h4 class="box-section-title text-indigo-600 border-b-2 border-indigo-600 pb-2 mb-4">결과 회신 작성 (Reply)</h4>
	            <button type="button" onclick="fillReplyDemo()" class="btn btn-xs btn-ghost text-indigo-500 font-bold border border-indigo-200">
		           시연
		        </button>
	            <div class="bg-indigo-50/30 p-6 rounded-2xl border-2 border-indigo-100 shadow-sm">
	                <textarea id="reply-text-input" 
	                          class="textarea w-full h-60 border-indigo-200 focus:border-indigo-500 focus:ring-2 focus:ring-indigo-200 bg-white" 
	                          placeholder="협진에 대한 회신 내용을 상세히 입력해 주세요..."></textarea>
	            </div>
	        </div>
			
			<div id="det-rejectArea" class="box-section hidden">
	            <h4 class="box-section-title text-red-600">협진 거절 사유 (Rejection Reason)</h4>
	            <div class="bg-red-50 p-6 rounded-2xl border border-red-100 font-mono text-sm leading-relaxed text-red-700 shadow-inner">
	                <p id="det-rejectReason" class="whitespace-pre-wrap">-</p>
	            </div>
	        </div>
			
			<div id="det-respArea" class="box-section hidden">
                <h4 class="box-section-title text-indigo-600">협진 회신 결과 (Consult Result)</h4>
                <div class="bg-indigo-50/30 p-6 rounded-2xl border border-indigo-100 font-mono text-sm leading-relaxed text-zinc-700 shadow-inner">
                    <div class="flex justify-between mb-2 pb-2 border-b border-indigo-100/50">
                        <span class="font-bold text-indigo-900" id="det-respDoctor">-</span>
                        <span class="text-xs text-zinc-400" id="det-respDate">-</span>
                    </div>
                    <div id="det-respContent" class="whitespace-pre-wrap pt-2">-</div>
                </div>
            </div>
		</div>
		
		<div class="p-4 border-t border-zinc-200 bg-zinc-50 flex justify-end gap-3 shrink-0">
			<button id="btn-reject" onclick="openRejectModal()" class="btn btn-secondary px-6">거절</button>
			<button id="btn-reply" onclick="openReplyForm()" class="btn btn-primary px-8">수락 및 회신 작성</button>
		</div>
	</div>
	
	
	<div id="view-write" class="view-section hidden">
		<div class="px-6 py-4 border-b border-zinc-200 bg-white flex justify-between items-center">
			<h3 class="text-xl font-black text-zinc-900 tracking-tight">새 협진 요청 작성</h3>
			<button onclick="cancelWrite()" class="btn btn-ghost btn-sm">닫기</button>
		</div>
		
		<div class="flex-1 overflow-y-auto p-8 space-y-8">
			<div class="box-section">
				<h4 class="box-section-title">환자 검색 (Patient Search)</h4>
					<div class="input-group mb-4">
						<input type="text" value="환자명" id="search-patient-keyword" 
							class="input flex-1" placeholder="환자명 또는 환자번호 입력" onkeyup="if(window.event.keyCode==13){searchConsultPatient()}">
						<button onclick="searchConsultPatient()" class="btn btn-secondary">검색</button>
					</div>
				<div id="search-patient-result" class="mb-4 space-y-2 max-h-60 overflow-y-auto hidden border rounded-xl p-2 bg-zinc-50">
                </div>

	            <div id="selected-patient-info" class="flex items-center gap-4 p-4 bg-indigo-50/50 border border-indigo-100 rounded-xl hidden">
	                <div class="h-12 w-12 rounded-full bg-indigo-100 flex items-center justify-center text-primary font-black text-xl">P</div>
	                <div>
	                    <p class="text-base font-bold text-zinc-900">
	                        <span id="write-patientName">-</span> 
	                        <span id="write-patientDetail" class="font-normal text-zinc-500 ml-2 text-sm">-</span>
	                    </p>
	                    <p id="write-wardInfo" class="text-xs text-zinc-400 mt-1">입원 정보 확인 중...</p>
	                </div>
	            </div>
			</div>
			
			<div class="grid grid-cols-4 gap-6">
				<div class="form-group">
					<label class="form-label font-bold">수신 의사</label>
					<select id="write-respDoctor" class="select w-full">
	                    <option value="">의사를 선택하세요</option>
	                </select>
				</div>
			</div>
			
			<div class="form-group">
				<label class="form-label font-bold">의뢰 사유 (Consult Reason)</label>
				<textarea id="write-reqContent" class="textarea w-full h-40" placeholder="상세 사유를 입력하세요.">수술 전 EKG 이상 소견(Abnormal T-wave inversion)에 대한 마취 가능 여부 평가 및 자문 구합니다.</textarea>
			</div>
		</div>
		
		<div class="p-4 border-t border-zinc-200 bg-zinc-50 flex justify-end gap-2 shrink-0">
			<button onclick="cancelWrite()" class="btn btn-secondary px-6">취소</button>
			<button onclick="sendConsult()" class="btn btn-primary px-10">의뢰 전송</button>
		</div>
	</div>
	
</section>