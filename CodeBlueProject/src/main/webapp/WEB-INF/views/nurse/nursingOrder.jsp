<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="h-full flex flex-col">
    <div class="content-header mb-3">
        <div class="content-header-title text-lg">입원 처방(오더) 목록</div>
        <div style="font-size: var(--font-sm); color: var(--color-text-secondary); margin-top:4px;">
            약품, 주사, 검사, 치료, 식이 처방 내역을 수행하고 관리합니다.
        </div>
    </div>
    
    <div class="table-wrapper mb-4 flex-1 overflow-auto border border-slate-200 rounded-lg bg-white">
        <table class="table table-striped w-full text-sm">
            <thead class="sticky top-0 bg-slate-50 z-10 border-b border-slate-200">
                <tr>
                    <th style="width: 50px;" class="text-center">No</th>
                    <th style="width: 100px;">처방일자</th>
                    <th style="width: 80px;">구분</th>
                    <th>처방명</th>
                    <th>상세내용</th>
                    <th style="width: 120px; text-align: center;">상태/수행</th>
                </tr>
            </thead>
            <tbody id="orderListBody">
                </tbody>
        </table>
        
        <div id="orderEmpty" class="hidden h-60 flex flex-col items-center justify-center text-slate-400 bg-slate-50">
            <i class="fas fa-clipboard-list text-3xl mb-3 opacity-30"></i>
            <span>수행할 처방 내역이 없습니다.</span>
        </div>
    </div>
</div>

<script>
//=======================================================
// 입원 오더 목록 로드 함수
//=======================================================
function loadOrderList() {	
    const tbody = document.getElementById('orderListBody');
    const emptyDiv = document.getElementById('orderEmpty');
    
    tbody.innerHTML = '';
    emptyDiv.classList.add('hidden');

    const list = globalPrescriptionList;

    if (!list || list.length === 0) {
        emptyDiv.classList.remove('hidden');
        return;
    }

    let html = '';
    let count = 1;
    let hasOrderData = false;

    list.forEach(item => {
        const reqDate = item.predetailRegdate ? item.predetailRegdate.substring(0, 10) : '-';

        // 1. 약품/주사 (Drug)
        if (item.drugList && item.drugList.length > 0) {
            item.drugList.forEach(d => {
                hasOrderData = true;
                const typeName = d.predrugDetailType === 'Y' ? '약품' : '주사';
                const detail = `\${d.predrugDetailDose} \${d.drugUnit || ''} / \${d.predrugDetailMethod || '-'} / \${d.predrugDetailFreq}회`;
                
                html += createOrderRow(
                    count++, reqDate, typeName, d.drugName, detail,
                    d.predrugDetailStatus, 'drug', d.drugNo, 
                    d.drugType, //주사 여부 확인을 위해 추가 전달
                    d.predetailNo
                );
            });
        }

        // 2. 치료 (Treatment)
        if (item.treatList && item.treatList.length > 0) {
            item.treatList.forEach(t => {
                hasOrderData = true;
                const detail = `\${t.pretreatmentDetailRemark || '-'}`;
                
                html += createOrderRow(
                    count++, reqDate, '치료', t.treatmentName, detail,
                    t.pretreatmentDetailStatus, 'treatment', t.treatmentNo, null
                );
            });
        }

        // 3. 검사 (Exam)
        if (item.examList && item.examList.length > 0) {
            item.examList.forEach(e => {
                hasOrderData = true;
                const detail = e.preexaminationDetailRemark || '-';
                
                html += createOrderRow(
                    count++, reqDate, '검사', e.examinationName, detail,
                    e.preexaminationDetailStatus, 'exam', e.examinationNo, null
                );
            });
        }

        // 4. 식이 (Diet)
        if (item.dietList && item.dietList.length > 0) {
            item.dietList.forEach(d => {
                hasOrderData = true;
                const detail = `\${d.dietType === '001' ? '일반식' : '치료식'} (\${d.predietDose}끼)`;
                
                html += createOrderRow(
                    count++, reqDate, '식이', d.dietName, detail,
                    d.predietStatus, 'diet', d.dietNo, null
                );
            });
        }
    });

    if (!hasOrderData) {
        emptyDiv.classList.remove('hidden');
    } else {
        tbody.innerHTML = html;
    }
}

