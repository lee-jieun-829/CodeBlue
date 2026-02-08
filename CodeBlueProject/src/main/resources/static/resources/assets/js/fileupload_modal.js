/** =================================
 * fileupload.js
 * auth : Been Daye
 * date : 2026-01-25
 ==================================== */

 /**
  * 파일 업로드 기능 
  * - 클릭하여 파일 선택
  * - 드래그 앤 드롭
  * - 다중 파일 업로드
  * - 파일 삭제
  * - 항목별 파일 관리
  */

// 항목별 파일 저장소 { examItemId: [files] }
let filesByExamItem = {};
// 현재 작업 중인 항목 ID
let currentExamItemId = null;
// 임시 파일 저장소 (모달에서 사용)
let tempFiles = [];

// 파일 크기 포맷 함수 => 사용자에게 파일 크기를 보기 좋게 표시하기 위함
function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes'; // 0바이트 처리
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k)); // 단위 인덱스 계산 (0: Bytes, 1: KB, 2: MB, 3: GB)
    return Math.round(bytes / Math.pow(k, i) * 100) / 100 + ' ' + sizes[i]; // 소수점 둘째 자리까지 표시 (반올림, 100 곱하고 나누기, 100, 예: 1.2345 -> 1.23)

    // Math.log(bytes) / Math.log(k) => bytes를 k진법으로 변환한 값의 로그 (밑이 k인 로그)
    // Math.pow(k, i) => k의 i제곱 (예: 1024^2 = 1048576)
}

// 파일 아이템 HTML 생성
function createFileItemHTML(file, index) {
    return `
        <div class="file-item" data-index="${index}">
            <div class="file-item-info">
                <i class="file-item-icon icon icon-file"></i>
                <div class="file-item-details">
                    <div class="file-item-name">${file.name}</div>
                    <div class="file-item-size">${formatFileSize(file.size)}</div>
                </div>
            </div>
            <div class="file-item-actions">
                <button class="file-item-remove" onclick="removeFile(${index})">
                    <i class="icon icon-x"></i>
                </button>
            </div>
        </div>
    `;
}

// 모달의 파일 목록 업데이트
function updateModalFileList() {
    const fileList = document.querySelector('#fileList');
    
    if (!fileList) return;
    
    if (tempFiles.length === 0) { // 파일이 없으면 숨김
        fileList.innerHTML = '';
        fileList.style.display = 'none';
        return;
    }
    
    fileList.style.display = 'flex';
    fileList.innerHTML = tempFiles
        .map((file, index) => createFileItemHTML(file, index)) // map으로 각 파일에 대해 HTML 생성
        .join(''); // join으로 배열을 문자열로 변환. 예: ['a','b','c'] ->'abc'
    
    // 파일 개수 업데이트
    updateModalFileCount();
}

// 모달 파일 개수 업데이트
function updateModalFileCount(){
	const countElement = document.querySelector('#modalFileCount');
	
    if (countElement) { // countElement가 존재하면
        countElement.textContent = tempFiles.length; // tempFiles의 갯수를 문자로 삽입
    }
}

// 모달에서 파일 삭제
function removeFile(index) {
    tempFiles.splice(index, 1); // 인덱스 위치에서 1개 요소 제거. splice(위치, 개수). 예: splice(2,1) => 2번째 인덱스 요소 1개 제거 
    updateModalFileList(); // 파일 목록 업데이트. 왜냐하면 인덱스가 바뀌었기 때문
}

// 파일 추가 (중복 체크)
function addFilesToModal(files) {
	// FileList를 배열로 변환하여 추가
	// Array.from() 메서드는 유사 배열 객체나 반복 가능한 객체를 얕게 복사하여 새로운 배열 인스턴스를 만듬
    const newFiles = Array.from(files);
    
    newFiles.forEach(newFile => {
		// 배열.some() 메서드는 배열 내의 어떤 요소라도 주어진 판별 함수를 통과하는지 테스트(하나라도 true 반환함)
        const isDuplicate = tempFiles.some(
            existingFile => 
                existingFile.name === newFile.name && 
                existingFile.size === newFile.size
        );
        
        if (!isDuplicate) {
            tempFiles.push(newFile); // 중복이 아니면 추가(파일 객체, 배열 마지막에 추가됨)
        } else {
            console.log(`중복 파일 제외: ${newFile.name}`);
        }
    });
    
    updateModalFileList();
}

// 모달 열기 (항목별)
function openUploadModal(examItemId, itemInfo) {
    currentExamItemId = examItemId;
    
    // 기존에 저장된 파일이 있으면 불러오기
    tempFiles = filesByExamItem[examItemId] ? [...filesByExamItem[examItemId]] : [];
    
    // 모달 타이틀 업데이트
    const modalTitle = document.querySelector('#uploadModalTitle');
    const modalSubtitle = document.querySelector('#uploadModalSubtitle');
    
    if (modalTitle && itemInfo) {
        modalTitle.textContent = `${itemInfo.examName} - ${itemInfo.site} ${itemInfo.laterality}`;
    }
    if (modalSubtitle) {
        modalSubtitle.textContent = '촬영 이미지를 업로드하세요';
    }
    
    // 파일 목록 업데이트
    updateModalFileList();
    
    // 모달 표시
    const modal = document.querySelector('#uploadModal');
    if (modal) {
        modal.style.display = 'flex';
    }
}

