<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="http://www.springframework.org/security/tags" prefix="sec" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<%@ include file="/WEB-INF/views/common/include/link.jsp" %>
<title>SB 정형외과 | 협진 의뢰 시스템</title>
<style>
    html, body { height: 100%; overflow: hidden; }
    body { font-family: "Pretendard", sans-serif; }
    .main-content { height: calc(100vh - 64px); }
    
    /* 탭 스타일 가이드 적용 */
    .tab-btn.active { color: #4f46e5; border-bottom: 2px solid #4f46e5; background-color: rgba(238, 242, 255, 0.5); }
    .tab-btn { color: #9ca3af; border-bottom: 2px solid transparent; }
    
    .view-section { display: none; }
    .view-section.active { display: flex; flex-direction: column; height: 100%; }
    
    .list-section { display: none; }
    .list-section.active { display: flex; flex-direction: column; }
</style>
</head>
<body data-gnb="gnb-consult">
    <%@ include file="/WEB-INF/views/common/include/header.jsp" %>
    
    <div class="main-container flex h-full">
        <%@ include file="/WEB-INF/views/common/include/left/left_doctor.jsp" %>
        
        <main class="main-content flex-1 bg-neutral-100 p-4 overflow-hidden">
            <section class="flex h-full w-full gap-[1rem]">
              
              <jsp:include page="/WEB-INF/views/consultation/inc/leftList.jsp" />

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
				
				    <div id="detail-content-view" class="hidden flex-1 flex flex-col h-full overflow-y-auto">
				        <jsp:include page="/WEB-INF/views/consultation/inc/rightDetail.jsp" />
				    </div>
				</div>
              
            </section>
        </main>
    </div>
    
    <jsp:include page="/WEB-INF/views/consultation/inc/modal.jsp" />

    <script>
    	const CONTEXT_PATH = "${pageContext.request.contextPath}";
    
    	<sec:authentication property="principal.employee.employeeNo" var="myEmpNo" />
        
        const loginDoctor = Number("${myEmpNo}"); 

        console.log("검증된 로그인 사번:", loginDoctor);
        
	   let allConsultList = [];
	   let currentDetailNo = null;
       
       document.addEventListener('DOMContentLoaded', function(){
    	  const urlParams = new URLSearchParams(window.location.search);
   	      const targetPatientNo = urlParams.get('patientNo');
   	      const action = urlParams.get('action');
   	      
   	   	  window.history.replaceState({}, document.title, window.location.pathname);
   	      
    	  loadConsultationList(); 
    	  
    	  if (targetPatientNo && action === 'new') {
    	      openNewConsultModal(targetPatientNo);
    	  }
       });
       
       async function loadConsultationList(){
    	   if (!loginDoctor || loginDoctor === "") {
    	        console.warn("로그인 정보(사번)가 없습니다. 세션을 확인하세요.");
    	        return;
    	    }
    	   
    	   try{
    		   const response = await axios.get('/consultation/api/selectReqConsultPatient');
    	   	
    	   	   const list = response.data;
    	   		console.log("받은 데이터 확인:", list);
    	   	   renderConsultList(list);
    	   }catch(error){
    		   console.error("협진 목록 로드 실패:", error);
    	   }
       }
       
       function renderConsultList(data){
    	   
    	   console.log("로그인 사번(loginDoctor):", loginDoctor, typeof loginDoctor);
    	    if(data.length > 0) {
    	        console.log("첫 번째 항목 데이터:", data[0]);
    	    }
    	    
    	   allConsultList = data;
    	   
    	   const receivedList = document.getElementById('list-received');
    	   const sentList = document.getElementById('list-sent');
    	   
    	   receivedList.innerHTML = '';
    	   sentList.innerHTML = '';
    	   
    	   if(!data || data.length === 0){
    		   receivedList.innerHTML = '<div class="p-10 text-center text-zinc-400 text-sm">내역이 없습니다.</div>';
    		   sentList.innerHTML = '<div class="p-10 text-center text-zinc-400 text-sm">내역이 없습니다.</div>';
    	        return;
    	   }
    	   
    	   data.forEach(item => {
    		  const isReceived = (Number(item.consultationRespdoctor) === Number(loginDoctor));
    		  const targetList = isReceived ? receivedList : sentList;
    		  
    		  let badgeClass = 'badge-warning';
    		  let statusText = '대기중';
    		  
    		  if(item.consultationStatus === '001'){
    			  badgeClass = 'badge-success'; 
    			  statusText = '완료';
    		  } else if(item.consultationStatus === '002'){
    			  badgeClass = 'badge-danger'; 
    			  statusText = '거절';
    		  }
    		  
    		  const html = `
    	            <div onclick="openDetail('\${isReceived ? 'received' : 'sent'}', \${item.consultationNo})" 
    	                 class="p-4 cursor-pointer hover:bg-zinc-50 border-l-4 \${isReceived ? 'border-red-500 bg-red-50/10' : 'border-primary bg-indigo-50/30'} transition divide-y divide-zinc-100">
    	                <div class="flex justify-between items-start mb-2">
    	                    <span class="font-bold text-zinc-900">\${item.patientName} (\${item.patientGen === 'MALE' ? '남' : '여'}/\${item.patientAge})</span>
    	                    <span class="badge \${badgeClass}">\${statusText}</span>
    	                </div>
    	                <div class="flex justify-between text-[11px] text-zinc-500">
    	                    <span>\${isReceived ? 'From. ' + item.reqDoctorName : 'To. ' + item.respDoctorName}</span>
    	                    <span class="font-medium">\${item.consultationReqdate}</span>
    	                </div>
    	            </div>
    	        `;
    	        
    	        targetList.insertAdjacentHTML('beforeend', html);
    	   });
       }
       
       
       function switchList(type) {
          document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active'));
          const tab = document.getElementById('tab-' + type);
          if (tab) tab.classList.add('active');
          document.querySelectorAll('.list-section').forEach(sec => sec.classList.remove('active'));
          const list = document.getElementById('list-' + type);
          if (list) list.classList.add('active');
          showRightView('empty');
       }

       function showRightView(viewId) {
    	  document.getElementById('detail-empty-view').classList.add('hidden');
    	  const contentView = document.getElementById('detail-content-view');
    	  contentView.classList.remove('hidden');
    	  contentView.classList.add('flex');
    	   
          document.querySelectorAll('.view-section').forEach(sec => {
             sec.classList.remove('active', 'flex');
             sec.classList.add('hidden');
          });
          
          const target = document.getElementById('view-' + viewId);
          if (target) {
              target.classList.add('active');
              target.classList.remove('hidden');
          }
       }

       async function openDetail(type, consultNo) { 
    	   currentDetailNo = consultNo;
    	    try {
    	        const response = await axios.get('/consultation/api/consultationDetail', {
    	            params : {consultationNo: consultNo}
    	        });
    	        const data = response.data;
    	        if(!data) return;

    	        showRightView('received');
    	        
    	        const gender = (data.patientGen === 'MALE' || data.patientGen === '남') ? '남' : '여';
    	        document.getElementById('det-patientName').innerText = `\${data.patientName} (\${gender}/\${data.patientAge}) - No.\${data.patientNo}`;
    	        document.getElementById('det-chartNo').innerText = data.chartNo || '-';
    	        document.getElementById('det-reqDoctor').innerText = data.reqDoctorName || '-';
    	        document.getElementById('det-reqDate').innerText = data.consultationReqdate || '-';
    	        document.getElementById('det-reqContent').innerText = data.consultationReqcontent || '-';

    	        const respArea = document.getElementById('det-respArea');
    	        const rejectArea = document.getElementById('det-rejectArea');
    	        const btnReject = document.getElementById('btn-reject');
    	        const btnReply = document.getElementById('btn-reply');

    	        respArea.classList.add('hidden');
    	        rejectArea.classList.add('hidden');
    	        btnReject.classList.add('hidden');
    	        btnReply.classList.add('hidden');

    	        if(data.consultationStatus === '001') { 
    	            respArea.classList.remove('hidden');
    	            document.getElementById('det-respDoctor').innerText = data.respDoctorName;
    	            document.getElementById('det-respDate').innerText = data.consultationRespdate;
    	            document.getElementById('det-respContent').innerText = data.consultationRespcontent;
    	        } 
    	        else if(data.consultationStatus === '002') {
    	            rejectArea.classList.remove('hidden');
    	            document.getElementById('det-rejectReason').innerText = data.consultationReason || '입력된 거절 사유가 없습니다.';
    	        } 
    	        else {
    	            const isReceived = (Number(data.consultationRespdoctor) === Number(loginDoctor));
    	            if(isReceived) {
    	                btnReject.classList.remove('hidden');
    	                btnReply.classList.remove('hidden');
    	            }
    	        }

    	        const badge = document.getElementById('det-statusBadge');
    	        if(data.consultationStatus === '001') {
    	            badge.innerText = '완료';
    	            badge.className = 'badge badge-success';
    	        } else if(data.consultationStatus === '002') {
    	            badge.innerText = '거절';
    	            badge.className = 'badge badge-danger';
    	        } else {
    	            badge.innerText = '답변 대기중';
    	            badge.className = 'badge badge-warning';
    	        }

    	    } catch(error) {
    	        console.error("상세 정보 조회 실패:", error);
    	        sweetAlert("error", "내용을 불러오지 못했습니다.");
    	    }
    	    cancelReply();
    	}
       
       function openWriteForm() { 
    	   showRightView('write'); 
    	   
    	   const input = document.getElementById('search-patient-keyword');
    	   input.readOnly = false;
    	   input.classList.remove('bg-zinc-100', 'cursor-not-allowed');
    	   
    	   document.getElementById('search-patient-keyword').value = '';
   	       document.getElementById('search-patient-result').innerHTML = '';
   	       document.getElementById('search-patient-result').classList.add('hidden');
   	       document.getElementById('selected-patient-info').classList.add('hidden');
   	       document.getElementById('write-reqContent').value = '';
   	    
   	       loadConsultDoctorList();
       }
       
       async function loadConsultDoctorList(){
    	   try{
    		   const response = await axios.get('/consultation/api/selectDoctorList');
    		   const select = document.getElementById('write-respDoctor');
    		   select.innerHTML = '<option value="">의사를 선택하세요</option>';
    	        
    	        response.data.forEach(doc => {
    	            if(Number(doc.employeeNo) !== Number(loginDoctor)) {
    	                select.innerHTML += `<option value="\${doc.employeeNo}">\${doc.employeeName} 의사</option>`;
    	            }
    	        });
    	   }catch(error){
    		   console.error("의사 목록 조회 실패", error);
    	   }
       }
       
       async function searchConsultPatient(){
    	   const keyword = document.getElementById('search-patient-keyword').value.trim();
    	   if(!keyword){
    		   return sweetAlert('info', '환자 성함 또는 번호를 입력하세요.');
    	   }
    	   
    	   const resultArea = document.getElementById('search-patient-result');
    	   resultArea.innerHTML = '<div class="p-4 text-center text-zinc-400">검색 중...</div>';
    	   resultArea.classList.remove('hidden');
    	   
    	   try{
    		  const response = await axios.get('/consultation/api/searchPatient', {
    			  params: {keyword}
    		  }) ;
    		  resultArea.innerHTML = '';
    		  
    		  if(response.data.length === 0){
    			  resultArea.innerHTML = '<p class="p-4 text-center text-zinc-400 font-medium">현재 입원 중인 환자가 없습니다.</p>';
    	          return;
    		  }
    		  
    		  response.data.forEach(p => {
    	            const html = `
    	                <div onclick="selectConsultPatient('\${p.patientNo}', '\${p.patientName}', '\${p.patientGen}', '\${p.patientAge}', '\${p.chartNo}', '\${p.employeeName}')" 
    	                     class="p-3 hover:bg-indigo-50 border-b border-zinc-100 cursor-pointer flex justify-between items-center bg-white rounded-lg mb-1 transition shadow-sm">
    	                    <div>
    	                        <span class="font-bold text-zinc-900">\${p.patientName}</span> 
    	                        <span class="text-xs text-zinc-500">(\${p.patientGen === 'MALE' ? '남' : '여'}/\${p.patientAge}세)</span>
    	                        <p class="text-[10px] text-primary font-bold">최근 차트: \${p.chartNo}</p>
    	                    </div>
    	                    <div class="text-right">
    	                        <span class="badge badge-default text-[10px]">주치의: \${p.employeeName}</span>
    	                    </div>
    	                </div>`;
    	            resultArea.insertAdjacentHTML('beforeend', html);
    	        });
    	   }catch(error){
    		   console.error("환자 검색 실패", error)
    	   }
       }
       
       let writeSelectChartNo = null;
       
       function selectConsultPatient(no, name, gen, age, chartNo, docName){
    	   writeSelectChartNo = chartNo;
    	   
    	   document.getElementById('search-patient-result').classList.add('hidden');
    	   document.getElementById('selected-patient-info').classList.remove('hidden');
    	    
    	   document.getElementById('write-patientName').innerText = name;
    	   const gender = (gen === 'MALE' || gen === '남') ? '남' : '여';
    	   document.getElementById('write-patientDetail').innerText = `| \${gender}/\${age} | No.\${no}`;
    	   const wardInfo = document.getElementById('write-wardInfo');
    	   if(wardInfo) wardInfo.innerText = `주치의: \${docName} | 대상 차트번호: \${chartNo}`;
       }
       
       function cancelWrite() { showRightView('empty'); }
       
       async function sendConsult() { 
    	   const respDoctor = document.getElementById('write-respDoctor').value;
    	   const reqContent = document.getElementById('write-reqContent').value.trim();
    	   
    	   if(!writeSelectChartNo){
    		   return sweetAlert('warning', '환자를 먼저 검색하여 선택해주세요!');
    	   }
    	   if(!respDoctor){
    		   return sweetAlert('warning', '수신 의사를 선택해주세요!');
    	   }
    	   if(!reqContent){
    		   return sweetAlert('warning', '의뢰 사유를 입력해주세요!');
    	   }
    	   
    	   const formData = {
    	   		chartNo: writeSelectChartNo,
    	   		consultationRespdoctor: respDoctor,
    	   		consultationReqcontent: reqContent,
    	   		reqDoctorName: "${employee.employeeName}", 
    	        consultationReqdoctor: loginDoctor
    	   }
    	   
    	   try{
    		   const response = await axios.post('/consultation/api/insertReqConsultation', formData);
    		   if(response.data.status === "success"){
    			   await Swal.fire("성공", "협진 의뢰가 전송되었습니다", "success");
    			   showRightView('empty');
    			   loadConsultationList();
    		   }else{
    			   sweetAlert('error', '저장에 실패했습니다.');
    		   }
    	   }catch(error){
    		   console.error("의뢰 전송 실패", error)
    	   }
       }
       
       function openReplyForm() {
    	    const btnReply = document.getElementById('btn-reply');
    	    const btnReject = document.getElementById('btn-reject');
    	    const replyArea = document.getElementById('reply-write-area');

    	    replyArea.classList.remove('hidden');

    	    btnReply.innerText = '회신 저장';
    	    btnReply.onclick = sendReply; 
    	    btnReply.classList.replace('px-8', 'px-12'); 

    	    btnReject.innerText = '작성 취소';
    	    btnReject.onclick = cancelReply;
    	    
    	    const input = document.getElementById('reply-text-input');
    	    input.value = '';
    	    input.focus();
    	    input.scrollIntoView({ behavior: 'smooth', block: 'center' });
    	}

    	function cancelReply() {
    	    const btnReply = document.getElementById('btn-reply');
    	    const btnReject = document.getElementById('btn-reject');
    	    const replyArea = document.getElementById('reply-write-area');

    	    replyArea.classList.add('hidden');

    	    btnReply.innerText = '수락 및 회신 작성';
    	    btnReply.onclick = openReplyForm;
    	    btnReply.classList.replace('px-12', 'px-8');

    	    btnReject.innerText = '거절';
    	    btnReject.onclick = openRejectModal;
    	}
       
       async function sendReply() {
    	   const respContent = document.querySelector('#reply-text-input').value.trim();
    	   
    	   if(!respContent){
    		   return sweetAlert('warning', '회신 내용을 입력해주세요!');
    	   }
    	   
    	   const formData = {
    	   		consultationNo: currentDetailNo,
    	   		consultationRespcontent: respContent,
    	   		respDoctorName: "\${employee.employeeName}"
    	   }
    	   
    	   try{
    		   const response = await axios.post('/consultation/api/updateRespConsultation', formData);
    		   
    		   if(response.data.status === "success") {
    	            await Swal.fire("성공", "협진 회신이 등록되었습니다.", "success");
    	            
    	            showRightView('empty');   
    	            loadConsultationList();   
    	        } else {
    	            sweetAlert('error', '회신 등록에 실패했습니다.');
    	        }
    	   }catch(error){
    		   console.error('회신 전송 실패', error);
    		   sweetAlert('error', '서버 통신 중 오류가 발생했습니다.')
    	   }
       }
       
       function openRejectModal() { 
    	   if(!currentDetailNo) return;
    	   
    	   const textarea = document.querySelector('#reject-modal textarea');
    	   if(textarea) textarea.value = '';
    	    
    	   document.getElementById('reject-modal').classList.remove('hidden');
       }
       
       function closeRejectModal() { document.getElementById('reject-modal').classList.add('hidden'); }
       
       async function confirmReject() { 
    	   const reason = document.querySelector('#reject-modal textarea').value.trim();
    	   
    	   if(!reason){
    		   return sweetAlert('warning', '거절 사유를 입력해주세요!');
    	   }
    	   
    	   const formData = {
    		   consultationNo: currentDetailNo,
    		   consultationReason: reason,
    		   respDoctorName: "\${employee.employeeName}"
    	   }
    	   
    	   try{
    		   const response = await axios.post('/consultation/api/updateRejectConsultation', formData);
    		   
    		   if(response.data.status === "success") {
    	            await Swal.fire("처리 완료", "협진 요청을 거절하였습니다.", "success");
    	            
    	            closeRejectModal();      
    	            showRightView('empty');  
    	            loadConsultationList();  
    	        } else {
    	            sweetAlert('error', '처리 중 오류가 발생했습니다.');
    	        }
    	   }catch(error){
    		   console.error("거절 전송 실패", error);
    	       sweetAlert('error', '서버 통신 오류가 발생했습니다.');
    	   }
       }

       async function openChartModal() {
    	    const chartNo = document.getElementById('det-chartNo').innerText;
    	    if (!chartNo || chartNo === '-') return;

    	    const imagingGrid = document.getElementById('chart-imaging-grid');
    	    const imagingEmpty = document.getElementById('chart-imaging-empty');
    	    const tbody = document.getElementById('chart-timeline-body');
    	    const summaryContainer = document.getElementById('chart-progressSummary');

    	    try {
    	        const response = await axios.get('/consultation/api/chartDetail', { params: { chartNo } });
    	        const data = response.data;
    	        
    	        if (summaryContainer) {
    	            if (data.progressNotes && data.progressNotes.length > 0) {
    	                const summaryText = data.progressNotes.map(n => 
    	                    `[\${n.progressnoteDate}] \n\${n.progressnoteContent}`
    	                ).join('\n\n----------------------------------------------------------------\n\n');
    	                
    	                summaryContainer.innerText = summaryText;
    	            } else {
    	                summaryContainer.innerText = '기록된 상세 진료 소견이 없습니다.';
    	            }
    	        }

    	        document.getElementById('chart-patientName').innerText = data.patientName;
    	        document.getElementById('chart-patientDetail').innerText = `\${data.patientGen === 'MALE' ? 'M' : 'F'} / \${data.patientAge} (\${data.patientNo})`;
    	        document.getElementById('chart-vitalsBP').innerText = data.latestPressure || '-/-';
    	        document.getElementById('chart-vitalsTemp').innerText = data.latestTemperature ? `\${data.latestTemperature}℃` : '-';
    	        document.getElementById('chart-diagnosisHistory').innerText = data.diagnosis.map(d => d.diagnosisName).join(', ') || '진단 정보 없음';

    	        let timeline = [];
    	        if(imagingGrid) imagingGrid.innerHTML = '';
    	        let imageCount = 0;

    	        if (data.drug) data.drug.forEach(item => {
    	            timeline.push({
    	                date: item.predetailRegdate || '-', name: item.drugName,
    	                dose: item.predrugDetailDose || '-', freq: item.predrugDetailFreq ? `\${item.predrugDetailFreq}회` : '-',
    	                days: item.predrugDetailDay ? `\${item.predrugDetailDay}일` : '-',
    	                type: '약', color: 'emerald', status: item.predrugDetailStatus
    	            });
    	        });

    	        if (data.treatment) data.treatment.forEach(item => {
    	            timeline.push({
    	                date: item.predetailRegdate || '-', name: item.treatmentName,
    	                dose: item.pretreatmentDetailDose || '-', freq: item.pretreatmentDetailFreq ? `\${item.pretreatmentDetailFreq}회` : '-',
    	                days: item.pretreatmentDetailDay ? `\${item.pretreatmentDetailDay}일` : '-',
    	                type: '치료', color: 'blue', status: item.pretreatmentDetailStatus
    	            });
    	        });

    	        if (data.examination) data.examination.forEach(item => {
    	            let rawPath = item.attachmentDetailPath || "";
    	            let fixedPath = rawPath.replace(/[\x01-\x09]/g, function(match) {
    	                return "/" + match.charCodeAt(0).toString(); 
    	            }).replace(/\+/g, "/53");

    	            timeline.push({
    	                date: item.predetailRegdate || '-',
    	                name: `\${item.examinationName} (\${item.preexaminationDetailSite || '전신'})`,
    	                dose: '-', freq: '1회', days: '-', type: '검사',
    	                status: item.preexaminationDetailStatus, color: 'zinc'
    	            });

    	            if (fixedPath && imagingGrid) {
    	                imageCount++;
    	                let webUrl = fixedPath.replace(/\\/g, '/').replace(/c:\/upload/i, '/upload');
    	                imagingGrid.insertAdjacentHTML('beforeend', `
    	                    <div onclick="viewExamFile('\${fixedPath}')" class="group relative rounded-2xl overflow-hidden border border-zinc-200 shadow-lg bg-black cursor-pointer h-80">
    	                        <img src="\${CONTEXT_PATH}\${webUrl}" class="w-full h-full object-cover opacity-90 group-hover:scale-105 transition duration-500">
    	                        <div class="absolute bottom-0 left-0 right-0 p-5 bg-gradient-to-t from-black/80">
    	                            <p class="text-white font-black text-sm">\${item.examinationName}</p>
    	                            <p class="text-zinc-400 text-[10px] mt-1">\${item.predetailRegdate}</p>
    	                        </div>
    	                    </div>`);
    	            }
    	        });

    	        if (imagingGrid && imagingEmpty) {
    	            imageCount > 0 ? (imagingGrid.classList.remove('hidden'), imagingEmpty.classList.add('hidden'))
    	                           : (imagingGrid.classList.add('hidden'), imagingEmpty.classList.remove('hidden'));
    	        }

    	        if (tbody) {
    	            tbody.innerHTML = '';
    	            timeline.sort((a, b) => new Date(b.date) - new Date(a.date));

    	            if (timeline.length === 0) {
    	                tbody.innerHTML = '<tr><td colspan="7" class="py-20 text-center text-zinc-400">처방 내역이 없습니다.</td></tr>';
    	            } else {
    	                timeline.forEach(row => {
    	                    tbody.insertAdjacentHTML('beforeend', `
    	                        <tr class="hover:bg-zinc-50/50 transition-colors border-b border-zinc-100">
    	                            <td class="px-6 py-4 font-mono text-xs text-zinc-500">\${row.date}</td>
    	                            <td class="px-6 py-4 font-bold text-zinc-900">\${row.name}</td>
    	                            <td class="px-6 py-4 text-zinc-600">\${row.dose}</td>
    	                            <td class="px-6 py-4 text-zinc-600">\${row.freq}</td>
    	                            <td class="px-6 py-4 text-zinc-600">\${row.days}</td>
    	                            <td class="px-6 py-4">
    	                                <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-\${row.color}-100 text-\${row.color}-700 border border-\${row.color}-200">\${row.type}</span>
    	                            </td>
    	                            <td class="px-6 py-4">
    	                                <span class="text-xs \${row.status === '001' ? 'text-zinc-400' : 'text-indigo-600 font-bold'}">
    	                                    \${row.status === '001' ? '완료' : '진행중'}
    	                                </span>
    	                            </td>
    	                        </tr>`);
    	                });
    	            }
    	        }
    	        document.getElementById('chart-modal').classList.remove('hidden');
    	    } catch (error) { console.error("차트 로드 실패", error); }
    	}
       
       function closeChartModal() { document.getElementById('chart-modal').classList.add('hidden'); }
       
       function viewExamFile(rawPath) {
    	    if (!rawPath) return;
    	    let fixedPath = rawPath.replace(/[\x01-\x09]/g, m => "/" + m.charCodeAt(0).toString())
    	                           .replace(/\+/g, "/53");
    	    let webUrl = fixedPath.replace(/\\/g, '/').replace(/C:\/upload/i, '/upload');
    	    let viewUrl = (CONTEXT_PATH === '/' ? '' : CONTEXT_PATH) + encodeURI(webUrl);
    	    window.open(viewUrl, '_blank', 'width=1100,height=850');
    	}
       
       function openNewConsultModal(patientNo) {
    	   openWriteForm(); 
    	    
    	   if (patientNo) {
    		   autoLoadPatientInfo(patientNo);
    	   }
    	}
       
       async function autoLoadPatientInfo(patientNo){
    	   try{
    		   const response = await axios.get('/consultation/api/searchPatient', {
    			   params: {keyword: patientNo}
    		   });
    		   
    		   if(response.data && response.data.length > 0) {
    			   const p = response.data[0];
    	            selectConsultPatient(
    	                p.patientNo, 
    	                p.patientName, 
    	                p.patientGen, 
    	                p.patientAge, 
    	                p.chartNo, 
    	                p.employeeName
    	            );
    	            
    	            const input = document.getElementById('search-patient-keyword');
    	            input.value = p.patientName;      
    	            input.readOnly = true;            
    	            input.classList.add('bg-zinc-100', 'cursor-not-allowed'); 
    		   } else{
    			   console.warn("전달된 번호와 일치하는 환자를 찾을 수 없습니다.");
    		   }
    	   }catch(error){
    		   console.error("자동 환자 정보 로드 실패", error);
    	   }
       }
       
       // 시연용
       function fillReplyDemo() {
           console.log("협진 회신 시연 데이터 입력");

           const replyContent = "상기 환자 검사 결과상으로는 문제 없을것으로 사료됨.";

           const el = document.getElementById('reply-text-input');
           
           if(el) {
               el.value = replyContent;
               el.focus(); 
           } else {
               console.error("'reply-text-input' 요소를 찾을 수 없습니다.");
           }
       }
       
    </script>
</body>
</html>