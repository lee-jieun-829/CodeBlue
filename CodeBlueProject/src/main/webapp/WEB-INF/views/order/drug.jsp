<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<!-- ===== Head 시작 ===== -->
<%@ include file="/WEB-INF/views/common/include/link.jsp" %>
<!-- ===== Head 끝 ===== -->
<title>공통 약품 목록</title>
<style>
	.table-th-center th {text-align: center !important;}
</style>
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
					    <div class="list-item list-item-active" >
					    	<a href="../order/drug">약품 목록 조회</a>					        
					    </div>
					    <div class="list-item" >
					    	 <a href="../order/product">물품 목록 조회</a>				        
					    </div>
					    <div class="list-item">
					        <a href="../order/list">주문 목록 조회</a>					        
					    </div>
					</div>
				</div>
				
				<!-- 약품목록 및 발주 영역 -->
				<div class="content-area flex flex-col h-full min-h-0 overflow-hidden">
					<div class="box h-[65%]  flex flex-col p-0 min-h-0 overflow-hidden justify-center">
						<div class="card  flex-1 overflow-y-auto min-h-0 my-2 pr-2 scrollbar">
							 <div class="h-[15%] card-header  flex-none" style="font-size: var(--font-base); font-weight: var(--font-semibold); ">
								 <span>약품 재고 조회</span>
								 <div class="btn-group-right">
								    <button onclick="checkLowStock()" class="btn btn-destructive btn-sm">⚠ 부족수량 약품 확인</button>
								    <input id="searchWord"type="text" class="input input-search input-sm" placeholder="검색어를 입력하세요">
								    <button onclick="searchDrugList()"class="btn btn-primary btn-sm">확인</button>
								</div> 
							 </div>
							 <div class="h-[78%] card-body  flex-1 overflow-y-auto">
							 	<!-- 약품리스트 출력 영역 -->
							 	<div id="drugList" class="table-wrapper">								    
								</div>	
							</div>
						<div id="pageNation" class="h-[7%] btn-group-center btn-sm" style="gap: 2px;">
										
						</div>
						</div> 
					</div>
					<div class="box h-[35%]  flex flex-col p-0 min-h-0 overflow-hidden">
				    <div class="card h-full flex flex-col min-h-0 my-2">				        
				        <div class="card-header  flex-none" style="font-size: var(--font-base); font-weight: var(--font-semibold); ">   
				            🛒 발주 바구니 
				            <div class="btn-group-right">
					            <button onclick="cleanAll()" class="btn btn-light btn-secondary btn-sm">전체 비우기</button>					            
					            <button onclick="insertModal()" class="btn btn-primary btn-sm">통합 발주 신청하기</button>
				            </div>
				        </div>
				        
				        <div class="card-body  flex-1 overflow-y-auto scrollbar">
				        	<div class="table-wrapper">
				            <table class="table table-center table-sm">
				            	<!-- 선택한 약품 출력 영역 -->				            	
				            	<tbody id="selectDrug"class="w-full">
				            		<tr>
						                <td colspan="6" style="padding: 2rem;">
						                    <div class="empty-state empty-state-sm" style="border:none;">
						                    	<svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
						                                    <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path>
						                                    <polyline points="13 2 13 9 20 9"></polyline>
						                                </svg>
						                         <div class="empty-state-title">장바구니 비었음</div>
						                         <div class="empty-state-description">담긴 약품이 없습니다.</div>
						                    </div>
						                </td>
						            </tr>				            						            		
				            	</tbody>				            	
				            </table>				            
				            </div>
				        </div>				        
				    </div>
				</div>
				</div>				
			</div>
		</main>
		<!-- ===== Main 끝 ===== -->
	</div>
	</div>