// 모달 닫기
function closeUploadModal() {
    const modal = document.querySelector('#uploadModal');
    if (modal) {
        modal.style.display = 'none';
    }
    
    // 임시 파일 초기화
    tempFiles = [];
    currentExamItemId = null;
}

// 모달에서 파일 저장
function saveModalFiles() {
	if (currentExamItemId === null) {
        alert('항목 정보가 없습니다.');
        return;
    }
    
    // 현재 항목에 파일 저장
    filesByExamItem[currentExamItemId] = [...tempFiles];
    
    // 테이블의 파일 개수 업데이트
    updateTableFileCount(currentExamItemId, tempFiles.length);
    
    // 모달 닫기
    closeUploadModal();
}

// 테이블의 파일 개수 업데이트
function updateTableFileCount(examItemid, count){
	const fileCountCell = document.querySelector(`[data-exam-item="${examItemid}"] .file-count`);
    if (fileCountCell) { // 한 검사항목의 파일갯수 정보를 넣을 공간이 있는가?
        fileCountCell.textContent = count; // 있다면 count를 삽입
        
        // 상태 배지 업데이트
        const statusBadge = fileCountCell.closest('tr').querySelector('.status-badge');
        if (statusBadge) {
            if (count === 0) {
                statusBadge.className = 'badge badge-default';
                statusBadge.textContent = '미완료';
            } else {
                statusBadge.className = 'badge badge-success';
                statusBadge.textContent = '완료';
            }
        }
    }
}

// 파일 입력 요소 생성 (모달용)
function createModalFileInput(allowedExtensions = []) {
    const input = document.createElement('input');
    input.type = 'file';
    input.multiple = true;
    input.style.display = 'none';
    input.id = 'modalFileInput';
    
	// 확장자 설정: 배열이 있으면 '.jpg,.png' 형태로 변환, 없으면 '*/*'
    if (allowedExtensions.length > 0) {
        input.accept = allowedExtensions.map(ext => `.${ext.trim()}`).join(',');
    } else {
        input.accept = '*/*';
    }
    
    input.addEventListener('change', (e) => {
        let files = Array.from(e.target.files); // FileList를 배열로 변환
        
        if (files.length > 0) {
			// 확장자 제한이 있을 때 검증 수행
            if (allowedExtensions.length > 0) {
                const filteredFiles = files.filter(file => {
                    const ext = file.name.split('.').pop().toLowerCase();
                    return allowedExtensions.includes(ext);
                });

				// 만약 선택한 파일 중 허용되지 않은 게 섞여 있다면
                if (filteredFiles.length !== files.length) {
                    alert(`허용되지 않은 파일 형식이 포함되어 제외되었습니다.\n(${allowedExtensions.join(', ')}만 가능)`);
                }
				// 필터링된 파일만 추가 (하나도 없으면 실행 안 됨)
                if (filteredFiles.length > 0) {
                    addFilesToModal(filteredFiles);
                }
            } else {
				// 제한이 없으면 바로 추가
                addFilesToModal(files);
            }
        }
		// input  초기화 (같은 파일 다시 선택 가능하도록)
        e.target.value = '';
    });
    
    return input; // 인풋 요소 반환
}


// 파일 입력 요소 생성 (숨겨진 input)
function createFileInput(allowedExtensions = []) {
    const input = document.createElement('input');
    input.type = 'file';
    input.multiple = true;
    input.style.display = 'none';
    
	// 확장자 설정: 배열이 있으면 '.jpg,.png' 형태로 변환, 없으면 '*/*'
	if(allowedExtensions.length > 0){
		input.accept = allowedExtensions.map(ext => `.${ext.trim()}`).join(',');
	} else {
		input.accept = '*/*';
	}
	
	input.addEventListener('change', (e) => {
        let files = Array.from(e.target.files); // FileList를 배열로 변환
        
        if (files.length > 0) {
            // [추가] 확장자 제한이 있을 때 검증 수행
            if (allowedExtensions.length > 0) {
                const filteredFiles = files.filter(file => {
                    const ext = file.name.split('.').pop().toLowerCase();
                    return allowedExtensions.includes(ext);
                });

                // 만약 선택한 파일 중 허용되지 않은 게 섞여 있다면
                if (filteredFiles.length !== files.length) {
                    alert(`허용되지 않은 파일 형식이 포함되어 제외되었습니다.\n(${allowedExtensions.join(', ')}만 가능)`);
                }

                // 필터링된 파일만 추가 (하나도 없으면 실행 안 됨)
                if (filteredFiles.length > 0) {
                    addFilesToModal(filteredFiles);
                }
            } else {
                // 제한이 없으면 바로 추가
                addFilesToModal(files);
            }
        }
        // input 초기화 (같은 파일 다시 선택 가능하도록)
        e.target.value = '';
    });
    
    return input; // 생성된 input 요소 반환
}

