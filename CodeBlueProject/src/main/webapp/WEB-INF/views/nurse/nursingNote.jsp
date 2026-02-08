<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="macromodal.jsp" />

<div class="h-full flex flex-col">
    <div class="content-header mb-3">
        <div class="content-header-title">간호 기록지 작성</div>
        <div class="content-header-actions">
           <button onclick="NurseMacroApp.openModal()" class="btn btn-secondary btn-sm">
               <i class="fas fa-magic mr-1"></i>나의 오더
           </button>
        </div>
    </div>

    <div class="box box-secondary mb-4">
        <div class="form-row form-row-4">
            <div class="form-group">
                <label class="form-label">혈압 (mmHg)</label>
                <input type="text" id="note-bp" class="input" placeholder="120/80">
            </div>
            <div class="form-group">
                <label class="form-label">체온 (°C)</label>
                <input type="text" id="note-bt" class="input" placeholder="36.5">
            </div>
            <div class="form-group">
                <label class="form-label">맥박 (회/분)</label>
                <input type="text" id="note-pr" class="input" placeholder="78">
            </div>
            <div class="form-group">
                <label class="form-label">식이</label>
                <select id="note-diet" class="select">
                    <option value="일반식">일반식</option>
                    <option value="금식">금식</option>
                    <option value="죽">죽</option>
                    <option value="당뇨식">당뇨식</option>
                    <option value="저염식">저염식</option>
                </select>
            </div>
        </div>
        
        <div class="form-group mt-3">
            <label class="form-label">기록 내용</label>
            <textarea id="note-textarea" class="textarea" rows="4" placeholder="환자의 상태 및 간호 내용을 입력하세요..."></textarea>
        </div>
        
        <div class="btn-group-right mt-3">
       		<button onclick="NurseMacroApp.quickRegister()" class="btn btn-secondary btn-sm">나의 오더 저장</button>
        	<button onclick="saveNursingNote()" class="btn btn-primary btn-sm">기록 저장</button>
        </div>
    </div>

    <div class="box-section-title mt-4 mb-2">간호 기록 이력</div>
    
    <div class="accordion flex-1 overflow-y-auto pr-1" id="nursing-history-accordion">
        <div class="box box-bordered h-full flex items-center justify-center">
            <div class="empty-state empty-state-sm">
                <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <line x1="8" y1="6" x2="21" y2="6"></line>
                    <line x1="8" y1="12" x2="21" y2="12"></line>
                    <line x1="8" y1="18" x2="21" y2="18"></line>
                    <line x1="3" y1="6" x2="3.01" y2="6"></line>
                    <line x1="3" y1="12" x2="3.01" y2="12"></line>
                    <line x1="3" y1="18" x2="3.01" y2="18"></line>
                </svg>
                <div class="empty-state-title">기록 없음</div>
                <div class="empty-state-description">환자를 선택하여 기록을 조회하세요.</div>
            </div>
        </div>
    </div>
</div>

