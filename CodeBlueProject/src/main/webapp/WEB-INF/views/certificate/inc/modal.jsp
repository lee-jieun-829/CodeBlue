<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="ptBackdrop" class="modal-backdrop hidden" style="display: none; align-items: center; justify-content: center; position: fixed; inset: 0; background: rgba(0,0,0,0.5); z-index: 1000;">
  <div class="modal modal-lg bg-white rounded-xl shadow-2xl" style="width: 800px; max-height: 90vh;">
    
    <div class="modal-header p-5 border-b flex justify-between items-center bg-white">
        <h3 class="modal-title font-bold text-xl">환자 검색</h3>
        <button type="button" class="btn btn-icon btn-ghost" onclick="closeModal()">×</button>
    </div>

    <div class="modal-body p-6 overflow-y-auto">
      <div class="grid grid-cols-12 gap-3 mb-6">
        <div class="col-span-12">
            <input type="text" id="modal-patient-search" 
                   onkeydown="if(event.key === 'Enter') patientSearch(this.value)"
                   placeholder="검색어를 입력하고 Enter를 누르세요" 
                   class="input input-search w-full" />
        </div>
      </div>
      
      <div id="modalSearchResult" class="box box-bordered bg-zinc-50 min-h-[350px] p-20 text-center text-zinc-400 font-medium">
          환자명을 입력하고 엔터를 누르면 내원 이력이 표시됩니다.
      </div>
    </div>

    <div class="modal-footer p-5 border-t flex justify-end bg-white">
        <button type="button" class="btn btn-secondary px-8" onclick="closeModal()">닫기</button>
    </div>
  </div>
</div>

<div id="ipOpModal" class="fixed inset-0 z-[100] hidden items-start justify-center bg-black/50 backdrop-blur-sm overflow-y-auto pt-[80px] pb-10">
    <div class="bg-white w-[950px] h-[calc(100vh-120px)] rounded-2xl shadow-2xl overflow-hidden flex flex-col border border-zinc-200">
    
        <div class="px-8 py-6 border-b border-zinc-100 flex justify-between items-center bg-white shrink-0">
            <h3 class="text-xl font-black text-zinc-900">소견서 신규 작성</h3>
            <button type="button" class="btn btn-icon btn-ghost" onclick="closeIpDocModal('op')">×</button>
        </div>
        
       	 <div class="p-8 overflow-y-auto flex-1 space-y-8">
	         <div class="box-section border-primary/20">
	            <h4 class="box-section-title">환자 기본 정보</h4>
	            <div class="grid grid-cols-3 gap-4 mb-4">
	                <div class="form-group">
		                <label class="form-label">성명</label>
		                <input id="opPatientName" class="input bg-zinc-100" readonly />
	                </div>
	                <div class="form-group">
		                <label class="form-label">주민번호</label>
		                <input id="opRrn" class="input bg-zinc-100" readonly />
	                </div>
	                <div class="form-group">
		                <label class="form-label">발급번호</label>
		                <input id="opPrintNo" class="input bg-zinc-100" readonly />
	                </div>
	            </div>
	            <div class="grid grid-cols-2 gap-3">
	                <div class="form-group col-span-2">
		                <label class="form-label">주소</label>
		                <input id="opAddress" class="input bg-zinc-100" readonly />
	                </div>
	                <div class="form-group col-span-2">
		                <label class="form-label">연락처</label>
		                <input id="opPhone" class="input bg-zinc-100" readonly />
	                </div>
	            </div>
	        </div>
	        <div class="box-section">
	        	<div class="flex items-center justify-between mb-2">
		            <h4 class="text-sm font-bold">상병 정보</h4>
		        </div>
			    <div class="table-wrapper mb-4">
			        <table class="table table-sm">
			            <thead>
			                <tr>
				                <th class="w-40">주/부</th>
				                <th class="w-40">상병코드</th>
				                <th>상병명</th>
			                </tr>
			            </thead>
			            <tbody id="opDxTbody">
			            </tbody>
			        </table>
			    </div>
			
			    <div class="flex justify-end items-center gap-3">
			        <label class="form-label font-bold text-zinc-900">진단일</label>
			        <div class="w-48">
			            <input id="opDxDate" type="date" class="input" />
			        </div>
			    </div>
			</div>
	        <div class="form-group">
	        	<label class="form-label font-bold text-zinc-900">진료 소견 입력</label>
	        	<textarea id="opContent" rows="5" class="textarea w-full"></textarea>
	        	<div class="grid grid-cols-2 gap-4">
		        	<div class="form-group">
	                	<label class="form-label font-bold text-zinc-900">비고</label>
	                	<input id="opRemark" type="text" class="input" />
	                </div>
	                <div class="form-group">
	                	<label class="form-label font-bold text-zinc-900">용도</label>
	                	<input id="opPurpose" type="text" class="input" />
	                </div>
	            </div>
	        </div>
	        <div class="box-section">
	            <h4 class="box-section-title">의료인 및 기관 정보</h4>
	            <div class="grid grid-cols-12 gap-3">
	                <div class="col-span-8 form-group">
		                <label class="form-label">의료기관 명칭/주소</label>
		                <input id="opOrg" class="input bg-zinc-100" readonly />
	                </div>
	                <div class="col-span-4 form-group">
		                <label class="form-label">면허번호</label>
		                <input id="opLicence" class="input bg-zinc-100" readonly />
	                </div>
	                <div class="col-span-12 form-group">
		                <label class="form-label">주치의 성명</label>
		                <input id="opDoctorName" class="input bg-zinc-100" readonly />
	                </div>
	            </div>
	        </div>
	       </div>
	        <div class="px-8 py-5 bg-zinc-50 border-t border-zinc-100 flex justify-end gap-3 shrink-0">
	            <button type="button" class="btn btn-secondary px-8" onclick="closeIpDocModal('op')">취소</button>
	            <button type="button" class="btn btn-primary px-10 font-black shadow-lg shadow-indigo-100" onclick="insertCertificate('op')">저장하기</button>
	        </div>
	    </div>
    </div>


