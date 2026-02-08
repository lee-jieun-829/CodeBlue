<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<style>
    .animate-spin-slow {
        animation: spin 3s linear infinite;
    }
</style>

<div id="aiUnifiedModal" class="modal-backdrop hidden" aria-hidden="true">
    <div class="modal modal-lg">        
        <div class="modal-header">
            <div class="flex items-center gap-2">
                <span class="text-xl">🤖</span>
                <h3 class="modal-title" id="aiModalTitle">AI 진료 어시스턴트</h3>
                <span style="font-size: var(--font-sm); color: var(--color-text-secondary);">
                with
                <img alt="ai" src="/resources/assets/images/icon/ai.jpg" 
                	style=" display: inline-block; vertical-align: -0.125em;  flex: 0 0 auto;  width: 3.5rem; height: 1rem;">
                	
         </span>
            </div>              
            <button type="button" onclick="closeAiModal()" class="btn btn-icon btn-ghost">✕</button>
        </div>
    

        <div class="modal-body" id="aiModalContent">
            
            <div id="aiMainView" class="space-y-6">
                <div class="flex items-center justify-between">
                    <h4 class="text-sm font-bold text-slate-900 tracking-tight">최근 진료 대화 히스토리</h4>
                    <span id="countAi" class="text-[11px] font-medium text-slate-400"></span>
                </div>
				<!-- 과거 히스토리 출력 영역 -->
                <div id="pastAi" class="grid gap-3 h-40 overflow-y-auto">                   
                </div>

                <div class="pt-4 border-t border-slate-100">
                    <button id="startRecordingBtn" class="btn btn-primary btn-lg w-full flex items-center justify-center gap-3 shadow-md">
                        <span class="text-lg">🎤</span> 새로운 진료 대화 분석 시작
                    </button>
                    <p class="text-center text-[11px] text-slate-400 mt-3 italic">
                        버튼을 누르면 음성 인식이 즉시 시작됩니다.
                    </p>
                </div>
            </div>

            <div id="aiRecordingView" class="hidden py-10 text-center">
            	<!-- 마이크버튼 -->
                <div id="micWrapper" class="w-20 h-20 bg-blue-50 rounded-full flex items-center justify-center mx-auto mb-6 relative">
			        <span id="centerIcon" class="text-4xl transition-all duration-300">🎤</span>
			        <div id="pingAnim" class="absolute inset-0 rounded-full border-4 border-blue-500 animate-ping opacity-25"></div>
			    </div>
				<!-- 스피너 -->
			    <div id="aiLoadingSpinner" class=" w-20 h-20 flex items-center justify-center mx-auto mb-6">
			        <div class="w-12 h-12 border-4 border-blue-600 border-t-transparent rounded-full animate-spin z-50 border-solid inline-block" ></div>
			    </div>
                <h4 id="aiStatusText" class="text-xl font-black text-slate-800 mb-2">대화를 듣고 분석하는 중...</h4>

                <div class="recording-wave mb-8">
                    
                </div>

                <div id="liveDiv" class="bg-slate-50 rounded-xl p-4 min-h-[100px] text-left border border-slate-200">
                    <p id="liveTranscript" class="text-sm text-slate-600 leading-relaxed italic">음성을 대기하고 있습니다...</p>
                </div>

                <button id="stopRecordingBtn" class="btn btn-danger btn-lg w-full mt-6 shadow-md">
                    대화 종료 및 결과 생성
                </button>
            </div>

            <div id="aiResultView" class="hidden space-y-6">
                <section>
                    <h4 class="text-xs font-black text-blue-600 uppercase mb-2">진료 대화 요약</h4>
                    <div id="aiSummary" class="p-4 bg-slate-50 rounded-xl text-sm leading-relaxed border border-slate-200 text-slate-700"></div>
                </section>
                <section>
                    <h4 class="text-xs font-black text-blue-600 uppercase mb-2">예상 환자 진단</h4>
                    <p id="aiDiagnosis" class="text-base font-bold text-slate-900 px-1"></p>
                </section>

                <div class="grid grid-cols-3 gap-4">
                    <div class="p-4 border border-slate-100 rounded-xl bg-slate-50/50">
                        <h5 class="text-[11px] font-bold text-slate-400 mb-2 uppercase">추천 상병</h5>
                        <ul id="aiDxList" class="text-xs space-y-1 font-bold text-blue-600"></ul>
                    </div>
                    <div class="p-4 border border-slate-100 rounded-xl bg-slate-50/50">
                        <h5 class="text-[11px] font-bold text-slate-400 mb-2 uppercase">추천 처방</h5>
                        <ul id="aiRxList" class="text-xs space-y-1 font-bold text-emerald-600"></ul>
                    </div>
                    <div class="p-4 border border-slate-100 rounded-xl bg-slate-50/50">
                        <h5 class="text-[11px] font-bold text-slate-400 mb-2 uppercase">추천 치료</h5>
                        <ul id="aiTxList" class="text-xs space-y-1 font-bold text-blue-500"></ul>
                    </div>
                </div>

                <div class="flex gap-2 pt-4 border-t border-slate-100">
                    <button onclick="resetToAiMain()" class="btn btn-secondary btn-lg flex-1">목록으로</button>
                    <button id="applyAiDataBtn" class="btn btn-primary btn-lg flex-[2] flex items-center justify-center gap-2 shadow-md">
                        <span>📝</span> 추천 내역 차트 적용
                    </button>
                </div>
            </div>

        </div>
        </div>
