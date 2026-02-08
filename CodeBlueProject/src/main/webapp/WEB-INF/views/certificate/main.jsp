<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<%@ include file="/WEB-INF/views/common/include/link.jsp" %>
<title>SB 정형외과</title>
<style>
    html, body { height: 100%; overflow: hidden; }
    body { font-family: "Pretendard", sans-serif; }
    .main-content { height: calc(100vh - 64px); }
    .accordion-content { max-height: 0; overflow: hidden; transition: max-height 0.3s ease-out; }
    .accordion-item.active .accordion-content { max-height: 1000px; overflow-y: auto; }
    .accordion-header i.icon-chevron-down { transition: transform 0.3s; }
    .accordion-item.active .accordion-header i.icon-chevron-down { transform: rotate(180deg); }
    .doc-item-list li:hover { background-color: #f1f5f9; cursor: pointer; }
</style>
</head>
<body data-gnb="gnb-certificate">
    <%@ include file="/WEB-INF/views/common/include/header.jsp" %>
    
    <div class="main-container flex h-full">
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
        
        <main class="main-content flex-1 bg-neutral-100 p-4 overflow-hidden">
            <section class="flex h-full w-full gap-[1rem]">
              
              <jsp:include page="/WEB-INF/views/certificate/inc/leftList.jsp" />

			  <div id="detail-section" class="flex flex-col h-full overflow-hidden flex-1 bg-white rounded-3xl shadow-md border border-zinc-200">
				    <div id="detail-empty-view" class="flex flex-col h-full items-center justify-center bg-zinc-50/30">
				        <div class="empty-state text-center">
				            <svg class="w-24 h-24 text-zinc-200 mb-6 mx-auto" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
				                <path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"></path>
				            </svg>
				            <p class="text-zinc-400 font-black text-2xl mb-2">내용 없음</p>
				            <p class="text-zinc-300 text-sm font-bold">좌측 목록에서 항목을 선택해주세요.</p>
				        </div>
				    </div>
				
				    <div id="detail-content-view" class="hidden h-full overflow-y-auto p-8">
				        <jsp:include page="/WEB-INF/views/certificate/inc/rightDetail.jsp" />
				    </div>
				</div>
              
            </section>
        </main>
    </div>

    <jsp:include page="/WEB-INF/views/certificate/inc/modal.jsp" />

    <script>
    const $ = (s) => document.querySelector(s);
	 let currentChartNo = null;
	 let selectPatient = null;
	 
	 const employeeCode = "${employee.employeeCode}";
	 const isDoctor = (employeeCode === '1');
	 
	 let loginDoctor = {
	 	name: "${employee.employeeName}",
	 	licence: "${employee.employeeDetailLicence}",
	 	org: "${employee.hospitalName} (${employee.hospitalAddr})"
	 }
	 
	 const CONTEXT_PATH = "${pageContext.request.contextPath}";
	
	 function openModal() { $("#ptBackdrop").style.display = "flex"; }
	 function closeModal() { $("#ptBackdrop").style.display = "none"; }
	 function showDxView() { showOnly($("#dxViewForm")); $("#detailTitle").textContent = "진단서 상세 조회"; }
	 function showOpView() { showOnly($("#opViewForm")); $("#detailTitle").textContent = "소견서 상세 조회"; }
	 function showOpForm() {
		 if(!isDoctor) return sweetAlert("warning", "의사 권한이 필요합니다!");
		 
		 if(!selectPatient) return sweetAlert("warning", "환자를 먼저 선택해주세요!");
		 
		 showOnly($("#opForm")); 
		 $("#detailTitle").textContent = "소견서 신규 작성"; 
		 
		 $("#opPatientName").value = selectPatient.patientName || '';
		 const rrn2 = (selectPatient.patientRegno2) ? selectPatient.patientRegno2.substring(0,1) : "?";
		 $("#opRrn").value = `\${selectPatient.patientRegno1}-\${rrn2}******`;
		 $("#opAddress").value = `\${selectPatient.patientAddr1 || ''} \${selectPatient.patientAddr2 || ''}`;
		 $("#opPhone").value = selectPatient.patientTel || '';
		 
		 $("#opOrg").value = loginDoctor.org;
		 $("#opLicence").value = loginDoctor.licence;
		 $("#opDoctorName").value = loginDoctor.name;
		 
		 selectChartDiagnosis("#op", 2);
	 }
	 function showDxForm() { 
		 if(!isDoctor) return sweetAlert("warning", "의사 권한이 필요합니다!");
		 
		 if(!selectPatient) return sweetAlert("warning", "환자를 먼저 선택해주세요!");
		 
		 showOnly($("#dxForm")); 
		 $("#detailTitle").textContent = "진단서 신규 작성"; 
		 
		 $("#dxPatientName").value = selectPatient.patientName || '';
		 const rrn2 = (selectPatient.patientRegno2) ? selectPatient.patientRegno2.substring(0,1) : "?";
		 $("#dxRrn").value = `\${selectPatient.patientRegno1}-\${rrn2}******`;
		 $("#dxAddress").value = `\${selectPatient.patientAddr1 || ''} \${selectPatient.patientAddr2 || ''}`;
		 $("#dxPhone").value = selectPatient.patientTel || '';
		 
		 $("#dxOrg").value = loginDoctor.org;
	     $("#dxLicence").value = loginDoctor.licence;
	     $("#dxDoctorName").value = loginDoctor.name;
		 
		 selectChartDiagnosis("#dx", 1);
	 }
	 
	
	 document.addEventListener("DOMContentLoaded", () => {
	     showOnly(null);
	
	     const modalSearchInput = document.querySelector("#ptBackdrop .modal-body input.input");

	     const btnDummy = document.getElementById("fillContent");
	     if(btnDummy) {
	         btnDummy.addEventListener("click", btnFillContent);
	     }
	     
	     const insertBtnGroup = document.querySelector(".btn-group");
	     if(insertBtnGroup && !isDoctor){
	    	 insertBtnGroup.style.display = "none";
	     }
	     
	     if (modalSearchInput) {
	         modalSearchInput.addEventListener("keydown", (event) => {
	             if (event.key === "Enter") {
	                 const keyword = event.target.value.trim();
	                 if (keyword) patientSearch(keyword); 
	                 else sweetAlert("warning", "검색어를 입력해주세요.");
	             }
	         });
	     }
	     
	     const docSearchInput = document.getElementById('document-search');
	     
	     if (docSearchInput) {
	    	    docSearchInput.addEventListener('input', (e) => {
	    	        const keyword = e.target.value.toLowerCase().trim();
	    	        const accordionItems = document.querySelectorAll('.accordion-item');

	    	        accordionItems.forEach(item => {
	    	            const categoryTitle = item.querySelector('.accordion-header span').textContent.toLowerCase();
	    	            const docList = item.querySelectorAll('.doc-item-list li');
	    	            
	    	            let hasVisibleItem = false;
	    	            const isCategoryMatch = categoryTitle.includes(keyword); 

	    	            docList.forEach(li => {
	    	                if (li.classList.contains('text-center')) return; 

	    	                const allText = li.innerText.toLowerCase();

	    	                if (isCategoryMatch || allText.includes(keyword)) {
	    	                    li.style.display = "";
	    	                    hasVisibleItem = true;
	    	                } else {
	    	                    li.style.display = "none";
	    	                }
	    	            });

	    	            if (hasVisibleItem) {
	    	                item.style.display = ""; 
	    	                if (keyword !== "") item.classList.add('active'); 
	    	            } else {
	    	                item.style.display = "none"; 
	    	            }
	    	        });
	    	        
	    	        if (keyword === "") {
	    	            accordionItems.forEach(item => item.classList.remove('active'));
	    	        }
	    	    });
	    	}
	});
	
	 function showOnly(section) {
		 const emptyView = $("#detail-empty-view");
		 const contentView = $("#detail-content-view");
	     
		 ["#rightEmpty", "#opForm", "#dxForm", "#opViewForm", "#dxViewForm", "#progView"].forEach(id => {
	         const el = $(id);
	         if(el) el.classList.add("hidden");
	     });
		 
		 if (!section) {
	         emptyView.classList.remove("hidden");
	         contentView.classList.add("hidden");
	     } else {
	         emptyView.classList.add("hidden");
	         contentView.classList.remove("hidden");
	         section.classList.remove("hidden"); 
	     }
	 }
	 
	 async function loadInpatientList() {
	     const keyword = document.getElementById('patient-search').value.trim();
	     
	     if(!keyword) {
	         sweetAlert("warning", "환자 성명 또는 환자 번호를 입력해주세요.");
	         return;
	     }
	     
	     openModal();
	     
	     const modalInput = document.querySelector("#ptBackdrop .modal-body input.input");
	     if (modalInput) {
	         modalInput.value = keyword; 
	     }
	     
	     await patientSearch(keyword);
	 }
	
	 async function patientSearch(keyword) {
		    const wrap = document.querySelector("#ptBackdrop .modal-body .box-bordered");
		    if(!wrap) return;

		    wrap.classList.add("p-20"); 
		    wrap.innerHTML = `
		        <div class="text-center w-full">
		            <div class="inline-block animate-spin rounded-full h-8 w-8 border-4 border-primary border-t-transparent mb-4"></div>
		            <div class="text-zinc-500 font-medium">환자 정보를 찾고 있습니다...</div>
		        </div>`;

		    try {
		        const response = await axios.get(`\${CONTEXT_PATH}/certificate/api/searchPatient`, {
		            params: { keyword: keyword }
		        });

		        if (!response.data || response.data.length === 0) {
		            wrap.innerHTML = `
		                <div class="text-center w-full">
		                    <i class="icon icon-info-circle text-4xl mb-4 opacity-20"></i>
		                    <div class="text-zinc-400 font-medium">"\${keyword}"에 대한 검색 결과가 없습니다.</div>
		                </div>`;
		            return;
		        }

		        wrap.classList.remove("p-20");
		        wrap.classList.add("p-0"); 

		        let html = '<ul class="w-full divide-y divide-zinc-100 bg-white">';
		        response.data.forEach(p => {
		            const pData = encodeURIComponent(JSON.stringify(p));
		            html += `
		                <li class="group flex items-center justify-between p-6 hover:bg-indigo-50/50 cursor-pointer transition-all w-full" 
		                    onclick="loadPatientInfo('\${pData}')">
		                    
		                    <div class="flex-1 flex flex-col gap-1.5">
		                        <div class="flex items-center gap-3">
		                            <span class="text-xl font-black text-zinc-900 tracking-tighter">\${p.patientName}</span>
		                            <span class="text-xs font-bold text-zinc-400 bg-zinc-100 px-2 py-0.5 rounded">
		                                \${p.patientGen === 'MALE' ? '남' : '여'}/\${p.patientAge || '??'}세
		                            </span>
		                        </div>
		                        <div class="flex items-center text-sm font-medium text-zinc-500 gap-3">
		                            <span class="badge badge-default font-bold">No. \${p.patientNo}</span>
		                            <span class="w-px h-3 bg-zinc-200"></span>
		                            <span class="tracking-tight">\${p.patientRegno1}-*******</span>
		                            <span class="w-px h-3 bg-zinc-200"></span>
		                            <span class="flex items-center gap-1"><i class="icon icon-phone text-xs text-zinc-300"></i> \${p.patientTel || '미등록'}</span>
		                        </div>
		                    </div>

		                    <div class="flex-shrink-0 ml-6 opacity-40 group-hover:opacity-100 transition-all text-zinc-400 group-hover:text-primary">
		                        <div class="flex items-center gap-1 font-black text-sm uppercase tracking-wider">
		                            Select Chart
		                            <i class="icon icon-chevron-right text-xs"></i>
		                        </div>
		                    </div>
		                </li>`;
		        });
		        html += '</ul>';
		        
		        wrap.innerHTML = html;

		    } catch (error) {
		        console.error("환자 검색 오류:", error);
		        wrap.innerHTML = '<div class="p-20 text-center text-red-400 font-bold">서버 통신 오류가 발생했습니다.</div>';
		    }
		}
	 
	 function loadPatientInfo(encodeData){
		 const p = JSON.parse(decodeURIComponent(encodeData));
		    selectPatient = p; 
		    
		    const compactName = $("#compactName");
		    const compactInfo = $("#compactInfo");
		    if(compactName && compactInfo){
		        compactName.textContent = p.patientName;
		        const gender = p.patientGen === "MALE" ? "남" : "여";
		        compactInfo.textContent = `환자번호 : \${p.patientNo} | \${gender} | \${p.patientAge || '??'}세`;
		    }
		    
		    showOnly($("#rightEmpty")); 

		    const writeBtnArea = $("#certWriteBtnArea");
		    if (writeBtnArea && isDoctor) {
		        writeBtnArea.style.display = "flex";
		    }
		    
		    axios.get(`${CONTEXT_PATH}/certificate/api/patientChartDetail`, {
		        params: { patientNo: p.patientNo }
		    }).then(resp => {
		        if(resp.data && resp.data.length > 0) {
		            currentChartNo = resp.data[0].chartNo; 
		        }
		    });
		    
		 closeModal();
		 
		 selectPatientDocList(p.patientNo);
	 }
	 
	 async function selectPatientDocList(patientNo){
		 try{
			 const response = await axios.get(`\${CONTEXT_PATH}/certificate/api/patientDocList`, {
				 params : {patientNo: patientNo}
			 });
			 
			 const docs = response.data;
			 
			 const diagList = document.querySelector("[data-category='DIAGNOSIS'] .doc-item-list");
	         const opinList = document.querySelector("[data-category='OPINION'] .doc-item-list");

	         diagList.innerHTML = "";
	         opinList.innerHTML = "";

	         if (docs.length === 0) {
	             const empty = '<li class="p-4 text-xs text-zinc-400 text-center">기록이 없습니다.</li>';
	             diagList.innerHTML = empty;
	             opinList.innerHTML = empty;
	             return;
	         }

	         docs.forEach(doc => {
	             const li = document.createElement("li");
	             li.className = "p-4 flex items-center justify-between hover:bg-zinc-50 cursor-pointer transition-all";
	            
	             li.onclick = () => patientDocDetail(doc.docType, doc.certificateNo, doc.chartNo, doc.medicalCertificateDate);
 
 	             li.innerHTML = `
 	                 <div>
 	                     <div class="font-bold text-zinc-900 text-sm">\${doc.medicalCertificateDate}</div>
 	                     <div class="text-xs text-zinc-400">\${doc.medicalCertificatePurpose || '내용 없음'}</div>
 	                 </div>
 	                 <i class="icon icon-chevron-right text-zinc-300"></i>
 	             `;
 
	             if (doc.certificateNo == 1) diagList.appendChild(li);
	             else if (doc.certificateNo == 2) opinList.appendChild(li);
	         });
	         
	         const resChart = await axios.get(`${CONTEXT_PATH}/certificate/api/patientChartDetail`, { 
	             params: { patientNo: patientNo } 
	         });

	         const progContainer = $("#prog-item-list");
	         if(!progContainer) return; 

	         progContainer.innerHTML = "";

	         resChart.data.forEach(chart => {
	             const li = document.createElement("li");
	             li.className = "p-4 flex items-center justify-between hover:bg-zinc-50 cursor-pointer transition-all";
	             
	             li.onclick = () => loadIntegratedDetail(chart.chartNo, chart.chartRegdate); 

	             li.innerHTML = `
	                 <div>
	                     <div class="font-bold text-zinc-900 text-sm">\${chart.chartRegdate}</div>
	                     <div class="text-[10px] text-zinc-400">작성자: \${chart.employeeName}</div>
	                 </div>
	                 <i class="icon icon-chevron-right text-zinc-300"></i>`;
	             progContainer.appendChild(li);
	         });
		 } catch (error) {
		        console.error("목록 로드 실패:", error);
		 }
	 }
	 
	 async function patientDocDetail(docType, certNo, chartNo, clickDate){
		 currentChartNo = chartNo;
		 try{
			 const response = await axios.get(`\${CONTEXT_PATH}/certificate/api/patientDocDetail`, {
				params : {docType: docType,
						  certificateNo: certNo,
						  chartNo: chartNo,
						  clickDate: clickDate} 
			 });
			 const d = Array.isArray(response.data) ? response.data[0] : response.data;
			 
			 const rrn2 = (d.patientRegno2 && d.patientRegno2.length > 0) ? d.patientRegno2.substring(0, 1) : "?";
			 const maskedRrn = `\${d.patientRegno1 || ''}-\${rrn2}******`;
			 
			 const renderDiagnosis = (tbodyId) => {
				    const tbody = $(tbodyId);
				    if(!tbody) return;
				    tbody.innerHTML = "";
				    
				    if(d.diagnosisList && d.diagnosisList.length > 0 && d.diagnosisList[0].diagnosisCode){
				    	let html = "";
				        d.diagnosisList.forEach(diag => {
				        	const typeText = diag.diagnosisDetailYN === 'Y' ? '주' : '부';
				        	
				        	html += `
		                        <tr class="border-b border-zinc-50">
		                            <td class="p-3 text-zinc-500 font-mono text-sm">\${typeText}</td>
		                            <td class="p-3 text-zinc-500 font-mono text-sm">\${diag.diagnosisCode}</td>
		                            <td class="p-3 text-zinc-700 font-medium">\${diag.diagnosisName}</td>
		                        </tr>`;
		                });
		                tbody.innerHTML = html;
		            } else {
		                tbody.innerHTML = '<tr><td colspan="2" class="p-8 text-center text-zinc-400 text-xs">등록된 상병 정보가 없습니다.</td></tr>';
		            }
				}

		        if (certNo == 1) { 
		            showDxView();
		            renderDiagnosis("#view-dxDxTbody");
		            
		            if($("#view-dxPatientName")) $("#view-dxPatientName").value = d.patientName || '';
		            if($("#view-dxRrn"))         $("#view-dxRrn").value = maskedRrn;
		            if($("#view-dxPrintNo"))     $("#view-dxPrintNo").value = d.medicalCertificatePrintNo || '';
		            if($("#view-dxAddress"))     $("#view-dxAddress").value = `\${d.patientAddr1 || ''} \${d.patientAddr2 || ''}`;
		            if($("#view-dxPhone"))       $("#view-dxPhone").value = d.patientTel || '';
		            
		            if($("#view-dxOnsetDate"))       $("#view-dxOnsetDate").value = d.medicalCertificateOnset || '';
		            if($("#view-dxDxDate"))      $("#view-dxDxDate").value = d.medicalCertificateDiagnosis || '';
		            if($("#view-dxContent"))     $("#view-dxContent").value = d.medicalCertificateContent || '';
		            if($("#view-dxRemark"))      $("#view-dxRemark").value = d.medicalCertificateRemark || '';
		            if($("#view-dxPurpose"))     $("#view-dxPurpose").value = d.medicalCertificatePurpose || '';
		            
		            if($("#view-dxOrg"))         $("#view-dxOrg").value = `\${d.hospitalName || ''} (\${d.hospitalAddr || ''})`;
		            if($("#view-dxLicence"))     $("#view-dxLicence").value = d.employeeDetailLicence || '';
		            if($("#view-dxDoctorName"))  $("#view-dxDoctorName").value = d.employeeName || '';

		        } else { 
		            showOpView();
		            renderDiagnosis("#view-opDxTbody");
		            
		            if($("#view-opPatientName")) $("#view-opPatientName").value = d.patientName || '';
		            if($("#view-opRrn"))         $("#view-opRrn").value = maskedRrn;
		            if($("#view-opPrintNo"))     $("#view-opPrintNo").value = d.medicalCertificatePrintNo || '';
		            if($("#view-opAddress"))     $("#view-opAddress").value = `\${d.patientAddr1 || ''} \${d.patientAddr2 || ''}`;
		            if($("#view-opPhone"))       $("#view-opPhone").value = d.patientTel || '';
		            
		            if($("#view-opDxDate"))      $("#view-opDxDate").value = d.medicalCertificateDiagnosis || '';
		            if($("#view-opContent"))     $("#view-opContent").value = d.medicalCertificateContent || '';
		            if($("#view-opRemark"))      $("#view-opRemark").value = d.medicalCertificateRemark || '';
		            if($("#view-opPurpose"))     $("#view-opPurpose").value = d.medicalCertificatePurpose || '';
		            
		            if($("#view-opOrg"))         $("#view-opOrg").value = `\${d.hospitalName || ''} (\${d.hospitalAddr || ''})`;
		            if($("#view-opLicence"))     $("#view-opLicence").value = d.employeeDetailLicence || '';
		            if($("#view-opDoctorName"))  $("#view-opDoctorName").value = d.employeeName || '';
		        }
		 } catch(error){
			 console.error("상세 조회 실패:", error);
			 sweetAlert("warning", "데이터를 가져오는 중 오류가 발생했습니다.");
		 }
	 }
	 
	 async function insertCertificate(type){
		const isDx = (type === 'dx');
		const prefix = isDx ? "#dx" : "#op";
		
		if(!currentChartNo){
			sweetAlert("warning", "환자를 먼저 선택해주세요!");
			return;
		}
		
		formData = {
			certificateNo: isDx ? 1 : 2,
			chartNo: currentChartNo,
			medicalCertificateOnset: isDx ? $(prefix + "OnsetDate").value : "",
			medicalCertificateDiagnosis: $(prefix + "DxDate").value,
			medicalCertificateContent: $(prefix + "Content").value,
			medicalCertificateRemark: $(prefix + "Remark").value,
			medicalCertificatePurpose: $(prefix + "Purpose").value
		};
		
		if(!formData.medicalCertificateDiagnosis) return sweetAlert("warning", "진단일을 입력해주세요!");
		if(!formData.medicalCertificateContent) return sweetAlert("warning", "내용을 입력해주세요!");
		if(!formData.medicalCertificatePurpose) return sweetAlert("warning", "용도를 입력해주세요!");
		
		if(!confirm(`\${isDx ? '진단서' : '소견서'}를 등록하시겠습니까?`)) return;
		
		try{
			const response = await axios.post(`\${CONTEXT_PATH}/certificate/api/insertCertificate`, formData);
			
			if(response.data.status === "success"){
				sweetAlert("success", "정상적으로 등록되었습니다.");
				
				showOnly(null);
				
				const patientNo = $("#compactInfo").textContent.match(/\d+/)[0];
				if(patientNo) selectPatientDocList(patientNo);
			}else{
				sweetAlert("error", "저장에 실패했습니다: " + (response.data.message || "알 수 없는 오류"));
			}
		}catch(error) {
	    	console.error("저장 중 에러 발생:", error);
	    	sweetAlert("error", "서버 통신 중 오류가 발생했습니다.");
		}
	 }
	 
	 async function selectChartDiagnosis(prefix, certNo){
		 if(!currentChartNo) return;
		 try{
			 const response = await axios.get(`\${CONTEXT_PATH}/certificate/api/patientDocDetail`,{
				 params: {
					 docType: 'CERT',
					 certificateNo: certNo,
					 chartNo: currentChartNo
				 }
			 });
			 
			 const dataList = response.data;
			 const d = (dataList && dataList.length > 0) ? dataList[0] : null;
			 
			 const targetOrgInput = $(prefix + "Org");
		        if (targetOrgInput) {
		            if (d && d.hospitalName) {
		                targetOrgInput.value = `\${d.hospitalName} (\${d.hospitalAddr || ''})`;
		            } else {
		                targetOrgInput.value = loginDoctor.org;
		            }
		        }

		        if ($(prefix + "Licence")) $(prefix + "Licence").value = loginDoctor.licence;
		        if ($(prefix + "DoctorName")) $(prefix + "DoctorName").value = loginDoctor.name;
			 
	         if(!dataList || dataList.length === 0) return;
			 
			 const tbody = $(`\${prefix}DxTbody`);
			 
			 if(tbody && d && d.diagnosisList) {
		            let html = "";
		            d.diagnosisList.forEach(diag => {
		            	const typeText = diag.diagnosisDetailYN === 'Y' ? '주' : '부';
		            	
		                html += `
		                    <tr class="border-b border-zinc-50">
	                            <td class="p-3 text-zinc-500 font-mono text-sm">\${typeText}</td>
		                        <td class="p-3 text-zinc-500 font-mono text-sm">\${diag.diagnosisCode}</td>
		                        <td class="p-3 text-zinc-700 font-medium">\${diag.diagnosisName}</td>
		                    </tr>`;
		            });
		            tbody.innerHTML = html;
		        }
		 }catch(error){
			 console.error("상병 로드 실패 : ", error);
		 }
	 }
	 
	 async function loadIntegratedDetail(chartNo, clickDate) {
		    try {
		        const res = await axios.get(`${CONTEXT_PATH}/certificate/api/patientDocDetail`, {
		            params: { docType: 'PROG', chartNo: chartNo, clickDate: clickDate }
		        });
		        
		        const d = res.data[0]; 
		        if(!d) return;

		        showOnly($("#progView"));

		        $("#prog-title").textContent = `\${clickDate} 진료 상세 기록`;
		        $("#prog-author").textContent = `담당의: \${d.employeeName || '-'}`;
		        
		        const noteArea = $("#prog-content");
		        if (d.progressNote && d.progressNote.length > 0) {
		            noteArea.innerHTML = d.progressNote.map(n => `
		                <div class="mb-2 text-sm text-zinc-700 leading-relaxed">\${n.progressnoteContent}</div>
		            `).join('');
		        } else {
		            noteArea.textContent = "기록된 내용이 없습니다.";
		        }

		        const dxTbody = $("#prog-dx-tbody");
		        if (d.diagnosisList && d.diagnosisList.length > 0) {
		            dxTbody.innerHTML = d.diagnosisList.map(dx => `
		                <tr class="border-b border-zinc-50">
		                    <td class="p-2 w-10">
		                        <span class="badge \${dx.diagnosisDetailYN==='Y'?'badge-danger':'badge-default'}">
		                            \${dx.diagnosisDetailYN==='Y'?'주':'부'}
		                        </span>
		                    </td>
		                    <td class="p-2 text-xs font-mono">\${dx.diagnosisCode}</td>
		                    <td class="p-2 text-xs">\${dx.diagnosisName}</td>
		                </tr>
		            `).join('');
		        } else {
		            dxTbody.innerHTML = "<tr><td colspan='3' class='p-4 text-center text-zinc-300 text-xs'>상병 정보 없음</td></tr>";
		        }

		        const typeMap = { '001': '약/주사', '002': '검사', '003': '처치', '004': '식이', '005': '수술' };
		        const orderList = $("#prog-order-list");
		        
		        const ordersHtml = (d.predetail || []).map(p => {
		            const name = p.drugList?.[0]?.drugName || p.examList?.[0]?.examinationName || 
		                         p.dietList?.[0]?.dietName || p.treatList?.[0]?.treatmentName || 
		                         p.operList?.[0]?.operationName;
		            
		            if(!name) return ''; 

		            return `
		                <div class="p-3 bg-zinc-50 rounded-lg flex justify-between items-center border border-zinc-100 mb-2">
		                    <div class="flex items-center gap-3">
		                        <span class="text-[10px] font-bold px-1.5 py-0.5 rounded bg-white border border-zinc-200">
		                            \${typeMap[p.predetailType] || p.predetailType}
		                        </span>
		                        <span class="text-sm font-bold text-zinc-700">\${name}</span>
		                    </div>
		                </div>`;
		        }).join('');

		        orderList.innerHTML = ordersHtml || "<div class='p-8 text-center text-zinc-300 text-xs'>해당 일자 처방 내역 없음</div>";

		    } catch (e) { console.error("상세 로드 실패:", e); }
		}
	
    </script>
</body>
</html>










