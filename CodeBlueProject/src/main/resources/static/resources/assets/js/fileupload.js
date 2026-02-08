/** =================================
 * fileupload.js
 * auth : Been Daye
 * date : 2025-12-30
 ==================================== */

/**
 * 파일 업로드 기능 
 * - 클릭하여 파일 선택
 * - 드래그 앤 드롭
 * - 다중 파일 업로드
 * - 파일 삭제
 */

// 파일 저장소 (실제로는 FormData나 서버로 전송)
let uploadedFiles = [];

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

// 파일 목록 업데이트
function updateFileList() {
    const fileList = document.querySelector('#fileList');
    
    if (uploadedFiles.length === 0) { // 파일이 없으면 숨김
        fileList.innerHTML = '';
        fileList.style.display = 'none';
        return;
    }
    
    fileList.style.display = 'flex';
    fileList.innerHTML = 
		uploadedFiles.map((file, index) => createFileItemHTML(file, index)) // map으로 각 파일에 대해 HTML 생성
        			 .join(''); // join으로 배열을 문자열로 변환. 예: ['a','b','c'] -> 'abc'
}

// 파일 추가
function addFiles(files) {
    // FileList를 배열로 변환하여 추가
    // Arrauy.from() 메서드는 유사 배열 객체나 반복 가능한 객체를 얕게 복사하여 새로운 배열 인스턴스를 만듬
    const newFiles = Array.from(files);
    
    // 중복 파일 체크 (파일명 + 크기로 판단)
    newFiles.forEach(newFile => {
        // 배열.some() 메서드는 배열 내의 어떤 요소라도 주어진 판별 함수를 통과하는지 테스트(하나라도 true 반환함)
        const isDuplicate = uploadedFiles.some(
            existingFile => 
                existingFile.name === newFile.name && 
                existingFile.size === newFile.size
        );
        
        if (!isDuplicate) {
            uploadedFiles.push(newFile); // 중복이 아니면 추가(파일 객체, 배열 마지막에 추가됨)
        } else {
            console.log(`중복 파일 제외: ${newFile.name}`);
        }
    });
    
    updateFileList();
}

// 파일 삭제
function removeFile(index) {
    uploadedFiles.splice(index, 1); // 인덱스 위치에서 1개 요소 제거. splice(위치, 개수). 예: splice(2,1) => 2번째 인덱스 요소 1개 제거 
    updateFileList(); // 파일 목록 업데이트. 왜냐하면 인덱스가 바뀌었기 때문
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
                    addFiles(filteredFiles);
                }
            } else {
                // 제한이 없으면 바로 추가
                addFiles(files);
            }
        }
        // input 초기화 (같은 파일 다시 선택 가능하도록)
        e.target.value = '';
    });
    
    return input; // 생성된 input 요소 반환
}

// Dropzone 초기화
function init_fileUpload(allowedExtensions = []) {
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
    
    // 초기 파일 목록 숨기기
    const fileList = document.querySelector('.file-list');
    if (fileList && uploadedFiles.length === 0) {
        fileList.style.display = 'none';
    }
}

// 업로드된 파일 리스트 반환
function getUploadedFiles() {
	return uploadedFiles;
}

// 업로드된 파일을 FormData로 변환 (서버 전송)
function getFormDataUpload(){
	const formData = new FormData();
	uploadedFiles.forEach((file) => {
		formData.append("uploadFiles", file); // key, value
	});
	
	return formData;
}

// 파일 목록 전체 초기화
function clearUploadedFiles() {
	uploadedFiles = [];
	updateFileList();
}