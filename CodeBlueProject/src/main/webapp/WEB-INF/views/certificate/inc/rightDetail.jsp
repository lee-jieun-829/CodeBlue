<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
	<section class="min-w-0 flex-1 box box-bordered bg-white flex flex-col h-full overflow-hidden shadow-md">
		<div class="flex h-full flex-col">
		  <div class="border-b border-neutral-200 p-5 flex justify-between items-center bg-white sticky top-0 z-5 shadow-sm">
		    <div>
		        <h2 id="detailTitle" class="text-xl font-black text-zinc-900 tracking-tight">기록 상세 조회 및 작성</h2>
		        <p id="detailSub" class="text-xs text-zinc-400 mt-1 font-medium">항목을 선택하거나 버튼을 눌러 새 문서를 작성하세요.</p>
		    </div>
		    <div id="certWriteBtnArea" class="btn-group" style="display: none;">
		        <button type="button" class="btn btn-secondary btn-sm" onclick="showOpForm()">소견서 등록</button>
		        <button type="button" class="btn btn-primary btn-sm" onclick="showDxForm()">진단서 등록</button>
		    </div>
		  </div>
		
		  <div class="min-h-0 flex-1 overflow-y-auto p-8 bg-white">
		    <div id="rightEmpty" class="empty-state py-40">
		        <i class="icon icon-clipboard empty-state-icon opacity-20"></i>
		        <div class="empty-state-title">조회할 데이터가 없습니다</div>
		    </div>
		    
		    <div id="progView" class="hidden space-y-6">
			    <div class="flex items-center justify-between border-b pb-4">
			        <h3 class="text-xl font-black text-zinc-800" id="prog-title">진료 상세 기록</h3>
			        <span class="badge badge-outline" id="prog-author">담당의: -</span>
			    </div>
			
			    <div id="prog-vital-area" class="grid grid-cols-4 gap-4">
			        </div>
			
			    <div class="grid grid-cols-12 gap-6">
			        <div class="col-span-7 box-section">
			            <h4 class="box-section-title">의사 경과 기록</h4>
			            <div id="prog-content" class="p-4 bg-zinc-50 rounded-xl text-sm min-h-[120px] whitespace-pre-wrap leading-relaxed"></div>
			        </div>
			        <div class="col-span-5 box-section">
			            <h4 class="box-section-title">진단 상병</h4>
			            <div class="table-wrapper">
			                <table class="table table-sm">
			                    <tbody id="prog-dx-tbody"></tbody>
			                </table>
			            </div>
			        </div>
			    </div>
			
			    <div class="box-section">
			        <h4 class="box-section-title">처방 및 조치 내역</h4>
			        <div id="prog-order-list" class="grid grid-cols-1 gap-2">
			            </div>
			    </div>
			</div>
		
		    <div id="opViewForm" class="hidden space-y-8">
			    <div class="flex items-center justify-between mb-4">
			        <h3 class="text-lg font-bold">소견서 상세 조회</h3>
			    </div>
			    
			    <div class="box-section">
			        <h4 class="box-section-title">환자 정보</h4>
			        <div class="grid grid-cols-3 gap-4 mb-4">
			            <div class="form-group">
				            <label class="form-label">성명</label>
				            <input id="view-opPatientName" class="input bg-zinc-100" readonly />
			            </div>
			            <div class="form-group">
				            <label class="form-label">주민번호</label>
				            <input id="view-opRrn" class="input bg-zinc-100" readonly />
			            </div>
			            <div class="form-group">
				            <label class="form-label">발급번호</label>
				            <input id="view-opPrintNo" class="input bg-zinc-100" readonly />
			            </div>
			        </div>
			        <div class="grid grid-cols-2 gap-3">
			            <div class="form-group col-span-2">
				            <label class="form-label">주소</label>
				            <input id="view-opAddress" class="input bg-zinc-100" readonly />
			            </div>
			            <div class="form-group col-span-2">
				            <label class="form-label">연락처</label>
				            <input id="view-opPhone" class="input bg-zinc-100" readonly />
			            </div>
			        </div>
			    </div>
			
			    <div class="box-section">
			        <h4 class="box-section-title">상병 정보</h4>
			        <div class="table-wrapper mb-4">
			            <table class="table table-sm">
			                <thead>
			                    <tr>
				                    <th class="w-40">주/부</th>
				                    <th class="w-40">상병코드</th>
				                    <th>상병명</th>
			                    </tr>
			                </thead>
			                <tbody id="view-opDxTbody">
			                    </tbody>
			            </table>
			        </div>
			        <div class="flex justify-end items-center gap-3">
			            <label class="form-label">진단일</label>
			            <div class="w-48">
			                <input id="view-opDxDate" type="date" readonly class="input bg-zinc-50" />
			            </div>
			        </div>
			    </div>
			
			    <div class="box-section">
			        <h4 class="box-section-title">진료 소견</h4>
			        <textarea id="view-opContent" rows="6" readonly class="textarea bg-zinc-50"></textarea>
			        <div class="grid grid-cols-2 gap-4">
			            <div class="form-group">
			                <label class="form-label font-bold text-zinc-900">비고</label>
			                <input id="view-opRemark" type="text" readonly class="input bg-zinc-50" />
			            </div>
			            <div class="form-group">
			                <label class="form-label font-bold text-zinc-900">용도</label>
			                <input id="view-opPurpose" type="text" readonly class="input bg-zinc-50" />
			            </div>
			        </div>
			    </div>
			
			    <div class="box-section">
		            <h4 class="box-section-title">의료인 및 기관 정보</h4>
		            <div class="grid grid-cols-12 gap-3">
		                <div class="col-span-8 form-group">
			                <label class="form-label">의료기관 명칭/주소</label>
			                <input id="view-opOrg" class="input bg-zinc-100" readonly/>
		                </div>
		                <div class="col-span-4 form-group">
			                <label class="form-label">면허번호</label>
			                <input id="view-opLicence" class="input bg-zinc-100" readonly/>
		                </div>
		                <div class="col-span-12 form-group">
			                <label class="form-label">주치의 성명</label>
			                <input id="view-opDoctorName" class="input bg-zinc-100" readonly/>
		                </div>
		            </div>
		        </div>
			</div>
		
		    <div id="dxViewForm" class="hidden space-y-8">
		        <div class="flex items-center justify-between mb-4">
					<h3 class="text-lg font-bold">진단서 상세 조회</h3>
				</div>
		        <div class="box-section">
					<h4 class="box-section-title">환자 정보</h4>
		            <div class="grid grid-cols-3 gap-4 mb-4">
		                <div class="form-group">
							<label class="form-label">성명</label>
							<input id="view-dxPatientName" class="input bg-zinc-100" readonly />
						</div>
		                <div class="form-group">
							<label class="form-label">주민등록번호</label>
							<input id="view-dxRrn" class="input bg-zinc-100" readonly />
						</div>
		                <div class="form-group">
							<label class="form-label">발급번호</label>
							<input id="view-dxPrintNo" class="input bg-zinc-100" readonly />
						</div>
		            </div>
		            <div class="grid grid-cols-2 gap-3">
			            <div class="form-group col-span-2">
				            <label class="form-label">주소</label>
				            <input id="view-dxAddress" class="input bg-zinc-100" readonly />
			            </div>
			            <div class="form-group col-span-2">
				            <label class="form-label">연락처</label>
				            <input id="view-dxPhone" class="input bg-zinc-100" readonly />
			            </div>
			        </div>
		        </div>
		        <div class="box-section">
		            <h4 class="box-section-title">질병 정보 및 소견</h4>
		            <div class="table-wrapper mb-4">
						<table class="table table-sm">
			                <tr>
			                    <th class="w-40">주/부</th>
			                    <th class="w-40">상병코드</th>
			                    <th>상병명</th>
		                    </tr>
			                <tbody id="view-dxDxTbody">
			                </tbody>
			            </table>
					</div>
		            <div class="grid grid-cols-2 gap-4">
			            <div class="form-group">
			            	<label class="form-label">발병일</label>
			            	<input id="view-dxOnsetDate" type="date" readonly class="input bg-zinc-50" />
			            </div>
			            <div class="form-group">
			            	<label class="form-label">진단일</label>
			            	<input id="view-dxDxDate" type="date" readonly class="input bg-zinc-50" />
			            </div>
			        </div>
		            <div class="form-group mt-4">
						<label class="form-label">향후 치료 의견</label>
						<textarea id="view-dxContent" rows="5" readonly class="textarea bg-zinc-50"></textarea>
		           	 <div class="grid grid-cols-2 gap-4">
		                <div class="form-group">
		                	<label class="form-label font-bold text-zinc-900">비고</label>
		                	<input id="view-dxRemark" type="text" readonly="readonly" class="input" />
		                </div>
		                <div class="form-group">
		                	<label class="form-label font-bold text-zinc-900">용도</label>
		                	<input id="view-dxPurpose" type="text" readonly="readonly" class="input" />
		                </div>
			        </div>
		           </div>
		        </div>
		        <div class="box-section">
		            <h4 class="box-section-title">의료인 및 기관 정보</h4>
		            <div class="grid grid-cols-12 gap-3">
		                <div class="col-span-8 form-group">
							<label class="form-label">의료기관 명칭/주소</label>
							<input id="view-dxOrg" class="input bg-zinc-100" readonly/>
						</div>
		                <div class="col-span-4 form-group">
							<label class="form-label">면허번호</label>
							<input id="view-dxLicence" class="input bg-zinc-100" readonly/>
						</div>
		                <div class="col-span-12 form-group">
							<label class="form-label">주치의 성명</label>
							<input id="view-dxDoctorName" class="input bg-zinc-100" readonly/>
						</div>
		            </div>
		        </div>
		    </div>
		
		    <div id="opForm" class="hidden space-y-6">
		        <div class="callout callout-info mb-4"><div class="callout-title font-bold text-primary">소견서 신규 작성</div></div>
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
		        <div class="btn-group-right">
			        <button type="button" class="btn btn-secondary" onclick="showOnly(null)">취소</button>
			        <button type="button" class="btn btn-primary px-8" onclick="insertCertificate('op')">저장하기</button>
		        </div>
		    </div>
		
		    <div id="dxForm" class="hidden space-y-6">
		        <div class="callout callout-info mb-4">
		        	<div class="callout-title font-bold text-primary">진단서 신규 작성</div>
		        </div>
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
		        <div class="btn-group-right">
			        <button type="button" class="btn btn-secondary" onclick="showOnly(null)">취소</button>
			        <button type="button" class="btn btn-primary px-8" onclick="insertCertificate('dx')">저장하기</button>
		        </div>
		      </div>
		    </div>
		  </div>
		  </div>
		</section>