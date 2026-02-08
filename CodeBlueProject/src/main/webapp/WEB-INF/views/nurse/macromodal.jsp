<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">



<div id="macroModal" class="fixed inset-0 bg-black/50 z-50 hidden justify-center items-center backdrop-blur-sm">
    <div class="bg-white rounded-lg shadow-2xl w-[900px] h-[600px] flex flex-col overflow-hidden animate-fade-in-up">
        
        <div class="flex justify-between items-center p-4 border-b bg-white shrink-0">
            <h3 class="font-bold text-lg text-slate-800 flex items-center gap-2">
                <span class="w-1.5 h-6 bg-blue-600 rounded-full"></span>
                간호 기록 매크로 템플릿
            </h3>
            <button type="button" onclick="NurseMacroApp.closeModal()" class="text-slate-400 hover:text-slate-600 transition">
                <i class="fas fa-times text-xl"></i> 
            </button>
        </div>

       <div class="flex-1 flex overflow-hidden">
            <div class="w-5/12 border-r bg-slate-50 flex flex-col">
                <div class="p-4 border-b bg-white">
                    <div class="flex justify-between items-center mb-2">
                        <label class="text-xs font-bold text-slate-500">키워드 검색</label>
                        <button onclick="NurseMacroApp.showCreateForm()" class="text-xs bg-blue-600 text-white px-3 py-1.5 rounded hover:bg-blue-700 font-bold transition shadow-sm flex items-center gap-1">
                            <i class="fas fa-plus"></i> 신규 생성
                        </button>
                    </div>
                    <div class="relative">
                        <input type="text" id="macroSearchInput" 
                               class="w-full border border-slate-300 rounded-md pl-3 pr-10 py-2 text-sm outline-none focus:border-blue-500 transition" 
                               placeholder="예: 낙상, 수술, 통증..."
                               onkeyup="if(window.event.keyCode===13) NurseMacroApp.search()">
                        <i class="fas fa-search absolute right-3 top-2.5 text-slate-400 cursor-pointer hover:text-blue-600" onclick="NurseMacroApp.search()"></i>
                    </div>
                </div>
                <div id="macroListContainer" class="flex-1 overflow-y-auto p-3 space-y-2"></div>
            </div>

            <div class="w-7/12 relative bg-white">
                
                <div id="viewMode" class="absolute inset-0 p-6 flex flex-col">
                    <label class="text-xs font-bold text-slate-500 mb-2 block">선택된 매크로 내용</label>
                    <div class="flex-1 border border-slate-200 rounded-lg p-5 bg-slate-50 overflow-y-auto mb-4 shadow-inner relative group">
                        <p id="previewText" class="text-slate-600 text-sm whitespace-pre-wrap leading-relaxed">좌측 목록에서 템플릿을 선택하세요.</p>
                        <button onclick="navigator.clipboard.writeText(document.getElementById('previewText').innerText); alert('복사되었습니다.');" 
                                class="absolute top-2 right-2 text-slate-300 hover:text-blue-500 opacity-0 group-hover:opacity-100 transition">
                            <i class="far fa-copy"></i>
                        </button>
                    </div>
                    <div class="bg-blue-50 text-blue-700 text-xs p-3 rounded-md mb-4 flex items-start gap-2 border border-blue-100">
                        <i class="fas fa-info-circle mt-0.5"></i>
                        <span>[문구 적용] 버튼을 클릭하면 차트에 내용이 추가됩니다.</span>
                    </div>
                    <div class="flex justify-end gap-2">
                        <button type="button" onclick="NurseMacroApp.closeModal()" class="px-4 py-2 text-slate-600 hover:bg-slate-100 rounded text-sm transition">닫기</button>
                        <button type="button" onclick="NurseMacroApp.applyMacro()" class="px-6 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded font-bold shadow-sm transition">
                            문구 적용
                        </button>
                    </div>
                </div>

                <div id="createMode" class="absolute inset-0 p-6 flex flex-col bg-white hidden z-10 animate-fade-in">
                    <div class="flex justify-between items-center mb-4 border-b pb-2">
                        <h4 class="font-bold text-slate-800">새 매크로 등록</h4>
                        <button onclick="NurseMacroApp.hideCreateForm()" class="text-sm text-slate-400 hover:text-red-500">
                            <i class="fas fa-times"></i> 취소
                        </button>
                    </div>
                    <div class="flex flex-col flex-1 gap-4">
                        <div>
                            <label class="block text-sm font-bold text-slate-700 mb-1">제목 (키워드) <span class="text-red-500">*</span></label>
                            <input type="text" id="newMacroName" class="w-full border-b-2 border-slate-200 p-2 text-sm font-bold focus:border-blue-500 outline-none transition" placeholder="예: [퇴원] 퇴원 생활 안내">
                        </div>
                        <div class="flex-1 flex flex-col relative">
                            <label class="block text-sm font-bold text-slate-700 mb-1">매크로 내용 <span class="text-red-500">*</span></label>
                            <textarea id="newMacroContent" class="flex-1 w-full border border-slate-300 rounded-lg p-4 text-sm focus:border-blue-500 outline-none resize-none leading-relaxed mb-12" placeholder="내용을 입력하세요."></textarea>
                            <div class="absolute bottom-0 right-0 left-0 p-2 bg-gradient-to-t from-white via-white to-transparent rounded-b-lg flex justify-end">
                                <button type="button" onclick="NurseMacroApp.saveNewMacro()" class="flex items-center gap-2 px-5 py-2.5 bg-blue-600 hover:bg-blue-700 text-white rounded-md font-bold shadow-md transition transform hover:-translate-y-0.5">
                                    <i class="fas fa-save"></i> 매크로 저장하기
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</div>