</body>
<jsp:include page="/WEB-INF/views/order/drugNotEnough.jsp" />
<jsp:include page="/WEB-INF/views/order/drugInsert.jsp" />
<script>
	let globalDrugList = [];
	let cartList = [];
	let searchInput = document.getElementById('searchWord');
	document.addEventListener("DOMContentLoaded", function() {
		loadDrugList(1);
		if(searchInput){
			searchInput.addEventListener("keyup", function(event) {
	            if (event.key === "Enter") {
	                searchDrugList();
	            }
	        });
	    }        
	});
	
	//==========================================================================
	//약품 리스트 함수
	//==========================================================================
	function loadDrugList(page = 1) {    
		const reqPage = page - 1;		
	    const searchWord = searchInput ? searchInput.value : '';	
	    axios.get('/order/drugList',{
	    	params: {
                page: reqPage,
                size: 6, // 한 페이지당 6개
                searchWord: searchWord
            }	
	    })
	  
	        .then(function (response) {	        	
	        	const pageData = response.data;
	        	globalDrugList =  pageData.content; 
	                       
	            const totalPages = pageData.totalPages; // 전체 페이지 수
	            const currPage = pageData.number; // 현재 페이지 (0부터 시작됨)	
	        	
	            console.log("받은 데이터:", drugList);
	        	let html=`
	        		<table class="table table-th-center">
	                <thead style="font-size: var(--font-sm); color: var(--color-text-secondary);" >
	                    <tr>
	                        <th>약품번호</th>
	                        <th>약품명</th>
	                        <th>제조사</th>
	                        <th style="">보유수량</th>
	                        <th>최소수량</th>
	                        <th>매입가</th>
	                        <th>출고가</th>
	                        <th>관리</th>
	                    </tr>
	                </thead>
	                <tbody style="font-size: var(--font-base);">
	            `;
	            if(globalDrugList && globalDrugList.length > 0) {
	            	globalDrugList.forEach(function(drug, index) {
                    // 수량 상태 로직 
                    let amountHtml = '';
                    if(drug.drugAmount > drug.drugSaftyStoke) {
                         // 정상
                         amountHtml = `<span style="color: var(--color-primary); font-weight: var(--font-semibold);">\${drug.drugAmount}</span> \${drug.drugUnit}`;
                    } else {
                         // 부족
                         amountHtml = `<span class="badge badge-danger">부족</span>
                         <span style="color: var(--color-destructive); font-weight: var(--font-semibold);">\${drug.drugAmount}</span> \${drug.drugUnit} 
                                       `;
                    }

                    html += `
                        <tr>
                            <td class="text-center">\${drug.drugNo}</td>
                            <td>\${drug.drugName}</td>
                            <td>\${drug.drugCompany}</td>
                            <td class="text-right">\${amountHtml}</td>
                            <td class="text-right">\${drug.drugSaftyStoke}</td>
                            <td class="text-right">\${drug.drugCost.toLocaleString()}원</td> 
                            <td class="text-right">\${drug.drugPrice.toLocaleString()}원</td>
                            <td class="text-center"><button onclick="selectDrug(\${index})" class="btn btn-primary btn-sm">발주</button></td>
                        </tr>
                    `;
                });
	          } else {
	              html += `<tr><td colspan="8" class="text-center p-4">데이터가 없습니다.</td></tr>`;
	          }

	          html += `</tbody></table>`;
                
	          document.getElementById('drugList').innerHTML = html;
			   renderPagination(currPage + 1, totalPages, 'pageNation', 'loadDrugList');
			   
	        })
	        .catch(function (error) {	            
	        	sweetAlert("warning", "서버오류, 약품리스트를 가져올 수 없습니다.", "확인");
	        });
	}
	
	//==========================================================================
	//장바구니 담기 함수
	//==========================================================================
	function selectDrug(index){
		const drug = globalDrugList[index];
		//장바구니 담겨있는지 확인용 플래그
		let isExist = false;
		
	    for (let i = 0; i < cartList.length; i++) {
	        if (cartList[i].drugNo === drug.drugNo) {
	            isExist = true; 
	            break;          
	        }
	    }

	    if (isExist) {
	        if (typeof sweetAlert !== 'undefined') {
	            sweetAlert("warning", "이미 장바구니에 담긴 약품입니다.", "확인");
	        } else {
	            alert("이미 장바구니에 담긴 약품입니다.");
	        }
	        return; 
	    }
	    
	    cartList.push({
	        ...drug,
	        orderQty: '' // 빈 값으로 초기화
	    });

	    renderCart();
	}
	
	//==========================================================================
	//장바구니 테이블 출력용 함수
	//==========================================================================
	function renderCart() {
		let selectDrugBody = document.getElementById('selectDrug');			
		let html ='';
		if (cartList.length === 0) {
	        html = `
	        	<tr>
	                <td colspan="6" style="padding: 2rem;">
	                    <div class="empty-state empty-state-sm" style="border:none;">
	                    	<svg class="empty-state-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
	                                    <path d="M13 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V9z"></path>
	                                    <polyline points="13 2 13 9 20 9"></polyline>
	                                </svg>
	                         <div class="empty-state-title">장바구니 비었음</div>
	                         <div class="empty-state-description">담긴 약품이 없습니다.</div>
	                    </div>
	                </td>
	            </tr>	
	        `;
		}else{
			cartList.forEach((drug, index) => {
		        let indexNum = index + 1;
	
		        html += `
		            <tr class="items-center border-b" style="font-weight: var(--font-semibold);">
		                <td>\${indexNum}</td>
		                <td style="text-align:left">\${drug.drugName}</td>
		                <td style="text-align:left">\${drug.drugCompany}</td>
		                <td>\${drug.drugCost.toLocaleString()}원</td> 
		                <td style="width: 10%;">
			                <div style="display: flex; align-items: center; gap: 5px; justify-content: center;">
				                <input type="number" class="input" value="\${drug.orderQty}" 
		                            style="width: 60px; text-align: center;"
		                            onchange="updateCartQty(\${index}, this.value)" />
		                     	<span>\${drug.drugUnit}</span>
	                     	</div>
		                </td>
		                
		                <td>
		                    <button onclick="removeCartItem(\${index})" class="btn btn-icon btn-destructive btn-sm">×</button>
		                </td>
		            </tr>
		        `;
		    });	                
		}
		selectDrugBody.innerHTML = html;
		
	}
	
	//==========================================================================
	//사용자 입력 주문수량 저장 함수
	//==========================================================================
	function updateCartQty(index, newQty) {
	    cartList[index].orderQty = newQty; // 입력한 값 저장
	}
	
	
	//==========================================================================
	//개별 장바구니 비우기 함수
	//==========================================================================
	function removeCartItem(index) {
        // 배열에서 해당 인덱스 요소를 1개 삭제
        cartList.splice(index, 1);
        // 화면 다시 그리기
        renderCart();
    }
	
	
	//==========================================================================
	//장바구니 비우기 함수
	//==========================================================================
	function cleanAll(){
		sweetAlert("warning", "바구니를 모두 비우시겠습니까?", "확인", "취소", true)
		.then(result => {		   
		   if (result.isConfirmed) { 
			   cartList = [];
			   renderCart();
			   Swal.fire('바구니를 비웠습니다.',"",'success');
		   }
		});		
	}
	function searchDrugList(){
		loadDrugList(page=1);
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
</script>

</html>