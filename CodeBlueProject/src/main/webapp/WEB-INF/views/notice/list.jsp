<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>SB 정형외과 - 공지사항</title>
    <jsp:include page="/WEB-INF/views/common/include/link.jsp" />
    
    <style>
        /* 커스텀 스크롤바 */
        .scrollbar::-webkit-scrollbar { width: 4px; }
        .scrollbar::-webkit-scrollbar-thumb { background-color: #cbd5e1; border-radius: 4px; }
        .scrollbar::-webkit-scrollbar-track { background-color: transparent; }
        
        /* [신규] 파일 업로드 Dropzone 스타일 */
        .file-dropzone {
            border: 2px dashed #cbd5e1;
            border-radius: 0.75rem;
            background-color: #f8fafc;
            padding: 2rem;
            text-align: center;
            cursor: pointer;
            transition: all 0.2s;
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }
        .file-dropzone:hover, .file-dropzone.drag-over {
            border-color: #3b82f6;
            background-color: #eff6ff;
        }
        .file-dropzone-icon {
            width: 48px;
            height: 48px;
            color: #94a3b8;
            margin-bottom: 0.5rem;
        }
        .file-dropzone-title {
            font-size: 0.95rem;
            font-weight: 600;
            color: #475569;
        }
        .file-dropzone-text {
            font-size: 0.8rem;
            color: #94a3b8;
        }

        /* [신규] 파일 리스트 아이템 스타일 */
        .file-list {
            margin-top: 1rem;
            display: flex;
            flex-direction: column;
            gap: 0.5rem;
        }
        .file-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.75rem 1rem;
            background-color: #fff;
            border: 1px solid #e2e8f0;
            border-radius: 0.5rem;
            box-shadow: 0 1px 2px rgba(0,0,0,0.02);
        }
        .file-item-info {
            display: flex;
            align-items: center;
            gap: 0.75rem;
            overflow: hidden;
        }
        .file-item-icon {
            font-size: 1.25rem;
        }
        .file-item-details {
            display: flex;
            flex-direction: column;
            min-width: 0;
        }
        .file-item-name {
            font-size: 0.875rem;
            font-weight: 500;
            color: #334155;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .file-item-size {
            font-size: 0.75rem;
            color: #94a3b8;
        }
        .file-item-remove {
            width: 24px;
            height: 24px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #cbd5e1;
            border-radius: 50%;
            transition: all 0.2s;
            background: none;
            border: none;
            cursor: pointer;
            font-size: 1.1rem;
        }
        .file-item-remove:hover {
            background-color: #fee2e2;
            color: #ef4444;
        }
        .file-item-actions button {
             border:none; background:none; cursor:pointer;
        }
    </style>
</head>