<div id="ipDxModal" class="fixed inset-0 z-[100] hidden items-start justify-center bg-black/50 backdrop-blur-sm overflow-y-auto pt-[80px] pb-10">
    <div class="bg-white w-[950px] h-[calc(100vh-120px)] rounded-2xl shadow-2xl overflow-hidden flex flex-col border border-zinc-200">
        
        <div class="p-5 border-b border-zinc-200 flex justify-between items-center bg-white shrink-0">
            <h3 class="text-xl font-black text-zinc-900">진단서 신규 작성</h3>
            <button type="button" class="btn btn-icon btn-ghost" id="fillContent" onclick="btnFillContent()">시연</button>
            <button type="button" class="btn btn-icon btn-ghost" onclick="closeIpDocModal('dx')">×</button>
        </div>
        
        <div class="p-8 overflow-y-auto flex-1 space-y-8">
        
	        <div class="box-section border-primary/20">
         		  	<h4 class="box-section-title">환자 기본 정보</h4>
	            <div class="grid grid-cols-3 gap-4 mb-4">
	                <div class="form-group">
		                <label class="form-label">성명</label>
		                <input id="dxPatientName" class="input bg-zinc-100" readonly />
	                </div>
	                <div class="form-group">
		                <label class="form-label">주민번호</label>
		                <input id="dxRrn" class="input bg-zinc-100" readonly />
	                </div>
	                <div class="form-group">
		                <label class="form-label">발급번호</label>
		                <input id="dxPrintNo" class="input bg-zinc-100" readonly />
	                </div>
	            </div>
	            <div class="grid grid-cols-2 gap-3">
	                <div class="form-group col-span-2">
		                <label class="form-label">주소</label>
		                <input id="dxAddress" class="input bg-zinc-100" readonly />
	                </div>
	                <div class="form-group col-span-2">
		                <label class="form-label">연락처</label>
		                <input id="dxPhone" class="input bg-zinc-100" readonly />
	                </div>
	            </div>
	        </div>
	        <div class="box-section">
	            <div class="flex items-center justify-between mb-2">
		            <h4 class="text-sm font-bold">질병 정보 및 소견</h4>
		        </div>
	            <div class="table-wrapper mb-4">
		            <table class="table table-sm">
		            	<thead>
		            		<tr>
		            			<th class="w-40">주/부</th>
		            			<th class="w-40">상병코드</th>
		            			<th>상병명</th>
		            		</tr>
		            	</thead>
		            	<tbody id="dxDxTbody">
		            	</tbody>
		            </table>
		        </div>
	            <div class="grid grid-cols-2 gap-4">
	                <div class="form-group">
	                	<label class="form-label font-bold text-zinc-900">발병일</label>
	                	<input id="dxOnsetDate" type="date" class="input" />
	                </div>
	                <div class="form-group">
	                	<label class="form-label font-bold text-zinc-900">진단일</label>
	                	<input id="dxDxDate" type="date" class="input" />
	                </div>
	            </div>
	        </div>
	        <div class="form-group mt-4">
		        <label class="form-label">향후 치료 의견</label>
		        <textarea id="dxContent" rows="5" class="textarea w-full"></textarea>
		        <div class="grid grid-cols-2 gap-4">
	                <div class="form-group">
	                	<label class="form-label font-bold text-zinc-900">비고</label>
	                	<input id="dxRemark" type="text" class="input" />
	                </div>
	                <div class="form-group">
	                	<label class="form-label font-bold text-zinc-900">용도</label>
	                	<input id="dxPurpose" type="text" class="input" />
	                </div>
		        </div>
		        <div class="box-section">
		            <h4 class="box-section-title">의료인 및 기관 정보</h4>
		            <div class="grid grid-cols-12 gap-3">
		                <div class="col-span-8 form-group">
			                <label class="form-label">의료기관 명칭/주소</label>
			                <input id="dxOrg" class="input bg-zinc-100" readonly />
		                </div>
		                <div class="col-span-4 form-group">
			                <label class="form-label">면허번호</label>
			                <input id="dxLicence" class="input bg-zinc-100" readonly />
		                </div>
		                <div class="col-span-12 form-group">
			                <label class="form-label">주치의 성명</label>
			                <input id="dxDoctorName" class="input bg-zinc-100" readonly />
		                </div>
		            </div>
		        </div>
		     </div>
	      </div>
	        <div class="px-8 py-5 bg-zinc-50 border-t border-zinc-100 flex justify-end gap-3 shrink-0">
	            <button type="button" class="btn btn-secondary px-8" onclick="closeIpDocModal('dx')">취소</button>
	            <button type="button" class="btn btn-primary px-10 font-black shadow-lg shadow-indigo-100" onclick="insertCertificate('dx')">저장하기</button>
	        </div>
	    </div>
	</div>
