<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<!-- ===== Head 시작 ===== -->
<%@ include file="/WEB-INF/views/common/include/link.jsp" %>
<!-- ===== Head 끝 ===== -->
<title>공통 공지사항</title>
</head>
<body class="bg-neutral-100 text-zinc-950" data-gnb="gnb-notice">
    <div class="app h-screen w-full flex flex-col">
    <!-- ===== Header 시작 ===== -->
	<%@ include file="/WEB-INF/views/common/include/header.jsp" %>
	<!-- ===== Header 끝 ===== -->
	
	<div class="main-container">
	<!-- ===== Sidebar 시작 (각 액터에 따라 sidebar jsp 교체)  ===== -->
		<sec:authorize access="hasRole('ROLE_ADMIN')">
			<%@ include file="/WEB-INF/views/common/include/left/left_admin.jsp" %>
		</sec:authorize>
		<sec:authorize access="hasRole('ROLE_DOCTOR')">
			<%@ include file="/WEB-INF/views/common/include/left/left_doctor.jsp" %>
		</sec:authorize>
		<sec:authorize access="hasRole('ROLE_NURSE_IN') or hasRole('ROLE_NURSE_OUT')">
			<%@ include file="/WEB-INF/views/common/include/left/left_nursing.jsp" %>
		</sec:authorize>
		<sec:authorize access="hasRole('ROLE_PHARMACIST')">
			<%@ include file="/WEB-INF/views/common/include/left/left_pharmacist.jsp" %>
		</sec:authorize>
		<sec:authorize access="hasRole('ROLE_RADIOLOGIST')">
			<%@ include file="/WEB-INF/views/common/include/left/left_radiologist.jsp" %>
		</sec:authorize>
		<sec:authorize access="hasRole('ROLE_THERAPIST')">
			<%@ include file="/WEB-INF/views/common/include/left/left_therapist.jsp" %>
		</sec:authorize>
		<sec:authorize access="hasRole('ROLE_OFFICE')">
			<%@ include file="/WEB-INF/views/common/include/left/left_reception.jsp" %>
		</sec:authorize>		
	<!-- ===== Sidebar 끝 ===== -->
		
		<!-- ===== Main 시작 ===== -->
		<main class="main-content overflow-hidden">
			<div class="grid grid-sidebar-lg grid-full-height"> <!-- main이 2분할 이상일 경우 grid 사이즈 클래스 추가 필요 -->
				<!-- 콘텐츠 영역 -->
										
				<div class="content-area flex flex-col h-full overflow-hidden">
						<!-- 리스트 헤더 -->
						<div class="btn-group-justified">
							<div class="btn-group-left">
								<div style="font-size: var(--font-lg); font-weight: var(--font-medium); margin-bottom: var(--spacing-xs);">공지사항</div>
							</div>
							<div class="btn-group-right">
								<input id="searchWord" type="text" placeholder="검색어를 입력하세요" class="input input-search input-sm" placeholder="Small Input" />
							</div>								
						</div>  
						<hr class="section-divider"/>
						<!-- 공지사항 리스트 출력 -->						
						<div class="h-full overflow-hidden"> 
							<div class="content-area flex flex-col h-full overflow-hidden">
							    <div id="noticeList" class="flex-1 overflow-y-auto min-h-0 my-2 pr-2 scrollbar"></div>
							 </div>
						</div>													
					</div>
					
					<!-- 공지사항 디테일 출력 -->
					<div class="content-area flex flex-col h-full min-h-0 overflow-hidden">
						<div id="noticeDetail" class="box h-full flex flex-col p-0 min-h-0 overflow-hidden justify-center">							
		                      <div class="box">
		                          <div class="empty-state empty-state-sm">
		                              <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
		                                  <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path>
		                                  <polyline points="13 2 13 9 20 9"></polyline>
		                              </svg>
		                              <div class="empty-state-title">선택된 공지사항이 없습니다</div>
		                              <div class="empty-state-description">공지사항을 선택해보세요.</div>
		                          </div>
		                      </div>                 
						</div>
					</div>					
				</div>
			
			
		</main>
		
		<!-- ===== Main 끝 ===== -->
	</div>
	</div>
    <script>
    //검색을 위해 전역변수에 담기
    let allNotices = [];
    
    document.addEventListener("DOMContentLoaded", function() {
        loadNoticeList();
        //검색기능
        document.getElementById('searchWord').addEventListener('keyup', function() {
            const keyword = this.value.trim(); // 검색어 공백 제거
            filterAndRender(keyword);
        });
    });

    function loadNoticeList() {      	
        axios.get('/notice/select')
            .then(function (response) {
            	allNotices = response.data;
            	//초기 화면 렌더링
            	filterAndRender('');
            })
            .catch(function (error) {
                console.error('Error fetching notice list:', error);
                document.getElementById('noticeList').innerHTML = 
                    '<div class="p-4 text-center text-red-500">공지사항 목록이 없습니다.</div>';
            });
    }
    
    function filterAndRender(keyword){
    	const listContainer = document.getElementById('noticeList');
        let importHtml = '';
        let commonHtml = '';

        // 키워드가 있으면 필터링, 없으면 전체 데이터 사용
        const filteredData = allNotices.filter(function(notice) {
            if (keyword === '') return true; // 검색어 없으면 다 보여줌
            
            // 제목 또는 날짜에 검색어가 포함되어 있는지 확인 (대소문자 구분 안함)
            return notice.noticeTitle.toLowerCase().includes(keyword.toLowerCase());
        });

        // 데이터가 있을 때 HTML 생성
        if (filteredData && filteredData.length > 0) {
            filteredData.forEach(function(notice) {          
                
                // 파일 아이콘
                let fileIcon = ""; 
                if(notice.fileNo && notice.fileNo > 0) {
                    fileIcon = `<span>📁</span>`;
                }

                // 리스트 아이템 HTML (중요/일반 구분)
                const itemHtml = `
                    <div class="box box-bordered box-shadow flex flex-col justify-center items-start gap-2 mb-3 cursor-pointer hover:bg-neutral-50 transition-colors" onclick="loadDetail(\${notice.noticeNo})">
                        <div class="w-full flex justify-between items-center">
                            \${notice.noticeImportant === 'Y' ? '<span class="badge badge-danger">● 중요</span>' : '<span class="badge badge-default">일반</span>'}
                            <span style="font-size: var(--font-sm); color: var(--color-text-secondary);">
                                \${notice.noticeRegDate}
                            </span>
                        </div>						
                        <div class="break-all whitespace-normal leading-snug" style="font-size: var(--font-base); font-weight: 500;">\${notice.noticeTitle}</div>
                        <p class="flex items-center gap-2">
                            <span style="font-size: var(--font-sm); color: var(--color-text-secondary);">👤\${notice.adminName}</span>
                            \${fileIcon}
                        </p>								
                    </div>
                `;

                if(notice.noticeImportant === 'Y') {
                    importHtml += itemHtml;
                } else {
                    commonHtml += itemHtml;
                }
            });

            listContainer.innerHTML = importHtml + commonHtml;

        } else {
            // 검색 결과가 없을 때
            listContainer.innerHTML = `
                <div class="box">
                    <div class="empty-state empty-state-sm">
                        <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path>
                            <polyline points="13 2 13 9 20 9"></polyline>
                        </svg>
                        <div class="empty-state-title">검색 결과 없음</div>
                        <div class="empty-state-description">조건에 맞는 공지사항이 없습니다.</div>
                    </div>
                </div>
            `;
        }
    }
    
    function loadDetail(noticeNo) {
    	
    	
        $.ajax({
            url: '/notice/detail/' + noticeNo,
            type: 'GET',
            dataType: 'json',
            success: function(notice) {
               
                // 파일 영역                
                let fileHtml = '';
                if(notice.fileList && notice.fileList.length > 0) {
                	let fileItemsStr = '';
                	notice.fileList.forEach(function(file) {
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
                		<div class="box box-bordered box-secondary" style="margin: 10px; position: absolute; bottom: 5%; width: 72%;">
                        <h3 style="font-size: var(--font-sm); color: var(--color-text-secondary); margin-bottom: 5px;">
                            첨부파일 (\${notice.fileList.length})
                        </h3>
                        <div class="file-list" style="max-height: 120px; overflow-y: auto;">
                            \${fileItemsStr}
                        </div>
                    </div>`;      
                	
                	
                    
                }
                // 상세 화면 HTML 생성
                let html = "";
                	html=`
                		<div class="card flex-1 overflow-y-auto min-h-0 my-2 pr-2 scrollbar">
                        <div class="card-header" style="display: block;">   
	                        <div class="btn-group-justified">
		                        <c:choose>
		                    		<c:when test="${notice.noticeImportant} == 'Y'">
		                    			<span class="badge badge-danger btn-group-left">● 중요</span>
		                    		</c:when>
		                    		<c:otherwise>
		                    			<span class="badge badge-default btn-group-left">일반</span>
		                    		</c:otherwise>
		                    	</c:choose>	                            
		                        <button onclick="closeDetail()"class="file-item-remove btn-group-right">×</button>
		                    </div>
		                    
                            <div class="card-title" style="margin-top:10px;">  	
                            	<div style="font-size: var(--font-2xl); font-weight: var(--font-bold);">\${notice.noticeTitle}</div>
                            	<div style="font-size: var(--font-sm); color: var(--color-text-secondary);">👤 \${notice.adminName} (No.\${notice.employeeNo}) &nbsp 📅 \${notice.noticeRegDate}</div>                               
                            </div>                            
                        </div>                        
                        <div class="card-body">\${notice.noticeContent}</div>
                        \${fileHtml}
                    </div>
                `;
                $('#noticeDetail').html(html);
            },
            error: function() {
                alert("상세 정보를 불러올 수 없습니다.");
            }
        });
    }
    
	function fileDownload(attachmentDetailNo){
		location.href = "/admin/notice/download/" + attachmentDetailNo;
	 }
	
	function closeDetail(){
		let html=`
			<div class="box">
	            <div class="empty-state empty-state-sm">
	                <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
	                    <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path>
	                    <polyline points="13 2 13 9 20 9"></polyline>
	                </svg>
	                <div class="empty-state-title">선택된 공지사항이 없습니다</div>
	                <div class="empty-state-description">공지사항을 선택해보세요.</div>
	            </div>
	        </div>    
		`;
		
		$('#noticeDetail').html(html)
	}
    </script>
</body>
</html>