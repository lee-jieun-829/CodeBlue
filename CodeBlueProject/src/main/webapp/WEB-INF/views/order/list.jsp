<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<!-- ===== Head 시작 ===== -->
<%@ include file="/WEB-INF/views/common/include/link.jsp" %>
<!-- ===== Head 끝 ===== -->
<title>주문 목록</title>
<body class="bg-neutral-100 text-zinc-950" data-gnb="gnb-order">
    <div class="app h-screen w-full flex flex-col">
     <!-- ===== Header 시작 ===== -->
	<%@ include file="/WEB-INF/views/common/include/header.jsp" %>
	<!-- ===== Header 끝 ===== -->
	<div class="main-container">
		<!-- ===== Sidebar 시작 (각 액터에 따라 sidebar jsp 교체)  ===== -->
				<sec:authorize access="hasRole('ROLE_ADMIN')">
					<%@ include file="/WEB-INF/views/common/include/left/left_admin.jsp" %>
				</sec:authorize>
				<sec:authorize access="hasRole('ROLE_DOCTOR')">
					<%@ include file="/WEB-INF/views/common/include/left/left_doctor.jsp" %>
				</sec:authorize>
				<sec:authorize access="hasRole('ROLE_NURSE_IN') or hasRole('ROLE_NURSE_OUT')">
					<%@ include file="/WEB-INF/views/common/include/left/left_nursing.jsp" %>
				</sec:authorize>
				<sec:authorize access="hasRole('ROLE_PHARMACIST')">
					<%@ include file="/WEB-INF/views/common/include/left/left_pharmacist.jsp" %>
				</sec:authorize>
				<sec:authorize access="hasRole('ROLE_RADIOLOGIST')">
					<%@ include file="/WEB-INF/views/common/include/left/left_radiologist.jsp" %>
				</sec:authorize>
				<sec:authorize access="hasRole('ROLE_THERAPIST')">
					<%@ include file="/WEB-INF/views/common/include/left/left_therapist.jsp" %>
				</sec:authorize>
				<sec:authorize access="hasRole('ROLE_OFFICE')">
					<%@ include file="/WEB-INF/views/common/include/left/left_reception.jsp" %>
				</sec:authorize>		
			<!-- ===== Sidebar 끝 ===== -->
		<!-- ===== Main 시작 ===== -->
		<main class="main-content overflow-hidden">
			<div class="grid grid-sidebar-lg grid-full-height"> <!-- main이 2분할 이상일 경우 grid 사이즈 클래스 추가 필요 -->
				<!-- 콘텐츠 영역 -->										
				<div class="content-area flex flex-col h-full overflow-hidden">
					<!-- 목록버튼 영역 -->
					<div class="btn-group-justified">
							<div class="btn-group-left">
								<div style="font-size: var(--font-lg); font-weight: var(--font-medium); margin-bottom: var(--spacing-xs);">재고 관리 메뉴</div>
							</div>																					
					</div>
					<hr class="section-divider"/>
					<div class="list">
					    <div class="list-item " >
					    	<a href="../order/drug">약품 목록 조회</a>					        
					    </div>
					    <div class="list-item" >
					    	 <a href="../order/product">물품 목록 조회</a>				        
					    </div>
					    <div class="list-item list-item-active">
					        <a href="../order/list">주문 목록 조회</a>					        
					    </div>
					</div>
				</div>
				
				<!-- 발주 목록 영역 -->
				<div class="content-area flex flex-col h-full min-h-0 overflow-hidden">
					<div class="box flex flex-col p-0 min-h-0 overflow-hidden justify-center">
					<div class=" card-header  flex-none" style="font-size: var(--font-base); font-weight: var(--font-semibold); ">
						<span>내 발주 목록</span>
						<div class="btn-group-right">								    
						   <input id="searchWord"type="date" class="input input-search input-sm" placeholder="검색어를 입력하세요">								    
						</div> 
					</div>
					<div class=" card-body  flex-1 overflow-y-auto">
						<div id="orderList" class="table-wrapper">							
						</div>
						<div id="pageNation" class="btn-group-center btn-sm" style="gap: 2px;">	
					</div>
					</div>
				</div>
			</div>
		</main>
		<!-- ===== Main 끝 ===== -->
	</div>
	</div>
