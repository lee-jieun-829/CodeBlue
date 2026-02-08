import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Swal from 'sweetalert2';
import Header from '../../components/layout/header.jsx';
import LeftAdmin from '../../components/layout/leftAdmin.jsx';
import DrugNotEnough from '../../features/order/DrugNotEnough.jsx';
import DrugInsert from '../../features/order/DrugInsert.jsx';
import { useNavigate } from 'react-router-dom';

const DrugPage = () => {
  // ==========================================================================
  // [Logic Section] 상태 관리 및 기능 함수 정의
  // ==========================================================================

  //상태(State) 정의
  const [drugList, setDrugList] = useState([]);       // 약품 목록 데이터
  const [cartList, setCartList] = useState([]);       // 장바구니 데이터
  const [searchWord, setSearchWord] = useState('');   // 검색어
  const [currentPage, setCurrentPage] = useState(1);  // 현재 페이지
  const [totalPages, setTotalPages] = useState(0);    // 전체 페이지 수
  const [isNotEnoughOpen, setIsNotEnoughOpen] = useState(false); // 부족 수량 모달용
  const [isOrderOpen, setIsOrderOpen] = useState(false);
  const navigate = useNavigate();

  //SweetAlert 버튼 스타일 공통 정의
  const swalOptions = {
      buttonsStyling: false,
      customClass: {
          confirmButton: 'bg-blue-600 text-white px-4 py-2 rounded-md font-bold hover:bg-blue-700',
          cancelButton: 'bg-gray-500 text-white px-4 py-2 rounded-md font-bold hover:bg-gray-600 ml-2'
      }
  };

  // 2. 초기 데이터 로드 (useEffect)
  useEffect(() => {
    fetchDrugList(1);
  }, []);

  // 3. 약품 목록 조회 함수 (Axios)
  const fetchDrugList = async (page = 1) => {
    try {
      const res = await axios.get('http://localhost:8060/api/order/drugList', {
       params: {
        page: page - 1,   // 중요: Spring Pageable은 페이지가 0부터 시작함
        size: 9,          // 한 페이지에 보여줄 개수 (@PageableDefault보다 우선됨)
        searchWord: searchWord, // 검색어 (@RequestParam 매핑)
        sort: 'drugNo,asc' // 정렬 조건 (필요 시 추가)
      },
      withCredentials: true
      });      
      
      if (res.data) {
        setDrugList(res.data.content); // 실제 데이터 목록
        setTotalPages(res.data.totalPages); // 전체 페이지 수
        setCurrentPage(page);
      }
    } catch (error) {
      console.error("Error fetching drug list:", error);
      Swal.fire({
          icon: "error",
          title: "Error",
          text: "약품 리스트를 가져올 수 없습니다.",
          ...swalOptions // 공통 스타일 적용
      });
    }
  };

  // 4. 검색 핸들러
  const handleSearch = () => {
    fetchDrugList(1);
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter') {
      handleSearch();
    }
  };

  // 5. 장바구니 추가 함수
  const addToCart = (drug) => {
    // 이미 장바구니에 있는지 확인
    const isExist = cartList.some(item => item.drugNo === drug.drugNo);

    if (isExist) {
      Swal.fire({
          icon: "warning",
          title: "Warning",
          text: "이미 장바구니에 담긴 약품입니다.",
          ...swalOptions // 공통 스타일 적용
      });
     
      return;
    }

    // 장바구니에 추가 (수량 orderQty는 빈 값으로 초기화)
    setCartList([...cartList, { ...drug, orderQty: '' }]);
  };

  // 6. 장바구니 수량 업데이트 함수
  const updateCartQty = (index, qty) => {
    const newCart = [...cartList];
    newCart[index].orderQty = qty;
    setCartList(newCart);
  };

  // 7. 장바구니 개별 삭제 함수
  const removeFromCart = (index) => {
    const newCart = cartList.filter((_, i) => i !== index);
    setCartList(newCart);
  };

  // 8. 장바구니 전체 비우기 함수
  const clearCart = () => {
    if (cartList.length === 0) return;

    Swal.fire({
      title: '경고',
      text: "바구니를 모두 비우시겠습니까?",
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: '확인',
      cancelButtonText: '취소',
      buttonsStyling: false,       
      customClass: {        
        confirmButton: 'bg-blue-600 text-white px-4 py-2 rounded-md font-bold hover:bg-blue-700 mr-2',      
        cancelButton: 'bg-gray-500 text-white px-4 py-2 rounded-md font-bold hover:bg-gray-600'
      }
    }).then((result) => {
      if (result.isConfirmed) {
        setCartList([]);
         Swal.fire({
          icon: "success",
          title: "성공",
          text: "바구니를 비웠습니다.",
          ...swalOptions // 공통 스타일 적용
      });  
      
      }
    });
  };

  // 9. 부족 수량 확인 (기능 추정 구현)
  const checkLowStock = () => {    
    setIsNotEnoughOpen(true);
  };

  // 10. 발주 신청 모달 (기능 추정 구현)
  const openOrderModal = () => {
    if (cartList.length === 0) {
      Swal.fire({
          icon: "warning",
          title: "장바구니가 비었습니다.",
          text: "장바구니에 신청할 약품을 담아주세요.",
          ...swalOptions 
      });      
      return;
    }
    setIsOrderOpen(true);
  };

  //페이지네이션 버튼 계산 로직
  const maxPageButtons = 5; // 화면에 보여질 최대 페이지 버튼 수 
  
  let startPage = Math.max(1, currentPage - Math.floor(maxPageButtons / 2));
  let endPage = Math.min(totalPages, startPage + maxPageButtons - 1);

  // 마지막 페이지에 도달했을 때, 앞쪽 페이지가 잘리지 않도록 조정
  if (endPage - startPage + 1 < maxPageButtons) {
      startPage = Math.max(1, endPage - maxPageButtons + 1);
  }

  // 계산된 startPage부터 endPage까지의 배열 생성
  const pageNumbers = [];
  for (let i = startPage; i <= endPage; i++) {
      pageNumbers.push(i);
  }


  // ==========================================================================
  // [View Section] JSX 화면 렌더링
  // ==========================================================================
  return (
    <div className="app h-screen w-full flex flex-col bg-neutral-100 text-zinc-950">
      {/* --- Header Placeholder --- */}
      <header className="w-full h-16 bg-white border-b border-gray-200">
        <Header />
      </header>

      <div className="main-container flex flex-1 overflow-hidden">
        {/* --- Sidebar Placeholder --- */}        
           <LeftAdmin />      

        {/* --- Main Content --- */}
        <main className="main-content flex-1 overflow-hidden p-4">
          <div className="grid grid-cols-[200px_1fr] h-full">
            
            {/* 왼쪽 메뉴 리스트 영역 */}
            <div className="content-area flex flex-col h-full bg-white rounded-lg shadow-sm border border-gray-200 p-4">
              <div className="mb-4">
                <div style={{ fontSize: 'var(--font-lg)', fontWeight: 'var(--font-medium)' }}>
                  재고 관리 메뉴
                </div>
              </div>
              <hr className="mb-4 border-gray-200" />
              <div className="flex flex-col space-y-2">       
                <div className="p-2 hover:bg-gray-50 text-gray-700 cursor-pointer"
                  onClick={() => navigate('/admin/orders')}>
                  발주 승인 관리
                </div>
                 <div className="p-2 bg-blue-50 text-blue-600 font-semibold rounded cursor-pointer"
                  onClick={() => navigate('/admin/drug')}>
                  약품 목록 조회
                </div>
                <div className="p-2 hover:bg-gray-50 text-gray-700 cursor-pointer"
                  onClick={() => navigate('/admin/product')}>
                  물품 목록 조회
                </div>
              </div>
            </div>

            {/* 오른쪽 메인 기능 영역 */}
            <div className="content-area flex flex-col h-full min-h-0 gap-4">
              
              {/* 상단: 약품 재고 조회 리스트 */}
              <div className="box h-[65%] flex flex-col bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
                <div className="card-header flex justify-between items-center p-4 border-b border-gray-100 bg-gray-50">
                  <span className="font-semibold text-lg">약품 재고 조회</span>
                  <div className="flex gap-2">
                    <button onClick={checkLowStock} className="px-3 py-1 bg-red-50 text-red-600 border border-red-200 rounded text-sm hover:bg-red-100">
                      ⚠ 부족수량 약품 확인
                    </button>
                    <input 
                      type="text" 
                      className="border border-gray-300 rounded px-2 py-1 text-sm focus:outline-none focus:border-blue-500" 
                      placeholder="검색어를 입력하세요"
                      value={searchWord}
                      onChange={(e) => setSearchWord(e.target.value)}
                      onKeyUp={handleKeyPress}
                    />
                    <button onClick={handleSearch} className="px-3 py-1 bg-blue-600 text-white rounded text-sm hover:bg-blue-700">
                      확인
                    </button>
                  </div>
                </div>

                <div className="card-body flex-1 overflow-y-auto p-0">
                  <table className="w-full text-center text-sm">
                    <thead className="bg-gray-50 text-gray-500 border-b border-gray-200 sticky top-0">
                      <tr>
                        <th className="py-2">약품번호</th>
                        <th className="py-2">약품명</th>
                        <th className="py-2">제조사</th>
                        <th className="py-2">보유수량</th>
                        <th className="py-2">최소수량</th>
                        <th className="py-2">매입가</th>
                        <th className="py-2">출고가</th>
                        <th className="py-2">관리</th>
                      </tr>
                    </thead>
                    <tbody>
                      {drugList.length > 0 ? (
                        drugList.map((drug, index) => {
                          const isLowStock = drug.drugAmount <= drug.drugSaftyStoke;
                          return (                            
                            <tr key={drug.drugNo} className="border-b border-gray-100 hover:bg-gray-50">
                              <td className="py-2">{drug.drugNo}</td>
                              <td className="py-2">{drug.drugName}</td>
                              <td className="py-2">{drug.drugCompany}</td>
                              <td className="py-2">
                                {isLowStock ? (
                                  <span className="text-red-600 font-semibold flex items-center justify-center gap-1">
                                    {drug.drugAmount} {drug.drugUnit}
                                    <span className="px-1 py-0.5 bg-red-100 text-red-600 text-xs rounded">부족</span>
                                  </span>
                                ) : (
                                  <span className="text-blue-600 font-semibold">
                                    {drug.drugAmount} {drug.drugUnit}
                                  </span>
                                )}
                              </td>
                              <td className="py-2">{drug.drugSaftyStoke}</td>
                              <td className="py-2">{drug.drugCost.toLocaleString()}원</td>
                              <td className="py-2">{drug.drugPrice.toLocaleString()}원</td>
                              <td className="py-2">
                                <button 
                                  onClick={() => addToCart(drug)} 
                                  className="px-3 py-1 bg-blue-100 text-blue-700 rounded text-xs hover:bg-blue-200"
                                >
                                  발주
                                </button>
                              </td>
                            </tr>
                          );
                        })
                      ) : (
                        <tr>
                          <td colSpan="8" className="py-10 text-gray-400">데이터가 없습니다.</td>
                        </tr>
                      )}
                    </tbody>
                  </table>
                </div>

               {/* 페이지네이션 영역 수정 */}
                <div className="h-[50px] flex justify-center items-center border-t border-gray-200 bg-white gap-1">
                  
                  {/*맨 처음으로 가기 버튼*/}
                  <button 
                    className="p-1 rounded hover:bg-gray-100 disabled:opacity-30" 
                    onClick={() => fetchDrugList(1)}
                    disabled={currentPage === 1}
                  >
                    ≪
                  </button> 
                  

                  <button 
                    className="p-1 rounded hover:bg-gray-100 disabled:opacity-30" 
                    onClick={() => fetchDrugList(currentPage - 1)}
                    disabled={currentPage === 1}
                  >
                    ◀
                  </button>                  
                  {pageNumbers.map(pageNum => (
                    <button
                      key={pageNum}
                      className={`px-3 py-1 rounded text-sm ${pageNum === currentPage ? 'bg-blue-600 text-white' : 'hover:bg-gray-100'}`}
                      onClick={() => fetchDrugList(pageNum)}
                    >
                      {pageNum}
                    </button>
                  ))}

                  <button 
                    className="p-1 rounded hover:bg-gray-100 disabled:opacity-30" 
                    onClick={() => fetchDrugList(currentPage + 1)}
                    disabled={currentPage === totalPages}
                  >
                    ▶
                  </button>
                  
                  {/* 맨 끝으로 가기 버튼*/}
                   <button 
                    className="p-1 rounded hover:bg-gray-100 disabled:opacity-30" 
                    onClick={() => fetchDrugList(totalPages)}
                    disabled={currentPage === totalPages}
                  >
                    ≫
                  </button> 
                 
                </div>
              </div>

              {/* 하단: 발주 바구니 영역 */}
              <div className="box h-[35%] flex flex-col bg-white rounded-lg shadow-sm border border-gray-200 overflow-hidden">
                <div className="card-header flex justify-between items-center p-4 border-b border-gray-100 bg-gray-50 font-semibold">
                  <span>🛒 발주 바구니</span>
                  <div className="flex gap-2">
                    <button onClick={clearCart} className="px-3 py-1 bg-white border border-gray-300 text-gray-700 rounded text-sm hover:bg-gray-50">
                      전체 비우기
                    </button>
                    <button onClick={openOrderModal} className="px-3 py-1 bg-blue-600 text-white rounded text-sm hover:bg-blue-700">
                      통합 발주 신청하기
                    </button>
                  </div>
                </div>

                <div className="card-body flex-1 overflow-y-auto p-0">
                  <table className="w-full text-center text-sm">
                    <thead className="bg-gray-50 text-gray-500 border-b border-gray-200 sticky top-0">
                      <tr>
                        <th className="py-2">No</th>
                        <th className="py-2">약품명</th>
                        <th className="py-2">제조사</th>
                        <th className="py-2">매입가</th>
                        <th className="py-2 w-32">주문수량</th>
                        <th className="py-2">삭제</th>
                      </tr>
                    </thead>
                    <tbody>
                      {cartList.length === 0 ? (
                        <tr>
                          <td colSpan="6" className="py-10">
                            <div className="flex flex-col items-center text-gray-400">
                              <svg className="w-10 h-10 mb-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"></path>
                              </svg>
                              <span>장바구니가 비어있습니다.</span>
                            </div>
                          </td>
                        </tr>
                      ) : (
                        cartList.map((item, index) => (
                          <tr key={item.drugNo} className="border-b border-gray-100">
                            <td className="py-2">{index + 1}</td>
                            <td className="py-2 font-medium">{item.drugName}</td>
                            <td className="py-2 text-gray-500">{item.drugCompany}</td>
                            <td className="py-2">{item.drugCost.toLocaleString()}원</td>
                            <td className="py-2">
                              <div className="flex items-center justify-center gap-1">
                                <input 
                                  type="number" 
                                  className="w-16 border border-gray-300 rounded px-1 py-0.5 text-center focus:outline-blue-500"
                                  value={item.orderQty}
                                  placeholder="수량"
                                  onChange={(e) => updateCartQty(index, e.target.value)}
                                />
                                <span className="text-gray-500">{item.drugUnit}</span>
                              </div>
                            </td>
                            <td className="py-2">
                              <button 
                                onClick={() => removeFromCart(index)}
                                className="text-gray-400 hover:text-red-500 font-bold px-2"
                              >
                                ✕
                              </button>
                            </td>
                          </tr>
                        ))
                      )}
                      
                    </tbody>
                  </table>
                </div>
              </div>
                      
            </div>
          </div>
        </main>
      </div>
      <DrugNotEnough 
        isOpen={isNotEnoughOpen}
        onClose={() => setIsNotEnoughOpen(false)}
        cartList={cartList}
        setCartList={setCartList}
      />  
      <DrugInsert
        isOpen={isOrderOpen} 
        onClose={() => setIsOrderOpen(false)} 
        cartList={cartList}
        clearCart={clearCart}
      />
    </div>
  );
};

export default DrugPage;