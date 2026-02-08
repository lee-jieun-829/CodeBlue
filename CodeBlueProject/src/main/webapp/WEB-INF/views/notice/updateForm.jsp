<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>SB 정형외과 - 공지 수정</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .input-text { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 6px; margin-top:5px; }
        .textarea-box { width: 100%; height: 300px; padding: 15px; border: 1px solid #ddd; border-radius: 6px; margin-top:5px; resize:none;}
        .form-footer { margin-top: 20px; display: flex; justify-content: flex-end; gap: 10px; }
        .btn-submit { background: #2962ff; color: #fff; border: none; padding: 10px 20px; border-radius: 6px; cursor: pointer; }
        .btn-cancel { background: #fff; border: 1px solid #ddd; padding: 10px 20px; border-radius: 6px; cursor: pointer; }
        .btn-submit:hover { background: #1e4bd1; }
        .btn-cancel:hover { background: #f5f5f5; }
    </style>
</head>
<body>
    <div class="container">
        <main class="content-area">
            <section class="panel detail-panel" style="padding:10px;">
                
                <h3 style="border-bottom:1px solid #eee; padding-bottom:15px; margin-bottom:20px;">공지사항 수정</h3>

                <form action="/admin/update" method="post" enctype="multipart/form-data">
                    
                    <input type="hidden" name="noticeNo" value="${notice.noticeNo}">
                    <input type="hidden" name="employeeNo" value="${notice.employeeNo}">

                    <div style="margin-bottom: 20px;">
                        <div style="display:flex; justify-content:space-between; align-items:center;">
                            <label style="font-weight:bold;">제목</label>
                            <label>
                                <input type="checkbox" name="noticeImportant" value="IMP" <c:if test="${notice.noticeImportant eq 'IMP'}">checked</c:if>>
                                중요 공지
                            </label>
                        </div>
                        <input type="text" name="noticeTitle" class="input-text" value="${notice.noticeTitle}" required>
                    </div>

                    <div style="margin-bottom: 20px;">
                        <label style="font-weight:bold;">내용</label>
                        <textarea name="noticeContent" class="textarea-box"><c:out value="${notice.noticeContent}"/></textarea>
                    </div>

                    <div style="margin-bottom: 20px;">
                        <label style="font-weight:bold;">파일 첨부</label>
                        <div style="margin-top:5px; font-size:13px; color:#666;">
                            <c:if test="${notice.fileNo > 0}">
                                <div style="color: #2962ff; font-weight: bold;">
                                    <i class="fas fa-check"></i> 현재 등록된 파일이 있습니다. (새 파일 업로드 시 기존 파일 삭제됨)
                                </div>
                            </c:if>
                        </div>
                        
                        <input type="file" name="files" multiple style="margin-top:5px;">
                        
                        <input type="hidden" name="fileNo" value="${notice.fileNo}">
                    </div>

                    <div class="form-footer">
                        <button type="button" class="btn-cancel" onclick="location.href='/admin/detail?noticeNo=${notice.noticeNo}'">취소</button>
                        
                        <button type="submit" class="btn-submit">수정 완료</button>
                    </div>
                </form>

            </section>
        </main>
    </div>
</body>
</html>