//=======================================================
//행 생성 함수
//=======================================================
function createOrderRow(no, date, type, name, detail, statusCode, category, id, drugType, predetailNo) {
    let statusHtml = '';
    
    // 뱃지 색상 설정
    let badgeColor = 'badge-default';
    if(type === '주사') badgeColor = 'badge-danger'; 
    else if(type === '약품') badgeColor = 'badge-primary'; 
    else if(type === '치료') badgeColor = 'badge-success'; 
    else if(type === '검사') badgeColor = 'badge-warning'; 
    
    // --- 상태 코드 로직 (핵심 수정 부분) ---
    
    // 1. [대기] 상태 (002)
    if (statusCode === '002') {
        // 조건: 카테고리가 'drug'이고, 타입이 'N'(주사)인 경우에만 버튼 표시
        if (category === 'drug' && drugType === '주사') {
            statusHtml = `<button class="btn btn-light btn-sm" onclick="updateOrderStatus('\${category}', '\${id}', '\${predetailNo}', '001')">수행하기</button> `;
        } else {
            // 나머지는 그냥 대기 뱃지
            statusHtml = '<span class="badge badge-warning badge-sm">대기</span>';
        }
    } 
    // 2. [완료] 상태 (001)
    else if (statusCode === '001') {
        statusHtml = '<span class="badge badge-success badge-sm">완료</span>';
    } 
    // 3. [진행중] 상태 (003 - 조제중/치료중/검사중 등)
    else if (statusCode === '003') {
        let processingText = '진행중';
        
        // 카테고리별 상세 텍스트 매핑 (공통코드명 참고)
        if(category === 'drug') processingText = '조제중';
        else if(category === 'exam') processingText = '검사중'; 
        else if(category === 'treatment') processingText = '치료중';
        else if(category === 'diet') processingText = '조리중'; // 예시

        statusHtml = `<span class="badge badge-primary badge-sm">\${processingText}</span>`;
    } 
    // 4. [중단] 상태 (004)
    else if (statusCode === '004') {
        statusHtml = `<span class="badge badge-danger badge-sm">중단</span>`;
    } 
    else {
        statusHtml = `<span class="badge badge-default badge-sm">\${statusCode || '-'}</span>`;
    }

    return `
        <tr class="border-b border-slate-100 hover:bg-slate-50 transition-colors">
            <td class="text-center text-slate-500">\${no}</td>
            <td class="text-gray-500 text-xs text-center">\${date}</td>
            <td><span class="badge \${badgeColor} badge-outline badge-sm">\${type}</span></td>
            <td class="font-medium text-slate-700">\${name}</td>
            <td class="text-xs text-slate-500">\${detail}</td>
            <td class="text-center">\${statusHtml}</td>
        </tr>
    `;
}

// 오더 수행 업데이트 
function updateOrderStatus(category, drugNo, predetailNo, nextStatus) {
	const payload =({
		predetailNo: predetailNo,
		drugNo: drugNo,
        predrugDetailStatus: nextStatus		//001
    });
	   Swal.fire({
           title: '',
           text: "주사 수행을 완료하시겠습니까?",
           icon: 'question',
           showCancelButton: true,
           confirmButtonText: '확인',
           cancelButtonText: '취소'
       }).then((result) => {
           if (result.isConfirmed) {
               axios.post("/nurse/predrugdetailstatusupdate", payload)
                   .then(res => {
                       sweetAlert("success", "주사 수행 완료 처리되었습니다.", "확인");
                       closeModal('modal-transfer');
                       const currentChartNo = document.getElementById('niChartNo').value;
                       fetchPrescriptionData(currentChartNo);
                   })
                   .catch(err => {
                       console.error("전실 저장 실패:", err);
                       sweetAlert("warning", "서버오류, 주사 수행 내용을 저장 실패하였습니다.", "확인");
                   });
           } 
       });
    
}
</script>