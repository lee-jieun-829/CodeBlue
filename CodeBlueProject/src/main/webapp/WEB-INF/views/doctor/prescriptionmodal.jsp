<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<style>
    /* 모달 오버레이 */
    .modal-overlay {
        transition: opacity 0.2s ease-in-out;
        opacity: 0;
        pointer-events: none;
        z-index: 9000; /* 모달 자체의 높이 */
    }
    .modal-overlay.active {
        opacity: 1;
        pointer-events: auto;
    }
    
    /* 검색 결과 리스트 스타일 */
    .result-list {
        max-height: 200px;
        overflow-y: auto;
        /* 중요: 글씨가 잘 보이도록 배경과 z-index, 그림자 강화 */
        background-color: white; 
    }
    /* 스크롤바 디자인 */
    .result-list::-webkit-scrollbar { width: 5px; }
    .result-list::-webkit-scrollbar-track { background: transparent; }
    .result-list::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 3px; }
</style>

<div id="modal-container">

    <div id="modal-diagnosis" class="modal-overlay fixed inset-0 flex items-center justify-center bg-black/50 backdrop-blur-sm font-sans">
        <div class="bg-white w-full max-w-lg rounded-lg shadow-2xl transform transition-all overflow-visible">
            <div class="flex justify-between items-center p-4 border-b bg-gray-50 rounded-t-lg">
                <h3 class="font-bold text-lg text-gray-800">상병 추가</h3>
                <button type="button" onclick="closeModal('modal-diagnosis')" class="text-gray-400 hover:text-gray-600 text-2xl">&times;</button>
            </div>
            <div class="p-6 space-y-4">
                
                <div class="relative w-full z-50"> <label class="block text-xs font-bold text-gray-500 mb-1">상병 검색</label>
                    <div class="relative">
                        <input type="text" 
                               id="diag-search-input" 
                               onclick="handleFocus(this, 'diagnosis')" 
	                           onfocus="handleFocus(this, 'diagnosis')"
                               onkeyup="handleSearch(this, 'diagnosis')"
                               autocomplete="off"
                               class="w-full border border-gray-300 rounded px-3 py-2 text-sm text-gray-900 focus:outline-none focus:border-blue-500 focus:ring-1 focus:ring-blue-500 transition-colors pl-9 bg-white" 
                               placeholder="상병명 또는 코드 입력">
                        <svg class="w-4 h-4 absolute left-3 top-2.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                        <button type="button" onclick="clearInput('diag-search-input')" class="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600 focus:outline-none">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                        </button>
                        <div id="diag-loading" class="hidden absolute right-3 top-2.5">
                            <div class="animate-spin h-4 w-4 border-2 border-blue-500 rounded-full border-t-transparent"></div>
                        </div>
                    </div>
                    <ul id="diag-results-list" 
                    	class="hidden absolute left-0 right-0 top-full mt-1 bg-white border border-gray-300 rounded-md shadow-xl max-h-[250px] overflow-y-auto z-[9999]">
                    </ul>
                </div>

                <div class="flex gap-6 items-center border-t border-gray-100 pt-4 z-0">
                    <span class="text-sm font-bold text-gray-600">구분:</span>
                    <label class="flex items-center gap-2 cursor-pointer hover:bg-gray-50 p-1 rounded">
                        <input type="radio" name="diag-type" value="main" class="accent-blue-600 w-4 h-4" checked> 
                        <span class="text-sm text-gray-700">주상병</span>
                    </label>
                    <label class="flex items-center gap-2 cursor-pointer hover:bg-gray-50 p-1 rounded">
                        <input type="radio" name="diag-type" value="sub" class="accent-blue-600 w-4 h-4"> 
                        <span class="text-sm text-gray-700">부상병</span>
                    </label>
                </div>

                <div class="grid grid-cols-5 gap-3">
                    <div class="col-span-2">
                        <label class="block text-xs font-bold text-gray-500 mb-1">상병코드</label>
                        <input type="text" id="diag-code" class="w-full bg-gray-100 border border-gray-200 rounded px-3 py-2 text-sm text-gray-900 cursor-not-allowed" readonly tabindex="-1">
                    </div>
                    <div class="col-span-3">
                        <label class="block text-xs font-bold text-gray-500 mb-1">상병명</label>
                        <input type="text" id="diag-name" class="w-full bg-gray-100 border border-gray-200 rounded px-3 py-2 text-sm text-gray-900 cursor-not-allowed" readonly tabindex="-1">
                    </div>
                </div>
            </div>
            <div class="p-4 border-t bg-gray-50 flex justify-end gap-2 rounded-b-lg">
                <button type="button" onclick="resetForm('modal-diagnosis')" class="px-4 py-2 text-sm text-red-500 hover:bg-red-50 rounded border border-transparent hover:border-red-100 transition-colors">초기화</button>
                <button 
                	type="button" 
                	class="px-4 py-2 bg-blue-600 text-white rounded text-sm hover:bg-blue-700 shadow-sm transition-colors font-medium"
                	onclick="addList('diagnosis')"
                	>
                	추가
                </button>
            </div>
        </div>
    </div>

    <div id="modal-treatment" class="modal-overlay fixed inset-0 flex items-center justify-center bg-black/50 backdrop-blur-sm font-sans">
        <div class="bg-white w-full max-w-xl rounded-lg shadow-2xl transform transition-all overflow-visible">
            <div class="flex justify-between items-center p-4 border-b bg-gray-50 rounded-t-lg">
                <h3 class="font-bold text-lg text-gray-800">치료 처방 추가</h3>
                <button type="button" onclick="closeModal('modal-treatment')" class="text-gray-400 hover:text-gray-600 text-2xl">&times;</button>
            </div>
            <div class="p-6 space-y-4">
                
                <div class="relative w-full z-50 search-box-area">
                    <label class="block text-xs font-bold text-gray-500 mb-1">치료 검색</label>
                    <div class="relative">
                        <input type="text" 
                               id="treat-search-input" 
                               onclick="handleFocus(this, 'treatment')" 
                       	       onfocus="handleFocus(this, 'treatment')"   
                               onkeyup="handleSearch(this, 'treatment')"
                               autocomplete="off"
                               class="w-full border border-gray-300 rounded px-3 py-2 text-sm text-gray-900 focus:outline-none focus:border-green-500 focus:ring-1 focus:ring-green-500 transition-colors pl-9 bg-white" 
                               placeholder="치료명 검색">
                        <svg class="w-4 h-4 absolute left-3 top-2.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                        <button type="button" onclick="clearInput('treat-search-input')" class="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600 focus:outline-none">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                        </button>
                        
                        <div id="treat-loading" class="hidden absolute right-3 top-2.5">
                            <div class="animate-spin h-4 w-4 border-2 border-green-500 rounded-full border-t-transparent"></div>
                        </div>
                    </div>
                    <ul id="treat-results-list" class="hidden absolute left-0 right-0 top-full mt-1 bg-white border border-gray-300 rounded-md shadow-xl max-h-[250px] overflow-y-auto z-[9999]"></ul>
                </div>

                <div class="grid grid-cols-4 gap-3 border-t border-gray-100 pt-4 z-0">
                    <div class="col-span-1">
                        <label class="block text-xs font-bold text-gray-500 mb-1">처방코드</label>
                        <input type="text" id="treat-code" class="w-full bg-gray-100 border border-gray-200 rounded px-2 py-2 text-sm text-gray-900 cursor-not-allowed" readonly>
                    </div>
                    
                    <div class="col-span-3">
                        <label class="block text-xs font-bold text-gray-500 mb-1">치료명</label>
                        <input type="text" id="treat-name" class="w-full bg-gray-100 border border-gray-200 rounded px-2 py-2 text-sm text-gray-900 cursor-not-allowed" readonly>
                    </div>

                    <div class="col-span-2">
                        <label class="block text-xs font-bold text-gray-700 mb-1">1회량</label>
                        <input min="0" type="number" id="treat-amount" class="w-full border border-gray-300 rounded px-2 py-2 text-sm text-gray-900 focus:border-green-500 focus:outline-none focus:ring-1 focus:ring-green-500">
                    </div>
                    
                    <div class="col-span-2">
                        <label class="block text-xs font-bold text-gray-700 mb-1">단위</label>
                        <input type="text" id="treat-unit" class="w-full border border-gray-300 rounded px-2 py-2 text-sm text-gray-900 focus:border-green-500 focus:outline-none focus:ring-1 focus:ring-green-500">
                    </div>
                </div>
            </div>
            <div class="p-4 border-t bg-gray-50 flex justify-end gap-2 rounded-b-lg">
                <button type="button" onclick="resetForm('modal-treatment')" class="px-4 py-2 text-sm text-red-500 hover:bg-red-50 rounded">초기화</button>
                <button 
                    type="button" 
                    class="px-4 py-2 bg-green-600 text-white rounded text-sm hover:bg-green-700 shadow-sm font-medium"
                    onclick="addList('treatment')">
                    추가
                </button>
            </div>
        </div>
    </div>

    <div id="modal-medication" class="modal-overlay fixed inset-0 flex items-center justify-center bg-black/50 backdrop-blur-sm font-sans">
        <div class="bg-white w-full max-w-2xl rounded-lg shadow-2xl transform transition-all overflow-visible">
            <div class="flex justify-between items-center p-4 border-b bg-gray-50 rounded-t-lg">
                <h3 class="font-bold text-lg text-gray-800">약제 처방 추가</h3>
                <button type="button" onclick="closeModal('modal-medication')" class="text-gray-400 hover:text-gray-600 text-2xl">&times;</button>
            </div>
            <div class="p-6 space-y-4">
                
                <div class="relative w-full z-50">
                    <label class="block text-xs font-bold text-gray-500 mb-1">약품 검색</label>
                    <div class="relative">
                        <input type="text" 
                               id="med-search-input" 
                               onclick="handleFocus(this, 'medication')"
                    	       onfocus="handleFocus(this, 'medication')" 
                               onkeyup="handleSearch(this, 'medication')"
                               autocomplete="off"
                               class="w-full border border-gray-300 rounded px-3 py-2 text-sm text-gray-900 focus:outline-none focus:border-orange-500 focus:ring-1 focus:ring-orange-500 transition-colors pl-9 bg-white" 
                               placeholder="약품명 검색">
                        <svg class="w-4 h-4 absolute left-3 top-2.5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"></path></svg>
                        <button type="button" onclick="clearInput('med-search-input')" class="absolute right-3 top-2.5 text-gray-400 hover:text-gray-600 focus:outline-none">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>
                        </button>
                        <div id="med-loading" class="hidden absolute right-3 top-2.5">
                            <div class="animate-spin h-4 w-4 border-2 border-orange-500 rounded-full border-t-transparent"></div>
                        </div>
                    </div>
                    <ul id="med-results-list" 
                    	class="hidden absolute left-0 right-0 top-full mt-1 bg-white border border-gray-300 rounded-md shadow-xl max-h-[250px] overflow-y-auto z-[9999]">
                    </ul>
                </div>

                <div class="grid grid-cols-4 gap-3 border-t border-gray-100 pt-4 z-0">
                    <div class="col-span-1">
                        <label class="block text-xs font-bold text-gray-500 mb-1">약제코드</label>
                        <input type="text" id="med-code" class="w-full bg-gray-100 border border-gray-200 rounded px-2 py-2 text-sm text-gray-900 cursor-not-allowed" readonly>
                    </div>
                    <div class="col-span-3">
                        <label class="block text-xs font-bold text-gray-500 mb-1">약제명</label>
                        <input type="text" id="med-name" class="w-full bg-gray-100 border border-gray-200 rounded px-2 py-2 text-sm text-gray-900 cursor-not-allowed" readonly>
                    </div>

                    <div class="col-span-1">
                        <label class="block text-xs font-bold text-gray-700 mb-1">1회량</label>
                        <input min="0" id="med-amount" type="number" class="w-full border border-gray-300 rounded px-2 py-2 text-sm text-gray-900 focus:border-orange-500 focus:outline-none focus:ring-1 focus:ring-orange-500">
                    </div>
                    <div class="col-span-1">
                        <label class="block text-xs font-bold text-gray-700 mb-1">횟수</label>
                        <input min="0" id="med-count" type="number" class="w-full border border-gray-300 rounded px-2 py-2 text-sm text-gray-900 focus:border-orange-500 focus:outline-none focus:ring-1 focus:ring-orange-500">
                    </div>
                    <div class="col-span-1">
                        <label  class="block text-xs font-bold text-gray-700 mb-1">일수</label>
                        <input min="0" id="med-day" type="number" class="w-full border border-gray-300 rounded px-2 py-2 text-sm text-gray-900 focus:border-orange-500 focus:outline-none focus:ring-1 focus:ring-orange-500">
                    </div>
                    <div class="col-span-1">
                        <label class="block text-xs font-bold text-gray-700 mb-1">용법</label>
                        <select id="med-usage"  class="w-full border border-gray-300 rounded px-2 py-2 text-sm text-gray-900 focus:border-orange-500 focus:outline-none focus:ring-1 focus:ring-orange-500 bg-white">
                            <option>식후 30분</option>
                            <option>식전 30분</option>
                            <option>취침 전</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="p-4 border-t bg-gray-50 flex justify-end gap-2 rounded-b-lg">
                <button type="button" onclick="resetForm('modal-medication')" class="px-4 py-2 text-sm text-red-500 hover:bg-red-50 rounded">초기화</button>
                <button 
                    type="button" 
                    class="px-4 py-2 bg-orange-600 text-white rounded text-sm hover:bg-orange-700 shadow-sm font-medium"
                    onclick="addList('medication')">
                    추가
                </button>
            </div>
        </div>
    </div>
