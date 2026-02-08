<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div id="listDetailUpdate" class="modal-backdrop" style="display: none;" onclick="if(event.target === this) closeModal('listDetailUpdate')">
    <div class="modal modal-lg" style="max-height: 90vh; display: flex; flex-direction: column;">
        <div class="modal-header">
            <h3 class="modal-title">주문 상세 내역</h3>
            <button class="btn btn-icon btn-ghost" onclick="closeModal('listDetailUpdate')">×</button>
        </div>
        
        <div class="modal-body" style="flex: 1; overflow-y: auto;">
            <div class="mb-4 text-sm text-gray-500 font-bold flex justify-between items-center">
                <span id="listDetailUpdateTitle"></span>
                <span id="editModeLabel" class="text-red-500 text-xs hidden">※ 수정 모드</span>
            </div>

            <div class="table-wrapper">
                <table class="table table-center">
                    <colgroup>
                         <col style="width: 60px;"> 
                         <col style="width: auto;">
                         <col style="width: 100px;">
                         <col style="width: 100px;">
                         <col style="width: 120px;">
                    </colgroup>
                    <thead>
                        <tr>                                       
                            <th id="thAction">No</th>
                            <th class="text-left" id="listDetailUpdateThead">품목명</th>
                            <th class="text-right">단가</th>
                            <th>신청수량</th>
                            <th class="text-right">주문액</th>
                        </tr>
                    </thead>
                    <tbody id="listDetailUpdateTbody">
                    </tbody>
                </table>
            </div>

            <div class="box box-bordered mt-6 bg-slate-50 flex justify-end items-center gap-4">
                <span class="text-lg font-bold text-slate-500">총 합계금액</span>
                <span id="listDetailUpdateTotalAmount" class="text-2xl font-black text-blue-600">0원</span>
            </div>

            <div id="searchSection" class="mt-6 border-t pt-4 hidden">
                <h4 class="font-bold mb-2">항목 추가 검색</h4>
                <div class="flex gap-2 mb-2">
                    <input type="text" id="searchInput" class="input input-bordered flex-1" placeholder="품목명 검색">
                    <button class="btn btn-primary" onclick="searchItems()">검색</button>
                </div>
                <div id="searchResultArea" class="border rounded p-2 bg-gray-50 h-32 overflow-y-auto text-sm hidden">
                </div>
            </div>
        </div>
        
        <div class="modal-footer justify-between">
            <div id="leftBtnGroup"></div>
            <div class="flex gap-2" id="btnGroup"></div>
        </div>
    </div>
