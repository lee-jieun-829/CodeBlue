<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>제증명 조회</title>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.26.17/dist/sweetalert2.all.min.js"></script>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.26.17/dist/sweetalert2.min.css">
    <style>
    	@font-face {
	        font-family: 'Pretendard';
	        font-weight: 45 920;
	        font-style: normal;
	        font-display: swap;
	        src: url('${pageContext.request.contextPath}/resources/assets/fonts/PretendardVariable.woff2') format('woff2-variations');
	    }
    
        /* 화면 기본 배경 */
        body { margin: 0; padding: 0; background-color: #f0f2f5; font-family: "Pretendard", -apple-system, BlinkMacSystemFont, system-ui, Roboto, "Helvetica Neue", "Segoe UI", "Apple SD Gothic Neo", "Noto Sans KR", "Malgun Gothic", sans-serif; -webkit-font-smoothing: antialiased; }
        
        /* 상단 툴바 (인쇄 버튼 포함) */
        .toolbar { position: sticky; top: 0; background: #333; color: white; padding: 12px; text-align: center; z-index: 100; box-shadow: 0 2px 5px rgba(0,0,0,0.3); }
        .toolbar button { padding: 8px 20px; cursor: pointer; background: #10b981; color: white; border: none; border-radius: 4px; font-weight: bold; }
        .toolbar button:hover { background: #059669; }

        /* A4 용지 스타일링 */
        .cert-container { display: flex; justify-content: center; padding: 0 0 30px 0;}
        .cert-paper {
	        width: 210mm;
	        min-height: 297mm;
	        padding: 20mm;
	        margin: 0 auto;
	        background: white;
	        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
	        color: #1e293b; 
	    }

        /* 증명서 내용 디자인 */
        .cert-title { text-align: center; font-size: 32px; font-weight: 700; text-decoration: underline; margin-bottom: 50px; }
        .cert-table { width: 100%; border-collapse: collapse; margin-bottom: 20px; }
        .cert-table th, .cert-table td { border: 1px solid #333; padding: 12px; font-size: 14px; }
        .cert-table th { background-color: #f8f9fa; width: 20%; text-align: center; }
        .content-box { border: 1px solid #333; height: 500px; padding: 20px; margin-top: -1px; line-height: 1.6; }
        
        /* 하단 직인 영역 */
        .footer { margin-top: 60px; text-align: center; }
        .hospital-name { font-size: 24px; font-weight: bold; margin-top: 40px; }
        /* .stamp { position: absolute; bottom: 85px; right: 100px; width: 70px; opacity: 0.8; } */

        /* 인쇄 시 스타일 (중요!) */
        @media print {
            body { background: none; }
            .toolbar { display: none; } /* 툴바 숨김 */
            .cert-container { padding: 0; }
            .cert-paper { width: 100%; border: none; box-shadow: none; margin: 0; }
        }
    </style>
</head>
<body>
    <div class="toolbar">
        <span id="cert-title">증명서 미리보기</span>
        <button onclick="handlePrint()" 
		        style="margin-left: 20px; ${certData.MEDICAL_CERTIFICATE_STATUS != 003 ? 'background-color: #94a3b8; cursor: not-allowed;' : ''}">
		    ${certData.MEDICAL_CERTIFICATE_STATUS != 003 ? '수납 대기 중' : '인쇄 및 PDF 저장'}
		</button>
    </div>
    
    <div class="cert-container">
	    <div class="cert-paper">
	        <div class="cert-title">${certData.CERTIFICATE_NAME}</div>
	
	       <table class="cert-table">
			    <tr>
			        <th style="width: 15%;">성 명</th>
			        <td style="width: 30%;">${certData.PATIENT_NAME}</td>
			        <th style="width: 15%;">발급번호</th>
			        <td style="width: 40%;">${certData.MEDICAL_CERTIFICATE_PRINT_NO}</td>
			    </tr>
			    <tr>
			        <th>연락처</th>
			        <td>${certData.PATIENT_TEL}</td>
			        <th>주민등록번호</th>
			        <td>${certData.PATIENT_REGNO1}-*******</td>
			    </tr>
			    <tr>
			        <th>주 소</th>
			        <td colspan="3">${certData.PATIENT_ADDR1} ${certData.PATIENT_ADDR2}</td>
			    </tr>
			</table>
	
	        <div style="font-weight: bold; margin: 25px 0 10px 0; font-size: 1.1rem;">질병 정보 및 소견</div>
	        <table class="cert-table" style="margin-top: 0;">
	            <thead style="background-color: #f8fafc;">
	                <tr>
	                    <th style="width: 15%;">주/부</th>
	                    <th style="width: 25%;">상병코드</th>
	                    <th style="width: 60%;">상병명</th>
	                </tr>
	            </thead>
	            <tbody>
	                <c:choose>
	                    <c:when test="${not empty certData.diagnosisList}">
	                        <c:forEach items="${certData.diagnosisList}" var="diag">
	                            <tr>
	                                <td style="text-align: center;">${diag.diagnosisDetailYN == 'Y' ? '주' : '부'}</td>
	                                <td style="text-align: center;">${diag.diagnosisCode}</td>
	                                <td>${diag.diagnosisName}</td>
	                            </tr>
	                        </c:forEach>
	                    </c:when>
	                    <c:otherwise>
	                        <tr>
	                            <td colspan="3" style="text-align: center; color: #94a3b8; py-4;">등록된 상병 정보가 없습니다.</td>
	                        </tr>
	                    </c:otherwise>
	                </c:choose>
	            </tbody>
	        </table>
	
	        <table class="cert-table" style="margin-top: -1px;">
	            <tr>
	                <th style="width: 15%;">발병일</th>
	                <td style="width: 35%;">${certData.MEDICAL_CERTIFICATE_ONSET}</td>
	                <th style="width: 15%;">진단일</th>
	                <td style="width: 35%;">${certData.MEDICAL_CERTIFICATE_DIAGNOSIS}</td>
	            </tr>
	            <tr>
	                <th>향후 치료 의견</th>
	                <td colspan="3" style="height: 300px; vertical-align: top; padding: 15px; line-height: 1.8;">
	                    ${certData.MEDICAL_CERTIFICATE_CONTENT}
	                </td>
	            </tr>
	            <tr>
	                <th>비 고</th>
	                <td>${certData.MEDICAL_CERTIFICATE_REMARK}</td>
	                <th>용 도</th>
	                <td>${certData.MEDICAL_CERTIFICATE_PURPOSE}</td>
	            </tr>
	        </table>
	
	        <div style="font-weight: bold; margin: 25px 0 10px 0; font-size: 1.1rem;">의료인 및 기관 정보</div>
	        <table class="cert-table">
	            <tr>
	                <th style="width: 20%;">의료기관 명칭/주소</th>
	                <td style="width: 50%;">${certData.HOSPITAL_NAME} (${certData.HOSPITAL_ADDR})</td>
	                <th style="width: 15%;">면허번호</th>
	                <td style="width: 15%;">제 ${certData.EMPLOYEE_DETAIL_LICENCE} 호</td>
	            </tr>
	            <tr>
	                <th>주치의 성명</th>
	                <td colspan="3">
	                    <div style="display: flex; justify-content: space-between; align-items: center;">
	                        <span>${certData.EMPLOYEE_NAME}</span>
	                        <!-- <span style="font-size: 0.9rem; font-weight: normal; color: #64748b;">(인 또는 서명)</span> -->
	                    </div>
	                </td>
	            </tr>
	        </table>
	
	        <div style="margin-top: 30px; font-size: 0.95rem; color: #475569; text-align: left;">
	            「의료법」 제17조 및 같은 법 시행규칙 제9조에 따라 위와 같이 진단합니다.
	        </div>
	
	        <div class="footer" style="margin-top: 50px; text-align: center; border-top: 2px solid #1e293b; pt-8;">
	            <p>발급 일자 : ${certData.MEDICAL_CERTIFICATE_DATE}</p>
	            <div class="hospital-name">
	                Code Blue 대전 병원장
	            </div>
	        </div>
	    </div>
	</div>
</body>
<script type="text/javascript">

//제증명 출력
function handlePrint(){
	const status = "${certData.MEDICAL_CERTIFICATE_STATUS}".trim();
	
	// 수납완료 상태가 아니면 알림창 뜸
	if(status !== '003'){
		Swal.fire({
            title: '출력 제한',
            text: '수납이 완료된 증명서만 인쇄할 수 있습니다.',
            icon: 'warning',
            confirmButtonColor: '#10b981',
            confirmButtonText: '확인'
        });
        return;
	}
	
	// 수납완료(003)인 상태만 출력 가능
	window.print();
}

document.addEventListener('DOMContentLoaded', function() {
    
	// 팝업창이 열리자마자 브라우저 창 크기 조절
    window.resizeTo(900, 800);
    
    // 화면 중앙 이동
    const x = (window.screen.availWidth - 900) / 2;
    const y = (window.screen.availHeight - 800) / 2;
    window.moveTo(x, y);
	
	// 에러
	const isError = "${error}";
    if(isError === "Y") {
        Swal.fire({
            title: '알림',
            text: '존재하지 않는 증명서입니다.',
            icon: 'error',
            confirmButtonText: '확인'
        }).then((result) => {
            if (result.isConfirmed) {
                window.close(); 
            }
        });
    }
    
});
</script>
</html>