// Dropzone 초기화 (모달용)
function init_modalFileUpload(allowedExtensions = []) {
    const dropzone = document.querySelector('.file-dropzone');
    if (!dropzone) return;
    
    // 숨겨진 파일 입력 요소 생성
    const fileInput = createFileInput(allowedExtensions);
    document.body.appendChild(fileInput); // body에 추가하여 폼 전송 시 사용 가능하도록 함
    
    // 클릭 이벤트 - 파일 탐색기 열기
    dropzone.addEventListener('click', () => {
        fileInput.click();
    });
    
    // 드래그 이벤트 - 드롭존 스타일 변경
    dropzone.addEventListener('dragenter', (e) => { // 드롭존 진입
        e.preventDefault(); // 기본 동작 방지 (파일 열기 방지)
        e.stopPropagation(); // 이벤트 버블링 방지 (상위 요소로 이벤트 전파 방지)
        dropzone.classList.add('dragging');
    });
    
    dropzone.addEventListener('dragover', (e) => { // 드롭존 위로 드래그
        e.preventDefault();
        e.stopPropagation();
        dropzone.classList.add('dragging');
    });
    
    dropzone.addEventListener('dragleave', (e) => { // 드롭존 이탈
        e.preventDefault();
        e.stopPropagation();
        dropzone.classList.remove('dragging');
    });
    
    // 드롭 이벤트 - 파일 업로드
    dropzone.addEventListener('drop', (e) => {
        e.preventDefault();
        e.stopPropagation();
        dropzone.classList.remove('dragging');
        
        const files = Array.from(e.dataTransfer.files); // dataTransfer : 드래그 앤 드롭된 데이터 접근.
		
		if(allowedExtensions.length > 0){ // 배열이 있는가??! => 있다!
			const filteredFiles = files.filter(file => {
				const ext = file.name.split('.').pop().toLowerCase(); // pop은 배열의 마지막 요소 접근.
				return allowedExtensions.includes(ext); // 꺼내놓은 ext(포맷)가 허용 확정자 배열에 값이 있는가! (includes는 배열안에 값이 있냐 => true/false)
			});
			
			// 허용되지 않은 파일 포함 여부 확인
			if(filteredFiles.length !== files.length) { // 유효한 확장자를 가진 파일의 개수 !== 사용자가 드래그해서 집어넣은 전체 파일 개수
				alert(`허용되지 않은 파일이 포함되어 있습니다. (${allowedExtensions.join(', ')}만 가능)`);
			}
			
			// 허용된 파일은 추가하기
			if (filteredFiles.length > 0) {
				addFiles(filteredFiles);
			}
		} else { // 파일 확장자 제한이 없을 경우에는
			if (files.length > 0) addFiles(files); // 파일 추가
		}
    });
}

// 특정 항목의 파일 가져오기
function getExamItemFiles(examItemId) {
    return filesByExamItem[examItemId] || [];
}

// 모든 항목의 파일을 FormData로 변환 (서버 전송용)
function getAllFilesFormData() {
    const formData = new FormData();
    
    for (const examItemId in filesByExamItem) {
        const files = filesByExamItem[examItemId];
        files.forEach((file) => {
            formData.append(`files_${examItemId}`, file);
        });
    }
    
    return formData;
}

// 특정 항목의 파일만 FormData로 변환
function getExamItemFormData(examItemId) {
    const formData = new FormData();
    const files = filesByExamItem[examItemId] || [];
    
    files.forEach((file) => {
        formData.append('uploadFiles', file);
    });
    
    return formData;
}

// 모든 파일 초기화
function clearAllFiles() {
    filesByExamItem = {};
    tempFiles = [];
    currentExamItemId = null;
}

// 특정 항목의 파일만 초기화
function clearExamItemFiles(examItemId) {
    filesByExamItem[examItemId] = [];
    updateTableFileCount(examItemId, 0);
}

// 전체 파일 개수 가져오기
function getTotalFileCount() {
    let total = 0;
    for (const examItemId in filesByExamItem) {
        total += filesByExamItem[examItemId].length;
    }
    return total;
}

// 완료된 항목 개수 가져오기 (파일이 2개 이상인 항목)
function getCompletedItemCount() {
    let completed = true;
	if(filesByExamItem.length > 0){
		for (const examItemId in filesByExamItem) {
		    if (filesByExamItem[examItemId].length < 1) {
				completed = false;
				retrun;  
		    }
		}		
	}else {
		completed = false;
	}

    return completed;
}