<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt"%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>공지사항 등록 - SB 정형외과</title>
<link rel="stylesheet"
    href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">

<style>
/* [기존 스타일 유지] */
* { box-sizing: border-box; margin: 0; padding: 0; }
body { font-family: 'Noto Sans KR', 'Malgun Gothic', sans-serif; background-color: #f5f6f8; height: 100vh; display: flex; flex-direction: column; overflow: hidden; }

/* 헤더 & 사이드바 & 공통 패널 */
header { height: 60px; background-color: #fff; border-bottom: 1px solid #ddd; display: flex; align-items: center; justify-content: space-between; padding: 0 20px; flex-shrink: 0; }
.logo { font-size: 20px; font-weight: bold; color: #333; }
.logo span { color: #2962ff; }
.header-icons i { margin-left: 20px; font-size: 18px; color: #555; cursor: pointer; }

.container { display: flex; flex: 1; height: calc(100vh - 60px); }
.sidebar { width: 80px; background-color: #fff; border-right: 1px solid #ddd; display: flex; flex-direction: column; align-items: center; padding-top: 20px; flex-shrink: 0; }
.menu-item { width: 100%; height: 70px; display: flex; flex-direction: column; align-items: center; justify-content: center; color: #666; cursor: pointer; transition: 0.2s; font-size: 12px; }
.menu-item:hover, .menu-item.active { background-color: #e3f2fd; color: #2962ff; border-left: 3px solid #2962ff; }
.menu-item i { font-size: 24px; margin-bottom: 5px; }

.content-area { flex: 1; padding: 20px; display: flex; gap: 20px; overflow-x: auto; }
.panel { background: #fff; border-radius: 12px; box-shadow: 0 2px 10px rgba(0, 0, 0, 0.03); display: flex; flex-direction: column; overflow: hidden; }

/* [패널 1] 서브 메뉴 */
.sub-menu-panel { width: 250px; flex-shrink: 0; padding: 20px; }
.sub-title { font-size: 16px; font-weight: bold; margin-bottom: 15px; border-left: 4px solid #2962ff; padding-left: 10px; color: #333; }
.sub-nav-item { padding: 12px 15px; border-radius: 8px; margin-bottom: 5px; cursor: pointer; font-size: 14px; color: #333; }
.sub-nav-item.active { background-color: #e3f2fd; color: #2962ff; font-weight: bold; display: flex; justify-content: space-between; align-items: center; }

/* [패널 2] 목록 패널 */
.list-panel { width: 400px; flex-shrink: 0; display: flex; flex-direction: column; }
.panel-header { padding: 20px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
.panel-header h2 { font-size: 18px; font-weight: bold; }
.list-content { flex: 1; overflow-y: auto; padding: 15px; background-color: #fff; }
.post-card { border: 1px solid #eee; border-radius: 8px; padding: 15px; margin-bottom: 10px; background: #fff; cursor: pointer; transition: 0.2s; }
.post-card:hover { border-color: #2962ff; box-shadow: 0 4px 12px rgba(41, 98, 255, 0.1); }
.badge { font-size: 11px; padding: 3px 6px; border-radius: 4px; background-color: #e3f2fd; color: #2962ff; margin-bottom: 5px; display: inline-block; }
.badge.general { background-color: #f5f5f5; color: #666; }
.post-title { font-size: 14px; font-weight: bold; margin-bottom: 5px; color: #333; }
.post-meta { font-size: 12px; color: #888; display: flex; justify-content: space-between; }

/* [패널 3] 글쓰기 폼 전용 스타일 */
.write-panel { flex: 1; min-width: 500px; padding: 30px; overflow-y: auto; }
.write-header { margin-bottom: 20px; padding-bottom: 15px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
.write-header h3 { font-size: 20px; font-weight: bold; color: #333; }

/* 입력 폼 스타일 */
.form-group { margin-bottom: 20px; }
.form-label { display: block; font-size: 13px; font-weight: bold; color: #555; margin-bottom: 8px; }
.form-input { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; outline: none; transition: 0.2s; }
.form-input:focus { border-color: #2962ff; box-shadow: 0 0 0 2px rgba(41, 98, 255, 0.1); }
textarea.form-input { resize: none; line-height: 1.6; min-height: 300px; }

/* 파일 업로드 커스텀 */
.file-box { border: 2px dashed #ddd; padding: 20px; text-align: center; border-radius: 8px; color: #888; cursor: pointer; transition: 0.2s; }
.file-box:hover { border-color: #2962ff; background-color: #f8faff; color: #2962ff; }

/* 중요 공지 체크박스 */
.imp-check-label { display: inline-flex; align-items: center; gap: 8px; cursor: pointer; font-size: 14px; font-weight: bold; color: #333; }
.imp-check-label input { width: 18px; height: 18px; accent-color: #2962ff; }

/* 버튼 그룹 */
.btn-group { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; border-top: 1px solid #eee; padding-top: 20px; }
.btn { padding: 10px 25px; border-radius: 6px; font-weight: bold; cursor: pointer; border: none; font-size: 14px; transition: 0.2s; }
.btn-cancel { background: #f1f3f5; color: #495057; }
.btn-cancel:hover { background: #e9ecef; }
.btn-submit { background: #2962ff; color: white; }
.btn-submit:hover { background: #1c44b2; }

/* 스크롤바 */
::-webkit-scrollbar { width: 6px; }
::-webkit-scrollbar-thumb { background: #ccc; border-radius: 10px; }
::-webkit-scrollbar-track { background: transparent; }
</style>
</head>
<body>

    <header>
        <div class="logo"><span>SB</span> 정형외과</div>
        <div class="header-icons">
            <i class="fas fa-home"></i> <i class="fas fa-search"></i> <i class="fas fa-bell"></i>
        </div>
    </header>

    <div class="container">
        <aside class="sidebar">
            <div class="menu-item"><i class="fas fa-chart-bar"></i>통계</div>
            <div class="menu-item"><i class="fas fa-user-md"></i>계정</div>
            <div class="menu-item"><i class="fas fa-keyboard"></i>매크로</div>
            <div class="menu-item active" onclick="location.href='/notice/list'"><i class="fas fa-bullhorn"></i>공지사항</div>
            <div class="menu-item"><i class="fas fa-calendar-alt"></i>일정</div>
        </aside>

        <main class="content-area">

            <section class="panel sub-menu-panel">
                <h3 class="sub-title">게시판 관리</h3>
                <div class="sub-nav-item active">공지사항 관리</div>
            </section>

            <section class="panel list-panel">
                <div class="panel-header">
                    <h2>목록</h2>
                </div>
                <div class="list-content">
                    <c:if test="${empty list}">
                        <div style="text-align: center; padding: 50px; color: #999;">
                            <i class="fas fa-exclamation-circle" style="font-size: 30px; margin-bottom: 10px;"></i>
                            <p>등록된 공지사항이 없습니다.</p>
                        </div>
                    </c:if>

                    <c:forEach items="${list}" var="notice">
                        <div class="post-card" onclick="location.href='/notice/detail?noticeNo=${notice.noticeNo}'">
                            <c:choose>
                                <c:when test="${notice.noticeImportant eq 'IMP'}">
                                    <span class="badge">중요 공지</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge general">일반 공지</span>
                                </c:otherwise>
                            </c:choose>

                            <div class="post-title">
                                <c:out value="${notice.noticeTitle}" />
                            </div>
                            <div class="post-meta">
                                <span><fmt:formatDate value="${notice.noticeRegDate}" pattern="yyyy.MM.dd" /></span>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </section>

            <section class="panel write-panel">
                
                <form action="/notice/insert" method="post" enctype="multipart/form-data">
                    <div class="write-header">
                        <h3>신규 공지 등록</h3>
                    </div>

                    <div class="form-group">
                        <label class="imp-check-label"> 
                            <input type="checkbox" name="noticeImportant" value="IMP"> 
                            <i class="fas fa-star" style="color: orange;"></i> 상단 중요 공지로 설정
                        </label>
                    </div>

                    <div class="form-group">
                        <label class="form-label">제목</label> 
                        <input type="text" name="noticeTitle" class="form-input" placeholder="제목을 입력하세요" required>
                    </div>

                    <div class="form-group">
                        <label class="form-label">내용</label>
                        <textarea name="noticeContent" class="form-input" placeholder="내용을 입력하세요"></textarea>
                    </div>

                    <div class="form-group">
                        <label class="form-label">첨부파일</label>

                        <div class="file-box" onclick="document.getElementById('fileInput').click()">
                            <i class="fas fa-cloud-upload-alt" style="font-size: 24px; margin-bottom: 5px;"></i><br> 
                            <span id="file-desc">클릭하여 파일을 업로드하세요</span>
                        </div>
                        
                        <input type="file" id="fileInput" name="uploadFile" style="display: none;" onchange="showFileName(this)">
                    </div>

                    <div class="btn-group">
                        <button type="button" class="btn btn-cancel" onclick="location.href='/notice/list'">취소</button>
                        <button type="submit" class="btn btn-submit">등록하기</button>
                    </div>
                </form>

            </section>
        </main>
    </div>
    
    <script>
        function showFileName(input) {
            if (input.files && input.files[0]) {
                var fileName = input.files[0].name;
                document.getElementById('file-desc').innerText = fileName;
            } else {
                document.getElementById('file-desc').innerText = "클릭하여 파일을 업로드하세요";
            }
        }
    </script>

    <c:if test="${param.error eq 'true'}">
        <script>
            alert("등록 중 오류가 발생했습니다. 다시 시도해주세요.");
        </script>
    </c:if>

</body>
</html>