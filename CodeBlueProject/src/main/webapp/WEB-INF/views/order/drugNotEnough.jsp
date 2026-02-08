<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<style>
    .modal-body-scroll {
        max-height: 60vh;
        overflow-y: auto;
    }
</style>

<div id="stockAlertModal" class="modal-backdrop" style="display: none;" onclick="if(event.target === this) closeModal('stockAlertModal')">
    <div class="modal modal-md">
        <div class="modal-header" style="border-bottom: 1px solid var(--color-danger-light);">
            <div style="display: flex; align-items: center; gap: var(--spacing-sm);">
                <span style="font-size: 1.5rem;">⚠️</span>
                <h3 class="modal-title" style="color: var(--color-danger);">재고 부족 약품 목록</h3>
            </div>
            <button class="btn btn-icon btn-ghost" onclick="closeModal('stockAlertModal')">×</button>
        </div>
        
        <div class="modal-body modal-body-scroll">
        	<div id="alertItemsList" class="list"></div>
        </div>
        
        <div class="modal-footer">
        	<button class="btn btn-danger-light" onclick="addAllLowStockToCart()">부족 품목 일괄 담기</button>
            <button class="btn btn-secondary" onclick="closeModal('stockAlertModal')">닫기</button>            
        </div>
    </div>
</div>

<script>
	let fetchedLowStockList = [];	//부족약품 담을 전역변수
	
   	//==========================================================================
 	// 부족수량 약품 출력 함수
 	//==========================================================================
    function checkLowStock() {
    	axios.get('/order/notEnoughDrug')
    	 .then(function (response) {
    		 fetchedLowStockList = response.data;
    		 if (!fetchedLowStockList || fetchedLowStockList.length === 0) {
    			 sweetAlert("success", "재고 부족 약품이 없습니다.", "확인");
    		 }
    		 
    		 const listContainer = document.getElementById('alertItemsList');
             let html = '';

             fetchedLowStockList.forEach((item, index) => {
                 html += `
                	 <div class="table-wrapper">
                	 <table class="table">	                     
	                     <tbody>
	                         <tr>
	                             <td style="width: 85%; font-size: var(--font-sm);; margin-bottom: 4px;"> 
	                             	\${item.drugName}
	                             <div class="text-xs text-gray-400 font-normal">\${item.drugCompany}</div>	
	                             <div style="font-size: var(--font-sm);">현재: \${item.drugAmount} / 안전재고: \${item.drugSaftyStoke}</div>
	                             </td>	                             	                             
	                             <td style="width: 15%; text-align: center;">
		                             <button onclick="addSingleFromModal(\${index})" class="btn btn-destructive btn-sm">담기</button>
		                         </td>
	                         </tr>
	                     </tbody>
	                 </table>
                	 </div>
                 `;
             });

             listContainer.innerHTML = html;
             openModal('stockAlertModal');
    	 })
    	 .catch(function (error) {	            
	       	sweetAlert("warning", "서버오류, 부족한 약품을 가져올 수 없습니다.", "확인");
	       }); 
    }

  	//==========================================================================
	//부족 품목 일괄 담기 함수
	//==========================================================================
    function addAllLowStockToCart() {
	    let addedCount = 0;        // 담긴 수량 확인용 변수
	    let skippedNames = [];     // 제외된 약품 이름을 담을 배열
	    
	    fetchedLowStockList.forEach(item => {
	        // 이미 장바구니에 있는지 확인 (drugNo 기준)
	        // 재미나이가 알려준 some함수 (배열 안에 조건에 맞는 요소가 하나라도 있는지 확인하는 조건 함수 true 나 false를 리턴해준다)
	        const isExist = cartList.some(cartItem => cartItem.drugNo === item.drugNo);
	        
	        if (!isExist) {
	            cartList.push({
	                ...item,
	                orderQty: ''
	            });
	            addedCount++;
	        } else {	        	
	            skippedNames.push(item.drugName);
	        }
	    });
	
	    // 메인 페이지의 장바구니 다시 그리기
	    renderCart();
	    closeModal('stockAlertModal');
	    
	    let msgHtml = '';
	    msgHtml += `총 <span style="color: #ef4444; font-weight: bold;">\${addedCount}</span>건이 장바구니에 추가되었습니다.<br/>`;
	    // 제외된 항목이 있다면 메시지 뒷부분에 추가
	    if (skippedNames.length > 0) {      
	        msgHtml += `<span style="font-size: var(--font-sm); color: var(--color-text-secondary); margin-bottom: var(--spacing-xs);">
	        				이미 담겨있는 <br/>[ \${skippedNames[0]} 외 \${skippedNames.length}건 ]<br/> 약품은 제외 하였습니다.
	        			</span>`;
	    }
	    
	    Swal.fire({
	        title: '완료',
	        html: msgHtml, 
	        icon: 'success'
	    });
	}
  	//==========================================================================
	//부족 품목 개별 담기 함수
	//==========================================================================
    function addSingleFromModal(index) {
        const item = fetchedLowStockList[index];
        
        // 중복 체크
        const isExist = cartList.some(cartItem => cartItem.drugNo === item.drugNo);
        
        if (isExist) {
            Swal.fire('알림', '이미 장바구니에 담긴 약품입니다.', 'warning');
            return;
        }

        // 장바구니 추가
        cartList.push({
            ...item,
            orderQty: ''
        });

        renderCart(); 
                
        
    }
</script>