</div>

<script>
    let recognition;
    let isRecording = false;
    let lastAiData = null;
    let final_transcript = '';
	
  	//====================================================================
    // Web Speech API 초기화
    //====================================================================
    if ('webkitSpeechRecognition' in window) {
        recognition = new webkitSpeechRecognition();
        recognition.continuous = true;
        recognition.interimResults = true;
        recognition.lang = 'ko-KR';

        recognition.onresult = (event) => {
            let interim_transcript = '';
            for (let i = event.resultIndex; i < event.results.length; ++i) {
                const transcript = event.results[i][0].transcript;
                if (event.results[i].isFinal) {
                    final_transcript += transcript + ' ';
                } else {
                    interim_transcript += transcript;
                }
            }
            const liveEl = document.getElementById('liveTranscript');
            if(liveEl) liveEl.innerText = final_transcript + interim_transcript;
        };
    }
	
  	//====================================================================
    // 모달 제어(과거 히스토리 불러오기, 어시스턴트 창 리셋)
    //====================================================================
    document.addEventListener("DOMContentLoaded", function() {
        const aiBtn = document.getElementById('aiAssistantBtn');
        const aiModal = document.getElementById('aiUnifiedModal');
        
        if(aiBtn && aiModal) {
            aiBtn.addEventListener('click', () => {   
            	//현재 진료중인 환자번호
            	const ptNo = targetPatient.patientNo
                aiModal.classList.replace('hidden', 'flex');                
                loadAiData(ptNo);
                resetToAiMain();
            });
        }
    });
    
  	//====================================================================
  	// 환자별 과거 ai어시스턴트 히스토리 불러오기
  	//====================================================================
    function loadAiData(ptNo) {
    	axios.get('/doctor/aiselect', {
    		params: {
    			patientNo: ptNo 
            }
    	})
    	.then(function (response) {
    		const data = response.data;
    		aiHistoryList = data;
    		let htmlContent = "";
            console.log("Axios로 받은 데이터:", data);
            document.getElementById('countAi').innerText = `총 \${data.length}건` ;
            if (data.length > 0) { //히스토리가 있을 때
            	for (let i = 0; i < data.length; i++) {
            		htmlContent += `
	            		<button onclick="renderAiResult(\${i})" class="h-[100px] flex items-center justify-between w-full p-4 rounded-xl border border-slate-100 bg-slate-50 hover:bg-white hover:border-indigo-200 hover:shadow-sm transition-all text-left group">
	                        <div>
	                            <p class="text-sm font-bold text-slate-700">\${data[i].aiDate} 진료</p>
	                            <p class="text-xs text-slate-500 mt-1 line-clamp-1 w-[480px]">[요약] \${data[i].aiContent}</p>
	                        </div>
	                        <span class="text-indigo-600 font-bold text-xs group-hover:translate-x-1 transition-transform">상세보기 →</span>
	                    </button>` ;                
            		} 
            }else{//히스토리가 없을 때
            	htmlContent= `                	
    	                <div class="empty-state empty-state-sm">
    	                    <svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
    	                        <line x1="8" y1="6" x2="21" y2="6"></line>
    	                        <line x1="8" y1="12" x2="21" y2="12"></line>
    	                        <line x1="8" y1="18" x2="21" y2="18"></line>
    	                        <line x1="3" y1="6" x2="3.01" y2="6"></line>
    	                        <line x1="3" y1="12" x2="3.01" y2="12"></line>
    	                        <line x1="3" y1="18" x2="3.01" y2="18"></line>
    	                    </svg>
    	                    <div class="empty-state-title">목록 없음</div>
    	                    <div class="empty-state-description">등록된 항목이 없습니다.</div>
    	                </div>
    	            `;
                }  
            document.getElementById('pastAi').innerHTML = htmlContent
            
    	})
    	.catch(function (error) {            
            console.error("Axios Error:", error);           
        })
    }
	
    function closeAiModal() {
        if (recognition && isRecording) recognition.stop();
        const aiModal = document.getElementById('aiUnifiedModal');
        if(aiModal) aiModal.classList.replace('flex', 'hidden');
    }
	
    //====================================================================
    // ai 모달 리셋 함수
    //====================================================================
    function resetToAiMain() {
    	final_transcript = ''; 
        lastAiData = null;
    	 document.getElementById('aiMainView').classList.remove('hidden');
         document.getElementById('aiRecordingView').classList.add('hidden');
         document.getElementById('aiResultView').classList.add('hidden');
         document.getElementById('aiModalTitle').innerText = "AI 진료 어시스턴트";
         
         //음성 텍스트 영역 다시 보이게 설정
         const liveDiv = document.getElementById('liveDiv');
         if(liveDiv) liveDiv.classList.remove('hidden');


         // 마이크/스피너 상태 원상복구
         const micWrapper = document.getElementById('micWrapper');
         const spinnerDiv = document.getElementById('aiLoadingSpinner');
         const statusText = document.getElementById('aiStatusText');
         const stopBtn = document.getElementById('stopRecordingBtn');

         // 마이크 다시 보이기, 스피너 숨기기
         if(micWrapper) micWrapper.classList.remove('hidden');
         if(spinnerDiv) spinnerDiv.classList.add('hidden'); 

         // 텍스트 및 버튼 원상복구
         if(statusText) statusText.innerText = "대화를 듣고 분석하는 중...";
         if(document.getElementById('liveTranscript')) {
             document.getElementById('liveTranscript').innerText = "음성을 대기하고 있습니다...";
         }

         if(stopBtn) {
             stopBtn.disabled = false;
             stopBtn.innerText = "대화 종료 및 결과 생성";
             stopBtn.classList.add('btn-danger', 'shadow-md');
             stopBtn.classList.remove('bg-slate-300', 'text-slate-500', 'cursor-not-allowed');
         }
         
         document.getElementById('aiDiagnosis').innerText = "";
         document.getElementById('aiDxList').innerHTML = "";
         document.getElementById('aiRxList').innerHTML = "";
         document.getElementById('aiTxList').innerHTML = "";
    }

  	//====================================================================
    // 녹음 시작
    //====================================================================
    const startBtn = document.getElementById('startRecordingBtn');
    if(startBtn) {
        startBtn.addEventListener('click', () => {
            document.getElementById('aiMainView').classList.add('hidden');
            document.getElementById('aiRecordingView').classList.remove('hidden');

            final_transcript = '';
            document.getElementById('liveTranscript').innerText = "대화를 기다리고 있습니다...";
            if (recognition) {
                recognition.start();
                isRecording = true;
            }
        });
    }
	
  	//====================================================================
    // 녹음 종료 및 분석 요청
    //====================================================================    
    const stopBtn = document.getElementById('stopRecordingBtn');
    
    if(stopBtn) {
        stopBtn.addEventListener('click', async () => {
        	stopBtn.disabled = true;
        	stopBtn.innerText = "결과 생성 중...";
        	stopBtn.classList.remove('btn-danger', 'shadow-md');
        	stopBtn.classList.add('bg-slate-300', 'text-slate-500', 'cursor-not-allowed');
        	
        	const micWrapper = document.getElementById('micWrapper');
            const spinnerDiv = document.getElementById('aiLoadingSpinner');
            const statusText = document.getElementById('aiStatusText');
            const liveDiv = document.getElementById('liveDiv');
			
            if(micWrapper) micWrapper.classList.add('hidden');
            if(spinnerDiv) spinnerDiv.classList.remove('hidden');
            
            if(liveDiv) liveDiv.classList.add('hidden');
            
            if(statusText) statusText.innerText = "AI 어시스턴트 진단 중...";
            
            
            if (recognition && isRecording) {
                recognition.stop();
                isRecording = false;
            }
            
         	//음성인식 변환한 텍스트
         	const transcriptText =  document.getElementById('liveTranscript').innerText;
            
            const loader = document.getElementById('loadingStatus'); 

            if (!transcriptText.trim() || transcriptText.includes("기다리고 있습니다")) {            	
                return;
            }

            if (loader) loader.classList.remove('hidden');

            try {
                const response = await axios.post('/doctor/ai', {
                    userPrompt: transcriptText,
                    patientAge: targetPatient.patientAge,
                    patientGender: targetPatient.patientGen
                });

                const data = response.data;
                console.log("data",data);
                lastAiData = data;
                renderAiResult(data);                

            } catch (error) {
                console.error("AI 분석 중 오류:", error);
                sweetAlert("warning", "서버오류, AI 분석 결과를 가져오는 데 실패했습니다.", "확인");     
                
            } finally {
                if (loader) loader.classList.add('hidden');
            }
        });
    }
    
  	//====================================================================
    // 결과 렌더링
    //====================================================================    
    function renderAiResult(param) {    	
    	let data;
    	let isHistoryMode = false; // 과거 내역 모드인지 확인하는 플래그
    	
        // 만약 넘어온 값이 숫자(인덱스)라면 전역 변수에서 꺼내온다.
        if (typeof param === 'number' || typeof param === 'string') {
            // 혹시 문자로 된 숫자일 수 있으니 인덱스로 사용
            data = aiHistoryList[param];
            isHistoryMode = true;
        } else {
            // 녹음 후 바로 넘어온 경우 (이미 객체임)
            data = param;
            isHistoryMode = false;
        }
        
        console.log("렌더링할 데이터:", data); // 확인용 로그
        
        const mainView = document.getElementById('aiMainView');
        const rView = document.getElementById('aiRecordingView');
        const resView = document.getElementById('aiResultView');
		
        if (mainView) mainView.classList.add('hidden');
        if (rView) rView.classList.add('hidden');
        if (resView) resView.classList.remove('hidden');

        document.getElementById('aiModalTitle').innerText = isHistoryMode ? "과거 진료 기록 상세" : "AI 분석 및 추천 결과";
        document.getElementById('aiSummary').innerText = data.aiContent || "요약 정보 없음";
		
        // 진단명
        if (data.aiDiagnosis && data.aiDiagnosis.length > 0) {
        	
            const diagEl = document.getElementById('aiDiagnosis');
            let diaName = "";
            let diagListHtml = "";
            
            for (let item of data.aiDiagnosis) {
            	let code = item.aiDiagnosisCode || item.diagnosisCode || ""; 
                let name = item.aiDiagnosisName || item.diagnosisName || "";
                
                diaName += `\${name} `;
                diagListHtml += `<li>\${code}<br/>\${name}</li>`;
            }
            if(diagEl) diagEl.innerText = diaName;
            document.getElementById('aiDxList').innerHTML = diagListHtml;
        } else {
            document.getElementById('aiDxList').innerHTML = "<li>진단 정보 없음</li>";
        }

        // 약제
        if (data.aiDrug && data.aiDrug.length > 0) {
            let drugListHtml = "";
            for (let item of data.aiDrug) {
            	
            	let rawName = item.aiDrugName || item.drugName || "";
                let spec = item.aiDrugSpec || item.drugSpec || ""
                
                let displayName = rawName
                
                drugListHtml += `<li>\${displayName}</li>`;
            }
            document.getElementById('aiRxList').innerHTML = drugListHtml;
        } else {
            document.getElementById('aiRxList').innerHTML = "<li>추천 약제 없음</li>";
        }

        // 치료
        if (data.aiTreatment && data.aiTreatment.length > 0) {
            let txListHtml = "";
            for (let item of data.aiTreatment) {
                txListHtml += `<li>\${item.aiTreatmentName}</li>`;
            }
            document.getElementById('aiTxList').innerHTML = txListHtml;
        } else {
            document.getElementById('aiTxList').innerHTML = "<li>추천 치료 없음</li>";
        }

        // 적용 버튼 연결
        const applyBtn = document.getElementById('applyAiDataBtn');
        if(applyBtn) {
        	if(isHistoryMode) {
                applyBtn.classList.add('hidden'); // 과거 내역은 적용 버튼 숨김
            } else {
                applyBtn.classList.remove('hidden'); // 새 기록은 적용 버튼 보임
            }
            applyBtn.onclick = () => {
                applyToChart(data);
                closeAiModal();
            };
        }
    }
  	
  	//====================================================================
    // 차트 적용
    //====================================================================
    async function applyToChart(data) {
        if (!data) return;
		//db에 insert 비동기 처리
		const payload = {
	        chartNo: currentChartNo,
	        patientNo: targetPatient.patientNo,
	        aiContent: data.aiContent,
	        aiDiagnosis: data.aiDiagnosis, // 컨트롤러 Map에서 "aiDiagnosis" 키로 받음
	        aiDrug: data.aiDrug            // 컨트롤러 Map에서 "aiDrug" 키로 받음
	    };
		console.log("서버로 보낼 데이터 확인:", payload);
		try {
			const response = await axios.post('/doctor/insert',payload
			);
	        if(response.data === 'success') {
	            console.log("DB 저장 성공");
	            
	            loadAiData(targetPatient.patientNo);
	        }
	    } catch (err) {
	        console.error("DB 저장 실패:", err);
	        // 저장 실패해도 화면 뿌리기는 계속 진행
	    }
        // 진료 기록 
        const noteArea = document.getElementById('clinicNote');
        
        if(noteArea) {
            const summary = data.aiContent || '';
            noteArea.value = `[AI 요약] \${summary}\n\${noteArea.value}`;
        }

        // 상병 테이블
        if (data.aiDiagnosis && data.aiDiagnosis.length > 0) {
            const dxBody = document.getElementById('dxTableBody');
            if(dxBody) {
                for (let i = 0; i < data.aiDiagnosis.length; i++) {
                	
                	
		            let index = dxBody.querySelectorAll("tr").length +1;
                    let item = data.aiDiagnosis[i];                    
                    let code = item.diagnosisCode || "";
                    let name = item.diagnosisName || "";                   

                    dxBody.innerHTML += 
                    `
                        <tr class="border-b border-slate-100 hover:bg-slate-50 transition-colors" 
                            data-no="\${item.diagnosisNo}" 
                            data-code="\${code}" 
                            data-name="\${name}">
                            <td class="text-center py-3">\${index}</td>
                            <td class="text-center py-3">
                                <div class="flex items-center justify-center">
                                    <input \${index == '1' ? 'checked' : ''} name="diagcheck\${index}" value="Y" type="radio" class="h-4 w-4 accent-blue-600 cursor-pointer"/>
                                </div>
                            </td>
                            <td class="text-center py-3">
                                <div class="flex items-center justify-center">
                                    <input \${index != '1' ? 'checked' : ''} name="diagcheck\${index}" value="N" type="radio" class="h-4 w-4 accent-blue-600 cursor-pointer"/>
                                </div>
                            </td>
                            <td class="text-center py-3">\${code}</td>
                            <td class="text-left py-3 pl-4">\${name}</td>
                            <td class="text-center py-3">
                                <button onclick="removeList(this)" class="p-1 hover:text-red-500 rounded transition-colors">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                </button>
                            </td>
                        </tr>
                    `
                }
            }
        }

        
        // 약제 테이블
        if (data.aiDrug && data.aiDrug.length > 0) {
            const rxBody = document.getElementById('rxTableBody');
            
            if(rxBody) {
                for (let i = 0; i < data.aiDrug.length; i++) {
                	let index = rxBody.querySelectorAll("tr").length +1;
                    let item = data.aiDrug[i];
                    console.log("asdfasdf",item);
                    let opts = ['식후 30분', '식전 30분', '취침 전'].map(m => `<option \${item.method === m ? 'selected' : ''}>\${m}</option>`).join('');
                    console.log(data.aiDrug);
                    rxBody.innerHTML += 
                    `
                        <tr class="border-b border-slate-100 hover:bg-slate-50 transition-colors" 
                            data-no="\${item.drugNo}" 
                            data-code="\${item.drugCode}" 
                            data-name="\${item.drugName}" 
                            data-company="\${item.drugCompany}">
                            
                            <td class="text-center py-3">\${index}</td>
                            
                            <td class="text-left py-3 pl-4" title="\${item.drugName}">
                                \${item.drugName.split('(')[0]}
                            </td>
                            
                            <td class="text-center py-3">
                                <input min="0" type="number" class="w-full border rounded px-1 py-1 text-center focus:outline-none focus:border-blue-500 bg-transparent transition-colors" 
                                    value="1"/>
                            </td>
                            
                            <td class="text-center py-3">
                                <input min="0" type="number" class="w-full border rounded px-1 py-1 text-center focus:outline-none focus:border-blue-500 bg-transparent transition-colors" 
                                    value="3"/>
                            </td>
                            
                            <td class="text-center py-3">
                                <input min="0" type="number" class="w-full border rounded px-1 py-1 text-center focus:outline-none focus:border-blue-500 bg-transparent transition-colors" 
                                    value="3"/>
                            </td>
                            
                            <td class="text-center py-3">
                                <select class="w-full border rounded px-1 py-1 text-center focus:outline-none focus:border-blue-500 bg-transparent transition-colors cursor-pointer">
                                    \${opts}
                                </select>
                            </td>
                            
                            <td class="text-center py-3">
                                <button onclick="removeList(this)" class="p-1 hover:text-red-500 rounded transition-colors">
                                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="18" y1="6" x2="6" y2="18"></line><line x1="6" y1="6" x2="18" y2="18"></line></svg>
                                </button>
                            </td>
                        </tr>
                    `;
                }
            }
        }

        // 치료 테이블
        if (data.aiTreatment && data.aiTreatment.length > 0) {
            const txBody = document.getElementById('txTableBody');
            
            if(txBody) {
                for (let i = 0; i < data.aiTreatment.length; i++) {
                	let index = txBody.querySelectorAll("tr").length +1;
                    let item = data.aiTreatment[i];
                    txBody.innerHTML += `
                        <tr>
                            <td>\${index}</td>
                            <td>\${item.aiTreatmentType}</td>
                            <td>\${item.aiTreatmentCode}</td>
                            <td>\${item.aiTreatmentName}</td>
                            <td>\${item.aiTreatmentDose}분</td>
                            <td>\${item.aiTreatmentProq}</td>
                            <td>
                                <button type="button" class="btn btn-icon btn-destructive btn-sm">×</button>
                            </td>
                        </tr>`;
                }
            }
        }
        sweetAlert("success", "차트에 성공적으로 반영되었습니다.", "확인").then(() => {
            resetToAiMain(); // 초기 상태로 되돌림
            closeAiModal();  // 모달 닫기
        });    
    }
    
    
    
    
</script>