<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<div id="insertModal" class="modal-backdrop" style="display: none;" onclick="if(event.target === this) closeModal('insertModal')">
	
    <div class="modal modal-lg">
        
        <div class="modal-header">
            <h3 class="modal-title">통합 발주 신청</h3>
            <button class="btn btn-icon btn-ghost" onclick="closeModal('insertModal')">×</button>
        </div>
        
        <div class="modal-body">
            <div class="mb-4 text-sm text-gray-500">
                선택하신 물품의 발주 내역을 최종 확인해주세요.
            </div>

            <div class="table-wrapper">
                <table class="table table-center">
                    <thead>
                        <tr>
                            <th style="width: 50px;">No</th>
                            <th class="text-left">물품명</th>
                            <th class="text-right">단가</th>
                            <th style="width: 100px;">신청갯수</th>
                            <th class="text-right">주문액</th>
                        </tr>
                    </thead>
                    <tbody id="bulkOrderList">
                    </tbody>
                </table>
            </div>

            <div class="box box-bordered mt-6 bg-slate-50 flex justify-end items-center gap-4">
                <span class="text-lg font-bold text-slate-500">총 합계금액</span>
                <span id="grandTotalAmount" class="text-2xl font-black text-blue-600">0원</span>
            </div>
        </div>
        
        <div class="modal-footer">
            <button class="btn btn-secondary" onclick="closeModal('insertModal')">취소</button>
            <button class="btn btn-primary" onclick="submitBulkOrder()">최종 신청 완료</button>
        </div>
    </div>
</div>

<script>
    // 전역 변수로 선언하되, 모달 열 때마다 0으로 초기화해야 함
	let grandTotal = 0;

    //==========================================================================
    // 통합 발주 모달 열기 및 데이터 렌더링
    //==========================================================================
    function insertModal() {
        // 장바구니 비었는지 확인
        if (!cartList || cartList.length === 0) {
	        if(typeof sweetAlert !== 'undefined') sweetAlert("warning", "장바구니가 비어있습니다.", "확인");            
	        return;
        }

        // 수량이 입력되지 않은 항목 체크
        const emptyQtyItem = cartList.find(item => !item.orderQty || item.orderQty <= 0);
        if (emptyQtyItem) {
            const pName = emptyQtyItem.productName;
            if(typeof Swal !== 'undefined') Swal.fire('확인 필요', `[\${pName}]의 수량을 입력해주세요.`, 'warning');            
            return;
        }

        // 테이블 그리기
        const tbody = document.getElementById('bulkOrderList');
        const grandTotalElem = document.getElementById('grandTotalAmount');
        let html = '';      
        
        
        grandTotal = 0; 

        cartList.forEach((item, index) => {
            let indexNum = index + 1;
            let qty = parseInt(item.orderQty);
            
            // 금액 누적
            grandTotal += item.productCost * qty;

            html += `
                <tr>
                    <td>\${indexNum}</td>
                    <td class="text-left ">
                        \${item.productName}
                        <div class="text-xs text-gray-400 font-normal">\${item.productCompany}</div>
                    </td>
                    <td class="text-right text-gray-600">
                        \${item.productCost.toLocaleString()}원
                    </td>
                    <td>
                        <span>\${qty} 개</span>
                    </td>
                    <td class="text-right">
                        \${(item.productCost*qty).toLocaleString()}원
                    </td>
                </tr>
            `;
        });

        tbody.innerHTML = html;
        grandTotalElem.innerText = grandTotal.toLocaleString() + "원";
		
        console.log('cartList', cartList);        
        openModal('insertModal');
    }

    //==========================================================================
    // 최종 신청 완료 처리
    //==========================================================================
    function submitBulkOrder() {   	
    	
        const orderData = {        		 
            orderTotalamt: grandTotal,        
            orderType: '002',      //발주 타입 물품          
            orderStatus: '001',               
            
            orderDetails: cartList.map(item => {
                return {
                    orderItemNo: item.productNo,       
                    orderDetailCount: parseInt(item.orderQty), 
                    orderItemType: '001'           
                };
            })
        };

        
    	axios.post('/order/orderInsert', orderData, {
            headers: {
                'Content-Type': 'application/json'
            }
        })
  	    .then(function (response) {	
			sendNewNotification(26030909, '물품 발주 신청', '새로운 물품 발주 신청이 접수되었습니다.', '006', 'http://localhost:5173/admin/orders');	           	
            // 성공 시 처리
  	    	Swal.fire({
                title: '발주 신청 완료',
                text: '발주 신청이 성공적으로 접수되었습니다.',
                icon: 'success',
                confirmButtonText: '확인'
            }).then((result) => {
                if (result.isConfirmed) {
                    processAfterSubmit();
                }
            });
    	})
  	    .catch(function (error) {	            
            console.error(error);
            if (error.response && error.response.status === 404) {
            	sweetAlert("warning", "발주 신청 처리에 실패했습니다. (결과값 없음)", "확인");
            } else {
            	sweetAlert("warning", "서버오류, 발주 신청을 실패하였습니다", "확인");
            }
        });
    }

    // 신청 후 뒷정리 함수
    function processAfterSubmit() {
        cartList = []; // 장바구니 비우기
        renderCart();  // 메인 화면 장바구니 UI 갱신
        closeModal('insertModal'); // 모달 닫기 
    }
</script>