</body>
<jsp:include page="/WEB-INF/views/order/listDetail.jsp" />
<jsp:include page="/WEB-INF/views/order/listDetailInsert.jsp" />
<jsp:include page="/WEB-INF/views/order/listDetailUpdate.jsp" />
<script type="text/javascript">
	let globalOrderList = [];
	
    document.addEventListener("DOMContentLoaded", function() {
        loadOrderList();
    });

    function loadOrderList(page = 1) {
        const reqPage = page - 1;  
        const searchInput = document.getElementById("searchWord"); 
        const searchWord = searchInput ? searchInput.value : '';    

        axios.get('/order/orderList', {
            params: {
                page: reqPage,
                size: 50,
                searchWord: searchWord
            }   
        })
        .then(function (response) {             
            const pageData = response.data;
            
            globalOrderList = pageData.content;
            
            const orderList = pageData.content; 
                       
            const totalPages = pageData.totalPages;
            const currPage = pageData.number;              
            

            //테이블 헤더
            let html = `
                <table class="table table-center" >
                    <thead>
                        <tr>                        
                            <th>구분</th>
                            <th class="text-left">주문목록</th>
                            <th>주문일시</th>
                            <th>상태</th>                        
                        </tr>
                    </thead>
                    <tbody>
            `;

            //데이터 반복
            if(globalOrderList && globalOrderList.length > 0) {
            	globalOrderList.forEach(function(order,index) {
                	let itemName = "발주 정보 없음";
                    let otherCount = 0;
                    let orderType = (order.orderType === '001') ? '약품' : '물품';
                    
                    if (order.orderDetails && order.orderDetails.length > 0) {                        
                        const firstDetail = order.orderDetails[0];     
                                         
                        if (firstDetail.drugList && firstDetail.drugList.length > 0) {
                            itemName = firstDetail.drugList[0].drugName; // 첫 번째 상세의 첫 번째 약품 이름 가져오기
                        }else{
                        	itemName = firstDetail.productList[0].productName;	// 첫 번째 상세의 첫 번째 물품 이름 가져오기
                        }
                        // 외 N건 계산 (전체 상세 개수 - 1)
                        otherCount = order.orderDetails.length - 1;
                    }

                    // 화면에 표시할 상품명 문자열 조합
                    let displayItemName = itemName;
                    if (otherCount > 0) {
                        displayItemName += ` 외 \${otherCount} 건`;
                    }
                    
                    let statusHtml = '';
                    if(order.orderStatus == "001") {     //주문대기               	
                         statusHtml = `
                         <span class="badge badge-default">승인대기</span>
                         <button class="btn btn-primary btn-sm">수정|삭제</button>	`; 
                    } else if (order.orderStatus == "002") {          //주문중              
                        statusHtml = `
                        <span class="badge badge-warning">주문중</span>
                        <button class="btn btn-primary btn-sm">수령확인</button>
                        `;
                    }else if(order.orderStatus == "004"){
                    	statusHtml = `<span class="badge badge-danger">반려</span>`;
                    }else {		//주문완료(003)
                        statusHtml = `<span class="badge badge-success">수령완료</span>`;
                    }
                  
                    html += `
                        <tr onclick="orderDetailModal(\${index})" class="cursor-pointer hover:bg-neutral-50">                                    
                            <td>\${orderType}</td>
                            <td class="text-left">\${displayItemName}</td>
                            <td>\${order.orderDate}</td>
                            <td>\${statusHtml}</td> 
                        </tr>
                    `;
                });
            } else {
                html += `<tr><td colspan="4" class="text-center p-4">데이터가 없습니다.</td></tr>`;
            }            
            html += `</tbody></table>`;            
            
            document.getElementById('orderList').innerHTML = html;            
            
            renderPagination(currPage + 1, totalPages, 'pageNation', 'loadOrderList');
        })
        .catch(function (error) {   
            console.log("error", error);
            sweetAlert("warning", "서버오류, 발주목록을 가져올 수 없습니다.", "확인");
        });
    }
    
  	//==========================================================================
	//모달 열기 함수
	//========================================================================== 
    function openModal(modalId) {
    	const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'flex';
            document.body.style.overflow = 'hidden'; // 배경 스크롤 막기
        }
    }
  	
    function orderDetailModal(index) {
        if (!globalOrderList || !globalOrderList[index]) return;
        const orderData = globalOrderList[index];
        
        if (orderData.orderStatus === '001') {
        	listDetailUpdate(index); // 수정 모달 함수 호출            
        } else if (orderData.orderStatus === '002') {
            fillReceiptModal(index); // 수령 모달 함수 호출            
        } else {
        	listDetail(index); // 조회 모달 함수 호출
            openModal('listDetail');
        }
    }
    
  	//==========================================================================
	//모달 닫기 함수
	//========================================================================== 
    function closeModal(modalId) {
        const modal = document.getElementById(modalId);
        if (modal) {
            modal.style.display = 'none';
            document.body.style.overflow = 'auto'; // 배경 스크롤 복구
        }
    }
    
	//==========================================================================
	//페이지네이션 함수
	//==========================================================================
	function renderPagination(currentPage, totalPages, targetId, clickFunction) {
		if(totalPages <= 0) {
	        document.getElementById(targetId).innerHTML = '';
	        return;
	   }
	
	   let html = '';
	   //페이지 네이션 갯수 정하기
	   let startPage = currentPage - 1;
	   let endPage = currentPage + 1;
	
	   if (startPage < 1) {
	       startPage = 1;
	       endPage = 3; 
	   }
		//끝페이지 수 
	   if (endPage > totalPages) {
	       endPage = totalPages;
	       startPage = Math.max(1, totalPages - 2); 
	   }
	
	   // 이전 버튼
	   const prevDisabled = (currentPage === 1) ? 'disabled' : '';
	   const prevClick = (currentPage === 1) ? '' : `onclick="\${clickFunction}(\${currentPage - 1})"`;
	   html += `
	       <button class="btn btn-icon btn-ghost" \${prevDisabled} \${prevClick}>
	           <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
	               <polyline points="15 18 9 12 15 6"></polyline>
	           </svg>
	       </button>
	   `;
	
	   // 앞쪽 ...
	   if (startPage > 1) {
	       html += `<button class="btn btn-ghost" onclick="\${clickFunction}(1)">1</button>`;
	       if (startPage > 2) {
	           html += `<button class="btn btn-ghost" disabled>...</button>`;
	       }
	   }
	
	   // 페이지 번호
	   for (let i = startPage; i <= endPage; i++) {
	       const activeClass = (i === currentPage) ? 'btn-primary' : 'btn-ghost';
	       html += `<button class="btn \${activeClass}" onclick="\${clickFunction}(\${i})">\${i}</button>`;
	   }
	
	   // 뒤쪽 ...
	   if (endPage < totalPages) {
	       if (endPage < totalPages - 1) {
	            html += `<button class="btn btn-ghost" disabled>...</button>`;
	       }
	       html += `<button class="btn btn-ghost" onclick="\${clickFunction}(\${totalPages})">\${totalPages}</button>`;
	   }
	
	   // 다음 버튼
	   const nextDisabled = (currentPage === totalPages) ? 'disabled' : '';
	   const nextClick = (currentPage === totalPages) ? '' : `onclick="\${clickFunction}(\${currentPage + 1})"`;
	   html += `
	       <button class="btn btn-icon btn-ghost" \${nextDisabled} \${nextClick}>
	           <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
	               <polyline points="9 18 15 12 9 6"></polyline>
	           </svg>
	       </button>
	   `;
	   document.getElementById(targetId).innerHTML = html;
	}
</script>
</html>