<body class="bg-neutral-100 text-zinc-950">

    <div class="app h-screen w-full flex flex-col">
        <jsp:include page="/WEB-INF/views/common/include/header.jsp" />
        
        <div class="main-container">
            <sec:authorize access="hasRole('ROLE_ADMIN')">
                <jsp:include page="/WEB-INF/views/common/include/left/left_admin.jsp" />
            </sec:authorize>
            <sec:authorize access="!hasRole('ROLE_ADMIN')">
                <jsp:include page="/WEB-INF/views/common/include/left/left_default.jsp" />
            </sec:authorize>

            <main class="main-content overflow-hidden">
                <div class="grid grid-sidebar-lg grid-full-height">
                    
                    <div class="content-area h-full overflow-hidden">
                        <div class="btn-group-justified">
                            <div class="btn-group-left">
                                <div style="font-size: var(--font-lg); font-weight: var(--font-medium); margin-bottom: var(--spacing-xs);">공지사항</div>
                            </div>
                            <div class="btn-group-right">
                             <sec:authorize access="hasRole('ROLE_ADMIN')">  
                             <button onclick="showWriteForm()" class="btn btn-primary btn-sm ">
                                 등록
                             </button>
                             
                                    
                           </sec:authorize>
                           </div>        
                        </div>
                          
                          <div class="form-group">
                             <input id="searchWord" type="text" placeholder="검색어 입력" class="input input-search input-sm" />  
                         </div>
                             
                        <hr class="section-divider"/>
                        
                        <div class="h-full overflow-hidden">
                            <div class="content-area flex flex-col h-full overflow-hidden p-0">
                                <div id="noticeListArea" class="flex-1 overflow-y-auto min-h-0 my-2 pr-2 scrollbar">
                                     <div class="h-full flex flex-col items-center justify-center text-gray-400 gap-2">
                                         <i class="fas fa-spinner fa-spin text-2xl text-blue-500"></i>
                                         <span class="text-sm">데이터를 불러오는 중...</span>
                                     </div>
                                </div>
                            </div>
                        </div>                                                  
                    </div>
                    
                    <div class="content-area flex flex-col h-full min-h-0 overflow-hidden">
                        <div id="detailPanel" class="h-full flex flex-col min-h-0 overflow-hidden relative">                          
                              <div class="box h-full flex items-center justify-center border-0 shadow-none bg-transparent">
                                  <div class="empty-state empty-state-sm">
                                      <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                          <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path>
                                          <polyline points="13 2 13 9 20 9"></polyline>
                                      </svg>
                                      <div class="empty-state-title">선택된 공지사항이 없습니다</div>
                                      <div class="empty-state-description">목록에서 게시물을 선택하거나 신규 등록을 진행하세요.</div>
                                  </div>
                              </div>                 
                        </div>
                    </div>                  
                </div>
            </main>
        </div>
    </div>

    <script>
        $(document).ready(function() {
            loadNoticeList();
            $('#searchWord').on('keyup', function() {
                loadNoticeList($(this).val());
            });
        });

        // 파일 드롭존 및 미리보기 이벤트 핸들러
        $(document).on('change', 'input[name="files"]', function(e) {
            const files = e.target.files;
            // .file-dropzone의 형제 요소인 .file-list를 찾음
            const $previewList = $(this).closest('.file-dropzone').next('.file-list');
            $previewList.empty();
            
            if(files.length > 0) {
                $.each(files, function(i, file) {
                    let html = `
                        <div class="file-item">
                            <div class="file-item-info">
                                <div class="file-item-icon">📄</div>
                                <div class="file-item-details">
                                    <div class="file-item-name">\${file.name}</div>
                                    <div class="file-item-size">\${formatBytes(file.size)}</div>
                                </div>
                            </div>
                            <div class="file-item-actions">
                                <button type="button" class="file-item-remove" title="제거">×</button>
                            </div>
                        </div>
                    `;
                    $previewList.append(html);
                });
            }
        });
        
        // 새로 추가된 파일 목록에서 X 버튼 클릭 시 (UI에서만 제거, 실제 input 초기화는 필요 시 추가 구현)
        $(document).on('click', '.file-list .file-item-remove', function() {
            $(this).closest('.file-item').remove();
            // 주의: input[type=file]은 개별 파일 삭제가 불가능하므로, 실제 로직 구현 시 DataTransfer 등을 사용해야 함.
            // 여기서는 UI 삭제만 처리하고, 필요 시 input 값을 초기화하는 방식을 씁니다.
            if($('.file-list').children().length === 0) {
                $('input[name="files"]').val(''); 
            }
        });

        //=========================================
        //   1. 목록 조회
        //  ========================================= 
        function loadNoticeList(keyword = '') {
            axios.get('/admin/notice/listData')
                .then(function(response) {
                    const data = response.data;
                    const filteredData = data.filter(n => {
                        return !keyword || n.noticeTitle.toLowerCase().includes(keyword.toLowerCase());
                    });

                    if (!filteredData || filteredData.length === 0) {
                        $('#noticeListArea').html(`
                            <div class="h-full flex items-center justify-center">
                                <div class="empty-state empty-state-sm">
                                    <div class="empty-state-title">검색 결과가 없습니다</div>
                                </div>
                            </div>
                        `);
                        return;
                    }

                    filteredData.sort((a, b) => {
                        if (a.noticeImportant === 'Y' && b.noticeImportant !== 'Y') return -1;
                        if (a.noticeImportant !== 'Y' && b.noticeImportant === 'Y') return 1;
                        return b.noticeNo - a.noticeNo;
                    });

                    let finalHtml = '';
                    $.each(filteredData, function(i, notice) {
                        const isImportant = notice.noticeImportant === 'Y';
                        let dateObj = new Date(notice.noticeRegDate);
                        let dateStr = dateObj.toLocaleDateString();
                        
                        let badgeHtml = isImportant 
                            ? `<span class="badge badge-danger">● 중요</span>` 
                            : `<span class="badge badge-default">일반</span>`;                       
                        let writerName = notice.adminName ? notice.adminName : '관리자';                         
                        let fileIcon = (notice.fileNo) ? '<span>📁</span>' : '';

                        finalHtml += `
                            <div class="box box-bordered box-shadow flex flex-col justify-center items-start gap-1.5 mb-3 cursor-pointer hover:bg-blue-50/30 transition-colors p-4" 
                                 onclick="loadDetail(\${notice.noticeNo})">
                                <div class="w-full flex justify-between items-center mb-1">
                                    \${badgeHtml}
                                    <span style="font-size: var(--font-xs); color: var(--color-text-secondary);">\${dateStr}</span>
                                </div>                      
                                <div class="break-all whitespace-normal leading-snug w-full truncate" style="font-size: var(--font-base); font-weight: 600; color: var(--color-text-primary);">
                                    \${notice.noticeTitle}
                                </div>
                                <div class="w-full flex justify-between items-end mt-1">
                                    <p class="flex items-center gap-1" style="font-size: var(--font-sm); color: var(--color-text-secondary);">
                                        <i class="fas fa-user-circle text-gray-300"></i>
                                        <span>👤\${writerName} </span>\${fileIcon}
                                    </p>
                                    
                                </div>
                            </div>
                        `;
                    });
                    $('#noticeListArea').html(finalHtml);
                })
                .catch(function(error) { console.error('Error:', error); });
        }

        /* =========================================
           2. 상세 조회
           ========================================= */
        function loadDetail(noticeNo) {
            axios.get('/admin/notice/detail/' + noticeNo)
                .then(function(response) {
                    const notice = response.data;
                    let dateObj = new Date(notice.noticeRegDate);
                    let dateStr = dateObj.toLocaleDateString();

                    // 파일 리스트 (요청하신 file-item 스타일 적용)
                    let fileHtml = '';
                    if(notice.fileList && notice.fileList.length > 0) {
                        let fileItemsStr = '';
                        notice.fileList.forEach(function(file) {
                            if(!file.attachmentDetailNo) return;
                            fileItemsStr += `
                            	<div class="file-item">
                                <div class="file-item-info">
                                    <div class="file-item-icon">📄</div>
                                    <div class="file-item-details">
                                        <div class="file-item-name">\${file.attachmentDetailMime}</div>
                                        <div class="file-item-size">\${file.attachmentDetailFancysize}</div>
                                    </div>
                                </div>
                                
                                <div class="file-item-actions">
                                    <button type="button" onclick="fileDownload(\${file.attachmentDetailNo})">
                                         <img src="/resources/assets/images/icon/download.svg" alt="다운로드" width="20" height="20">
                                    </button>
                                </div>
                            </div>
                            `;
                        });
                        fileHtml = `
                            <div class="mt-6 pt-4 border-t border-dashed border-gray-200 flex flex-col">
                                <h3 style="font-size: var(--font-sm); font-weight: bold; color: var(--color-text-secondary); margin-bottom: 8px;">
                                    첨부파일 <span class="text-blue-500">\${notice.fileList.length}</span>
                                </h3>
                                <div class="file-list flex-1 overflow-y-auto scrollbar" style="max-height: 150px;">\${fileItemsStr}
                                </div>                            
                            </div>`;
                    }

                    let badge = notice.noticeImportant === 'Y'
                        ? '<span class="badge badge-danger">● 중요</span>'
                        : '<span class="badge badge-default">일반</span>';
                    
                    // [중요] 하단 고정 Footer (buttons)
                    // flex-shrink-0을 주어 스크롤 영역 밖에서 항상 보이게 처리
                    let actionButtons = `
                        <div class="card-footer p-4 border-t border-gray-100 flex justify-end gap-2 bg-gray-50 flex-shrink-0">
                            <button class="btn btn-white border hover:bg-red-50 hover:border-red-200 hover:text-red-500" onclick="deleteNotice(\${notice.noticeNo})">
                                <i class="far fa-trash-alt mr-1"></i> 삭제
                            </button>
                            <button class="btn btn-primary" onclick="showUpdateForm(\${notice.noticeNo})">
                                <i class="far fa-edit mr-1"></i> 수정
                            </button>
                        </div>
                    `;

                    let html = `
                        <div class="card h-full flex flex-col shadow-sm border border-gray-200 bg-white rounded-lg overflow-hidden">
                            <div class="card-header block border-b border-gray-100 p-6 pb-4 flex-shrink-0">   
                                <div class="flex justify-between items-start mb-3">
                                    \${badge}
                                    <button onclick="resetDetailPanel()" class="text-gray-400 hover:text-gray-600 transition">
                                        <i class="fas fa-times text-lg"></i>
                                    </button>
                                </div>
                                <div>  	
                                    <h1 class="text-xl font-bold text-gray-800 leading-snug mb-2">\${notice.noticeTitle}</h1>
                                    <div class="flex items-center gap-3 text-xs text-gray-400">
                                        <span class="flex items-center gap-1"><i class="fas fa-user-circle"></i> \${notice.employeeName || '관리자'}</span>
                                        <span class="w-px h-3 bg-gray-200"></span>
                                        <span class="flex items-center gap-1"><i class="far fa-calendar"></i> \${dateStr}</span>
                                    </div>                               
                                </div>                            
                            </div>                        
                            <div class="card-body overflow-y-auto scrollbar p-6 flex-1 min-h-0">
                                <div class="whitespace-pre-wrap leading-relaxed text-sm text-gray-700">\${notice.noticeContent}</div>
                                \${fileHtml}
                            </div>
                            <sec:authorize access="hasRole('ROLE_ADMIN')">
                                \${actionButtons}
                            </sec:authorize>
                        </div>
                    `;
                    $('#detailPanel').html(html);
                })
                .catch(function(error) { console.error(error); });
        }

        /* =========================================
           3. 등록 폼 (Dropzone 적용)
           ========================================= */
        function showWriteForm() {
            let html = `
                <div class="card h-full flex flex-col bg-white border border-gray-200 shadow-sm rounded-lg overflow-hidden">
                    <div class="card-header flex justify-between items-center border-b border-gray-100 p-5 flex-shrink-0">
                        <div class="font-bold text-lg text-gray-800 flex items-center gap-2">
                            <i class="fas fa-pen-square text-blue-500"></i> 공지사항 등록
                        </div>
                        <button onclick="resetDetailPanel()" class="text-gray-400 hover:text-gray-600"><i class="fas fa-times"></i></button>
                    </div>
                    
                    <div class="card-body overflow-y-auto scrollbar p-6 flex-1 min-h-0">
                        <form id="noticeForm" enctype="multipart/form-data" class="flex flex-col gap-5">
                            <div class="form-group">
                                <label class="text-xs font-bold text-gray-500 mb-1 block">제목 <span class="text-red-500">*</span></label>
                                <input type="text" name="noticeTitle" class="input input-bordered w-full" placeholder="제목을 입력하세요" required>
                            </div>
                            
                            <div class="form-group">
                                <label class="text-xs font-bold text-gray-500 mb-1 block">공지 유형</label>
                                <select name="noticeImportant" class="input input-bordered w-40">
                                    <option value="N">일반 공지</option>
                                    <option value="Y">중요 공지</option>
                                </select>
                            </div>

                            <div class="form-group flex-1 flex flex-col">
                                <label class="text-xs font-bold text-gray-500 mb-1 block">내용 <span class="text-red-500">*</span></label>
                                <textarea name="noticeContent" class="textarea textarea-bordered w-full h-64 resize-none flex-1" placeholder="내용을 입력하세요" required></textarea>
                            </div>

                            <div class="form-group">
                                <label class="text-xs font-bold text-gray-500 mb-1 block">첨부파일</label>
                                <div class="file-dropzone">
                                    <input type="file" name="files" id="fileUpload" class="absolute inset-0 w-full h-full opacity-0 cursor-pointer" multiple>
                                    <svg class="file-dropzone-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12"></path>
                                    </svg>
                                    <div class="file-dropzone-title">파일을 여기에 드롭하세요</div>
                                    <div class="file-dropzone-text">또는 클릭하여 파일 선택</div>
                                </div>
                                <div class="file-list"></div>
                            </div>
                        </form>
                    </div>

                    <div class="card-footer p-4 border-t border-gray-100 bg-gray-50 flex justify-end gap-2 flex-shrink-0">
                        <button type="button" class="btn btn-white border" onclick="resetDetailPanel()">취소</button>
                        <button type="button" class="btn btn-primary" onclick="submitNotice()">등록완료</button>
                    </div>
                </div>
            `;
            $('#detailPanel').html(html);
        }

        /* 등록 처리 */
        function submitNotice() {
            let formData = new FormData(document.getElementById("noticeForm"));
            if(!formData.get("noticeTitle").trim() || !formData.get("noticeContent").trim()){
                alert("제목과 내용은 필수입니다."); return;
            }
            axios.post('/admin/notice/insert', formData, { headers: { 'Content-Type': 'multipart/form-data' } })
                .then(function(res) {
                    if(res.data === "SUCCESS") { alert("등록되었습니다."); loadNoticeList(); resetDetailPanel(); }
                    else { alert("등록 실패"); }
                }).catch(function() { alert("서버 오류가 발생했습니다."); });
        }

        /* 수정 폼 */
        function showUpdateForm(noticeNo) {
            axios.get('/admin/notice/detail/' + noticeNo).then(function(response) {
                const notice = response.data;
                
                // 기존 파일 목록
                let existingFilesHtml = '';
                if(notice.fileList && notice.fileList.length > 0) {
                     notice.fileList.forEach(f => {
                        if(!f.attachmentDetailNo) return;
                        existingFilesHtml += `
                        <div class="file-item">
                            <div class="file-item-info">
                                <div class="file-item-icon">📎</div>
                                <div class="file-item-details">
                                    <div class="file-item-name">\${f.attachmentDetailMime || f.attachmentDetailName}</div>
                                    <div class="file-item-size">\${formatBytes(f.attachmentDetailSize)}</div>
                                </div>
                            </div>
                            <div class="file-item-actions">
                                <button type="button" class="file-item-remove" onclick="removeFileUI(this, \${f.attachmentDetailNo})">×</button>
                            </div>
                        </div>`;
                     });
                }

                let html = `
                    <div class="card h-full flex flex-col bg-white border border-gray-200 shadow-sm rounded-lg overflow-hidden">
                         <div class="card-header flex justify-between items-center border-b border-gray-100 p-5 flex-shrink-0">
                            <div class="font-bold text-lg text-gray-800 flex items-center gap-2">
                                <i class="fas fa-edit text-blue-500"></i> 공지사항 수정
                            </div>
                            <button onclick="loadDetail(\${notice.noticeNo})" class="text-gray-400 hover:text-gray-600"><i class="fas fa-times"></i></button>
                        </div>
                        <div class="card-body overflow-y-auto scrollbar p-6 flex-1 min-h-0">
                            <form id="updateForm" enctype="multipart/form-data" class="flex flex-col gap-5">
                                <input type="hidden" name="noticeNo" value="\${notice.noticeNo}">
                                <div class="form-group">
                                    <label class="text-xs font-bold text-gray-500 mb-1 block">제목</label>
                                    <input type="text" name="noticeTitle" class="input input-bordered w-full" value="\${notice.noticeTitle}" required>
                                </div>
                                <div class="form-group">
                                    <label class="text-xs font-bold text-gray-500 mb-1 block">유형</label>
                                    <select name="noticeImportant" class="input input-bordered w-40">
                                        <option value="N" \${notice.noticeImportant == 'N' ? 'selected' : ''}>일반 공지</option>
                                        <option value="Y" \${notice.noticeImportant == 'Y' ? 'selected' : ''}>중요 공지</option>
                                    </select>
                                </div>
                                <div class="form-group flex-1 flex flex-col">
                                    <label class="text-xs font-bold text-gray-500 mb-1 block">내용</label>
                                    <textarea name="noticeContent" class="textarea textarea-bordered w-full h-64 resize-none flex-1" required>\${notice.noticeContent}</textarea>
                                </div>
                                <div class="form-group">
                                    <label class="text-xs font-bold text-gray-500 mb-1 block">첨부파일 관리</label>
                                    <div class="file-list mb-3" id="existingFiles">
                                        \${existingFilesHtml}
                                    </div>
                                    <div id="deleteFilesArea"></div>
                                    
                                    <div class="file-dropzone">
                                        <input type="file" name="files" class="absolute inset-0 w-full h-full opacity-0 cursor-pointer" multiple>
                                        <svg class="file-dropzone-icon" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path></svg>
                                        <div class="file-dropzone-title">추가할 파일을 드래그하세요</div>
                                    </div>
                                    <div class="file-list"></div>
                                </div>
                            </form>
                        </div>
                        <div class="card-footer p-4 border-t border-gray-100 bg-gray-50 flex justify-end gap-2 flex-shrink-0">
                            <button type="button" class="btn btn-white border" onclick="loadDetail(\${notice.noticeNo})">취소</button>
                            <button type="button" class="btn btn-primary" onclick="submitUpdate()">수정완료</button>
                        </div>
                    </div>
                `;
                $('#detailPanel').html(html);
            });
        }

        // --- Utils ---
        function deleteNotice(noticeNo) {
             if(confirm('삭제하시겠습니까?')) {
                 axios.post('/admin/notice/delete/' + noticeNo).then(res => {
                     if(res.data === 'SUCCESS') { alert('삭제되었습니다.'); loadNoticeList(); resetDetailPanel(); }
                 });
             }
        }
        function removeFileUI(btn, fileNo) {
            $(btn).closest('.file-item').remove();
            $('#deleteFilesArea').append(`<input type="hidden" name="deleteFileNos" value="\${fileNo}">`);
        }
        function submitUpdate() {
            let formData = new FormData(document.getElementById("updateForm"));
            axios.post('/admin/notice/update', formData, { headers: { 'Content-Type': 'multipart/form-data' } }).then(res => {
                if(res.data === 'SUCCESS') { alert('수정되었습니다.'); loadNoticeList(); loadDetail(formData.get("noticeNo")); }
            });
        }
        function resetDetailPanel() {
            $('#detailPanel').html(`
                <div class="box h-full flex items-center justify-center border-0 shadow-none bg-transparent">
                    <div class="empty-state empty-state-sm">
                        <div class="empty-state-title">선택된 공지사항이 없습니다</div>
                    </div>
                </div>`);
        }
        function fileDownload(no) { location.href = "/admin/notice/download/" + no; }
        function formatBytes(bytes) { if(bytes===0) return '0 Bytes'; const k=1024; const sizes=['Bytes','KB','MB','GB']; const i=Math.floor(Math.log(bytes)/Math.log(k)); return parseFloat((bytes/Math.pow(k,i)).toFixed(2))+' '+sizes[i]; }
    </script>
    
</body>
</html>