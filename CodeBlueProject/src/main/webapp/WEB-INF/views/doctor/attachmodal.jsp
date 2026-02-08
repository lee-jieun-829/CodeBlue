<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div id="filePreviewModal" class="fixed inset-0 z-50 hidden" aria-labelledby="modal-title" role="dialog" aria-modal="true">
    
    <div class="fixed inset-0 bg-gray-500 bg-opacity-75 transition-opacity" onclick="closeFileModal()"></div>

    <div class="fixed inset-0 z-10 overflow-y-auto">
        <div class="flex min-h-full items-center justify-center p-4 text-center sm:p-0">
            
            <div class="relative transform overflow-hidden rounded-lg bg-white text-left shadow-xl transition-all sm:my-8 w-full sm:max-w-7xl">
                
                <div class="bg-white px-4 pt-5 pb-4 sm:p-6 border-b border-gray-200 flex justify-between items-center">
                    <h3 class="text-lg font-medium text-gray-900" id="modal-title">
                        <i class="icon icon-clipboard-list mr-2"></i>검사 결과 파일
                    </h3>
                    <button type="button" class="bg-white rounded-md text-gray-400 hover:text-gray-500 focus:outline-none" onclick="closeFileModal()">
                        <i class="icon icon-x text-2xl"></i>
                    </button>
                </div>

                <div class="bg-gray-50 px-6 py-6 h-[700px]">
                    <div class="grid grid-cols-12 gap-6 h-full">
                        
                        <div class="col-span-4 flex flex-col bg-white rounded-lg border border-gray-200 h-full shadow-sm">
                            <div class="p-3 bg-gray-100 border-b border-gray-200 font-bold text-sm text-gray-700">
                                첨부 파일 목록
                            </div>
                            <ul id="modalFileList" class="overflow-y-auto flex-1 p-2 space-y-2">
                                </ul>
                        </div>

                        <div class="col-span-8 flex flex-col h-full">
                            <div class="flex justify-between items-center mb-2 px-1">
                                <span class="text-sm font-bold text-gray-800 flex items-center">
                                    <i class="icon icon-monitor mr-2 text-gray-500"></i>
                                    <span id="previewFileName">파일을 선택해주세요</span>
                                </span>
                                <button type="button" id="btnOpenNewWindow" class="btn btn-sm btn-primary hidden" onclick="openCurrentFileInNewWindow()">
                                    <i class="icon icon-external-link mr-1"></i>새 창으로 보기
                                </button>
                            </div>

                            <div class="flex-1 bg-slate-800 rounded-lg flex items-center justify-center overflow-hidden relative border border-gray-400 shadow-inner">
                                <img id="previewImage" src="" alt="미리보기" class="max-w-full max-h-full object-contain hidden">
                                <div id="previewMessage" class="text-gray-400 text-center">
                                    <i class="icon icon-image text-5xl mb-3 opacity-50"></i>
                                    <p class="text-gray-300 font-medium">왼쪽 목록에서 파일을 선택하세요.</p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="bg-gray-50 px-4 py-3 sm:px-6 flex flex-row-reverse border-t border-gray-200">
                    <button type="button" class="btn btn-secondary w-full sm:w-auto text-sm font-medium" onclick="closeFileModal()">
                        닫기
                    </button>
                </div>

            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
//현재 선택된 파일 정보를 저장할 변수
let currentFileUrl = null;

/**
 * [핵심] 파일 모달 열기 함수
 * @param {Array} fileList - [{no: 1, name: 'photo.jpg', url: '/path...'}]
 */
function openFileModal(fileList) {
    const modal = document.getElementById('filePreviewModal');
    const listContainer = document.getElementById('modalFileList');
    const previewImg = document.getElementById('previewImage');
    const previewMsg = document.getElementById('previewMessage');
    const btnNewWindow = document.getElementById('btnOpenNewWindow');
    const titleSpan = document.getElementById('previewFileName');

    // 1. 초기화
    listContainer.innerHTML = ''; 
    previewImg.classList.add('hidden'); 
    previewImg.src = '';
    previewMsg.classList.remove('hidden'); 
    btnNewWindow.classList.add('hidden'); 
    titleSpan.innerText = '파일을 선택해주세요';
    currentFileUrl = null;

    // 2. 리스트 렌더링
    if (!fileList || fileList.length === 0) {
        listContainer.innerHTML = '<li class="text-center text-gray-400 py-4">첨부된 파일이 없습니다.</li>';
    } else {
        fileList.forEach((file, index) => {
            // 확장자로 타입 자동 추론
            const isImage = isImageFile(file.name);
            
            // 리스트 아이템 생성
            const li = document.createElement('li');
            li.className = `p-3 rounded-md cursor-pointer hover:bg-blue-50 border border-gray-100 transition-colors flex items-center gap-3`;
            
            // 클릭 이벤트
            li.onclick = () => {
                // 디자인 활성화
                document.querySelectorAll('#modalFileList li').forEach(el => {
                    el.classList.remove('bg-blue-100', 'border-blue-300', 'text-blue-700');
                });
                li.classList.add('bg-blue-100', 'border-blue-300', 'text-blue-700');

                // 미리보기 함수 호출 (파일객체 + 이미지여부 전달)
                updatePreview(file, isImage);
            };

            // 아이콘 자동 선택
            const iconClass = isImage ? 'icon-image' : 'icon-file-text';
            
            li.innerHTML = `
                <div class="flex-shrink-0 w-8 h-8 rounded bg-white border border-gray-200 flex items-center justify-center text-gray-500">
                    <i class="icon \${iconClass} text-lg"></i>
                </div>
                <div class="flex-1 truncate">
                    <p class="text-sm font-medium truncate">\${file.name}</p>
                    <p class="text-xs text-gray-400">No.\${file.no || (index + 1)}</p>
                </div>
            `;
            listContainer.appendChild(li);

            // 첫 번째 파일 자동 선택
            if (index === 0) li.click();
        });
    }

    modal.classList.remove('hidden');
}

/**
 * 미리보기 업데이트
 */
function updatePreview(file, isImage) {
    const previewImg = document.getElementById('previewImage');
    const previewMsg = document.getElementById('previewMessage');
    const btnNewWindow = document.getElementById('btnOpenNewWindow');
    const titleSpan = document.getElementById('previewFileName');

    currentFileUrl = file.url;
    titleSpan.innerText = file.name;
    btnNewWindow.classList.remove('hidden');

    if (isImage) {
        previewImg.src = file.url;
        previewImg.classList.remove('hidden');
        previewMsg.classList.add('hidden');
    } else {
        previewImg.classList.add('hidden');
        previewMsg.innerHTML = `
            <i class="icon icon-file-text text-5xl text-gray-300 mb-4 opacity-50"></i>
            <p class="text-gray-500 font-medium">미리보기를 지원하지 않는 형식입니다.</p>
            <p class="text-sm text-blue-500 mt-2">우측 상단 '새 창으로 보기'를 이용하세요.</p>
        `;
        previewMsg.classList.remove('hidden');
    }
}

/**
 * 확장자 체크 헬퍼 함수
 */
function isImageFile(fileName) {
    if(!fileName) return false;
    const ext = fileName.split('.').pop().toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].includes(ext);
}

// 닫기, 새창 열기 함수는 기존과 동일
function closeFileModal() { document.getElementById('filePreviewModal').classList.add('hidden'); }
function openCurrentFileInNewWindow() { if (currentFileUrl) window.open(currentFileUrl, '_blank'); }
</script>