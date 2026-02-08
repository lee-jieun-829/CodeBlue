<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="h-full flex flex-col">
    <div class="content-header mb-3">
        <div class="content-header-title text-lg">
            <span>수술 관리</span> 
            <div style="font-size: var(--font-sm); color: var(--color-text-secondary); margin-top:4px;">
                환자의 예정 수술목록, 수술일과 수술 진행 상태를 볼 수 있습니다.
            </div>
        </div>             
    </div>

    <div id="surgeryListContainer" class="flex-1 overflow-y-auto pr-2 pb-4">
        </div>

    <div id="surgeryEmpty" class="hidden h-60 flex flex-col items-center justify-center text-slate-400 border border-slate-200 rounded-lg bg-slate-50">
        <i class="fas fa-notes-medical text-3xl mb-3 opacity-30"></i>
        <span>수술/시술 예정 내역이 없습니다.</span>
    </div>
</div>

<script>
function loadSurgeryList() {
    const container = document.getElementById('surgeryListContainer');
    const emptyDiv = document.getElementById('surgeryEmpty');

    container.innerHTML = '';
    emptyDiv.classList.add('hidden');

    // 전역 변수에서 데이터 가져오기 
    const list = globalPrescriptionList;

    if (!list || list.length === 0) {
        emptyDiv.classList.remove('hidden');
        return;
    }

    let html = '';
    let hasSurgeryData = false;

    // [Loop 1] 처방 리스트 순회
    list.forEach(predetail => {
        // 수술 정보가 있는 경우만
        if (predetail.operList && predetail.operList.length > 0) {
            hasSurgeryData = true;

            // [Loop 2] 수술 리스트 순회
            predetail.operList.forEach(op => {                    
                // 상태값 처리
                let rawStatus = op.preoperationStatus;
                let displayStatus = rawStatus || '수술 대기';
                let calloutClass = 'callout-warning'; 

                if (rawStatus === '001'){
                    calloutClass = 'callout-success'; 
                    displayStatus = '수술 완료';
                } else if (rawStatus === '002') {
                    calloutClass = 'callout-warning';
                    displayStatus = '수술 대기';
                } else if (rawStatus === '003') { 
                    calloutClass = 'callout-primary'; 
                    displayStatus = '수술 중';
                }

                const opDate = op.preoperationRegdate ? op.preoperationRegdate.substring(0, 16) : '-';
                const reqDate = predetail.predetailRegdate ? predetail.predetailRegdate.substring(0, 10) : '-';
                const opName = op.operationName || op.operationCode || '-';
                const doctor = op.employeeNo || '미정';

                html += `
                    <div class="callout \${calloutClass} mb-4 shadow-sm transition-all hover:shadow-md">
                        <div class="callout-title flex justify-between items-center">
                            <span>\${opName}</span>
                            <span class="text-xs font-normal opacity-70">처방일: \${reqDate}</span>
                        </div>
                        <div class="callout-content">
                            <strong>일시:</strong> \${opDate}
                        </div>
                        <div class="callout-content">
                            <strong>집도의:</strong> 박의사
                        </div>
                        <div class="callout-content flex items-center gap-2">
                            <strong>수술 상태:</strong> 
                           
                                \${displayStatus}
                            
                        </div>
                    </div>
                `;
            });
        }
    });
    
    if (!hasSurgeryData) {
        emptyDiv.classList.remove('hidden');
    } else {
        container.innerHTML = html;
    }
}
</script>