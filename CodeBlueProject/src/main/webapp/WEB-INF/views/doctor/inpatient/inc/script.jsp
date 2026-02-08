<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>

<script>

    const employeeCode = "${employee.employeeCode}";
    const isDoctor = (employeeCode === '1');
    
    let loginDoctor = {
        name: "${employee.employeeName}",
        licence: "${employee.employeeDetailLicence}",
        org: "${employee.hospitalName} (${employee.hospitalAddr})",
        employeeNo: Number("${employee.employeeNo}") || 0
    };

    const CONTEXT_PATH = "${pageContext.request.contextPath}";

	axios.interceptors.request.use(function (config) {
	    const token = localStorage.getItem("accessToken"); 
	    if (token) {
	        config.headers.Authorization = 'Bearer ' + token;
	    }
	    return config;
	});

  document.addEventListener("DOMContentLoaded", function() {
    loadInpatientList();
    
    const searchInput = document.getElementById('order-search-input');
    const categorySelect = document.getElementById('order-category-select');
    
    if(searchInput){
        const fetchOrders = async () => {
            const keyword = searchInput.value.trim();
            const category = categorySelect.value;
            
            try {
                const response = await axios.get('/doctor/inpatient/api/searchOrder', {
                    params: { category, keyword }
                });
                renderOrderSearchResult(response.data, category);
            } catch (error) {
                console.error("처방 검색 중 오류:", error);
            }
        };

        searchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                fetchOrders();
            }
        });

        searchInput.addEventListener('input', (e) => {
            const keyword = e.target.value.trim();
            if (keyword.length >= 1) {
                fetchOrders();
            } else {
                document.getElementById('order-search-result').innerHTML = '';
            }
        });
    }
    
  });
  
	let currentPatientNo = null;
	let detail = null;
	let currentAdmissionNo = null;
	let currentChartNo = null;
	let currentConsultantNo = null;
	let currentSearchResult = [];
	let currentOrderData = null;
	
  function switchTab(tabName) {
	  document.querySelectorAll('.tab-content').forEach(el => {
	        el.classList.remove('active');
	        el.style.display = 'none';
	    });

	    const targetTab = document.getElementById('content-' + tabName);
	    if (targetTab) {
	        targetTab.classList.add('active');
	        targetTab.style.display = 'flex'; 
	    }

	    document.querySelectorAll('.tab-btn').forEach(btn => btn.classList.remove('active', 'border-indigo-500', 'text-indigo-600'));
	    const activeBtn = document.getElementById('btn-' + tabName);
	    if (activeBtn) activeBtn.classList.add('active', 'border-indigo-500', 'text-indigo-600');
  }
  
  function switchModalTab(type){
	  let dcBtn = document.getElementById('btn-modal-dc');
	  let changeBtn = document.getElementById('btn-modal-change');
	    
	  if (type === 'DC') {
	      dcBtn.classList.add('bg-red-100');
	      changeBtn.classList.remove('bg-zinc-100');
	      processSelectedOrders('DC');
	  } else {
	      changeBtn.classList.add('bg-zinc-100');
	      dcBtn.classList.remove('bg-red-100');
	      processSelectedOrders('CHANGE');
	  }
  }

  function openModal() {
	if(!detail){
		Swal.fire({
	         title: "환자를 먼저 선택해주세요!",
	         icon: "warning",
	         customClass: {
	             confirmButton: "btn btn-primary btn-lg",
	             title: "text-xl text-primary mb-3"
	         },
	         confirmButtonText: "확인",
	         reverseButtons: true
	      });
		return;
	}
	
	const headerTitle = document.querySelector('#order-modal h2 + p');
    headerTitle.innerText = `환자: \${detail.patientName} (\${detail.patientNo}) / 주치의: \${detail.employeeName}`;
	  
    const modal = document.getElementById('order-modal');
    modal.classList.remove('hidden');
    setTimeout(() => { modal.firstElementChild.classList.add('opacity-100'); }, 10);
    
    document.getElementById('selected-order-list').innerHTML = '';
  }