</div>

<script>

    let debounceTimer;

    // 2. 모달 열기
    function openModal(id) {
        document.getElementById(id).classList.add('active');
        // 모달 열릴 때 초기화가 필요하면 주석 해제
        resetForm(id);
    }

    // 3. 모달 닫기
    function closeModal(id) {
        document.getElementById(id).classList.remove('active');
        document.querySelectorAll('.result-list').forEach(el => el.classList.add('hidden'));
    }

    // 4. 폼 초기화
    function resetForm(modalId) {
        document.getElementById(modalId).querySelectorAll('input:not([type="radio"])').forEach(input => input.value = '');
    }

    // [신규 기능] 5. 포커스 시 데이터가 비어있으면 기본값 노출
    function handleFocus(input, type) {
        const keyword = input.value.trim();
        // 입력값이 없을 때만 기본 데이터 3개 노출
        if(keyword.length === 0) {
            const listId = type === 'diagnosis' ? 'diag-results-list' : 
                           type === 'treatment' ? 'treat-results-list' : 'med-results-list';
            const listEl = document.getElementById(listId);
            
            // 데이터베이스 앞쪽 3개만 잘라서 가져옴
            // 검색어가 있든 없든, 클릭하면 해당 검색 함수를 호출하여 리스트를 엽니다.
		   if(type === 'diagnosis') selectDiagnosis(keyword, type);
		   else if(type === 'treatment') selectTreatment(keyword, type);
		   else if(type === 'medication') selectDrug(keyword, type);
        }
    }

    // 6. 검색 핸들러 (Debouncing 적용)
    function handleSearch(input, type) {
        const keyword = input.value.trim().toUpperCase();

        const listId = type === 'diagnosis' ? 'diag-results-list' : 
                       type === 'treatment' ? 'treat-results-list' : 'med-results-list';
        const loadingId = type === 'diagnosis' ? 'diag-loading' : 
                          type === 'treatment' ? 'treat-loading' : 'med-loading';

        const listEl = document.getElementById(listId);
        const loadingEl = document.getElementById(loadingId);

        
        if(debounceTimer) clearTimeout(debounceTimer);
        
        loadingEl.classList.remove('hidden');
        listEl.classList.add('hidden');
        
        debounceTimer = setTimeout(() => {

            if(type === 'diagnosis') selectDiagnosis(keyword,type);
            if(type === 'treatment') selectTreatment(keyword,type);
            if(type === 'medication') selectDrug(keyword,type);
            
            // 입력 다 지우면 목록 숨기기 (혹은 기본목록 보여주기로 정책 변경 가능)
            if(keyword.length === 0) {
                listEl.classList.add('hidden');
                loadingEl.classList.add('hidden');
                return;
            }
        }, 300);
    }

    // 7. 결과 그리기 (공통 함수)
    function renderResults(data, listEl, type) {
        listEl.innerHTML = '';

        if(data.length === 0) {
            listEl.innerHTML = '<li class="px-4 py-3 text-sm text-gray-500 text-center">검색 결과가 없습니다.</li>';
        } else {
            data.forEach(item => {
                const li = document.createElement('li');
                // 글씨 색상(text-gray-900) 강제 적용 및 배경색 명시
                li.className = "px-4 py-2 hover:bg-gray-100 cursor-pointer border-b border-gray-100 last:border-0 flex justify-between items-center transition-colors bg-white";
                
                if(type === 'diagnosis'){
                    li.innerHTML = `
                        <span class="font-medium text-gray-900">\${item.diagnosisName}</span>
                        <span class="text-xs text-gray-500 bg-gray-50 px-1.5 py-0.5 rounded border border-gray-200">\${item.diagnosisCode}</span>
                    `;
                }

                if(type === 'treatment'){
                    li.innerHTML = `
                        <span class="font-medium text-gray-900">\${item.treatmentName}</span>
                        <span class="text-xs text-gray-500 bg-gray-50 px-1.5 py-0.5 rounded border border-gray-200">\${item.treatmentCode}</span>
                    `;
				}

                if(type === 'medication'){
                    li.innerHTML = `
                        <span class="font-medium text-gray-900">\${item.drugName}</span>
                        <span class="text-xs text-gray-500 bg-gray-50 px-1.5 py-0.5 rounded border border-gray-200">\${item.drugCode}</span>
                    `;
                }

                li.onmousedown = (e) => {
                    e.preventDefault(); // 블러 이벤트 방지
                    selectItem(type, item);
                    listEl.classList.add('hidden');
                };
                listEl.appendChild(li);
            });
        }
        listEl.classList.remove('hidden');
    }

    // 8. 선택 시 인풋 채우기
    function selectItem(type, item) {
        if (type === 'diagnosis') {
            document.getElementById('diag-code').value = item.diagnosisCode;
            document.getElementById('diag-name').value = item.diagnosisName;
            document.getElementById('diag-search-input').value = item.diagnosisName;
        } else if (type === 'treatment') {
            document.getElementById('treat-code').value = item.treatmentCode;
            document.getElementById('treat-name').value = item.treatmentName;
            document.getElementById('treat-search-input').value = item.treatmentName;
        } else if (type === 'medication') {
            document.getElementById('med-code').value = item.drugCode;
            document.getElementById('med-name').value = item.drugName;
            document.getElementById('med-search-input').value = item.drugName;
        }
    }

    // 9. 외부 클릭 시 닫기
    document.addEventListener('click', function(e) {
        if (!e.target.closest('.relative')) {
            document.querySelectorAll('.result-list').forEach(el => el.classList.add('hidden'));
        }
    });
    
    // 10. 추가 버튼 클릭시 해당 화면에 추가 
    function addList(type){
        if(type === 'diagnosis'){
            let tbody = document.getElementById('dxTableBody');
            
            let index = tbody.querySelectorAll("tr").length +1;

            let code = document.getElementById("diag-code").value;
            let name = document.getElementById("diag-name").value;
            let type = document.querySelector("input[name='diag-type']:checked").value;
            tbody.innerHTML += `
                <tr>
                    <td>\${index}</td>
                    <td><input \${type === 'main' ? 'checked' : ''} name="diagcheck\${index}" type="radio" class="h-4 w-4 align-middle accent-blue-600" /></td>
                    <td><input \${type === 'sub' ? 'checked' : ''} name="diagcheck\${index}" type="radio" class="h-4 w-4 align-middle accent-blue-600" /></td>
                    <td>\${code}</td>
                    <td>\${name}</td>
                    <td>
                        <button onclick="removeList(this)" type="button" class="btn btn-icon btn-destructive btn-sm">×</button>
                    </td>
                </tr>
            `
            closeModal('modal-diagnosis');
        }  
        if(type === 'treatment'){
            let tbody = document.getElementById('txTableBody');
            let index = tbody.querySelectorAll("tr").length +1;
            
            let code = document.getElementById("treat-code").value;
            let name = document.getElementById("treat-name").value;
            let amount = document.getElementById("treat-amount").value;
            let unit = document.getElementById("treat-unit").value;

            tbody.innerHTML += `
                <tr>
                    <td>\${index}</td>
                    <td>\${code}</td>
                    <td>\${name}</td>
                    <td><input min="0" type="number" class="input" value="\${amount}" /></td>
                    <td><input type="text" class="input" value="\${unit}" /></td>
                    <td>
                        <button onclick="removeList(this)" type="button" class="btn btn-icon btn-destructive btn-sm">×</button>
                    </td>
                </tr>
            `;
            closeModal('modal-treatment');
        }  
        if(type === 'medication'){
            let tbody = document.getElementById('rxTableBody');
            let index = tbody.querySelectorAll("tr").length +1;
            
            let name = document.getElementById("med-name").value;
            let amount = document.getElementById("med-amount").value;
            let count = document.getElementById("med-count").value;
            let day = document.getElementById("med-day").value;
            let usage = document.getElementById("med-usage").value;
            console.log(usage);
            tbody.innerHTML += `
                <tr>
                    <td>\${index}</td>
                    <td>\${name.split('(')[0]}</td>
                    <td><input min="0" type="number" class="input" value="\${amount}" /></td>
                    <td><input min="0" type="number" class="input" value="\${count}" /></td>
                    <td><input min="0" type="number" class="input" value="\${day}" /></td>
                    <td>
                        <select  class="w-full border border-gray-300 rounded px-2 py-2 text-sm text-gray-900 focus:border-orange-500 focus:outline-none focus:ring-1 focus:ring-orange-500 bg-white">
                            <option \${usage === '식후 30분' ? 'selected' : ''} >식후 30분</option>
                            <option \${usage === '식전 30분' ? 'selected' : ''}>식전 30분</option>
                            <option \${usage === '취침 전' ? 'selected' : ''}>취침 전</option>
                        </select>
                        
                    </td>
                    <td>
                        <button onclick="removeList(this)" type="button" class="btn btn-icon btn-destructive btn-sm">×</button>
                    </td>
                </tr>
            `

            closeModal('modal-medication')
        } 

    }


    // 리스트에서 삭제
    function removeList(ele){
        ele.parentElement.parentElement.remove();
    }
    

    function selectDiagnosis(searchWord,type){
        console.log("상병명가져오기 ... ", searchWord);
        axios.post("/doctor/api/getDiagnosis", {
            "searchWord" : searchWord
        })
        .then(function (response) {
            console.log(response.data);
            let listId = 'diag-results-list';
            const listEl = document.getElementById(listId);
            renderResults(response.data, listEl ,type);
        }).catch(function (error) {
			
        });
    }
    
    function selectTreatment(searchWord, type){
        console.log("치료목록가져오기 ... ", searchWord);
        axios.post("/doctor/api/getTreatment", { // 컨트롤러 주소 확인
            "searchWord" : searchWord
        })
        .then(function (response) {
            let listId = 'treat-results-list';
            const listEl = document.getElementById(listId);
            renderResults(response.data, listEl ,type);
        }).catch(function (error) {
            console.error(error);
        });
    }

    function selectDrug(searchWord,type){
        console.log("약품목록가져오기 ... ", searchWord);
        axios.post("/doctor/api/getDrug", {
            "searchWord" : searchWord
        })
        .then(function (response) {
            console.log(response.data);
            let listId = 'med-results-list';
            const listEl = document.getElementById(listId);
            renderResults(response.data, listEl ,type);
        }).catch(function (error) {
			
        });
    }
    
	// [신규] X 버튼 클릭 시 입력값 초기화 및 포커스 유지
    function clearInput(inputId) {
        const input = document.getElementById(inputId);
        if (input) {
            input.value = '';  // 값 비우기
            input.focus();     // 다시 입력할 수 있게 포커스
            // 리스트는 닫거나, 빈 값 기준으로 다시 검색(선택 사항)
            // 여기서는 깔끔하게 리스트를 닫습니다.
            document.querySelectorAll('.result-list').forEach(el => el.classList.add('hidden'));
        }
    }

    // [신규] ESC 키 누르면 열려있는 검색 목록 닫기
    document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
            document.querySelectorAll('.result-list').forEach(el => el.classList.add('hidden'));
        }
    });
</script>