<script>
    /**
     * 간호 기록 리스트 로드 함수
     */
    function loadNursingNoteList() {
    	// 차트 번호 유효성 검사
    	 if (!window.currentChartNo) {
             sweetAlert("warning", "환자가 선택되지 않았습니다.", "확인");
             return;
         }

        const accordionContainer = document.getElementById('nursing-history-accordion');   

        // 로딩 표시
        accordionContainer.innerHTML = `
            <div class="flex flex-col items-center justify-center py-10 text-gray-400">
                <i class="fas fa-spinner fa-spin text-2xl mb-2"></i>
                <span class="text-sm">데이터를 불러오는 중...</span>
            </div>`;

        // 서버 데이터 요청 (params로 감싸야 @RequestParam 인식)
        axios.get("/nurse/nursingchartselect", {
            params: { 
                chartNo: window.currentChartNo 
            }
   		 })
        .then(res => {
            const list = res.data;
            console.log("간호기록지 데이터 확인:", list); // 콘솔에서 데이터 확인 필수
            renderNursingNoteList(list);
        })
        .catch(err => {
            console.error("간호기록 조회 실패:", err);
            renderEmptyState("데이터를 불러오지 못했습니다.", true);
        });
    }

    /**
     * Empty State 렌더링 헬퍼
     */
    function renderEmptyState(message, isError = false) {
        const accordionContainer = document.getElementById('nursing-history-accordion');
        const iconColorClass = isError ? "text-red-400" : "text-slate-300";
        
        accordionContainer.innerHTML = `
            <div class="box box-bordered h-full flex items-center justify-center bg-slate-50">
                <div class="empty-state empty-state-sm">
                    <svg class="empty-state-icon \${iconColorClass}" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                        <polyline points="14 2 14 8 20 8"></polyline>
                        \${isError ? '<line x1="9" y1="15" x2="15" y2="15"></line>' : ''}
                    </svg>
                    <div class="empty-state-title">\${isError ? '오류 발생' : '기록 없음'}</div>
                    <div class="empty-state-description">\${message}</div>
                </div>
            </div>`;
    }

    /**
     * 데이터를 받아 아코디언 HTML 렌더링
     * [중요] JSON 키값과 변수명이 정확히 일치해야 합니다.
     */
    function renderNursingNoteList(list) {
        const container = document.getElementById('nursing-history-accordion');
        
        if (!list || list.length === 0) {
            renderEmptyState("작성된 간호 기록이 없습니다.");
            return;
        }

        let html = '';
        list.forEach(item => {
            // 1. 날짜 포맷팅 (키: nursingchartDate)
            let dateStr = '-';
            if (item.nursingchartDate) {
                const dateObj = new Date(item.nursingchartDate);
                const year = dateObj.getFullYear();
                const month = String(dateObj.getMonth() + 1).padStart(2, '0');
                const day = String(dateObj.getDate()).padStart(2, '0');
                const hour = String(dateObj.getHours()).padStart(2, '0');
                const min = String(dateObj.getMinutes()).padStart(2, '0');
                dateStr = `\${year}-\${month}-\${day} \${hour}:\${min}`;
            }

            // 2. 작성자 (키: employeeName)
            const writerName = item.employeeName || '작성자미상';
            
            // 3. 바이탈 사인 뱃지 (보내주신 JSON 키값에 맞춤)
            // nursingchartPressure, nursingchartTemperature, nursingchartPulse, nursingchartDiet
            let badges = '';
            if (item.nursingchartPressure) badges += `<span class="badge badge-default text-xs mr-1">혈압: \${item.nursingchartPressure}</span>`;
            if (item.nursingchartTemperature) badges += `<span class="badge badge-default text-xs mr-1">체온: \${item.nursingchartTemperature}</span>`;
            if (item.nursingchartPulse) badges += `<span class="badge badge-default text-xs mr-1">맥박: \${item.nursingchartPulse}/분</span>`;
            if (item.nursingchartDiet) badges += `<span class="badge badge-default text-xs">식이: \${item.nursingchartDiet}</span>`;

            // 4. 내용 (키: nursingchartContent)
            html += `
            <div class="accordion-item bg-white border border-slate-200 rounded mb-2 shadow-sm hover:border-blue-200 transition-colors active">
                <button class="accordion-header w-full flex justify-between items-center p-3" onclick="toggleNoteAccordion(this)">
                    <div class="flex items-center gap-3">
                        <span class="font-bold text-slate-700">\${dateStr}</span>
                        <div class="flex items-center text-xs text-slate-500 border-l border-slate-300 pl-3">
                            <i class="fas fa-user-nurse mr-1"></i> \${writerName}
                        </div>
                    </div>
                    <i class="fas fa-chevron-down text-slate-400 text-xs transition-transform duration-200 accordion-icon"></i>
                </button>
                <div class="accordion-body hidden border-t border-slate-100 bg-slate-50/50">
                    <div class="accordion-body-content p-4">
                        <div class="flex flex-wrap gap-1 mb-3">
                            \${badges}
                        </div>
                        <p class="text-sm text-slate-700 whitespace-pre-wrap leading-relaxed">\${item.nursingchartContent}</p>
                    </div>
                </div>
            </div>`;
        });

        container.innerHTML = html;
    }
    
    /**
     * 간호 기록 저장 요청
     */
    function saveNursingNote() {
        if (!window.currentChartNo) {
            sweetAlert("warning", "환자가 선택되지 않았습니다.", "확인");
            return;
        }

        const content = document.getElementById('note-textarea').value;
        if (!content.trim()) {
            sweetAlert("warning", "기록 내용을 입력해주세요.", "확인");
            document.getElementById('note-textarea').focus();
            return;
        }

        const payload = {
            chartNo: window.currentChartNo,
            nursingchartPressure: document.getElementById('note-bp').value,
            nursingchartTemperature: document.getElementById('note-bt').value,
            nursingchartPulse: document.getElementById('note-pr').value, 
            nursingchartDiet: document.getElementById('note-diet').value,
            nursingchartContent: content
        };

        axios.post("/nurse/nursingchartinsert", payload)
            .then(res => {
                sweetAlert("success", "간호 기록이 저장되었습니다.", "확인");
                
                // 폼 초기화
                document.getElementById('note-bp').value = '';
                document.getElementById('note-bt').value = '';
                document.getElementById('note-pr').value = '';
                document.getElementById('note-textarea').value = '';
                
                // 목록 갱신
                loadNursingNoteList();
            })
            .catch(err => {
                console.error("저장 실패:", err);
                sweetAlert("error", "저장에 실패했습니다.", "확인");
            });
    }

    //아코디언 토글 로직 
    window.toggleNoteAccordion = function(button) {
        const item = button.closest('.accordion-item');
        const body = item.querySelector('.accordion-body');
        const icon = item.querySelector('.accordion-icon');
        
        if (body.classList.contains('hidden')) {
            body.classList.remove('hidden');
            if(icon) icon.classList.add('rotate-180'); 
        } else {
            body.classList.add('hidden');
            if(icon) icon.classList.remove('rotate-180');
        }
    }
</script>