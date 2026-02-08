<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="h-full flex flex-col relative">
    
    <div id="niEmptyState" class="h-full flex flex-col items-center justify-center">
        <div class="box box-bordered border-0 shadow-none">
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
                <div class="empty-state-description">환자를 선택해주세요</div>
            </div>
        </div>
    </div>

    <div id="niFormContainer" class="hidden h-full flex flex-col">
        <input type="hidden" id="niChartNo" value=""> 
        <input type="hidden" id="niAssessmentNo" value=""> 
        <input type="hidden" id="niAdmissionNo" value=""> 
        
        <div class="content-header mb-3">
            <div class="content-header-title text-lg">
                <span id="niPatientNameTitle">000</span> 환자 간호정보 조사지
                <div style="font-size: var(--font-sm); color: var(--color-text-secondary); margin-top:4px;">
                    환자 개인의 특성과 간호 요구를 종합적으로 파악 하기 위해 간호정보 조사지를 작성해주세요
                </div>
            </div>             
        </div>

        <div class="box box-secondary mb-4">
            <div class="form-row form-row-2">
                <div class="form-group">
                    <label class="form-label">키 (cm)</label>
                    <input type="number" class="input" id="niHeight" >
                </div>
                <div class="form-group">
                    <label class="form-label">체중 (kg)</label>
                    <input type="number" class="input" id="niWeight" placeholder="0">
                </div>
            </div>
            
            <div class="form-row form-row-2 mt-3">
                 <div class="form-group">
                    <label class="form-label">흡연 상태</label>
                    <select class="select" id="niSmoking">
                        <option value="비흡연">비흡연</option>
                        <option value="흡연">흡연</option>
                        <option value="금연">금연</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label">음주 상태</label>
                    <select class="select" id="niAlcohol">
                        <option value="비음주">비음주</option>
                        <option value="음주">음주</option>
                    </select>
                </div>
            </div>
            <div class="form-row form-row-2 mt-3">
                <div class="form-group">
                    <label class="form-label">입원 경로</label>
                    <select class="select" id="niAdminPath">
                        <option value="외래 진료 후">외래 진료 후</option>
                        <option value="응급실 경유">응급실 경유</option>
                        <option value="타병원 전원">타병원 전원</option>
                        <option value="기타">기타</option>
                    </select>
                </div>
                 <div class="form-group">
                    <label class="form-label">과거 병력 및 알레르기</label>
                    <input type="text" class="input" id="niHistory" placeholder="고혈압, 당뇨 등">
                </div>
            </div>
        </div>

        <div class="box box-bordered mb-4">
            <div class="form-row form-row-2">
                <div class="form-group">
                    <label class="form-label text-red-600">통증 점수 (NRS)</label>
                    <select class="select border-red-200 focus:border-red-500" id="niPainScore">
                        <option value="0">0 : 통증 없음</option>
                        <option value="1">1 : 경미한 통증</option>
                        <option value="2">2 : 경미한 통증</option>
                        <option value="3">3 : 경미한 통증</option>
                        <option value="4">4 : 중등도 통증</option>
                        <option value="5">5 : 중등도 통증</option>
                        <option value="6">6 : 중등도 통증</option>
                        <option value="7">7 : 심한 통증</option>
                        <option value="8">8 : 심한 통증</option>
                        <option value="9">9 : 심한 통증</option>
                        <option value="10">10 : 극심한 통증</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label text-red-600">통증 부위</label>
                    <input type="text" class="input border-red-200 focus:border-red-500" id="niPainSite" placeholder="예: 우측 발목">
                </div>
            </div>
            <div class="form-row form-row-2 mt-3">
                <div class="form-group">
                    <label class="form-label text-orange-600">낙상 위험도</label>
                    <select class="select border-orange-200" id="niFallRisk">
                        <option value="낮음">낮음</option>
                        <option value="중간">중간 (주의)</option>
                        <option value="높음">높음</option>
                    </select>
                </div>
                <div class="form-group">
                    <label class="form-label text-orange-600">욕창 위험도</label>
                    <select class="select border-orange-200" id="niSoreRisk">
                        <option value="정상">정상</option>
                        <option value="주의">주의</option>
                        <option value="위험">위험</option>
                    </select>
                </div>
            </div>
        </div>

        <div class="btn-group-right mt-auto">
            <button type="button" class="btn btn-primary" id="btnSaveNursing" onclick="saveNursingInfo('insert')">
                저장 완료
            </button>
            <button type="button" class="btn btn-secondary hidden" id="btnUpdateNursing" onclick="saveNursingInfo('update')">
                수정 저장
            </button>
        </div>
    </div>
</div>