/*   function openModal() {
	    const modal = document.getElementById('order-modal');
	    modal.classList.add('hidden');
	  }
   */
  function closeModal() {
    const modal = document.getElementById('order-modal');
    modal.classList.add('hidden');
  }

  function closeMacroModal() {
    const modal = document.getElementById('macro-modal');
    modal.classList.add('hidden');
  }

  function openRegularOrderModal() {
	  document.getElementById('selected-action-list').innerHTML = ''
	  
	  if(!detail || !currentOrderData) {
		  Swal.fire({
		         title: "환자 처방 정보를 찾을 수 없습니다!",
		         icon: "warning",
		         customClass: {
		             confirmButton: "btn btn-primary btn-lg",
		             title: "text-xl text-primary mb-3"
		         },
		         confirmButtonText: "확인",
		         reverseButtons: true
		      });
		  return;
	  }
	  const modalHeaderP = document.querySelector('#regular-order-modal p.text-xs');
	    
	  modalHeaderP.innerText = '환자: ' + detail.patientName + ' (' + detail.patientNo + ') / 입원일: ' + detail.admissionDate;

	  renderCurrentOrder();
	    
    document.getElementById('regular-order-modal').classList.remove('hidden');
  }
  
  function closeRegularOrderModal() {
    document.getElementById('regular-order-modal').classList.add('hidden');
  }
  
  function toggleDropdown(event, id) {
      event.stopPropagation();
      const dropdown = document.getElementById(id);
      const allDropdowns = document.querySelectorAll('.dropdown-menu');
      
      allDropdowns.forEach(d => {
          if (d.id !== id) d.classList.remove('show');
      });
      
      dropdown.classList.toggle('show');
  }
  
  function toggleAccordion(button) {
      const item = button.closest('.accordion-item');
      const accordion = button.closest('.accordion');
      const isActive = item.classList.contains('active');
      
      accordion.querySelectorAll('.accordion-item').forEach(i => {
          i.classList.remove('active');
      });
      
      if (!isActive) {
          item.classList.add('active');
      }
  }
  
  async function loadInpatientList() {
    const keyword = document.getElementById('patient-search').value;
    const locationNo = document.getElementById('ward-select').value;
    const container = document.getElementById('patient-list-container');
    const countSpan = document.getElementById('total-count');

    try {
    	
      const response = await axios.get("/doctor/inpatient/api/patientList", {
    	  params: {
              keyword: keyword,  
              locationNo : locationNo 
          }
      });

      const list = response.data.filter(patient => 
	      patient.admissionStatus === '001' || patient.admissionStatus === '002'
	  );
      
      const statusMap = {
   	      '001': { text: '재원중', color: 'bg-indigo-50 text-indigo-600 border-indigo-100', active: true },
   	      '002': { text: '퇴원대기', color: 'bg-rose-50 text-rose-600 border-rose-100', active: false },
   	      '003': { text: '수납대기', color: 'bg-orange-50 text-orange-600 border-orange-100', active: false },
   	      '004': { text: '퇴원완료', color: 'bg-zinc-100 text-zinc-500 border-zinc-200', active: false }
   	  };
      
      const insuranceMap = {
   	      '001': '건강보험',
   	      '002': '차상위1종',
   	      '003': '차상위2종',
   	      '004': '급여1종',
   	      '005': '급여2종',
   	      '006': '산재',
   	      '009': '자보',
   	      '010': '자보100',
   	      '011': '일반',
   	      '012': '일반100'
      };
      
      if (countSpan) countSpan.innerText = list.length;
      
      let html = "";
      
      if (list.length === 0) {
        html = `<li class="text-center py-10 text-zinc-400 text-sm">현재 입원 환자가 없습니다.</li>`;
      } else {
          list.forEach(patient => {
              const statusInfo = statusMap[patient.admissionStatus] || { text: '상태미정', color: 'bg-zinc-50', active: false };
              const isSelectable = statusInfo.active; 

              const borderClass = isSelectable 
              		? 'border-indigo-500 ring-2 ring-indigo-500/10 shadow-md' 
              		: 'border-zinc-200 bg-zinc-50 opacity-70';
              const roomBadgeClass = isSelectable 
              		? 'bg-zinc-800 text-white' 
              		: 'bg-zinc-400 text-white';
              const gender = (patient.patientGen === 'MALE') ? '남' : '여';
              const insuranceName = insuranceMap[patient.admissionInsurance] || patient.admissionInsurance;

              const clickAction = isSelectable 
              		? "loadPatientDetail(" + patient.patientNo + ")" 
              		: "Swal.fire({icon:'info', title:'알림', text:'퇴원 심사 중인 환자는 처방 수정이 불가합니다.'})";

              html += `
              <li class="relative">
                <div onclick="\${clickAction}" 
                     class="flex cursor-pointer flex-col rounded-xl border \${borderClass} p-4 transition \${isSelectable ? 'hover:bg-zinc-50' : 'cursor-not-allowed'}">
                  <div class="flex items-center justify-between mb-2">
                    <div class="flex items-center gap-2">
                      <span class="rounded \${roomBadgeClass} px-1.5 py-0.5 text-xs font-bold">\${patient.roomNo}호</span>
                      <span class="text-lg font-bold \${isSelectable ? 'text-zinc-900' : 'text-zinc-400'}">\${patient.patientName}</span>
                      <span class="text-xs text-zinc-500">\${gender}/\${patient.patientAge}</span>
                    </div>
                    <div class="flex flex-col items-end gap-1">
                        <span class="rounded-md \${statusInfo.color} px-2 py-0.5 text-[10px] font-bold border">
                            \${statusInfo.text}
                        </span>
                        <span class="rounded-md bg-blue-50 px-2 py-0.5 text-[10px] font-bold text-blue-600 border border-blue-100">\${insuranceName}</span>
                    </div>
                  </div>
                  <div class="text-xs text-zinc-500">
                    <p>환자번호: \${patient.patientNo}</p>
                    <p>주치의: \${patient.employeeName}</p>
                  </div>
                  \${!isSelectable ? '<div class="absolute inset-0 flex items-center justify-center rounded-xl bg-white/5 opacity-50"><i class="icon icon-lock text-zinc-400"></i></div>' : ''}
                </div>
              </li>
              `;
          });
      }
      container.innerHTML = html;

    } catch (error) {
      console.error("환자 리스트 로드 에러:", error);
    }
  }
  
  function renderOrderSearchResult(data, category){
	    const container = document.getElementById('order-search-result');
	    
	    const limitedData = data.slice(0, 30);
	    currentSearchResult = limitedData;
	    
	    const badgeMap = {
	        '001': { text: '약/주사', class: 'badge badge-warning' },
	        '002': { text: '검사', class: 'badge badge-primary' },
	        '003': { text: '치료', class: 'badge badge-success' },
	        '005': { text: '수술', class: 'badge badge-danger' },
	        '004': { text: '식이', class: 'badge badge-default' }
	    };
	    
	    if (!limitedData || limitedData.length === 0) {
	        container.innerHTML = '<div class="px-4 py-10 text-center text-xs text-zinc-400">검색 결과가 없습니다.</div>';
	        return;
	    }
	    
	    let html = "";
	    limitedData.forEach((item, index) => {
	    	const typeStr = (category === '001') ? ` | \${item.drugType || '타입미지정'}` : "";

	        html += `<button type="button" onclick="addOrderToSelect(\${index})" class="w-full px-4 py-3 text-left hover:bg-zinc-50 border-b border-zinc-100 flex items-start gap-2 transition-colors">`;
	        html += `  <span class="rounded \${badgeMap[category].class} px-1.5 py-0.5 text-[10px] font-bold shrink-0 mt-0.5">\${badgeMap[category].text}</span>`;
	        html += `  <div class="flex-1 overflow-hidden">`;
	        html += `    <p class="text-sm font-bold text-zinc-700 truncate">\${item.itemName}</p>`; 
	        html += `    <p class="text-[10px] text-zinc-400 mt-0.5">\${item.itemNo}\${typeStr}</p>`; 
	        html += `  </div>`;
	        html += `</button>`;
	    });
	    container.innerHTML = html;
	}
  
  // 처방상세내역 불러오기
  function addOrderToSelect(index) {
	  	const item = currentSearchResult[index];
	  	if (!item) return;
	  
	    const list = document.getElementById('selected-order-list');
	    
	    const duplicateSelector = '[data-code="' + item.itemNo + '"][data-category="' + item.categoryCode + '"]';
	    const isDuplicate = list.querySelector(duplicateSelector);
	    
	    if (isDuplicate) {
	        Swal.fire({ 
	            icon: 'info', 
	            title: '이미 선택된 항목입니다.',
	            text: '[' + item.itemName + '] 항목이 이미 목록에 있습니다.' 
	        });
	        return;
	    }
	    
	    const badgeMap = {
		        '001': { text: '약/주사', class: 'badge badge-warning' },
		        '002': { text: '검사', class: 'badge badge-primary' },
		        '003': { text: '치료', class: 'badge badge-success' },
		        '004': { text: '식이', class: 'badge badge-default' },
		        '005': { text: '수술', class: 'badge badge-danger' }
		    };
	    
	    let currentBadge = badgeMap[item.categoryCode];

	    let row = `<div class="grid grid-cols-12 gap-1 items-center border-b border-zinc-100 px-4 py-2 hover:bg-zinc-50 transition" 
            data-code="\${item.itemNo}" data-category="\${item.categoryCode}">`;

			row += `  <div class="col-span-1 text-center"><input type="checkbox" checked class="h-3.5 w-3.5"></div>`;
			row += `  <div class="col-span-1 text-center"><span class="rounded \${currentBadge.class} px-1 py-0.5 text-[9px] font-bold">\${currentBadge.text}</span></div>`;
			
			if (item.categoryCode === '001') {
			    row += `  <div class="col-span-3 pr-1 overflow-hidden leading-tight">
			                <p class="text-xs font-bold text-zinc-800 truncate" title="\${item.itemName}">\${item.itemName}</p>
			                <p class="text-[9px] text-zinc-400 truncate">\${item.itemNo} [\${item.drugType || '-'}]</p>
			              </div>`;
			    row += `  <div class="col-span-1"><input type="number" value="1" class="w-full rounded border border-zinc-200 py-1 text-center text-xs"></div>`;
			    row += `  <div class="col-span-1"><input type="number" value="3" class="w-full rounded border border-zinc-200 py-1 text-center text-xs"></div>`;
			    row += `  <div class="col-span-1"><input type="number" value="1" class="w-full rounded border border-zinc-200 py-1 text-center text-xs"></div>`;
			    row += `  <div class="col-span-2">
			                <select class="w-full rounded border border-zinc-200 py-1 text-[10px] h-7">
			                    <option value="PO">내복</option><option value="IV">주사(IV)</option><option value="IM">주사(IM)</option>
			                </select>
			              </div>`;
			              const isInjChecked = (item.drugType === '주사') ? 'checked' : '';
			    row += `  <div class="col-span-1 text-center">
			                <input type="checkbox" name="isInjection" class="h-3.5 w-3.5 accent-red-500" value="N" \${isInjChecked}>
			              </div>`;
			}else if(item.categoryCode === '002') {
		        row += `  <div class="col-span-3 pr-1 leading-tight">
		                    <p class="text-xs font-bold text-zinc-800 truncate">\${item.itemName}</p>
		                    <p class="text-[9px] text-zinc-400">\${item.itemNo}</p>
		                  </div>`;
		        row += `  <div class="col-span-3">
		                    <select class="w-full rounded border border-zinc-200 py-1 text-[10px] h-7" name="examSite">
		                        <option value="머리 및 얼굴">머리 및 얼굴</option><option value="경부">경부</option><option value="흉부" selected>흉부</option>
		                        <option value="상복부">상복부</option><option value="하복부">하복부</option><option value="상완부">상완부</option>
		                        <option value="주관절">주관절</option><option value="전완부">전완부</option><option value="완관절">완관절</option>
		                        <option value="수부">수부</option><option value="제 1번 수지">제 1번 수지</option><option value="제 2번 수지">제 2번 수지</option>
		                        <option value="제 3번 수지">제 3번 수지</option><option value="제 4번 수지">제 4번 수지</option><option value="제 5번 수지">제 5번 수지</option>
		                        <option value="골반">골반</option><option value="대퇴부">대퇴부</option><option value="슬관절">슬관절</option>
		                        <option value="하퇴부">하퇴부</option><option value="족관절">족관절</option><option value="족부">족부</option><option value="족지">족지</option>
		                    </select>
		                  </div>`;
		        row += `  <div class="col-span-2">
		                    <select class="w-full rounded border border-zinc-200 py-1 text-[10px] h-7" name="examLaterality">
		                        <option value="좌">좌(Left)</option>
		                        <option value="우">우(Right)</option>
		                    </select>
		                  </div>`;
		        row += `  <div class="col-span-1"><input type="number" value="1" class="w-full rounded border border-zinc-200 py-1 text-center text-xs" title="횟수"></div>`;
		    }else {
			    row += `  <div class="col-span-9 pr-2 text-[11px] text-zinc-400 truncate">\${item.itemName} (\${item.itemNo})</div>`;
			}
			
			row += `  <div class="col-span-1 text-center">
			            <button type="button" onclick="this.closest('.grid').remove()" class="text-zinc-300 hover:text-red-500">
			                <i class="icon icon-trash"></i>
			            </button>
			          </div>`;
			row += `</div>`;
			
			list.insertAdjacentHTML('beforeend', row);
	}
  
  // 환자 상세정보 불러오기
  async function loadPatientDetail(patientNo){
	  if (!patientNo) return;
	  
	  document.getElementById('detail-empty-view').classList.add('hidden');
	  document.getElementById('order-empty-view').classList.add('hidden');
	    
	  document.getElementById('detail-content-view').classList.remove('hidden');
	  document.getElementById('order-content-view').classList.remove('hidden');
	  
	  currentPatientNo = patientNo;
	  
	  try{
		  const response = await axios.get(`/doctor/inpatient/api/clinicalDetail?patientNo=\${patientNo}`);
		  detail = response.data;
		  
		  console.log("서버에서 받은 데이터:", detail);
		  
		  currentAdmissionNo = detail.admissionNo;
	      currentChartNo = detail.chartNo;
	        
	      renderBaseInfo(detail);
	        
	      renderProgressNotes(detail.progressNotes);
	      renderDiagnosis(detail.diagnosis);
	        
	      renderVitalHistory(detail.nursingCharts);
	      renderNursingRecords(detail.nursingCharts);
	      renderNursingAssessments(detail.assessments);
	        
	      renderOrderHistory(detail);
	        
	      renderExamResults(detail.examination);
	        
	      switchTab('progress');
	        
	      loadOrderList(patientNo);
		  
	  }catch(error){
		  console.error("상세 정보 로드 중 오류 발생:", error);
	      alert("데이터를 불러오는 데 실패했습니다.");
	  }
  }
  
  // 환자 기본 정보 불러오기
  function renderBaseInfo(detail){
	  const genderStr = (detail.patientGen && detail.patientGen.toUpperCase() === 'MALE') ? '남' : '여';
	  document.getElementById('det-patientName').innerText = detail.patientName;
	  document.getElementById('det-patientGen').innerText = genderStr;
	  document.getElementById('det-patientAge').innerText = detail.patientAge;
	  document.getElementById('det-patientNo').innerText = detail.patientNo;
	  
	  document.getElementById('det-v-bp').innerText = '-';
      document.getElementById('det-v-pr').innerText = '-';
      document.getElementById('det-v-bt').innerText = '-';
	  
	  const tagsContainer = document.getElementById('det-tags');
	    tagsContainer.innerHTML = '';
	    
      const today = new Date();
      today.setHours(0, 0, 0, 0);
      
      if (detail.admissionDate) {
          const admDate = new Date(detail.admissionDate);
          admDate.setHours(0, 0, 0, 0);
          const hd = Math.floor((today - admDate) / (1000 * 60 * 60 * 24)) + 1;
          
          tagsContainer.innerHTML += `
              <span class="tag tag-success px-2 py-1 text-xs font-bold rounded border">HD #\${hd}</span>
          `;
      }

      if (detail.preoperationRegdate) {
          tagsContainer.innerHTML += `
              <span class="tag tag-danger px-2 py-1 text-xs font-bold rounded border">
                  수술: \${detail.preoperationRegdate}
              </span>
          `;
      }
	  
	  if(detail.nursingCharts && detail.nursingCharts.length > 0){
		  const latest = detail.nursingCharts[0];
		  document.getElementById('det-v-bp').innerText = latest.nursingchartPressure || '-';
		  document.getElementById('det-v-pr').innerText = latest.nursingchartPulse || '-';
		  document.getElementById('det-v-bt').innerText = latest.nursingchartTemperature || '-';
	  }
  }
  
  // 간호정보조사지 불러오기
  function renderNursingAssessments(assessments){
	  if(assessments && assessments.length > 0){
		  document.getElementById('det-v-nrs').innerText = assessments[0].nursingAssessmentPainscore || '-';
	  } else {
		  document.getElementById('det-v-nrs').innerText = '-';
	  }
  }
  
  // 경과기록 불러오기
  function renderProgressNotes(notes) {
	    const list = document.getElementById('progress-note-list');
	    list.innerHTML = ''; 

	    if (!notes || notes.length === 0) {
	        list.innerHTML = '<div class="text-center py-10 text-zinc-400">기록이 없습니다.</div>';
	        return;
	    }

	    notes.forEach(note => {
	        const date = new Date(note.progressnoteDate).toLocaleString();
	        const card = `
	            <div class="card card-simple mb-4 rounded-xl border border-zinc-200 bg-white p-5 shadow-sm">
	                <div class="flex items-center justify-between mb-3">
	                    <div class="flex items-center gap-2">
	                        <span class="h-2 w-2 rounded-full bg-indigo-500"></span>
	                        <span class="text-sm font-bold text-zinc-800">\${date}</span>
	                    </div>
	                    <span class="text-xs text-zinc-400">작성자: \${note.employeeName}</span>
	                </div>
	                <div class="space-y-2 text-sm text-zinc-700 font-mono whitespace-pre-wrap">\${note.progressnoteContent}</div>
	            </div>`;
	        list.insertAdjacentHTML('beforeend', card);
	    });
	}
  
    // 진단명 불러오기
	function renderDiagnosis(list) {
	    const diagContainer = document.getElementById('diagnosis-info-area');
	    if (!diagContainer) return;
	
	    diagContainer.innerHTML = '';
	    diagContainer.className = "flex-none px-6 py-3 bg-indigo-50/30 border-b border-indigo-100 flex items-start min-h-[50px]";
	
	    const mainDiag = list ? list.find(d => d.diagnosisDetailYN === 'Y' || d.diagnosisDetailYn === 'Y') : null;
	    const subDiags = list ? list.filter(d => d.diagnosisDetailYN === 'N' || d.diagnosisDetailYn === 'N') : [];
	
	    if (!list || list.length === 0) {
	        diagContainer.innerHTML = `
	            <div class="flex items-center justify-between w-full">
	                <div class="flex items-center gap-3">
	                    <span class="text-[11px] font-black text-indigo-500 uppercase tracking-widest">Diagnosis</span>
	                    <div class="h-4 w-px bg-indigo-200"></div>
	                    <span class="text-sm text-zinc-400 italic">등록된 진단 정보가 없습니다.</span>
	                </div>
	                <button onclick="openDiagSearchModal()" class="flex items-center gap-1.5 text-xs font-bold text-indigo-600 bg-white px-4 py-1.5 rounded-lg border border-indigo-200 shadow-sm hover:bg-indigo-50 transition-all">
	                    <i class="icon icon-plus"></i> 상병 등록
	                </button>
	            </div>
	        `;
	        return;
	    }

	    diagContainer.innerHTML = `
	        <div class="flex flex-wrap items-start w-full gap-y-3 gap-x-6">
	            <div class="flex items-center gap-3 mt-1.5 shrink-0">
	                <span class="text-[11px] font-black text-indigo-500 uppercase tracking-widest">Diagnosis</span>
	                <div class="h-4 w-px bg-indigo-200"></div>
	            </div>

	            <div class="flex items-center gap-2 mt-1 shrink-0">
	                <span class="bg-red-500 text-white text-[10px] font-black px-1.5 py-0.5 rounded shadow-sm">주</span>
	                <span class="text-sm font-bold text-zinc-900">\${mainDiag ? `[\${mainDiag.diagnosisCode}] \${mainDiag.diagnosisName}` : '미등록'}</span>
	            </div>

	            <div class="flex items-start gap-2 flex-1 min-w-[300px]">
	                <span class="bg-zinc-800 text-white text-[10px] font-black px-1.5 py-0.5 rounded shadow-sm mt-1 shrink-0">부</span>
	                <div class="flex flex-wrap items-center gap-2 text-[13px] text-zinc-600 font-medium">
	                    \${subDiags.length > 0 
	                        ? subDiags.map(d => `
	                            <span class="bg-white px-2 py-0.5 rounded border border-zinc-200 shadow-sm text-zinc-700 whitespace-nowrap">
	                                [\${d.diagnosisCode}] \${d.diagnosisName}
	                            </span>`).join('')
	                        : '<span class="italic text-zinc-300 mt-1">없음</span>'}
	                </div>
	            </div>

	            <button onclick="openDiagSearchModal()" 
	                    class="ml-auto mt-1 flex items-center gap-1 text-[11px] font-bold text-indigo-600 bg-white px-3 py-1.5 rounded-lg border border-indigo-200 shadow-sm hover:bg-indigo-50 transition-all shrink-0">
	                <i class="icon icon-plus"></i> 상병 추가
	            </button>
	        </div>
	    `;
	}
	
	function openDiagSearchModal() {
	    const backdrop = document.getElementById('diagSearchBackdrop'); 
	    backdrop.style.display = 'flex';
	    backdrop.classList.remove('hidden');
	    document.getElementById('modal-diag-search-input').value = '';
	    document.getElementById('modalDiagSearchResult').innerHTML = '상병명을 입력하고 엔터를 누르세요.';
	    setTimeout(() => document.getElementById('modal-diag-search-input').focus(), 100);
	}
	
	function closeDiagModal() {
	    const backdrop = document.getElementById('diagSearchBackdrop');
	    backdrop.style.display = 'none';
	    backdrop.classList.add('hidden');
	}
	
	async function searchDiagnosisInModal(keyword) {
	    const resultArea = document.getElementById('modalDiagSearchResult');
	    if (!keyword.trim()) return;
	
	    resultArea.innerHTML = '<div class="text-center py-20 text-indigo-500 font-bold">검색 중...</div>';
	
	    try {
	        const response = await axios.get('/doctor/inpatient/api/searchOrder', {
	            params: { category: 'DIAG', keyword: keyword }
	        });
	        
	        const items = response.data.slice(0, 30);
	        if (items.length === 0) {
	            resultArea.innerHTML = '검색 결과가 없습니다.';
	            return;
	        }
	
	        let html = '<div class="grid grid-cols-1 gap-2">';
	        items.forEach(item => {
	            html += `
	                <div class="flex items-center justify-between p-4 bg-white rounded-xl border border-zinc-200 hover:border-indigo-400 transition-all">
	                    <div class="flex-1">
	                        <p class="text-[15px] font-bold text-zinc-800">\${item.itemName}</p>
	                        <p class="text-xs text-indigo-500 font-mono font-bold mt-1">\${item.itemCode || item.itemNo}</p>
	                    </div>
	                    <div class="flex gap-2">
	                        <button onclick="saveDiagFromModal('\${item.itemNo}', 'Y')" class="px-3 py-1.5 bg-red-50 text-red-600 text-[11px] font-bold rounded-lg border border-red-100 hover:bg-red-500 hover:text-white transition-all">주 진단</button>
	                        <button onclick="saveDiagFromModal('\${item.itemNo}', 'N')" class="px-3 py-1.5 bg-zinc-100 text-zinc-600 text-[11px] font-bold rounded-lg border border-zinc-200 hover:bg-zinc-800 hover:text-white transition-all">부 진단</button>
	                    </div>
	                </div>`;
	        });
	        html += '</div>';
	        resultArea.innerHTML = html;
	    } catch (e) { console.error(e); }
	}
	
	async function saveDiagFromModal(diagNo, type) {
	    if (!currentChartNo) return;
	    try {
	        await axios.post('/doctor/inpatient/api/insertDiagnosis', {
	            chartNo: currentChartNo,
	            diagnosisNo: diagNo,
	            diagnosisDetailYN: type
	        });
	        closeDiagModal();
	        loadPatientDetail(currentPatientNo); 
	        Swal.fire({ icon: 'success', title: '진단 등록 완료', timer: 800, showConfirmButton: false });
	    } catch (e) { console.error(e); }
	}

	function renderNursingRecords(records) {
	    const tbody = document.getElementById('nursing-note-list');
	    if (!tbody) return;
	    tbody.innerHTML = '';
	    
	    if (!records || records.length === 0) {
	        tbody.innerHTML = '<tr><td colspan="3" class="p-10 text-center text-zinc-400">간호 기록이 없습니다.</td></tr>';
	        return;
	    }
	
	    records.forEach(r => {
	        const dateObj = new Date(r.nursingchartDate);
	        
	        const fullDate = `\${dateObj.toLocaleDateString()} \${dateObj.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'})}`;
	        
	        const row = `
	            <tr class="hover:bg-zinc-50 border-b border-zinc-50">
	                <td class="px-6 py-4 text-zinc-500 text-xs font-medium w-52 whitespace-nowrap">\${fullDate}</td>
	                <td class="px-6 py-4 font-bold text-zinc-700 w-24">\${r.employeeName || '간호사'}</td>
	                <td class="px-6 py-4 text-zinc-800 leading-relaxed">\${r.nursingchartContent}</td>
	            </tr>`;
	            
	        tbody.insertAdjacentHTML('beforeend', row);
	    });
	}

	// 바이탈 불러오기
	function renderVitalHistory(records) {
	    const tbody = document.getElementById('vital-history-list');
	    if (!tbody) return;
	    tbody.innerHTML = '';
	    
	    if (!records || records.length === 0) {
	        tbody.innerHTML = '<tr><td colspan="3" class="p-10 text-center text-zinc-400">바이탈 기록이 없습니다.</td></tr>';
	        return;
	    }

	    records.forEach(r => {
	        const dateObj = new Date(r.nursingchartDate);
	        const row = `
	            <tr class="hover:bg-zinc-50 border-b border-zinc-50">
	                <td class="text-zinc-500 font-mono">\${dateObj.toLocaleDateString()}</td>
	                <td class="font-bold text-zinc-700">\${dateObj.toLocaleTimeString([], {hour:'2-digit', minute:'2-digit'})}</td>
	                <td class="text-indigo-600 font-black">\${r.nursingchartPressure || '-'}</td>
	                <td class="text-zinc-800 font-bold">\${r.nursingchartPulse || '-'}</td>
	                <td class="text-rose-500 font-black">\${r.nursingchartTemperature || '-'}°C</td>
	            </tr>`;
	        tbody.insertAdjacentHTML('beforeend', row);
	    });
	}
	
	// 협진의뢰 화면 변경
	function requestConsultation(){
		if(!currentPatientNo){
			Swal.fire({
	            title: "환자를 선택해주세요!",
	            icon: "warning",
	            confirmButtonText: "확인",
	            customClass: { confirmButton: "btn btn-primary" }
	        });
	        return;
		}
		location.href = CONTEXT_PATH + "/consultation/main?patientNo=" + currentPatientNo + "&action=new";
	}
	
	// 협진결과 불러오기
	function renderConsultantResult(results) {
	    const listContainer = document.getElementById('consult-result-list');
	    listContainer.innerHTML = ''; 

	    results.forEach(result => {
	        let statusText = '대기';
	        let statusClass = 'bg-amber-100 text-amber-700';
	        let contentHtml = `<p class="text-zinc-400 italic p-3 bg-zinc-50 rounded text-center text-xs">상대 의사가 확인 중입니다.</p>`;

	        if (result.consultationStatus === '001') {
	            statusText = '완료';
	            statusClass = 'bg-green-100 text-green-700';
	            contentHtml = `
	                <p class="text-indigo-600 mb-1 text-[11px] font-bold">[회신 내용]</p>
	                <p class="text-zinc-600 bg-blue-50/50 p-3 rounded border border-blue-100 text-sm">\${result.consultationRespcontent || '내용 없음'}</p>`;
	        } else if (result.consultationStatus === '002') {
	            statusText = '거절';
	            statusClass = 'bg-red-100 text-red-700';
	            contentHtml = `
	                <p class="text-red-600 mb-1 text-[11px] font-bold">[거절 사유]</p>
	                <p class="text-red-600 bg-red-50 p-3 rounded border border-red-100 text-sm">\${result.consultationReason || '사유 미입력'}</p>`;
	        }

	        const date = result.consultationReqdate ? new Date(result.consultationReqdate).toLocaleString() : '-';
	        
	        const card = `
	            <div class="card card-simple rounded-2xl border border-zinc-200 bg-white p-5 shadow-sm">
	                <div class="flex justify-between items-center mb-3 pb-2 border-b border-zinc-100">
	                    <div class="flex items-center gap-2">
	                        <span class="text-[10px] font-bold text-zinc-400 uppercase tracking-tighter">To.</span>
	                        <span class="font-bold text-zinc-800 text-sm">\${result.respDoctorName} 의사</span>
	                        <span class="text-[10px] text-zinc-400 font-mono ml-2">\${date}</span>
	                    </div>
	                    <span class="text-[10px] \${statusClass} font-bold px-2 py-0.5 rounded">\${statusText}</span>
	                </div>
	                <div class="space-y-3">
	                    <div>
	                        <p class="text-zinc-400 text-[10px] font-bold mb-1">[나의 의뢰 내용]</p>
	                        <p class="text-zinc-700 text-sm leading-relaxed">\${result.consultationReqcontent}</p>
	                    </div>
	                    <div class="pt-2 border-t border-dashed border-zinc-100">
	                        \${contentHtml}
	                    </div>
	                </div>
	            </div>
	        `;
	        listContainer.insertAdjacentHTML('beforeend', card);
	    });
	}

	// 협진 모달 열기
	async function openConsultResultModal() {
	    if (!currentPatientNo) {
	        Swal.fire("알림", "환자를 먼저 선택해주세요.", "info");
	        return;
	    }

	    try {
	        const response = await axios.get('/consultation/api/selectReqConsultPatient');
	        const myResults = response.data.filter(item => 
	            Number(item.patientNo) === Number(currentPatientNo) && 
	            Number(item.consultationReqdoctor) === loginDoctor.employeeNo
        	);
			
	        if (myResults.length === 0) {
	            Swal.fire("정보", "이 환자에 대해 직접 의뢰하신 협진 내역이 없습니다.", "info");
	            return;
	        }
	        
	        renderConsultantResult(myResults);

	        document.getElementById('consult-result-modal').classList.remove('hidden');
	    } catch (error) {
	        console.error("협진 결과 로드 실패:", error);
	    }
	}
	
	// 협진모달 닫기
	function closeConsultResultModal() {
	    document.getElementById('consult-result-modal').classList.add('hidden');
	}
	
	// 처방내역 불러오기
	function renderOrderHistory(data){
		const tbody = document.getElementById('chart-history-body');
	    if (!tbody) return;
	    tbody.innerHTML = '';

	    let timeline = [];

	    if(data.drug) {
	    	data.drug.forEach(i => timeline.push({ 
	    		date: i.predetailRegdate, 
	    		name: i.drugName, 
	    		dose: i.predrugDetailDose, 
	    		freq: i.predrugDetailFreq, 
	    		days: i.predrugDetailDay, 
	    		type: '약/주사', 
	    		status: i.predrugDetailStatus, 
	    		color: 'badge-warning' }));
	    }
	    
	    if(data.diet) {
	    	data.diet.forEach(i => timeline.push({ 
	    		date: i.predetailRegdate, 
	    		name: i.dietName, 
	    		dose: i.predietDose, 
	    		freq: i.predietFreq, 
	    		days: i.predietDay, 
	    		type: '식이', 
	    		status: i.predietStatus, 
	    		color: 'badge-default' }));
	    }
	    
	    if(data.treatment) {
	    	data.treatment.forEach(i => timeline.push({ 
	    		date: i.predetailRegdate, 
	    		name: i.treatmentName, 
	    		dose: i.pretreatmentDetailDose, 
	    		freq: i.pretreatmentDetailFreq, 
	    		days: i.pretreatmentDetailDay, 
	    		type: '치료', 
	    		status: i.pretreatmentDetailStatus, 
	    		color: 'badge-success' }));
	    }
	    
	    if(data.examination) {
	    	data.examination.forEach(i => timeline.push({ 
	    		date: i.predetailRegdate, 
	    		name: i.examinationName, 
	    		dose: '-', 
	    		freq: i.preexaminationDetailFreq, 
	    		days: i.preexaminationDetailDay, 
	    		type: '검사', 
	    		status: i.preexaminationDetailStatus, 
	    		color: 'badge-primary' }));
	    }

	    timeline.sort((a, b) => new Date(b.date) - new Date(a.date));

	    if (timeline.length === 0) {
	        tbody.innerHTML = '<tr><td colspan="7" class="p-10 text-center text-zinc-400">처방 히스토리가 없습니다.</td></tr>';
	        return;
	    }

	    timeline.forEach(row => {
	        const statusText = row.status === '001' ? '완료' : '진행중';
	        const statusClass = row.status === '001' ? 'text-zinc-400' : 'text-indigo-600 font-bold';
	        
	        tbody.innerHTML += `
	            <tr class="hover:bg-zinc-50 border-b border-zinc-50">
	                <td class="p-3 text-xs font-mono text-zinc-500">\${row.date}</td>
	                <td class="p-3 font-bold text-zinc-800">\${row.name}</td>
	                <td class="p-3 text-center text-zinc-600">\${row.dose}</td>
	                <td class="p-3 text-center text-zinc-600">\${row.freq}회</td>
	                <td class="p-3 text-center text-zinc-600">\${row.days}일</td>
	                <td class="p-3"><span class="\${row.color} px-2 py-0.5 rounded text-[10px] font-bold">\${row.type}</span></td>
	                <td class="p-3 text-xs \${statusClass}">\${statusText}</td>
	            </tr>`;
	    });
	}
	
	// 검사결과 사진 불러오기
	function renderExamResults(examList) {
	    const tbody = document.getElementById('exam-result-history-body');
	    if (!tbody) return;
	    tbody.innerHTML = '';

	    if (!examList || examList.length === 0) {
	        tbody.innerHTML = '<tr><td colspan="6" class="p-10 text-center text-zinc-400 italic">조회된 검사 내역이 없습니다.</td></tr>';
	        return;
	    }

	    examList.forEach((item, index) => {
	        const isCompleted = item.preexaminationDetailStatus === '001';
	        let rawPath = item.attachmentDetailPath || ""; 
	        let finalUrl = "";
	        let hasFile = rawPath.trim() !== "";

	        if (hasFile) {
	            let step1 = rawPath.replace(/\\/g, '/');
	            let step2 = step1.replace(/C:\/upload/i, '/upload');
	            finalUrl = encodeURI(step2);
	        }

	        let viewUrl = CONTEXT_PATH + finalUrl;
	        
	        /* 원래는 width=1100, height=850 */
	        let row = `
	            <tr class="hover:bg-zinc-50 \${hasFile ? 'cursor-pointer' : ''} border-b border-zinc-100" 
	                \${hasFile ? "onclick=\"window.open('" + viewUrl + "', '_blank', 'width=410,height=700')\"" : ""}> 
	                <td class="w-16 text-center text-zinc-400 font-mono">\${index + 1}</td>
	                <td class="w-32 text-left text-zinc-600">\${item.predetailRegdate || '-'}</td>
	                <td class="w-32 text-left font-semibold text-zinc-700">\${item.preexaminationDetailSite || '-'}</td>
	                <td class="text-left font-bold text-zinc-800">\${item.examinationName}</td>
	                <td class="w-32 text-center">
	                    <span class="badge \${isCompleted ? 'badge-success' : 'badge-primary'} inline-block">
	                        \${isCompleted ? '검사완료' : '대기중'}
	                    </span>
	                </td>
	                <td class="w-20 text-center">
	                    \${hasFile ? '<i class="icon icon-file"></i>' : '<span class="text-zinc-300">-</span>'}
	                </td>
	            </tr>`;
	        tbody.insertAdjacentHTML('beforeend', row);
	    });
	}
	
	// 처방내역 불러오기
	async function loadOrderList(patientNo){
		  if (!patientNo) return;
		  
		  currentPatientNo = patientNo;
		  
		  try{
			  const response = await axios.get(`/doctor/inpatient/api/orderList?patientNo=\${patientNo}`);
			  const order = response.data;
			  currentOrderData = response.data;
			  
			  console.log("서버에서 받은 데이터:", order);
			  
			  currentAdmissionNo = order.admissionNo;
			  currentChartNo = order.chartNo;
			  
			  renderDiet(order);
			  renderDrug(order);
			  renderTreatment(order);
			  renderExamination(order);
			  renderOperation(order);
			  
		  }catch(error){
			  console.error("상세 정보 로드 중 오류 발생:", error);
		      alert("데이터를 불러오는 데 실패했습니다.");
		  }
	  }
	
	// 식이처방 불러오기
	function renderDiet(order){
		const container = document.getElementById('diet-items-area');
	    if (!container) return;
	    container.innerHTML = '';

	    if (!order.diet || order.diet.length === 0) {
	        container.innerHTML = '<div class="text-center py-6 text-zinc-400 text-xs italic">식이 처방 내역이 없습니다.</div>';
	        return;
	    }

	    let html = "";
	    order.diet.forEach(item => {
	        const isCompleted = item.predietStatus === '001';
	        const statusBadge = isCompleted 
		        ? '<span class="badge badge-success shrink-0 ml-auto text-[10px] px-1.5 py-0.5 rounded">완료</span>'
		        : '<span class="badge badge-primary shrink-0 ml-auto text-[10px] px-1.5 py-0.5 rounded">진행중</span>';

	        html += `
	            <div class="rounded-lg border \${isCompleted ? 'border-zinc-100 opacity-60' : 'border-zinc-200'} bg-white p-3 shadow-sm hover:border-indigo-300 transition mb-2">
	               <div class="flex flex-col gap-1">
	                  <div class="flex items-center gap-2">
	                  <i class="icon icon-drug"></i>
	                    <span class="text-sm font-bold \${isCompleted ? 'text-zinc-400' : 'text-zinc-800'}">\${item.dietName}</span>
	                    \${statusBadge}
	                  </div>
	                  
	                  <div class="flex items-center gap-3 mt-1 pl-5">
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.predietDose}</span> <span class="text-[10px]">용량</span>
	                    </p>
	                    <span class="h-1 w-1 rounded-full bg-zinc-200"></span>
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.predietFreq}</span> <span class="text-[10px]">회/일</span>
	                    </p>
	                    <span class="h-1 w-1 rounded-full bg-zinc-200"></span>
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.predietDay}</span> <span class="text-[10px]">일분</span>
	                    </p>
	                  </div>
	               </div>
	            </div>
	        `;
	    });

	    container.innerHTML = html;
	}
	// 약처방 불러오기
	function renderDrug(order){
		const container = document.getElementById('drug-items-area');
	    if (!container) return;
	    container.innerHTML = '';

	    if (!order.drug || order.drug.length === 0) {
	        container.innerHTML = '<div class="text-center py-6 text-zinc-400 text-xs italic">약/주사 처방 내역이 없습니다.</div>';
	        return;
	    }

	    let html = "";
	    order.drug.forEach(item => {
	        const isCompleted = item.predrugDetailStatus === '001';
	        const typeLabel = (item.predrugDetailType === 'Y') ? '약' : '주사';
	        const statusBadge = isCompleted 
		        ? '<span class="badge badge-success shrink-0 ml-auto text-[10px] px-1.5 py-0.5 rounded">완료</span>'
		        : '<span class="badge badge-primary shrink-0 ml-auto text-[10px] px-1.5 py-0.5 rounded">진행중</span>';
		        
	        html += `
	            <div class="rounded-lg border \${isCompleted ? 'border-zinc-100 opacity-60' : 'border-zinc-200'} bg-white p-3 shadow-sm hover:border-indigo-300 transition mb-2">
	               <div class="flex flex-col gap-1">
	                  <div class="flex items-center gap-2">
	                  <i class="icon icon-drug"></i>
	                    <span class="text-sm font-bold \${isCompleted ? 'text-zinc-400' : 'text-zinc-800'}">\${item.drugName}</span>
	                    \${statusBadge}
	                  </div>
	                  
	                  <div class="flex items-center gap-3 mt-1 pl-5">
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.predrugDetailDose}</span> <span class="text-[10px]">용량</span>
	                    </p>
	                    <span class="h-1 w-1 rounded-full bg-zinc-200"></span>
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.predrugDetailFreq}</span> <span class="text-[10px]">회/일</span>
	                    </p>
	                    <span class="h-1 w-1 rounded-full bg-zinc-200"></span>
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.predrugDetailDay}</span> <span class="text-[10px]">일분</span>
	                    </p>
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${typeLabel}</span> <span class="text-[10px]">구분</span>
	                    </p>
	                  </div>
	               </div>
	            </div>
	        `;
	    });

	    container.innerHTML = html;
	}
	
	// 치료처방 불러오기
	function renderTreatment(order){
		const container = document.getElementById('treatment-items-area');
	    if (!container) return;
	    container.innerHTML = '';

	    if (!order.treatment || order.treatment.length === 0) {
	        container.innerHTML = '<div class="text-center py-6 text-zinc-400 text-xs italic">처치/치료 처방 내역이 없습니다.</div>';
	        return;
	    }

	    let html = "";
	    order.treatment.forEach(item => {
	        const isCompleted = item.pretreatmentDetailStatus === '001';
	        const statusBadge = isCompleted 
		        ? '<span class="badge badge-success shrink-0 ml-auto text-[10px] px-1.5 py-0.5 rounded">완료</span>'
		        : '<span class="badge badge-primary shrink-0 ml-auto text-[10px] px-1.5 py-0.5 rounded">대기</span>';

	        html += `
	            <div class="rounded-lg border \${isCompleted ? 'border-zinc-100 opacity-60' : 'border-zinc-200'} bg-white p-3 shadow-sm hover:border-indigo-300 transition mb-2">
	               <div class="flex flex-col gap-1">
	                  <div class="flex items-center gap-2">
	                  <i class="icon icon-drug"></i>
	                    <span class="text-sm font-bold \${isCompleted ? 'text-zinc-400' : 'text-zinc-800'}">\${item.treatmentName}</span>
	                    \${statusBadge}
	                  </div>
	                  
	                  <div class="flex items-center gap-3 mt-1 pl-5">
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.pretreatmentDetailDose}</span> <span class="text-[10px]">용량</span>
	                    </p>
	                    <span class="h-1 w-1 rounded-full bg-zinc-200"></span>
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.pretreatmentDetailFreq}</span> <span class="text-[10px]">회/일</span>
	                    </p>
	                    <span class="h-1 w-1 rounded-full bg-zinc-200"></span>
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.pretreatmentDetailDay}</span> <span class="text-[10px]">일분</span>
	                    </p>
	                  </div>
	               </div>
	            </div>
	        `;
	    });

	    container.innerHTML = html;
	}
	
	// 검사처방 불러오기
	function renderExamination(order){
		const container = document.getElementById('test-items-area');
	    if (!container) return;
	    container.innerHTML = '';

	    if (!order.examination || order.examination.length === 0) {
	        container.innerHTML = '<div class="text-center py-6 text-zinc-400 text-xs italic">검사 처방 내역이 없습니다.</div>';
	        return;
	    }

	    let html = "";
	    order.examination.forEach(item => {
	        const isCompleted = item.preexaminationDetailStatus === '001';
	        const statusBadge = isCompleted 
		        ? '<span class="badge badge-success shrink-0 ml-auto text-[10px] px-1.5 py-0.5 rounded">완료</span>'
		        : '<span class="badge badge-primary shrink-0 ml-auto text-[10px] px-1.5 py-0.5 rounded">대기</span>';

	        html += `
	            <div class="rounded-lg border \${isCompleted ? 'border-zinc-100 opacity-60' : 'border-zinc-200'} bg-white p-3 shadow-sm hover:border-indigo-300 transition mb-2">
	               <div class="flex flex-col gap-1">
	                  <div class="flex items-center gap-2">
	                  <i class="icon icon-drug"></i>
	                    <span class="text-sm font-bold \${isCompleted ? 'text-zinc-400' : 'text-zinc-800'}">\${item.examinationName}</span>
	                    \${statusBadge}
	                  </div>
	                  
	                  <div class="flex items-center gap-3 mt-1 pl-5">
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.preexaminationDetailSite}</span> <span class="text-[10px]">부위</span>
	                    </p>
	                    <span class="h-1 w-1 rounded-full bg-zinc-200"></span>
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.preexaminationDetailFreq}</span> <span class="text-[10px]">회/일</span>
	                    </p>
	                    <span class="h-1 w-1 rounded-full bg-zinc-200"></span>
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.preexaminationDetailDay}</span> <span class="text-[10px]">일분</span>
	                    </p>
	                    <p class="text-xs text-zinc-500">
	                        <span class="font-semibold text-zinc-700">\${item.preexaminationDetailLaterality}</span> <span class="text-[10px]">방향</span>
	                    </p>
	                  </div>	
	               </div>
	            </div>
	        `;
	    });

	    container.innerHTML = html;
	}
	
	// 수술처방 불러오기
	function renderOperation(order){
		const container = document.getElementById('surgery-items-area');
	    if (!container) return;
	    container.innerHTML = '';

	    if (!order.operation || order.operation.length === 0) {
	        container.innerHTML = '<div class="text-center py-6 text-zinc-400 text-xs italic">수술 처방 내역이 없습니다.</div>';
	        return;
	    }

	    let html = "";
	    order.operation.forEach(item => {
	    	console.log("수술 항목 데이터:", item);
	        const isCompleted = item.preoperationStatus === '001';
	        const isWaiting = item.preoperationStatus === '002';
	        const statusBadge = isCompleted 
	            ? '<span class="text-emerald-500 font-bold text-[10px] ml-auto">완료</span>'
	            : '<span class="text-rose-500 font-bold text-[10px] ml-auto">대기</span>';
	        
            let opDate = item.preoperationRegdate || '미정';
            if (opDate !== '미정' && opDate.length > 16) opDate = opDate.substring(0, 16);

	        let confirmBtn = "";
	        if (isWaiting) {
	            confirmBtn = `
	                <button onclick="confirmSurgery(\${item.predetailNo}, \${item.operationNo})" 
	                        class="ml-2 bg-indigo-500 hover:bg-indigo-600 text-white text-[10px] px-2 py-1 rounded transition shadow-sm">
	                    완료
	                </button>`;
	        }    
		    
	        html += `
	            <div class="rounded-lg border \${isCompleted ? 'border-zinc-100 opacity-60' : 'border-zinc-200'} bg-white p-3 shadow-sm hover:border-indigo-300 transition mb-2">
	               <div class="flex flex-col gap-1">
	                  <div class="flex items-center gap-2">
	                    <i class="icon icon-surgery text-rose-500"></i> <span class="text-sm font-bold \${isCompleted ? 'text-zinc-400' : 'text-zinc-800'}">\${item.operationName}</span>
	                    \${statusBadge}
	                  </div>
	                  
	                  <div class="flex items-center gap-2 mt-0.5 pl-5 text-[11px]">
	                    <p class="text-zinc-500">
	                        <span class="text-zinc-400">집도의:</span> 
	                        <span class="font-bold \${item.employeeName ? 'text-indigo-600' : 'text-zinc-300'}">\${item.employeeName || '미지정'}</span>
	                    </p>
	                    <span class="w-px h-2 bg-zinc-200"></span>
	                    <p class="text-zinc-500">
	                        <span class="text-zinc-400">수술일자:</span>
	                        <span class="font-semibold text-zinc-700">\${opDate}</span> 
	                    </p>
	                  </div>
	               </div>
	            </div>
	        `;
	    });

	    container.innerHTML = html;
	}
	
	// 수술처방 상태값 변경
	async function confirmSurgery(predetailNo, operationNo) {
	    const { isConfirmed } = await Swal.fire({
	        title: '수술을 확정하시겠습니까?',
	        text: '상태가 완료로 변경되며 수술일이 오늘로 기록됩니다.',
	        icon: 'question',
	        showCancelButton: true,
	        confirmButtonText: '확정',
	        cancelButtonText: '취소',
	        reverseButtons: true
	    });

	    if (isConfirmed) {
	        const updateList = [{
	            actionType: 'CONFIRM',  
	            predetailNo: predetailNo,
	            operationNo: operationNo,
	            categoryCode: '005',
	            chartNo: currentChartNo,
	            employeeNo: loginDoctor.employeeNo 
	        }];

	        try {
	            const response = await axios.post('/doctor/inpatient/api/updatePrescription', updateList);

	            if (response.data.status === "success") {
	                Swal.fire({ icon: 'success', title: '확정 완료', timer: 800, showConfirmButton: false });
	                loadOrderList(currentPatientNo); 
	            } else {
	                Swal.fire("오류", response.data.message || "처리에 실패했습니다.", "error");
	            }
	        } catch (error) {
	            console.error("수술 확정 에러:", error);
	            Swal.fire("오류", "상태 변경 중 서버 에러가 발생했습니다.", "error");
	        }
	    }
	}
	
	// order-modal 처방추가 모달 불러오기
	function renderCurrentOrder(){
	    const container = document.getElementById('current-order-list-modal');
	    container.innerHTML = '';
	
	    if (!currentOrderData) {
	        container.innerHTML = '<div class="text-center py-10 text-zinc-400 text-xs">처방 내역이 없습니다.</div>';
	        return;
	    }
	
	    let html = "";
	    
	    const processCategory = (items, typeName, typeCode) => {
	        if (!items || items.length === 0) return;
	        
	        html += `<div class="text-[10px] font-bold text-zinc-400 mt-4 mb-2 px-1 border-b border-zinc-100">\${typeName}</div>`;
	        
	        items.forEach(i => {
	            if(i.status === '004') return;
	            
	            let info = "";
	            let code = "";
	            let inj = i.predrugDetailType || "";
	            
	            if(typeCode === '001') { info = i.predrugDetailFreq + '회/일'; code = i.drugNo; }
	            else if(typeCode === '004') { info = '매끼'; code = i.dietNo; }
	            else if(typeCode === '003') { info = i.pretreatmentDetailFreq + '회/일'; code = i.treatmentNo; }
	            else if(typeCode === '002') { info = '1회'; code = i.examinationNo; }
	
	            html += `
	                <label class="flex items-start gap-3 p-3 rounded-lg border border-zinc-200 cursor-pointer hover:bg-zinc-50 transition mb-2 bg-white">
	                    <input type="checkbox" class="mt-1 h-4 w-4 rounded text-indigo-600 focus:ring-indigo-500" 
	                           data-code="\${code}" data-type="\${typeCode}" data-predetail="\${i.predetailNo}" data-inj="\${inj}">
	                    <div>
	                        <p class="text-sm font-bold text-zinc-800">\${i.drugName || i.dietName || i.treatmentName || i.examinationName}</p>
	                        <p class="text-xs text-zinc-500">\${info} / \${typeName}</p>
	                    </div>
	                </label>`;
	        });
	    };
	
	    processCategory(currentOrderData.diet, '식이', '004');
	    processCategory(currentOrderData.drug, '약/주사', '001');
	    processCategory(currentOrderData.treatment, '처치/치료', '003');
	    processCategory(currentOrderData.examination, '검사', '002');
	
	    if (html === "") {
	        container.innerHTML = '<div class="text-center py-10 text-zinc-400">진행 중인 처방이 없습니다.</div>';
	    } else {
	        container.innerHTML = html;
	    }
	}
	
	// 처방추가 모달 전체삭제
	function clearSelectedOrders() {
	    var list = document.getElementById('selected-order-list');
	    
	    if (list.children.length === 0) {
	        Swal.fire({ icon: 'info', title: '삭제할 처방이 없습니다.' });
	        return;
	    }

	    Swal.fire({
	        title: '정말 전체 삭제하시겠습니까?',
	        text: '선택한 모든 처방 항목이 사라집니다.',
	        icon: 'warning',
	        showCancelButton: true,
	        customClass: {
	             confirmButton: "btn btn-primary btn",
	             cancelButton: "btn btn-secondary  btn",
	             title: "text-xl text-primary mb-3"
	         },
	        confirmButtonText: '전체 삭제',
	        cancelButtonText: '취소',
	        reverseButtons: true
	    }).then(function(result) {
	        if (result.isConfirmed) {
	            list.innerHTML = '';
	            
	            Swal.fire({
	                icon: 'success',
	                title: '목록이 비워졌습니다.',
	                timer: 3000,
	                showConfirmButton: false
	            });
	        }
	    });
	}
	
	// regular-order-modal 정규처방 불러오기
	function processSelectedOrders(actionType) {
	    let leftList = document.getElementById('current-order-list-modal');
	    let rightList = document.getElementById('selected-action-list');
	    
	    if (!leftList || !rightList) return;

	    let checkedInputs = leftList.querySelectorAll('input:checked');
	    
	    if (checkedInputs.length === 0) {
	        Swal.fire({ icon: 'info', title: '항목을 먼저 선택해주세요.' });
	        return;
	    }

	    if (rightList.querySelector('.icon-pharmacy')) {
	        rightList.innerHTML = '';
	    }

	    checkedInputs.forEach(function(input) {
	    	let label = input.closest('label');
	    	let name = label.querySelector('p.text-sm').innerText;
	    	let info = label.querySelector('p.text-xs').innerText;
	    	let code = input.getAttribute('data-code');
	    	let type = input.getAttribute('data-type');
	    	let predetailNo = input.getAttribute('data-predetail');
	    	let isInjOrigin = input.getAttribute('data-inj');

	    	let bgColor = (actionType === 'DC') ? 'bg-red-50' : 'bg-blue-50';
	    	let textColor = (actionType === 'DC') ? 'text-red-600' : 'text-blue-600';
	    	let badgeText = (actionType === 'DC') ? '중단' : '변경';

	    	let html = '<div class="action-item-card p-4 rounded-lg border border-zinc-200 ' + 
	    		bgColor + ' mb-3 transition-all" data-code="' + code + '" data-predetail="' + 
	    			predetailNo + '" data-action="' + actionType + '" data-type="' + type + '">';

	    	html += '    <div class="flex justify-between items-start mb-2">';
	    	html += '        <div>';
	    	html += '            <p class="text-sm font-bold text-zinc-800">' + name + '</p>';
	    	html += '            <span class="text-[10px] font-bold ' + textColor + ' border px-1.5 py-0.5 rounded">' + badgeText + ' 예정</span>';
	    	html += '        </div>';
	    	html += '        <button type="button" onclick="event.preventDefault(); event.stopPropagation(); this.closest(\'.action-item-card\').remove()" class="text-zinc-400 hover:text-zinc-600 text-xl">×</button>';
	    	html += '    </div>';

	    	if (actionType === 'CHANGE') {
	    	    html += '    <div class="grid grid-cols-4 gap-2 mt-3 pt-3 border-t border-blue-100">';
	    	    html += '        <div><label class="block text-[10px] font-bold text-blue-400 mb-1">용량</label><input type="text" class="w-full border border-blue-200 rounded px-2 py-1 text-xs" value="1"></div>';
	    	    html += '        <div><label class="block text-[10px] font-bold text-blue-400 mb-1">횟수</label><input type="number" class="w-full border border-blue-200 rounded px-2 py-1 text-xs" value="3"></div>';
	    	    html += '        <div><label class="block text-[10px] font-bold text-blue-400 mb-1">일수</label><input type="number" class="w-full border border-blue-200 rounded px-2 py-1 text-xs" value="1"></div>';
	    	    
	    	    html += '        <div class="flex flex-col items-center justify-center">';
	    	    html += '            <label class="block text-[10px] font-bold text-red-400 mb-1">주사</label>';
	    	    if (type === '001') {
	    	    	let checkedAttr = (isInjOrigin === 'N') ? 'checked' : '';
	    	    	html += '        <input type="checkbox" name="isInjection" class="h-4 w-4 accent-red-500" value="N" ' + checkedAttr + '>';
	    	    } else {
	    	        html += '        <span class="text-zinc-300 text-[10px]">-</span>';
	    	    }
	    	    html += '        </div>';
	    	    html += '    </div>';
	    	} else {
	            html += '    <p class="text-xs text-zinc-500 mt-1 italic">' + info + ' 처방이 중단됩니다.</p>';
	        }
	        
	        html += '</div>';

	        rightList.insertAdjacentHTML('beforeend', html);
	        input.checked = false; 
	    });
	}
	
	// 경과기록지 입력
	async function insertProgressNote() {
		const inputField = document.getElementById('progress-input');
		const content = inputField.value.trim();
		
		console.log("저장 시도 - 차트번호:", currentChartNo, "내용:", content);

	    if (!currentChartNo) {
	        Swal.fire({ icon: 'error', title: '입원 차트 정보를 찾을 수 없습니다.' });
	        return;
	    }
	    if (!content) {
	        Swal.fire({ icon: 'info', title: '기록 내용을 입력하세요.' });
	        inputField.focus();
	        return;
	    }
	    
	    const { isConfirmed } = await Swal.fire({
	        title: '경과 기록을 저장하시겠습니까?',
	        text: "작성하신 내용을 차트에 영구히 기록합니다.",
	        icon: 'question',
	        showCancelButton: true,
	        confirmButtonColor: '#4f46e5', 
	        cancelButtonColor: '#6b7280',
	        confirmButtonText: '저장',
	        cancelButtonText: '취소',
	        reverseButtons: true 
	    });

	    if (isConfirmed) {
	        const noteData = {
	            chartNo: parseInt(currentChartNo), 
	            progressnoteContent: content
	        };
		    try {
		        const response = await axios.post('/doctor/inpatient/api/insertProgress', noteData);
	
		        if (response.data.status === "success") {
		            Swal.fire({ 
		                icon: 'success', 
		                title: '저장 완료', 
		                timer: 1000, 
		                showConfirmButton: false 
		            });
		            
		            inputField.value = '';
		            
		            loadPatientDetail(currentPatientNo); 
		        } else {
		            Swal.fire({ icon: 'error', title: '저장 실패', text: response.data.message });
		        }
		    } catch (error) {
		        console.error("저장 중 에러 발생:", error);
		    }
	    }
	}
	
	// 처방 추가
	async function insertPrescription(){
		if (!currentChartNo) {
			sweetAlert("warning", "입원 차트 정보가 없습니다.");
	        return;
	    }
		
		const list = document.getElementById('selected-order-list');
	    const rows = list.querySelectorAll('[data-code]'); 

	    if (rows.length === 0) {
	        Swal.fire({ icon: 'warning', title: '추가할 처방이 없습니다.' });
	        return;
	    }

	    const grouped = {};

	    rows.forEach(row => {
	        const isChecked = row.querySelector('input[type="checkbox"]').checked;
	        if (!isChecked) return;

	        const category = row.getAttribute('data-category'); 
	        const itemNo = row.getAttribute('data-code');
	        const numInputs = row.querySelectorAll('input[type="number"]');
	        const existingPredetailNo = row.getAttribute('data-predetail');

	        if (!grouped[category]) {
	            grouped[category] = {
	                predetailType: category,
	                chartNo: currentChartNo,
	                drugList: [], 
	                examList: [], 
	                treatList: [], 
	                dietList: [], 
	                operList: []
	            };
	        }

	        if (category === '001') { // 약/주사 (DrugVO)
	        	const typeCheckbox = row.querySelector('input[name="isInjection"]');
	        	const injCheck = row.querySelector('input[name="isInjection"]');
	        
	            grouped[category].drugList.push({
	                drugNo: itemNo,
	                predrugDetailDose: numInputs[0]?.value || 1,
	                predrugDetailFreq: numInputs[1]?.value || 3,
	                predrugDetailDay: numInputs[2]?.value || 1,
	                predrugDetailMethod: row.querySelector('select')?.value || '내복',
               		predrugDetailType: (injCheck && injCheck.checked) ? 'N' : 'Y'
	            });
	        } 
	        else if (category === '002') { // 검사 (ExaminationVO)
            	const siteSelect = row.querySelector('select[name="examSite"]');
                const lateralitySelect = row.querySelector('select[name="examLaterality"]');
                
	            grouped[category].examList.push({
	                examinationNo: itemNo,
	                preexaminationDetailFreq: numInputs[0]?.value || 1,
	                preexaminationDetailDay: numInputs[1]?.value || 1,
	                preexaminationDetailSite: siteSelect?.value || '흉부',
	                preexaminationDetailLaterality: lateralitySelect?.value || '우'
	            });
	        } 
	        else if (category === '003') { // 치료 (TreatmentVO)
	            grouped[category].treatList.push({
	                treatmentNo: itemNo,
	                pretreatmentDetailDose: numInputs[0]?.value || 1,
	                pretreatmentDetailFreq: numInputs[1]?.value || 1,
	                pretreatmentDetailDay: numInputs[2]?.value || 1,
	                		
	            });
	        } 
	        else if (category === '004') { // 식이 (DietVO)
	            grouped[category].dietList.push({
	                dietNo: itemNo,
	                predietDose: numInputs[0]?.value || 3,
	                predietFreq: numInputs[1]?.value || 1,
	                predietDay: numInputs[2]?.value || 1
	            });
	        }
	        else if (category === '005') { // 수술 (OperationVO)
	            grouped[category].operList.push({
	                operationNo: itemNo,
	                predetailNo: existingPredetailNo ? Number(existingPredetailNo) : 0,
               		employeeNo: loginDoctor.employeeNo
	            });
	        }
	    });

	    const prescriptionList = Object.values(grouped);

	    if (prescriptionList.length === 0) {
	        sweetAlert("info", "저장할 항목을 체크해주세요.");
	        return;
	    }
	    
	    const { isConfirmed } = await Swal.fire({
	        title: '처방을 저장하시겠습니까?',
	        text: "선택한 모든 항목이 환자 차트에 즉시 반영됩니다.",
	        icon: 'question',
	        showCancelButton: true,
	        confirmButtonColor: '#4f46e5', 
	        cancelButtonColor: '#6b7280',
	        confirmButtonText: '저장하기',
	        cancelButtonText: '취소',
	        reverseButtons: true
	    });
	    if (isConfirmed) {
		    try {
		        const response = await axios.post('/doctor/inpatient/api/insertPrescription', prescriptionList);
		        if (response.data.status === "success") {
		            Swal.fire({ 
		            	icon: 'success', 
		            	title: '처방 저장 완료', 
		            	timer: 1000, 
		            	showConfirmButton: false });
		            closeModal();
		            loadOrderList(currentPatientNo); 
		        }
		    } catch (error) {
		        console.error("저장 중 오류:", error);
		    }
	    }
	}
	
	// 정규처방 변경
	async function insertRegularOrderChanges(){
		const list = document.getElementById('selected-action-list');
	    const items = list.querySelectorAll('.action-item-card');

	    if (items.length === 0) {
	    	sweetAlert("warning", "변경할 내역이 없습니다.");
	        return;
	    }

	    const updateList = Array.from(items).map(card => {
	        const action = card.getAttribute('data-action');
	        const category = card.getAttribute('data-type');
	        
	        const data = {
	            actionType: action,
	            predetailNo: Number(card.getAttribute('data-predetail')),
	            itemNo: Number(card.getAttribute('data-code')),
	            categoryCode: category,
	            chartNo: currentChartNo 
	        };

	        if (action === 'CHANGE') {
	            const inputs = card.querySelectorAll('input');
	            const injCheck = card.querySelector('input[name="isInjection"]');
	            
	            data.dose = Number(inputs[0].value);
	            data.freq = Number(inputs[1].value);
	            data.days = Number(inputs[2].value);
	            
	            if (category === '001') {
	                data.drugType = (injCheck && injCheck.checked) ? 'N' : 'Y';
	            }
	        }
	        
	        return data;
	    });

	    try {
	        const response = await axios.post('/doctor/inpatient/api/updatePrescription', updateList);
	        
	        if (response.data.status === "success") {
	            Swal.fire({ 
	                icon: 'success', 
	                title: '처방 변경이 완료되었습니다.', 
	                timer: 1500, 
	                showConfirmButton: false 
	            });
	            
	            closeRegularOrderModal();
	            loadOrderList(currentPatientNo); 
	        } else {
	            Swal.fire({ icon: 'error', title: '변경 실패', text: response.data.message });
	        }
	    } catch (error) {
	        console.error("정규 처방 변경 중 오류:", error);
	    }
	}
	
	// 서류 모달 열기
	async function openIpDocModal(type, chartNo) {
	    const targetChartNo = chartNo || currentChartNo; 
	    
	    if (!targetChartNo) return Swal.fire("경고", "진료 차트를 먼저 선택해주세요!", "warning");

	    const isDx = (type === 'dx');
	    const modalId = isDx ? "#ipDxModal" : "#ipOpModal";
	    const prefix = isDx ? "dx" : "op"; 
	    const typeName = isDx ? "진단서" : "소견서";

	    document.getElementById(`\${prefix}Content`).value = "";
	    document.getElementById(`\${prefix}Remark`).value = "";
	    document.getElementById(`\${prefix}Purpose`).value = "";
	    document.getElementById(`\${prefix}DxDate`).value = new Date().toISOString().substring(0, 10);

	    try {
	        const response = await axios.get('/certificate/api/patientDocDetail', {
	            params: { 
	            	docType: 'CERT', 
	            	certificateNo: isDx ? 1 : 2, 
	            	chartNo: targetChartNo 
	            }
	        });
	        
	        const d = (response.data && response.data.length > 0) ? response.data[0] : response.data;
	        
	        if (d && d.medicalCertificateContent) {
	            return Swal.fire({
	                icon: 'info',
	                title: `이미 작성된 \${typeName}가 있습니다.`,
	                text: "기존 문서를 수정하시거나 새로 출력해 주세요.",
	                confirmButtonColor: '#4f46e5'
	            });
	        }
	        
	        document.querySelector(modalId).classList.remove("hidden");
		    document.querySelector(modalId).classList.add("flex");
	        
	        const pName = d.patientName || (detail ? detail.patientName : "");
	        const pReg1 = d.patientRegno1 || (detail ? detail.patientNo : ""); 
	        const pAddr = d.patientAddr1 ? `\${d.patientAddr1} \${d.patientAddr2 || ''}` : "";
	        const pTel  = d.patientTel || "";

	        document.getElementById(`\${prefix}PatientName`).value = pName;
	        document.getElementById(`\${prefix}Rrn`).value = pReg1 ? `\${pReg1}-*******` : "";
	        document.getElementById(`\${prefix}Address`).value = pAddr;
	        document.getElementById(`\${prefix}Phone`).value = pTel;
	        
	        document.getElementById(`\${prefix}Org`).value = d.hospitalName ? `\${d.hospitalName} (\${d.hospitalAddr})` : loginDoctor.org;
	        document.getElementById(`\${prefix}Licence`).value = d.employeeDetailLicence || loginDoctor.licence;
	        document.getElementById(`\${prefix}DoctorName`).value = d.employeeName || loginDoctor.name;

	        const tbody = document.getElementById(`\${prefix}DxTbody`);
	        tbody.innerHTML = "";
	        
	        let diagList = [];
	        if (d && d.diagnosisList && d.diagnosisList.length > 0) {
	            diagList = d.diagnosisList;
	        } else if (detail && detail.diagnosis && detail.diagnosis.length > 0) {
	            diagList = detail.diagnosis;
	        }

	        if (diagList.length > 0) {
	            diagList.forEach((diag, idx) => {
	                const ynValue = diag.diagnosisDetailYN || diag.diagnosisDetailYn;
	                const typeText = ynValue === 'Y' ? '주' : '부';
	                
	                tbody.innerHTML += `
	                    <tr class="border-b border-zinc-50 text-center">
	                        <td class="p-3 text-zinc-500 font-bold">\${typeText}</td>
	                        <td class="p-3 text-zinc-500 font-mono text-sm">\${diag.diagnosisCode}</td>
	                        <td class="p-3 text-zinc-700 font-medium text-left px-4">\${diag.diagnosisName}</td>
	                    </tr>`;
	            });
	        } else {
	            tbody.innerHTML = '<tr><td colspan="3" class="p-10 text-center text-zinc-400">등록된 상병 정보가 없습니다.</td></tr>';
	        }
	    } catch (e) {
	        console.error("모달 데이터 로딩 중 에러:", e);
	    }
	}

	// 서류 모달 닫기
	function closeIpDocModal(type) {
	    const id = type === 'dx' ? "#ipDxModal" : "#ipOpModal";
	    document.querySelector(id).classList.add("hidden");
	    document.querySelector(id).classList.remove("flex");
	}

	// 진단서, 소견서 입력
	async function insertCertificate(type) {
	    const prefix = type;
	    const certNo = (type === 'dx' ? 1 : 2);
	    
	    const formData = {
	        certificateNo: certNo,
	        chartNo: currentChartNo, 
	        medicalCertificateOnset: certNo === 1 ? document.getElementById(`\${prefix}OnsetDate`).value : "",
	        medicalCertificateDiagnosis: document.getElementById(`\${prefix}DxDate`).value,
	        medicalCertificateContent: document.getElementById(`\${prefix}Content`).value,
	        medicalCertificateRemark: document.getElementById(`\${prefix}Remark`).value,
	        medicalCertificatePurpose: document.getElementById(`\${prefix}Purpose`).value
	    };

	    if (!formData.medicalCertificateContent) {
	        return Swal.fire({ 
	        	icon: 'info', 
	        	title: '내용을 입력해주세요.' 
	        });
	    }

	    try {
	        const resp = await axios.post('/certificate/api/insertCertificate', formData);
	        if (resp.data.status === "success") {
	            Swal.fire({ 
	            	icon: 'success', 
	            	title: '저장 완료', 
	            	timer: 1000, 
	            	showConfirmButton: false 
	            });
	            closeIpDocModal(type);
	        }
	    } catch (e) {
	        console.error("저장 중 오류 발생:", e);
	    }
	}
	
	// 퇴원대기 상태로 변경
	async function chageAdmissionStatus(){
		if(!currentPatientNo){
			sweetAlert("warning", "환자를 먼저 선택해주세요!");
			return;
		}
		
		const { isConfirmed } = await Swal.fire({
	        title: '퇴원 심사를 요청하시겠습니까?',
	        text: "간호부로 퇴원 정보가 전달됩니다.",
	        icon: 'question',
	        showCancelButton: true,
	        confirmButtonText: '요청',
	        cancelButtonText: '취소',
	        reverseButtons: true
	    });
		
		if(isConfirmed){
			try{
				const response = await axios.post('/doctor/inpatient/api/updateDischarge', {
					patientNo: currentPatientNo
				});
				
				if (response.data.status === "success") {
	                Swal.fire({
	                    icon: 'success',
	                    title: '요청 완료',
	                    text: '퇴원 심사 요청이 정상적으로 접수되었습니다.',
	                    timer: 1500,
	                    showConfirmButton: false
	                });

	                loadInpatientList(); 
	            } else {
	                sweetAlert("error", "처리에 실패했습니다: " + response.data.message);
	            }
			}catch(error){
				console.error("퇴원 요청 중 오류 발생:", error);
	            sweetAlert("error", "서버 통신 중 오류가 발생했습니다.");
			}
		}
	}
	
	// 시연용
	
	const setValById = (id, val) => {
	    const el = document.getElementById(id);
	    if (el) el.value = val;
   	 };
   	 
	window.btnFillContent = function() {
        console.log("시연 버튼 클릭됨");
        
        const v = makeContent();
        
        setValById("dxOnsetDate", v.onset);
        setValById("dxDxDate", v.dxDate);
        setValById("dxContent", v.dxContent);
        setValById("dxRemark", v.dxRemark);
        setValById("dxPurpose", v.dxPurpose);
        
        console.log("데이터 입력 완료");
    };
 
    function makeContent(){
        return {
            onset: "2026-01-25",       
            dxDate: "2026-02-02",     
            dxContent: "상기 환자는 2026년 1월 25일 계단에서 낙상하여 본원에 내원함.\n" +
                       "X-ray 및 MRI 정밀 검사 결과, 우측 발목 전거비인대 파열(S93.4) 및 비골 원위부 미세 골절(S82.4) 소견 관찰됨.\n\n" +
                       "현재 단하지 부목 고정(Short Leg Splint) 및 약물 치료 중이며, 향후 약 4주간의 절대 안정 및 경과 관찰이 필요할 것으로 사료됨.\n" +
                       "통증 지속 시 수술적 치료 가능성 설명함.",
            dxRemark: "일상생활 동작 제한 및 목발 보행 요함",
            dxPurpose: "보험사 제출용"
        };
	 }
	
</script>