</div>
<script>
    // 현재 편집 중인 데이터를 담을 전역 변수
    let currentOrderNo = null;
    let currentOrderType = "";
    let currentDetailList = []; // 리스트 데이터를 여기서 관리 (추가/삭제 반영)

    // 1. 모달 열기 및 초기 데이터 세팅
	function listDetailUpdate(index) { 
	    if (!globalOrderList || !globalOrderList[index]) {
	        console.error("데이터를 찾을 수 없습니다.");
	        return;
	    }
		
	    const orderData = globalOrderList[index];
        currentOrderNo = orderData.orderNo;
        currentOrderType = orderData.orderType;

        // 원본 데이터를 깊은 복사하여 편집용 리스트 초기화
        // (취소 시 원본 유지를 위해 복사본 사용 권장)
        currentDetailList = JSON.parse(JSON.stringify(orderData.orderDetails));
	
	    if (!currentDetailList || currentDetailList.length === 0) {
	    	sweetAlert("warning", "상세 내역이 없습니다.", "확인"); 	       
	        return;
	    }
	    
	    // 초기 화면 그리기 (읽기 모드: false)
        renderTable(false);
	    
	    openModal('listDetailUpdate'); 
	}
	
    // 2. 테이블 및 UI 렌더링 함수 (핵심)
    // isEditMode: true(수정화면), false(조회화면)
    function renderTable(isEditMode) {
        // 헤더 텍스트 설정
	    let typeText = (currentOrderType === '001') ? '📌 발주 약품 내역' : '📌 발주 물품 내역';
	    let tHeadName = (currentOrderType === '001') ? '약품명' : '물품명'; 
	    
	    document.getElementById('listDetailUpdateTitle').innerHTML = typeText;
	    document.getElementById('listDetailUpdateThead').innerHTML = tHeadName;
        
        // 수정 모드 라벨 및 컬럼명 변경
        document.getElementById('editModeLabel').classList.toggle('hidden', !isEditMode);
        document.getElementById('thAction').innerText = isEditMode ? "삭제" : "No";

        // 검색창 표시 여부
        document.getElementById('searchSection').classList.toggle('hidden', !isEditMode);
        // 검색 결과창 초기화 및 숨김
        document.getElementById('searchResultArea').innerHTML = "";
        document.getElementById('searchResultArea').classList.add('hidden');
        document.getElementById('searchInput').value = "";

        // 버튼 그룹 변경
        const btnGroup = document.getElementById('btnGroup');
        if (isEditMode) {
            btnGroup.innerHTML = `
                <button class="btn btn-secondary" onclick="cancelEdit()">취소</button>
                <button class="btn btn-primary" onclick="submitUpdate()">수정 완료</button>
            `;
        } else {
            btnGroup.innerHTML = `
                <button class="btn btn-secondary" onclick="closeModal('listDetailUpdate')">닫기</button>
                <button class="btn btn-primary" onclick="startEdit()">수정</button>
                <button class="btn btn-destructive-outline" onclick="deleteOrder(\${currentOrderNo})">삭제</button>
            `;
        }

        // 리스트 반복 렌더링
        let html = "";
        let totalAmount = 0;

        currentDetailList.forEach((detail, idx) => {
            let name = "-", company = "-", price = 0, unit = "";
            let qty = detail.orderDetailCount;

            // 데이터 추출 (약품/물품 구분)
            if (currentOrderType === '001') { 
                if (detail.drugList && detail.drugList.length > 0) {
                    const d = detail.drugList[0];
                    name = d.drugName; company = d.drugCompany; price = d.drugPrice; unit = d.drugUnit;
                }
            } else { 
                if (detail.productList && detail.productList.length > 0) {
                    const p = detail.productList[0];
                    name = p.productName; company = p.productCompany; price = p.productCost; unit = "개";
                }
            }
            
            let rowTotal = price * qty;
            totalAmount += rowTotal;

            // 모드에 따른 HTML 분기
            let actionHtml = isEditMode 
                ? `<button class="btn btn-xs btn-circle btn-ghost text-red-500" onclick="removeRow(\${idx})">✕</button>`
                : `\${idx + 1}`;
            
            let qtyHtml = isEditMode
                ? `<input type="number" class="input input-sm input-bordered w-full text-center" 
                   value="\${qty}" min="1" onchange="updateQty(\${idx}, this.value)">`
                : `<span>\${qty} \${unit}</span>`;

            html += `
                <tr>
                    <td class="text-center">\${actionHtml}</td>
                    <td class="text-left">
                        <div class="font-medium">\${name}</div>
                        <div class="text-xs text-gray-400 font-normal">\${company}</div>
                    </td>
                    <td class="text-right text-gray-600">\${price.toLocaleString()}원</td>
                    <td class="text-center" style="width: 100px;">\${qtyHtml}</td>
                    <td class="text-right font-semibold">\${rowTotal.toLocaleString()}원</td>
                </tr>
            `;
        });

        document.getElementById('listDetailUpdateTbody').innerHTML = html;
        document.getElementById('listDetailUpdateTotalAmount').innerHTML = totalAmount.toLocaleString() + "원";
    }

    // --- 기능 함수들 ---

    // [수정 시작] 버튼 클릭
    function startEdit() {
        renderTable(true);
    }

    // [취소] 버튼 클릭 (원래 상태로 복구)
    function cancelEdit() {
        if(confirm("수정을 취소하시겠습니까? 변경사항이 사라집니다.")) {
            // 원본 데이터로 다시 초기화 (globalOrderList에서 다시 가져오기)
            listDetailUpdate(globalOrderList.findIndex(o => o.orderNo === currentOrderNo));
        }
    }

    // [수량 변경] 인풋 값 변경 시 데이터 업데이트 & 재렌더링
    function updateQty(idx, newVal) {
        if(newVal < 1) { 
        	sweetAlert("warning", "1개 이상이어야 합니다.", "확인");         	
        	renderTable(true); 
        	return; 
        	}
        currentDetailList[idx].orderDetailCount = parseInt(newVal);
        renderTable(true); // 총액 재계산을 위해 다시 그림
    }

    // [삭제] X 버튼 클릭 시 리스트에서 제거
    function removeRow(idx) {
        if(currentDetailList.length <= 1) {
        	sweetAlert("warning", "최소 1개의 품목은 있어야 합니다. 전체 삭제를 이용해주세요.", "확인");             
            return;
        }
        currentDetailList.splice(idx, 1); // 배열에서 해당 인덱스 삭제
        renderTable(true); // 다시 그리기
    }

 // [검색] 버튼 클릭
    function searchItems() {
        const keyword = document.getElementById('searchInput').value;
        if(!keyword) { 
            sweetAlert("warning", "검색어를 입력해주세요.", "확인");
            return; 
        }
        
        axios.get('/order/searchItems', {
            params: {
                type: currentOrderType,
                keyword: keyword
            }
        })
        .then(res => {
            const results = res.data; 
            const resultArea = document.getElementById('searchResultArea');
            resultArea.innerHTML = "";
            resultArea.classList.remove('hidden');

            if(results.length === 0) {
                resultArea.innerHTML = "<div class='text-center p-2'>검색 결과가 없습니다.</div>";
                return;
            }

            let html = "<ul class='menu bg-base-100 w-full p-0'>";
            results.forEach(item => {
                let no, name, company, price, unit;

                if(currentOrderType === '001') { 
                    // 약품 (DrugVO 필드명 사용)
                    no = item.drugNo;
                    name = item.drugName;
                    company = item.drugCompany;
                    price = item.drugPrice;
                    unit = item.drugUnit;
                } else { 
                    // 물품 (ProductVO 필드명 사용)
                    no = item.productNo;
                    name = item.productName;
                    company = item.productCompany;
                    price = item.productCost; 
                    unit = "개";
                }

                // [중요] 통일된 객체 생성
                let commonItem = {
                    itemNo: no,
                    itemName: name,
                    company: company,
                    price: price,
                    unit: unit
                };

                // [수정 포인트] 여기서 원래 item이 아니라 'commonItem'을 인코딩해야 합니다!
                const itemStr = encodeURIComponent(JSON.stringify(commonItem));

                html += `
                    <li>
                        <a onclick="addRow('\${itemStr}')" class="flex justify-between gap-4 hover:bg-blue-50 transition-colors duration-200 cursor-pointer">
                            <span>
                                <span class="font-bold">\${name}</span>
                                <span class="text-xs text-gray-400 ml-2">\${company}</span>
                            </span>
                            <span class="text-blue-600">\${price.toLocaleString()}원</span>
                        </a>
                    </li>
                `;
            });
            html += "</ul>";
            resultArea.innerHTML = html;
        })
        .catch(err => {
            console.error(err);
            sweetAlert("warning", "검색 중 오류가 발생했습니다.", "확인");            
        });
    }

    // [추가] 검색 결과 클릭 시 리스트에 추가
    function addRow(itemStr) {
        const item = JSON.parse(decodeURIComponent(itemStr)); // 여기서 item은 위에서 만든 commonItem이 됨
        
        const exists = currentDetailList.some(detail => detail.orderItemNo == item.itemNo);
        if(exists) {
        	sweetAlert("warning", "이미 리스트에 존재하는 품목입니다.", "확인");       
            
            return;
        }

        let newDetail = {
            orderDetailNo: 0,
            orderDetailCount: 1,
            orderNo: currentOrderNo,
            orderItemNo: item.itemNo, // commonItem의 itemNo 사용
            drugList: [],
            productList: []
        };

        if(currentOrderType === '001') {
            newDetail.drugList = [{
                drugName: item.itemName,   // commonItem의 itemName 사용
                drugCompany: item.company, // commonItem의 company 사용
                drugPrice: item.price,     // commonItem의 price 사용
                drugUnit: item.unit
            }];
        } else {
            newDetail.productList = [{
                productName: item.itemName,
                productCompany: item.company,
                productCost: item.price // 여기서 price가 undefined가 아니게 됨!
            }];
        }

        currentDetailList.push(newDetail);
        renderTable(true); 
        
        document.getElementById('searchInput').value = "";
        document.getElementById('searchResultArea').classList.add('hidden');
    }

    // [저장] 수정 완료 버튼 클릭
    function submitUpdate() {
        if(currentDetailList.length === 0) { 
        	sweetAlert("warning", "품목이 없습니다.", "확인");        	
        	return; 
        	}
        
        Swal.fire({
            title:'',
            text: "현재 상태로 발주 내역을 수정하시겠습니까?",
            icon: 'question',
            showCancelButton: true,
            confirmButtonText: '수정',
            cancelButtonText: '취소'
        }).then((result) => {
            if (result.isConfirmed) {
                // 서버로 전송
                axios.post('/order/updateOrder', {
                    orderNo: currentOrderNo,
                    orderDetails: currentDetailList
                })
                .then(res => {
                    Swal.fire("성공", "수정이 완료되었습니다.", "success");
                    closeModal('listDetailUpdate');
                    loadOrderList(); // 목록 새로고침
                })
                .catch(err => {
                    console.error(err);
                    Swal.fire("실패", "수정 중 오류가 발생했습니다.", "error");
                });
            }
        });
    }

	function deleteOrder(orderNo){
		Swal.fire({
	        icon: 'warning',
	        title: '정말 해당 발주 신청을 삭제하시겠습니까?',
	        text: "삭제한 데이터는 복구할 수 없습니다.",
	        showCancelButton: true,
	        confirmButtonText: '확인',
	        cancelButtonText: '취소'
	    }).then((result) => {        
	        if (result.isConfirmed) {	            
	            
	            axios.get('/order/orderDelete',{
	            		params: { 
                        orderNo: orderNo 
	            	}
                })
	            .then(res => {                 
	                Swal.fire("삭제완료", "해당 발주 삭제가 완료되었습니다.", "success");
	                closeModal('listDetailUpdate'); 
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