<script>
    const NurseMacroApp = {
        employeeNo: 25123903, 
        macroType: '002', 
        selectedContent: '', 

        // 1. [즉시 저장] 텍스트 입력 후 '매크로 저장' 버튼 클릭 시 실행
        quickRegister: function() {
            const textarea = document.getElementById('note-textarea');
            const content = textarea ? textarea.value : '';

            if (!content || !content.trim()) {
                alert("저장할 내용이 없습니다.");
                if(textarea) textarea.focus();
                return;
            }

            // 제목 자동 생성 (앞 15글자)
            const autoTitle = content.length > 15 ? content.substring(0, 15) + "..." : content;

            axios.post('/api/macro/add', {
                macroName: autoTitle,       
                macroContent: content,      
                macroType: this.macroType,
                employeeNo: this.employeeNo
            })
            .then(res => {
                alert("매크로가 저장되었습니다.");
            })
            .catch(err => {
                console.error("저장 실패:", err);
                alert("저장 중 오류가 발생했습니다.");
            });
        },

        // 2. 모달 열기 (에러 방지 코드 추가됨)
        openModal: function() {
            const modal = document.getElementById('macroModal');
            if(modal) {
                modal.classList.remove('hidden');
                modal.classList.add('flex');
                this.hideCreateForm(); // 기본 뷰로 초기화
                this.search();
            }
        },

        closeModal: function() {
            const modal = document.getElementById('macroModal');
            if(modal) {
                modal.classList.add('hidden');
                modal.classList.remove('flex');
                this.selectedContent = '';
                const preview = document.getElementById('previewText');
                if(preview) preview.innerText = '좌측 목록에서 템플릿을 선택하세요.';
            }
        },

        // [수정됨] 에러 방지: 요소가 있는지 확인 후 실행
        showCreateForm: function() {
            const viewMode = document.getElementById('viewMode');
            const createMode = document.getElementById('createMode');
            const nameInput = document.getElementById('newMacroName');
            const contentInput = document.getElementById('newMacroContent');

            if(viewMode) viewMode.classList.add('hidden');
            if(createMode) createMode.classList.remove('hidden');
            
            if(nameInput) {
                nameInput.value = '';
                nameInput.focus();
            }
            // quickRegister가 아닐 때는 내용 초기화
            if(contentInput && !contentInput.value) {
                contentInput.value = '';
            }
        },

        // [수정됨] 에러 방지: 요소가 있는지 확인 후 실행
        hideCreateForm: function() {
            const createMode = document.getElementById('createMode');
            const viewMode = document.getElementById('viewMode');

            if(createMode) createMode.classList.add('hidden');
            if(viewMode) viewMode.classList.remove('hidden');
        },

        // 3. 모달 내부 저장 기능
        saveNewMacro: function() {
            const nameInput = document.getElementById('newMacroName');
            const contentInput = document.getElementById('newMacroContent');
            
            const name = nameInput ? nameInput.value : '';
            const content = contentInput ? contentInput.value : '';

            if(!name.trim()) { alert("제목을 입력해주세요."); if(nameInput) nameInput.focus(); return; }
            if(!content.trim()) { alert("내용을 입력해주세요."); if(contentInput) contentInput.focus(); return; }

            axios.post('/api/macro/add', {
                macroName: name,
                macroContent: content,
                macroType: this.macroType,
                employeeNo: this.employeeNo
            })
            .then(res => {
                alert("매크로가 저장되었습니다.");
                this.hideCreateForm();
                this.search(name);
            })
            .catch(err => {
                console.error("저장 오류:", err);
                alert("저장 실패");
            });
        },

        // 4. 목록 조회
        search: function(autoSelectName = null) {
            const keywordEl = document.getElementById('macroSearchInput');
            const container = document.getElementById('macroListContainer');
            const keyword = keywordEl ? keywordEl.value : '';
            
            if(container) container.innerHTML = `<div class="p-10 text-center text-gray-400 text-sm">로딩 중...</div>`;
            
            axios.get('/api/macro/list', {
                params: {
                    employeeNo: this.employeeNo,
                    macroType: this.macroType,
                    keyword: keyword
                }
            })
            .then(res => {
                const list = res.data;
                if(container) {
                    container.innerHTML = '';
                    if(!list || list.length === 0) {
                        container.innerHTML = `<div class="p-10 text-center text-gray-400 text-sm">데이터가 없습니다.</div>`;
                        return;
                    }

                    list.forEach(item => {
                        const div = document.createElement('div');
                        div.className = "p-3 border rounded-lg bg-white cursor-pointer hover:border-blue-400 hover:shadow-sm transition group mb-1";
                        
                        // 색상 로직
                        const formatTitle = (title) => {
                            if (!title) return "제목 없음";
                            const match = title.match(/^(\[.*?\])(.*)/);
                            if (match) {
                                const tag = match[1];
                                const rest = match[2];
                                let colorClass = "text-blue-600";
                                if (tag.includes("안전") || tag.includes("낙상")) colorClass = "text-orange-600";
                                if (tag.includes("수술") || tag.includes("응급")) colorClass = "text-red-600";
                                return `<span class="\${colorClass} font-bold mr-1">\${tag}</span>\${rest}`;
                            }
                            return title;
                        };

                        div.innerHTML = `
                            <div class="font-bold text-sm text-slate-700 group-hover:text-blue-600 mb-1 truncate">
                                \${formatTitle(item.macroName)}
                            </div>
                            <div class="text-xs text-slate-500 truncate pl-2 border-l-2 border-slate-200">\${item.macroContent}</div>
                        `;
                        div.onclick = () => {
                            this.hideCreateForm();
                            Array.from(container.children).forEach(el => el.classList.remove('border-blue-500', 'bg-blue-50', 'ring-1', 'ring-blue-500'));
                            div.classList.add('border-blue-500', 'bg-blue-50', 'ring-1', 'ring-blue-500');
                            
                            this.selectedContent = item.macroContent;
                            const preview = document.getElementById('previewText');
                            if(preview) preview.innerText = item.macroContent;
                        };
                        container.appendChild(div);

                        if(autoSelectName && item.macroName === autoSelectName) {
                            div.click();
                            div.scrollIntoView({ behavior: "smooth", block: "center" });
                        }
                    });
                }
            })
            .catch(err => {
                console.error(err);
                if(container) container.innerHTML = `<div class="text-center text-red-400 text-sm mt-4">오류 발생</div>`;
            });
        },

        // 5. 문구 적용
        applyMacro: function() {
            if(!this.selectedContent) {
                alert("적용할 템플릿을 선택해주세요.");
                return;
            }
            const textarea = document.getElementById('note-textarea');
            if(textarea) {
                const current = textarea.value;
                textarea.value = current + (current ? "\n" : "") + this.selectedContent;
                textarea.scrollTop = textarea.scrollHeight;
            }
            this.closeModal();
        }
    };
</script>