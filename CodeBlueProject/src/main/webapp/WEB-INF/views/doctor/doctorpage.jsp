<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>매크로 관리</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <style>
        .dashed-box {
            border: 2px dashed #cbd5e1;
            border-radius: 0.5rem;
            min-height: 120px;
            display: flex; flex-direction: column; justify-content: center; align-items: center;
            cursor: pointer; transition: 0.2s; background-color: #f8fafc;
        }
        .dashed-box:hover { border-color: #3b82f6; background-color: #eff6ff; }
        
        /* 선택된 아이템 태그 스타일 */
        .item-tag {
            width: 90%;
            background: white; border: 1px solid #e2e8f0; 
            padding: 6px 12px; margin: 2px 0; border-radius: 6px;
            display: flex; justify-content: space-between; align-items: center;
            font-size: 0.85rem;
            box-shadow: 0 1px 2px rgba(0,0,0,0.05);
        }
        
        /* 선택사항 */
        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: #f1f5f9; }
        ::-webkit-scrollbar-thumb { background: #cbd5e1; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #94a3b8; }
    </style>
</head>
<body class="bg-gray-100 h-screen overflow-hidden flex text-gray-800">

    <div class="w-80 bg-white border-r flex flex-col shadow-md z-10">
        <div class="p-5 border-b">
            <h2 class="text-lg font-bold flex items-center gap-2">
                <i class="fas fa-list text-blue-600"></i> 내 매크로 목록
            </h2>
            <button onclick="MacroApp.initNew()" class="mt-3 w-full text-blue-600 border border-blue-200 bg-blue-50 py-2 rounded text-sm font-bold hover:bg-blue-100 transition">
                + 신규 생성
            </button>
        </div>
        <div class="p-3 border-b bg-gray-50">
             <input type="text" placeholder="매크로 명칭 검색" class="w-full p-2 border rounded text-sm outline-none focus:border-blue-500">
        </div>
        <div id="macroListArea" class="flex-1 overflow-y-auto">
            <div class="p-10 text-center text-gray-400 text-sm">로딩 중...</div>
        </div>
    </div>

    <div class="flex-1 flex flex-col bg-white">
        <div class="h-16 border-b flex justify-between items-center px-8 bg-white shrink-0">
            <div>
                <h1 class="text-xl font-bold">매크로 상세 설정</h1>
                <span class="text-xs text-gray-400 uppercase tracking-wider">MACRO CONFIGURATION</span>
            </div>
            <div class="space-x-2">
                <button onclick="MacroApp.deleteMacro()" class="px-4 py-2 text-red-500 hover:bg-red-50 rounded font-medium transition">
                    <i class="fas fa-trash-alt mr-1"></i> 삭제
                </button>
                <button onclick="MacroApp.save()" class="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded font-bold shadow-sm transition">
                    <i class="fas fa-save mr-1"></i> 저장하기
                </button>
            </div>
        </div>

        <div class="flex-1 overflow-y-auto p-10 bg-gray-50">
            <div class="max-w-5xl mx-auto bg-white p-8 rounded-xl shadow-sm border border-gray-200">
                
                <div class="grid grid-cols-12 gap-6 mb-8">
                    <div class="col-span-4">
                        <label class="block text-sm font-bold text-gray-700 mb-2">역할 선택</label>
                        <select id="macroType" class="w-full p-2.5 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 outline-none">
                            <option value="001">의사 (처방/상병 포함)</option>
                        </select>
                    </div>
                    <div class="col-span-8">
                        <label class="block text-sm font-bold text-gray-700 mb-2">매크로 명칭 <span class="text-red-500">*</span></label>
                        <input type="text" id="macroName" class="w-full p-2.5 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 outline-none" placeholder="예: 발목 염좌 기본 세트">
                    </div>
                </div>

                <div class="grid grid-cols-2 gap-6 mb-8">
                    
                    <div>
                        <label class="block text-blue-600 font-bold mb-2 text-sm">
                            <i class="fas fa-notes-medical mr-1"></i> 상병코드 세트
                        </label>
                        <div id="diagnosisArea" class="dashed-box" onclick="MacroApp.openSearch('DIAGNOSIS')">
                            <i class="fas fa-plus text-gray-300 text-2xl mb-2"></i>
                            <span class="text-gray-400 text-sm">클릭하여 상병 추가</span>
                        </div>
                    </div>

                    <div>
                        <label class="block text-blue-600 font-bold mb-2 text-sm">
                            <i class="fas fa-pills mr-1"></i> 약제처방 세트
                        </label>
                        <div id="drugArea" class="dashed-box" onclick="MacroApp.openSearch('DRUG')">
                            <i class="fas fa-plus text-gray-300 text-2xl mb-2"></i>
                            <span class="text-gray-400 text-sm">클릭하여 약제 추가</span>
                        </div>
                    </div>

                    <div>
                        <label class="block text-blue-600 font-bold mb-2 text-sm">
                            <i class="fas fa-procedures mr-1"></i> 치료항목
                        </label>
                        <div id="treatmentArea" class="dashed-box" onclick="MacroApp.openSearch('TREATMENT')">
                            <i class="fas fa-plus text-gray-300 text-2xl mb-2"></i>
                            <span class="text-gray-400 text-sm">클릭하여 치료 추가</span>
                        </div>
                    </div>
                    
                    <div>
                        <label class="block text-gray-400 font-bold mb-2 text-sm">
                            </label>
                    </div>
          		</div>
          		
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">매크로 멘트</label>
                    <textarea id="macroContent" class="w-full h-32 p-3 border border-gray-300 rounded focus:ring-2 focus:ring-blue-500 outline-none resize-none" placeholder="환자 차트에 자동으로 입력될 텍스트를 작성하세요."></textarea>
                </div>

            </div>
        </div>
    </div>

    <div id="searchModal" class="hidden fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div class="bg-white p-6 rounded-lg w-96 shadow-xl h-[550px] flex flex-col animate-fade-in-up">
            <div class="flex justify-between items-center mb-4 border-b pb-2">
                <h3 class="font-bold text-lg text-gray-800" id="modalTitle">항목 검색</h3>
                <button onclick="MacroApp.closeModal()" class="text-gray-400 hover:text-gray-600">
                    <i class="fas fa-times text-xl"></i>
                </button>
            </div>
            
            <div class="relative flex items-center mb-2">
                <input type="text" id="modalInput" 
                       class="w-full p-2 pl-3 pr-10 border border-gray-300 rounded focus:border-blue-500 outline-none transition" 
                       placeholder="검색어 입력 후 엔터"
                       onkeyup="if(window.event.keyCode===13) MacroApp.searchDB()">
                <button onclick="MacroApp.searchDB()" class="absolute right-3 text-blue-500 hover:text-blue-700">
                    <i class="fas fa-search"></i>
                </button>
            </div>

            <div class="flex-1 overflow-y-auto border border-gray-100 bg-gray-50 rounded mt-2 p-1">
                <ul id="searchResultList" class="space-y-1">
                    <li class="text-center text-gray-400 text-sm mt-20 flex flex-col items-center">
                        <i class="fas fa-search text-2xl mb-2 text-gray-300"></i>
                        <span>검색어를 입력하세요.</span>
                    </li>
                </ul>
            </div>
        </div>
    </div>

    <script>
        const MacroApp = {
            state: {
                macroNo: 0, 
                employeeNo: 25121901, 
                diagnosisList: [],
                drugList: [],
                treatmentList: [],
            },
            
            tempSearchType: '', 

            init: function() {
                this.loadList();
            },

            // --- 1. 매크로 목록 조회 ---
            loadList: function() {
                const empNo = Number(this.state.employeeNo);
                
                axios.get('/api/macro/list?employeeNo=' + empNo)
                    .then(response => {
                        const data = response.data; // 서버에서 받은 List<MacroVO>
                        const listArea = document.getElementById('macroListArea');
                        listArea.innerHTML = '';
                        
                        if(!data || data.length === 0) {
                            listArea.innerHTML = '<div class="p-10 text-center text-gray-400 text-sm">등록된 매크로가 없습니다.<br>신규 생성을 눌러주세요.</div>';
                            return;
                        }

                        data.forEach(item => {
                            const div = document.createElement('div');
                            div.className = "p-4 border-b hover:bg-blue-50 cursor-pointer transition group";
                            
                            div.innerHTML = `
                                <div class="font-bold text-gray-800 group-hover:text-blue-700">\${item.macroName}</div>
                                <div class="text-xs text-gray-500 mt-1 flex justify-between">
                                    <span>\${item.macroType}</span>
                                    <span class="text-gray-300">#\${item.macroNo}</span>
                                </div>
                            `;
                            div.onclick = () => this.loadDetail(item.macroNo);
                            listArea.appendChild(div);
                        });
                    })
                    .catch(err => {
                        console.error("목록 조회 실패:", err);
                        // 에러 처리 로직 추가 가능
                    });
            },

            // --- 2. 상세 조회 ---
            loadDetail: function(macroNo) {
                axios.get('/api/macro/detail/' + macroNo)
                    .then(response => {
                        const data = response.data; // 서버에서 받은 MacroVO 객체
                        
                        this.state.macroNo = data.macroNo;
                        
                        document.getElementById('macroName').value = data.macroName;
                        // DB에서 가져온 값이 001이면 자동으로 선택됩니다.
                        document.getElementById('macroType').value = data.macroType;
                        document.getElementById('macroContent').value = data.macroContent || ''; 

                        // 리스트 초기화
                        this.state.diagnosisList = [];
                        this.state.drugList = [];
                        this.state.treatmentList = [];
                        
                        if (data.macroDetails) {
                            data.macroDetails.forEach(detail => {
                                // [중요] 백엔드 VO 필드명에 맞게 매핑 확인
                                const item = { 
                                    code: detail.macroDetailCode || detail.macroDetailPrename, 
                                    name: detail.macroDetailPrename 
                                };
                                if (detail.macroDetailType === 'DIAGNOSIS') this.state.diagnosisList.push(item);
                                else if (detail.macroDetailType === 'DRUG') this.state.drugList.push(item);
                                else if (detail.macroDetailType === 'TREATMENT') this.state.treatmentList.push(item);
                            });
                        }
                        
                        this.renderLists();
                    })
                    .catch(err => console.error("상세 조회 실패:", err));
            },

            // --- 3. 신규 모드 ---
            initNew: function() {
                this.state.macroNo = 0;
                this.state.diagnosisList = [];
                this.state.drugList = [];
                this.state.treatmentList = [];
                
                document.getElementById('macroName').value = '';
                document.getElementById('macroContent').value = '';
                // 신규 생성 시 select box는 첫 번째 옵션(001)으로 자동 설정됨
                document.getElementById('macroType').selectedIndex = 0;
                document.getElementById('macroName').focus();
                
                this.renderLists();
            },

            // --- 4. 저장 ---
            save: function() {
                const name = document.getElementById('macroName').value;
                const content = document.getElementById('macroContent').value;
                const type = document.getElementById('macroType').value; // 이제 "001"이 담김
                
                if (!name.trim()) { alert("매크로 명칭을 입력하세요."); return; }

                const payload = {
                    macroNo: Number(this.state.macroNo),
                    macroName: name,
                    macroType: type,
                    macroContent: content, 
                    employeeNo: Number(this.state.employeeNo),
                    
                    diagnosisList: this.state.diagnosisList.map(item => ({ diagnosisCode: item.code, diagnosisName: item.name })),
                    drugList: this.state.drugList.map(item => ({ drugCode: item.code, drugName: item.name })),
                    treatmentList: this.state.treatmentList.map(item => ({ treatmentCode: item.code, treatmentName: item.name }))
                };

                const url = this.state.macroNo === 0 ? '/api/macro/add' : '/api/macro/update';
                
                axios.post(url, payload)
                    .then(response => {
                        const text = response.data; 
                        if(String(text).includes("SUCCESS")) {
                            alert("저장되었습니다.");
                            this.loadList();
                            if (this.state.macroNo === 0) this.initNew();
                        } else {
                            alert("저장 실패: " + text);
                        }
                    })
                    .catch(err => {
                        console.error("저장 실패:", err);
                        alert("통신 오류가 발생했습니다.");
                    });
            },
            
            // --- 5. 삭제 ---
            deleteMacro: function() {
                if(this.state.macroNo === 0) {
                    alert("삭제할 매크로를 선택해주세요.");
                    return;
                }
                if(!confirm("정말 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.")) return;
                
                axios.post('/api/macro/delete/' + this.state.macroNo)
                    .then(response => {
                        const text = response.data;
                        
                        if(String(text).includes("SUCCESS")){
                            alert("삭제되었습니다.");
                            this.initNew();
                            this.loadList();
                        } else {
                            alert("삭제 실패");
                        }
                    })
                    .catch(err => {
                        console.error("삭제 실패:", err);
                        alert("통신 오류가 발생했습니다.");
                    });
            },

            // --- UI 렌더링 ---
            renderLists: function() {
                this.renderBox('diagnosisArea', this.state.diagnosisList, 'DIAGNOSIS');
                this.renderBox('drugArea', this.state.drugList, 'DRUG');
                this.renderBox('treatmentArea', this.state.treatmentList, 'TREATMENT');
            },

            renderBox: function(elementId, list, type) {
                const box = document.getElementById(elementId);
                box.innerHTML = ''; 

                if (list.length === 0) {
                    box.innerHTML = `
                        <i class="fas fa-plus text-gray-300 text-2xl mb-2 pointer-events-none"></i>
                        <span class="text-gray-400 text-sm pointer-events-none">클릭하여 추가</span>
                    `;
                    return;
                }

                list.forEach((item, index) => {
                    const tag = document.createElement('div');
                    tag.className = 'item-tag animate-fade-in'; 
                    tag.innerHTML = `
                        <div class="flex items-center overflow-hidden">
                            <div class="w-2 h-2 rounded-full bg-blue-500 mr-2 shrink-0"></div>
                            <span class="truncate font-medium text-gray-700" title="\${item.name}">\${item.name}</span>
                        </div>
                        <i class="fas fa-times text-gray-300 hover:text-red-500 cursor-pointer p-1 ml-2 transition"
                           onclick="event.stopPropagation(); MacroApp.removeItem('\${type}', \${index})"></i>
                    `;
                    box.appendChild(tag);
                });
            },

            // --- 모달 & 검색 ---
            openSearch: function(type) {
                this.tempSearchType = type;
                const titleMap = { 'DIAGNOSIS': '상병', 'DRUG': '약품', 'TREATMENT': '치료' };
                document.getElementById('modalTitle').innerText = (titleMap[type] || type) + " 검색";
                document.getElementById('modalInput').value = '';
                document.getElementById('searchResultList').innerHTML = 
                    `<li class="text-center text-gray-400 text-sm mt-20 flex flex-col items-center">
                        <i class="fas fa-keyboard text-2xl mb-2 text-gray-300"></i>
                        <span>검색어를 입력하고 엔터를 누르세요.</span>
                    </li>`;
                
                document.getElementById('searchModal').classList.remove('hidden');
                document.getElementById('modalInput').focus();
            },

            closeModal: function() {
                document.getElementById('searchModal').classList.add('hidden');
            },

            // --- 검색 (Axios) ---
            searchDB: function() {
                const keyword = document.getElementById('modalInput').value;
                if(!keyword.trim()) { alert("검색어를 입력하세요."); return; }

                let url = '';
                // [API 경로 확인] Controller 설정에 따라 수정
                if (this.tempSearchType === 'DIAGNOSIS') url = '/api/macro/diagnosis/search';
                else if (this.tempSearchType === 'DRUG') url = '/api/macro/drug/search';
                else if (this.tempSearchType === 'TREATMENT') url = '/api/macro/treatment/search';
                
                url += '?keyword=' + encodeURIComponent(keyword);

                // 로딩 표시
                document.getElementById('searchResultList').innerHTML = '<li class="text-center text-gray-400 mt-10">검색 중...</li>';

                axios.get(url)
                    .then(response => {
                        this.renderSearchResults(response.data);
                    })
                    .catch(err => {
                        console.error("검색 실패:", err);
                        document.getElementById('searchResultList').innerHTML = '<li class="text-center text-red-400 mt-10">오류 발생</li>';
                    });
            },

            renderSearchResults: function(list) {
                const ul = document.getElementById('searchResultList');
                ul.innerHTML = '';

                if (!list || list.length === 0) {
                    ul.innerHTML = '<li class="text-center text-gray-400 text-sm mt-10">검색 결과가 없습니다.</li>';
                    return;
                }

                list.forEach(item => {
                    // [중요] VO 필드명 매핑 (Backend VO 확인 필수)
                    let code = item.diagnosisCode || item.drugCode || item.treatmentCode || item.code;
                    let name = item.diagnosisName || item.drugName || item.treatmentName || item.name;

                    const li = document.createElement('li');
                    li.className = "p-3 border-b border-gray-100 hover:bg-blue-50 cursor-pointer flex justify-between items-center bg-white rounded transition";
                    li.innerHTML = `
                        <div class="flex flex-col">
                            <span class="text-gray-800 font-bold text-sm">\${name}</span>
                            <span class="text-xs text-blue-500">\${code}</span>
                        </div>
                        <i class="fas fa-plus-circle text-gray-300 hover:text-blue-500 text-lg"></i>
                    `;
                    li.onclick = () => this.selectItem(code, name);
                    ul.appendChild(li);
                });
            },

            selectItem: function(code, name) {
                const newItem = { code: code, name: name };
                if (this.tempSearchType === 'DIAGNOSIS') this.state.diagnosisList.push(newItem);
                else if (this.tempSearchType === 'DRUG') this.state.drugList.push(newItem);
                else if (this.tempSearchType === 'TREATMENT') this.state.treatmentList.push(newItem);
                
                this.renderLists();
                this.closeModal();
            },
            
            removeItem: function(type, index) {
                if (type === 'DIAGNOSIS') this.state.diagnosisList.splice(index, 1);
                else if (type === 'DRUG') this.state.drugList.splice(index, 1);
                else if (type === 'TREATMENT') this.state.treatmentList.splice(index, 1);
                this.renderLists();
            }
        };

        window.onload = function() {
            MacroApp.init();
        };
    </script>
</body>
</html>