<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c"%>
<style>
	/* 모달 가운데 정렬 강제 (hidden 클래스가 제거되면 flex가 적용됨) */
     .modal-wrapper {
       display: flex;
       align-items: center;
       justify-content: center;
     }
     
     /* 모달 전체를 숨기는 클래스 */
	.hidden {
	    display: none !important;
	}
	
	/* 유효성 검사 에러 메시지 스타일  */
	.error-msg {
	    color: #ef4444;
	    font-size: 0.75rem; 
	    margin-top: 0.25rem;
	    display: none; 
	}
	.input-error {
	    border-color: #ef4444 !important;
	}
	
	.error-msg.show {
	    display: block !important;
	    visibility: visible !important;
	    opacity: 1 !important;
	}
	
	/* 침상 버튼 기본 스타일 */
	.ward-section {
	    width: 100% !important;
	    margin-bottom: 2rem;
	}
	
	.room-container {
	    width: 100% !important;
	    display: flex;
	    flex-direction: column;
	    padding: 1rem;
	}
	
	.room-container .grid {
	    display: flex !important; 
	    gap: 0.75rem !important;
	}
	
	.room-container .flex {
	    gap: 6px; 
	}
	
	.bed-item {
		flex : 1 !important;
	    display: flex;
	    flex-direction: column;
	    align-items: center;
	    justify-content: center;
	    height: 75px !important; /* 높이 고정 */
	    min-width : 0;
	    border-radius: 8px;
	    border: 1px solid #e2e8f0;
	    transition: all 0.2s ease;
	    width: 100%;
	    background: #fff;
	}
	
	/* 사용 중인 병상 */
	.bed-item.occupied {
	    background-color: var(--color-slate-50);
	    color: var(--color-slate-400);
	    cursor: not-allowed;
	    border-style: dashed;
	}
	
	/* 선택 가능한 병상 */
	.bed-item.available {
	    background-color: #f5f3ff;
	    border-color: #ddd6fe;
	    cursor: pointer;
	}
	
	.bed-item.available:hover {
	    background-color: #ede9fe;
	    border-color: var(--color-primary);
	    transform: translateY(-2px);
	    box-shadow: var(--shadow-md);
	}
	
	/* 스크립트로 선택했을 때 적용되는 스타일 */
	.bed-item.selected {
	    background-color: #7c3aed !important;
	    border-color: #6d28d9 !important;
	    color: white !important;
	    box-shadow: 0 4px 12px rgba(124, 58, 237, 0.4);
	}
	
	/* 내부 텍스트 조절 */
	.bed-no { 
	    font-size: 11px; 
	    font-weight: 600; 
	    margin-bottom: 4px; 
	    opacity: 0.8;
	}
	.bed-status { 
	    font-size: 12px; 
	    font-weight: 800; 
	}
	
	/* 선택 시 내부 텍스트 흰색으로 강제 */
	.bed-item.selected .bed-no, 
	.bed-item.selected .bed-status { 
	    color: white !important; 
	}
	.bed-no { font-size: 10px; font-weight: 600; margin-bottom: 2px; color: #64748b; }
	.bed-status { font-size: 12px; font-weight: 700; color: #1e293b; }
	
	/* 사용중인 병상 스타일 (차분한 회색) */
	.bed-item.occupied {
	    background-color: #f1f5f9; 
	    border-color: #e2e8f0;     
	    cursor: not-allowed ;        
	    filter: grayscale(1);                 
	}
	
	/* 사용중인 병상의 내부 글자 스타일 */
	.bed-item.occupied .bed-no {
	    color: #94a3b8;    
	}
	
	.bed-item.occupied .bed-status {
	    color: #cbd5e1; 
	    font-weight: normal;
	}
</style>


<!-- 신규 환자 등록 모달 시작-->
<div id="modal-new-patient" class="modal-wrapper fixed inset-0 z-50 hidden bg-gray-600 bg-opacity-75">
    <div class="modal-content modal-hidden mx-4 w-full max-w-2xl rounded-xl bg-white shadow-2xl flex flex-col max-h-[90vh]">
        <div class="flex items-center justify-between border-b p-5">         
            <div class="flex items-center gap-3">
            	<h3 class="text-xl font-semibold text-gray-900">신규 환자 등록</h3>
		        <button type="button" onclick="autoFillPatientForm()" 
		                class="btn btn-sm btn-success-light btn-icon-left">
		            <i class="icon icon-shooting-star"></i>자동완성
		        </button>
		    </div>
            <button type="button" onclick="closeModal('modal-new-patient')" class="btn btn-goast btn-icon">
                <i class="icon icon-lg icon-x icon-muted"></i>
            </button>
        </div>

        <div class="p-6 overflow-y-auto scroll-content flex-1">
            <div class="mb-6">
                <h4 class="mb-3 title-h2 font-bold text-blue-600 flex items-center gap-2">
                    <span class="w-1 h-3 bg-blue-600 rounded-full"></span> 기본 인적 사항
                </h4>
                <div class="form-row form-row-2 mb-0">
	                <div class="form-group">
	                    <label class="form-label form-label-required">성명</label>
	                    <input type="text" id="patientName" class="input"/>
	                	<span id="err-patientName" class="error-msg">성명은 한글 또는 영문으로 입력해주세요.</span>
	                </div>
	                <div class="form-group">
	                    <label class="form-label form-label-required">성별</label>
	                    <select id="patientGen" class="select">
	                        <option value="">선택</option>
	                        <option value="MALE">남성</option>
	                        <option value="FEMALE">여성</option>
	                    </select>
	                </div>
	            </div>
                <div class="form-group">
                    <label class="form-label form-label-required">주민등록번호</label>
                    <div class="form-field-group">
                        <input type="text" id="patientRegno1" placeholder="예) 901234" maxlength="6" class="input" style="flex: 1;"/>
                        <span class="text-zinc-400" style="align-self: center;">-</span>
                        <input type="text" id="patientRegno2" placeholder="예) 1234567" maxlength="7" class="input" style="flex: 1;"/>
                    </div>
                    <span id="err-patientRegno" class="error-msg">올바른 주민등록번호 형식이 아닙니다.</span>
                </div>
                <div class="form-group">
				    <label class="form-label">이메일</label>
				    <div class="form-field-group"> 
				        <input type="text" id="email_id" placeholder="아이디" 
				               class="input"
				               oninput="combineEmail()"/>
				        
				        <span class="text-slate-400 font-bold px-1" style="align-self: center;">@</span>
				        
				        <input type="text" id="email_domain" placeholder="도메인 입력" 
				               class="input"
				               oninput="combineEmail()"/>
				        
				        <select id="email_select" onchange="handleEmailSelect()"
				                class="select">
				            <option value="">직접입력</option>
				            <option value="naver.com">naver.com</option>
				            <option value="gmail.com">gmail.com</option>
				            <option value="daum.net">daum.net</option>
				        </select>
				    </div>
				    <input type="hidden" id="patientEmail" name="patientEmail">
				    <span id="err-patientEmail" class="error-msg">올바른 이메일 형식이 아닙니다.</span>
				</div>
				<div class="form-group">
			        <label class="form-label form-label-required">연락처</label>
			        <input type="text" id="patientTel" placeholder="예) 010-0000-0000" 
			               class="input"/>
			    	<span id="err-patientTel" class="error-msg">올바른 전화번호 형식이 아닙니다. (예: 010-1234-5678)</span>
			    </div>
            </div>

            <div class="mb-6">
                <h4 class="mb-3 title-h3 font-bold text-slate-600 flex items-center gap-2">
                    <span class="w-1 h-3 bg-slate-400 rounded-full"></span> 주소지 정보
                </h4>
                <div class="form-group">
                    <div class="form-field-group">
                        <input type="text" id="patientPostcode" placeholder="우편번호" class="input" style="flex:1;" readonly/>
                        <button class="btn btn-secondary" onclick="DaumPostcode()">주소 검색</button>
                    </div>
                    <input type="text" id="patientAddr1" placeholder="기본 주소" class="input" readonly/>
                    <input type="text" id="patientAddr2" placeholder="상세 주소를 입력하세요" class="input"/>
                	<span id="err-patientAddr2" class="error-msg">상세 주소는 한글, 영문, 숫자만 입력 가능하며 20자 이내여야 합니다.</span>
                </div>
            </div>

            <div class="mb-2">
                <h4 class="mb-3 title-h2 font-bold text-emerald-600 flex items-center gap-2">
                    <span class="w-1 h-3 bg-emerald-600 rounded-full"></span> 접수 및 배정 정보
                </h4>
                <!-- 초진 데이터 전송 -->
                <input type="hidden" id="newPatientVisittype" value="002">
                <div class="form-row form-row-2 mb-0">
                	<div class="form-group">
			    		<label class="form-label form-label-required">진료실/담당의</label>
	        			<select id="locationNo" class="select">
					        <option value="">담당의를 선택하세요</option>
					    </select>
	                </div>
	                <div class="form-group">
	                    <label class="form-label form-label-required">보험 유형</label>
	                    <select id="registrationInsurance" class="select">
				            <option value="001">건강보험</option>
				            <option value="002">차상위1종</option>
				            <option value="003">차상위2종</option>
				            <option value="004">급여1종</option>
				            <option value="005">급여2종</option>
				            <option value="006">산재</option>
				            <option value="007">산재100</option>
				            <option value="008">후유장해</option>
				            <option value="009">자보</option>
				            <option value="010">자보100</option>
				            <option value="011">일반</option>
				            <option value="012">일반100</option>					        
						</select>
					</div>
               	</div>
                <div class="form-group">
                    <label class="form-label">환자 메모</label>
                    <textarea id="newPatientMemo" name="patientMemo" rows="2" class="textarea resize-none" placeholder="알러지, 과거 병력 등 참고사항"></textarea>
                </div>
            </div>
        </div>

        <div class="flex justify-end space-x-2 border-t p-4 bg-slate-50 rounded-b-xl">
            <button type="button" onclick="closeModal('modal-new-patient')" class="btn btn-secondary">취소</button>
            <button type="button" onclick="newPatientRegistration()" class="btn btn-primary">등록 완료</button>
        </div>
    </div>
</div>
<!-- 신규 환자 등록 모달 끝-->

<!-- 병동 현황 조회 모달 시작 -->
<div id="modal-ward-status" class="modal-wrapper fixed inset-0 hidden bg-gray-600 bg-opacity-75">
    <div class="modal-content mx-4 w-full max-w-4xl rounded-xl bg-white shadow-2xl flex flex-col max-h-[90vh]">
        <div class="flex items-center justify-between border-b p-5 shrink-0">
            <h3 class="text-xl font-bold text-slate-800 flex items-center gap-2">
                <span class="w-1.5 h-6 bg-purple-600 rounded-full"></span> 병동 현황 및 병상 배정
            </h3>
            <button type="button" onclick="closeModal('modal-ward-status')" class="text-slate-400 hover:text-slate-600 transition">
                <i class="fas fa-times text-xl"></i>
            </button>
        </div>

        <div class="p-6 overflow-y-auto scroll-content flex-1 space-y-10 bg-slate-50/30">
            
   			<div class="ward-section">
			    <h4 class="text-base font-bold text-purple-700 mb-4 border-l-4 border-purple-500 pl-3">1층 VIP병동 (101호 ~ 103호)</h4>
			    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
			        <c:forEach var="roomNo" items="101,102,103">
			            <div class="room-container bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
			                <h5 class="font-bold text-slate-700 mb-3 text-sm">${roomNo}호</h5>
			                <div class="grid grid-cols-1 gap-2"> <button type="button" data-bed-no="${roomNo}01" data-location-no="${roomNo}" data-status="001" data-display="${roomNo}호 01번" onclick="selectBed(this)" class="bed-item available">
			                        <span class="bed-no">01</span><span class="bed-status">배정가능</span>
			                    </button>
			                </div>
			            </div>
			        </c:forEach>
			    </div>
			</div>
			
			<div class="ward-section">
			    <h4 class="text-base font-bold text-blue-700 mb-4 border-l-4 border-blue-500 pl-3">2층 집중병동 (201호 ~ 203호)</h4>
			    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
			        <c:forEach var="roomNo" items="201,202,203">
			            <div class="room-container bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
			                <h5 class="font-bold text-slate-700 mb-3 text-sm">${roomNo}호</h5>
			                <div class="grid grid-cols-2 gap-2"> <c:forEach var="bedIdx" items="01,02">
			                        <button type="button" data-bed-no="${roomNo}${bedIdx}" data-location-no="${roomNo}" data-status="001" data-display="${roomNo}호 ${bedIdx}번" onclick="selectBed(this)" class="bed-item available">
			                            <span class="bed-no">${bedIdx}</span><span class="bed-status">배정가능</span>
			                        </button>
			                    </c:forEach>
			                </div>
			            </div>
			        </c:forEach>
			    </div>
			</div>
			
			<div class="ward-section">
			    <h4 class="text-base font-bold text-emerald-700 mb-4 border-l-4 border-emerald-500 pl-3">4층 일반병동 (401호 ~ 403호)</h4>
			    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
			        <c:forEach var="roomNo" items="401,402,403">
			            <div class="room-container bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
			                <h5 class="font-bold text-slate-700 mb-3 text-sm">${roomNo}호</h5>
			                <div style="display: grid !important; grid-template-columns: repeat(2, 1fr); gap: 0.5rem;">
			                    <c:forEach var="bedIdx" items="01,02,03,04">
			                        <button type="button" data-bed-no="${roomNo}${bedIdx}" data-location-no="${roomNo}" data-status="001" data-display="${roomNo}호 ${bedIdx}번" onclick="selectBed(this)" class="bed-item available">
			                            <span class="bed-no">${bedIdx}</span><span class="bed-status">배정가능</span>
			                        </button>
			                    </c:forEach>
			                </div>
			            </div>
			        </c:forEach>
			    </div>
			</div>
			
			<div class="ward-section">
			    <h4 class="text-base font-bold text-amber-700 mb-4 border-l-4 border-amber-500 pl-3">6층 일반병동 (601호 ~ 603호)</h4>
			    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
			        <c:forEach var="roomNo" items="601,602,603">
			            <div class="room-container bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
			                <h5 class="font-bold text-slate-700 mb-3 text-sm">${roomNo}호</h5>
			                <div style="display: grid !important; grid-template-columns: repeat(3, 1fr); gap: 0.5rem;">
			                    <c:forEach var="bedIdx" items="01,02,03,04,05,06">
			                        <button type="button" data-bed-no="${roomNo}${bedIdx}" data-location-no="${roomNo}" data-status="001" data-display="${roomNo}호 ${bedIdx}번" onclick="selectBed(this)" class="bed-item available">
			                            <span class="bed-no">${bedIdx}</span><span class="bed-status">배정가능</span>
			                        </button>
			                    </c:forEach>
			                </div>
			            </div>
			        </c:forEach>
			    </div>
			</div>
			
        </div>

        <footer class="p-5 border-t bg-slate-50 flex items-center justify-between rounded-b-xl shrink-0">
            <div class="flex flex-col">
                <span class="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Selected Bed</span>
                <span id="tempSelectedBedText" class="text-sm font-bold text-purple-700">-</span>
            </div>
            <div class="flex gap-2">
                <button type="button" onclick="closeModal('modal-ward-status')" class="btn btn-secondary px-6">취소</button>
                <button type="button" onclick="confirmBedAssignment()" class="btn btn-primary bg-purple-600 border-none px-8 shadow-lg">배정 확정</button>
            </div>
        </footer>
    </div>
</div>
<!-- 병동 현황 조회 모달 끝 -->