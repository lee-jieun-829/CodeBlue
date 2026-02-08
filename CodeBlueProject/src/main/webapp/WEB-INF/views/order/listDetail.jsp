<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="listDetail" class="modal-backdrop" style="display: none;" onclick="if(event.target === this) closeModal('listDetail')">
    <div class="modal modal-lg">
        <div class="modal-header">
            <h3 class="modal-title">주문 상세 내역</h3>
            <button class="btn btn-icon btn-ghost" onclick="closeModal('listDetail')">×</button>
        </div>
        
        <div class="modal-body">
            <div class="mb-4 text-sm text-gray-500 font-bold" id="listDetailTitle"></div>

            <div id="rejectCallout" class="callout callout-danger mb-6" style="display: none;">
                <div class="callout-title">
                    <svg class="callout-title-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <circle cx="12" cy="12" r="10"></circle>
                        <line x1="15" y1="9" x2="9" y2="15"></line>
                        <line x1="9" y1="9" x2="15" y2="15"></line>
                    </svg>
                    반려 사유
                </div>
                <div class="callout-content" id="rejectContent">
                    </div>
            </div>

            <div class="table-wrapper">
                <table class="table table-center">
                     <colgroup>
                         <col style="width: 50px;">
                         <col style="width: auto;">
                         <col style="width: 100px;">
                         <col style="width: 100px;">
                         <col style="width: 120px;">
                    </colgroup>
                    <thead>
                        <tr>                                       
                            <th>No</th>
                            <th class="text-left" id="listDetailThead"></th>
                            <th class="text-right">단가</th>
                            <th>신청수량</th>
                            <th class="text-right">주문액</th>
                        </tr>
                    </thead>
                    <tbody id="listDetailTbody"></tbody>
                </table>
            </div>

            <div class="box box-bordered mt-6 bg-slate-50 flex justify-end items-center gap-4">
                <span class="text-lg font-bold text-slate-500">총 합계금액</span>
                <span id="listDetailAmount" class="text-2xl font-black text-blue-600"></span>
            </div>
        </div>
        
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeModal('listDetail')">닫기</button>
        </div>
    </div>
</div>

<script>
function listDetail(index) { 
    if (!globalOrderList || !globalOrderList[index]) {
        console.error("데이터를 찾을 수 없습니다.");
        return;
    }
	
    const orderData = globalOrderList[index];
    const detailList = orderData.orderDetails; 

    if (!detailList || detailList.length === 0) {
        alert("상세 내역이 없습니다.");
        return;
    }
    
    const orderType = orderData.orderType; 
    
    // 헤더 텍스트 설정
    let typeText = (orderType === '001') ? '  📌 발주 약품 내역' : '📌 발주 물품 내역';
    let tHeadName = (orderType === '001') ? '약품명' : '물품명'; 
    
    document.getElementById('listDetailTitle').innerHTML = typeText;
    document.getElementById('listDetailThead').innerHTML = tHeadName;

    
    const rejectCallout = document.getElementById('rejectCallout');
    const rejectContent = document.getElementById('rejectContent');

    if (orderData.orderStatus === '005') {
        // 1. 상태가 005(반려)이면 박스를 보여줌 (display: block 또는 flex)
        rejectCallout.style.display = 'block'; 
        
        // 2. 사유 텍스트 주입 (없으면 기본 멘트)
        rejectContent.innerText = orderData.orderContent ? orderData.orderContent : "반려 사유가 기재되지 않았습니다.";
    } else {
        // 3. 아니면 숨김
        rejectCallout.style.display = 'none';
        rejectContent.innerText = "";
    }
    
    let orderItemListHtml = "";
    let totalAmount = 0; 
    
    detailList.forEach((detail, idx) => {
        let name = "-";
        let company = "-";
        let price = 0;
        let unit = "";
        let qty = detail.orderDetailCount; 
       
        if (orderType === '001') { // 약품                    
            if (detail.drugList && detail.drugList.length > 0) {
                const drug = detail.drugList[0]; 
                name = drug.drugName;
                company = drug.drugCompany;
                price = drug.drugPrice; 
                unit = drug.drugUnit;   
            }
        } else { // 물품     
            if (detail.productList && detail.productList.length > 0) {
                const product = detail.productList[0];
                name = product.productName;
                company = product.productCompany;
                price = product.productCost;       
                unit = "개";
            }
        }

        let rowTotal = price * qty;
        totalAmount += rowTotal;

        orderItemListHtml += `
            <tr>
                 <td class="text-center">\${idx + 1}</td>
                 <td class="text-left">
                    <div class="font-medium">\${name}</div>
                    <div class="text-xs text-gray-400 font-normal">\${company}</div>
                </td>
                <td class="text-right text-gray-600">
                    \${price.toLocaleString()}원
                </td>
                <td class="text-center">
                    <span>\${qty} \${unit}</span>
                </td>
                <td class="text-right font-semibold">
                    \${rowTotal.toLocaleString()}원
                </td>
            </tr>
        `;
    });
   
   document.getElementById('listDetailTbody').innerHTML = orderItemListHtml;   
   document.getElementById('listDetailAmount').innerHTML = totalAmount.toLocaleString()+"원";   
   
   openModal('listDetail'); 
}
</script>