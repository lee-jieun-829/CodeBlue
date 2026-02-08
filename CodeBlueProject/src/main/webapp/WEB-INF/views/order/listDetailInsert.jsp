<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="listDetailInsert" class="modal-backdrop" style="display: none;" onclick="if(event.target === this) closeModal('listDetailInsert')">
    <div class="modal modal-lg">
        <div class="modal-header">
            <h3 class="modal-title">배송 완료 확인</h3>
            <button class="btn btn-icon btn-ghost" onclick="closeModal('listDetailInsert')">×</button>
        </div>
        
        <div class="modal-body">
            <div class="mb-4 text-sm text-gray-500 font-bold" id="listDetailInsertTitle"></div>

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
                            <th class="text-left" id="listDetailInsertHead">품목명</th>
                            <th class="text-right">단가</th>
                            <th>신청수량</th>
                            <th class="text-right">주문액</th>
                        </tr>
                    </thead>
                    <tbody id="listDetailInsertTbody"></tbody>
                </table>
            </div>

            <div class="box box-bordered mt-6 bg-slate-50 flex justify-end items-center gap-4">
                <span class="text-lg font-bold text-slate-500">총 합계금액</span>
                <span id="listDetailInsertAmount" class="text-2xl font-black text-blue-600">0원</span>
            </div>
        </div>
        
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeModal('listDetailInsert')">닫기</button>
            <button class="btn btn-primary" id="btnConfirmReceipt">수령 확인 (재고반영)</button>
        </div>
    </div>
</div>

<script>
function fillReceiptModal(index) {
	// globalOrderList가 비어있거나 인덱스가 없으면 리턴
    if (!globalOrderList || !globalOrderList[index]) {
        console.error("데이터를 찾을 수 없습니다.");
        return;
    }
	
	 //  해당 인덱스의 주문 정보 객체 가져오기
    const orderData = globalOrderList[index];    
    // 주문 상세 리스트 추출
    const detailList = orderData.orderDetails; 

    // 데이터가 비어있을 경우 예외처리
    if (!detailList || detailList.length === 0) {
        alert("상세 내역이 없습니다.");
        return;
    }
    
    
    const orderType = orderData.orderType;
    
    // 헤더 텍스트 설정
    let typeText = (orderType === '001') ? '  📌 발주 약품 내역' : '📌발주 물품 내역';
    let tHeadName = (orderType === '001') ? '약품명' : '물품명';     
    document.getElementById('listDetailInsertTitle').innerHTML = typeText;
    document.getElementById('listDetailInsertHead').innerHTML = tHeadName;
    
    //수령 확인 버튼에 데이터를 할당하기 위해 여기서 온클릭 이벤트를 연결
    document.getElementById('btnConfirmReceipt').onclick = function() {
        confirmReceipt(orderData);
    };    
    
    let orderItemListHtml = "";
    let totalAmount = 0; // 총 합계
	let footerButton ="";
    
    
    // 주문한 아이템 리스트 반복 시작
    detailList.forEach((detail, idx) => {
        let name = "-";
        let company = "-";
        let price = 0;
        let unit = "";
        let qty = detail.orderDetailCount; // 신청 갯수
        let footerButton = "";
       
        
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
            }
        }

        // 단가 * 수량
        let rowTotal = price * qty;
        totalAmount += rowTotal;

        // 주문 item list
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
   
  
   
   document.getElementById('listDetailInsertTbody').innerHTML = orderItemListHtml;   
   document.getElementById('listDetailInsertAmount').innerHTML = totalAmount.toLocaleString()+"원";   
   
   openModal('listDetailInsert'); 
}

// 수령 확인 요청
function confirmReceipt(orderData) {
	console.log(orderData);
	Swal.fire({
        icon: 'warning',
        title: '수령 확인',
        text: "물품을 모두 수령하셨습니까? 재고에 반영됩니다.",
        showCancelButton: true,
        confirmButtonText: '확인',
        cancelButtonText: '취소'
    }).then((result) => {        
        if (result.isConfirmed) {
            
            // --- Axios 요청 시작 ---
            axios.post('/order/orderDetailUpdate', orderData)
            .then(res => {                 
                Swal.fire("성공", "수령 확인이 완료되었습니다.", "success");
                
                closeModal('listDetailInsert'); 
                loadOrderList(); 
            })
            .catch(err => { 
                console.error(err); 
                Swal.fire("실패", "처리 중 오류가 발생했습니다.", "error");
            });            
            
        }
    });
}
</script>