<script>
    /**
     * [로드 함수] 부모 페이지에서 호출
     */
    function loadNursingChartInfo(admissionNo, patientName) {
        
        if(!admissionNo) {
            showNiEmptyState();
            return;
        }

        showNiForm();
        resetNursingForm();
        document.getElementById('niAdmissionNo').value = admissionNo;
        if(patientName) document.getElementById('niPatientNameTitle').textContent = patientName;

        axios.get(`/nurse/assessmentselect`, {
            params: { admissionNo: admissionNo }
        })
        .then(res => {
            let data = res.data;
            if (Array.isArray(data)) {
                if (data.length > 0) data = data[0]; 
                else { 
                    console.error("데이터 배열 비어있음"); 
                    return; 
                }
            }

            // [중요] 차트 번호 세팅 및 전역 상태 업데이트
            if (data && data.chartNo) {
                // 1. 화면의 hidden input 세팅
                document.getElementById('niChartNo').value = data.chartNo;
                
                // 2. 전역 변수 업데이트 (다른 탭에서 사용)
                window.currentChartNo = data.chartNo;
                console.log("ChartNo Updated:", window.currentChartNo);
                
                // 3. 통합 데이터(처방/수술) 로드 트리거
                if(typeof fetchPrescriptionData === 'function') {
                    fetchPrescriptionData(data.chartNo);
                }
            } else {
            	sweetAlert("warning", "차트 번호를 찾을 수 없습니다.", "확인");    
               
                return;
            }
            
            // 신규/수정 모드 및 탭 잠금 처리
            if (!data.nursingAssessmentNo) {
                toggleMode('insert');
                // 조사지 미작성 -> 타 탭 잠금
                if(typeof isAssessmentSaved !== 'undefined') isAssessmentSaved = false;
            } else {
                toggleMode('update');
                bindNursingData(data);
                // 조사지 작성됨 -> 타 탭 해제
                if(typeof isAssessmentSaved !== 'undefined') isAssessmentSaved = true;
            }
        })
        .catch(err => {
            console.error("간호정보조사지 로드 실패:", err);
            toggleMode('insert');
        });
    }

    function showNiEmptyState() {
        document.getElementById('niEmptyState').classList.remove('hidden');
        document.getElementById('niFormContainer').classList.add('hidden');
    }

    function showNiForm() {
        document.getElementById('niEmptyState').classList.add('hidden');
        document.getElementById('niFormContainer').classList.remove('hidden');
    }

    function bindNursingData(data) {
        document.getElementById('niChartNo').value = data.chartNo || '';
        document.getElementById('niAssessmentNo').value = data.nursingAssessmentNo || '';
        
        document.getElementById('niHeight').value = data.nursingAssessmentHeight || '';
        document.getElementById('niWeight').value = data.nursingAssessmentWeight || '';
        
        setSelectValue('niAdminPath', data.nursingAssessmentAdminPath);
        setSelectValue('niSmoking', data.nursingAssessmentSmoking);
        setSelectValue('niAlcohol', data.nursingAssessmentAlcohol);
        setSelectValue('niPainScore', data.nursingAssessmentPainscore);
        document.getElementById('niPainSite').value = data.nursingAssessmentPainsite || '';
        document.getElementById('niHistory').value = data.nursingAssessmentHistory || '';
        setSelectValue('niFallRisk', data.nursingAssessmentFallrisk);
        setSelectValue('niSoreRisk', data.nursingAssessmentSorerisk);
    }

    function toggleMode(mode) {
        const btnSave = document.getElementById('btnSaveNursing');
        const btnUpdate = document.getElementById('btnUpdateNursing');
       

        if (mode === 'update') {
            btnSave.classList.add('hidden');
            btnUpdate.classList.remove('hidden');
        } else {
            btnSave.classList.remove('hidden');
            btnUpdate.classList.add('hidden');
            
            document.getElementById('niAssessmentNo').value = ''; 
        }
    }

    function saveNursingInfo(type) {
        const admissionNo = document.getElementById('niAdmissionNo').value;
        const chartNo = document.getElementById('niChartNo').value;
        const assessmentNo = document.getElementById('niAssessmentNo').value;
        const patientName = document.getElementById('niPatientNameTitle').textContent;
        
        const payload = {
            admissionNo: parseInt(admissionNo),
            chartNo: chartNo ? parseInt(chartNo) : 0,
            nursingAssessmentNo: assessmentNo ? parseInt(assessmentNo) : 0,
            nursingAssessmentHeight: document.getElementById('niHeight').value,
            nursingAssessmentWeight: document.getElementById('niWeight').value,
            nursingAssessmentAdminPath: document.getElementById('niAdminPath').value,
            nursingAssessmentSmoking: document.getElementById('niSmoking').value,
            nursingAssessmentAlcohol: document.getElementById('niAlcohol').value,
            nursingAssessmentHistory: document.getElementById('niHistory').value,
            nursingAssessmentPainscore: document.getElementById('niPainScore').value,
            nursingAssessmentPainsite: document.getElementById('niPainSite').value,
            nursingAssessmentFallrisk: document.getElementById('niFallRisk').value,
            nursingAssessmentSorerisk: document.getElementById('niSoreRisk').value
        };

        const url = type === 'insert' ? '/nurse/assessmentinsert' : '/nurse/assessmentupdate';
        const msg = type === 'insert' ? '저장하시겠습니까?' : '수정 내용을 저장하시겠습니까?';

		Swal.fire({
		    title: '알림',
		    text: msg,
		    icon: 'question',
		    showCancelButton: true,		   
		    confirmButtonText: '확인',
		    cancelButtonText: '취소'
		}).then((result) => {
		    if (result.isConfirmed) {			
        axios.post(url, payload)
        .then(res => {
        	sweetAlert("success", "처리되었습니다.", "확인");
        
            loadNursingChartInfo(admissionNo, patientName);
        })
        .catch(err => {
            console.error(err);
            sweetAlert("warning", "서버오류, 저장 중 오류가 발생했습니다.", "확인");           
        });		
		}
		});
    }

    function setSelectValue(id, value) {
        const el = document.getElementById(id);
        if(value) el.value = value;
        else el.selectedIndex = 0;
    }

    function resetNursingForm() {
        document.getElementById('niHeight').value = '';
        document.getElementById('niWeight').value = '';
        document.getElementById('niPainSite').value = '';
        document.getElementById('niHistory').value = '';
        document.getElementById('niChartNo').value = '';
        document.getElementById('niAssessmentNo').value = '';
        document.querySelectorAll('#niFormContainer select').forEach(sel => sel.selectedIndex = 0);
    }
</script>