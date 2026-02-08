import React, { useState, useEffect, useMemo } from 'react';
import axios from 'axios';
import Swal from 'sweetalert2';
import Header from '../../components/layout/header.jsx';
import LeftAdmin from '../../components/layout/leftAdmin.jsx';
import { useNavigate } from 'react-router-dom';

// 날짜 포맷 헬퍼
const formatDate = (date) => {
  return date.toISOString().split('T')[0];
};

const OrdersPage = () => {
  const navigate = useNavigate();

  // ==========================================================================
  // [State Definitions]
  // ==========================================================================
  const [orderList, setOrderList] = useState([]);       // 전체 목록
  const [filteredList, setFilteredList] = useState([]); // 필터링된 목록
  const [selectedOrder, setSelectedOrder] = useState(null); // 현재 선택된 상세 주문

  // 필터 상태
  const [currentType, setCurrentType] = useState('002'); // '002': 물품(기본), '001': 약품
  const [startDate, setStartDate] = useState(() => {
    const d = new Date();
    d.setMonth(d.getMonth() - 1); // 기본 1달 전
    return formatDate(d);
  });
  const [endDate, setEndDate] = useState(() => formatDate(new Date()));
  const [statusFilter, setStatusFilter] = useState('all'); // all, 001, 002, 005...

  // 반려 모달 상태
  const [isRejectModalOpen, setIsRejectModalOpen] = useState(false);
  const [rejectReason, setRejectReason] = useState('');

  // SweetAlert 옵션
  const swalOptions = {
    buttonsStyling: false,
    customClass: {
      confirmButton: 'bg-blue-600 text-white px-4 py-2 rounded-md font-bold hover:bg-blue-700',
      cancelButton: 'bg-gray-500 text-white px-4 py-2 rounded-md font-bold hover:bg-gray-600 ml-2'
    }
  };  

  // 초기 데이터 로드 
  useEffect(() => {
    fetchOrderList();
    // 탭이 바뀌거나 재조회 시 상세 선택 초기화
    setSelectedOrder(null);
  }, [currentType]); // 타입이 바뀔 때마다 서버에서 새로 가져오는 것이 좋음

  // 주문 목록 조회
  const fetchOrderList = async () => {
    try {     
      const res = await axios.get('http://localhost:8060/api/order/orderList', {
        params: {
          page: 0,
          size: 100, 
          searchWord: '', 
          orderType: currentType 
        },
        withCredentials: true
      });

      if (res.data && res.data.content) {
        // 서버에서 온 전체 데이터
        const allData = res.data.content;
        console.log(allData);
        // 1차 필터: 현재 탭(물품/약품)에 맞는 것만 저장
        const typeFiltered = allData.filter(item => item.orderType === currentType);
        setOrderList(typeFiltered);
      }
    } catch (error) {
      console.error("Error fetching orders:", error);
    }
  };

  // 로컬 필터링 (날짜, 상태) - orderList가 변경되거나 필터 조건이 바뀔 때 실행
  useEffect(() => {
    let result = [...orderList];

    // 1. 날짜 필터
    if (startDate && endDate) {
      result = result.filter(order => {       
        return order.orderDate >= startDate && order.orderDate <= endDate;
      });
    }

    // 2. 상태 필터
    if (statusFilter !== 'all') {
      result = result.filter(order => order.orderStatus === statusFilter);
    }

    setFilteredList(result);
  }, [orderList, startDate, endDate, statusFilter]);


  // ==========================================================================
  // [Action Handlers]
  // ==========================================================================
    // 상태 변경 API 호출 공통 함수
  const updateOrderStatus = async (status, content) => {
    try {      
      const payload = {
        orderNo: selectedOrder.orderNo,
        orderStatus: status,
        orderContent: content        
      };
      await axios.post('http://localhost:8060/api/order/orderupdate', payload, {
        headers: { 
            'Content-Type': 'application/json' 
        },
        withCredentials: true 
      });       
      
      // Mocking: 성공했다고 가정하고 로컬 상태 업데이트
      Swal.fire({
        icon: 'success',
        title: '처리 완료',
        text: status === '002' ? '발주가 승인되었습니다.' : '발주가 반려되었습니다.',
        ...swalOptions
      });

      // 목록 새로고침
      fetchOrderList(); 

    } catch (error) {
      console.error(error);
      Swal.fire('오류', '처리 중 오류가 발생했습니다.', 'error');
    }
  };
  // 승인 처리
  const handleApprove = async () => {
    if (!selectedOrder) return;

    const result = await Swal.fire({
      title: '최종 승인',
      text: "해당 발주 건을 승인하시겠습니까? 상태가 '주문중'으로 변경됩니다.",
      icon: 'question',
      showCancelButton: true,
      confirmButtonText: '승인',
      cancelButtonText: '취소',
      ...swalOptions
    });

    if (result.isConfirmed) {
      updateOrderStatus('002', null); // 002: 주문중
    }
  };

  // 반려 처리 (모달 열기)
  const openRejectModal = () => {
    setRejectReason('');
    setIsRejectModalOpen(true);
  };

  // 반려 확정
  const handleRejectConfirm = async () => {
    if (!rejectReason.trim()) {
      Swal.fire('알림', '반려 사유를 입력해주세요.', 'warning');
      return;
    }
    await updateOrderStatus('005', rejectReason); // 005: 반려
    setIsRejectModalOpen(false);
  };



  // ==========================================================================
  // [Helper Functions for Rendering]
  // ==========================================================================
  
  // 상태 뱃지 렌더링
  const renderStatusBadge = (status) => {
    switch (status) {
      case '001': return <span className="bg-orange-100 text-orange-600 px-2 py-0.5 rounded text-[10px] font-bold">승인대기</span>;
      case '002': return <span className="bg-blue-100 text-blue-600 px-2 py-0.5 rounded text-[10px] font-bold">주문중</span>;
      case '003': return <span className="bg-green-100 text-green-600 px-2 py-0.5 rounded text-[10px] font-bold">배송완료</span>;
      case '005': return <span className="bg-red-100 text-red-600 px-2 py-0.5 rounded text-[10px] font-bold">반려됨</span>;
      default: return <span className="bg-gray-100 text-gray-600 px-2 py-0.5 rounded text-[10px] font-bold">수령완료</span>;
    }
  };

  // 상세 품목 데이터 추출 (약품/물품 구조 차이 해결)
  const getDetailInfo = (detail) => {
    let name = "-";
    let company = "-";
    let price = 0;
    
    if (currentType === '001') { // 약품
      if (detail.drugList && detail.drugList.length > 0) {
        name = detail.drugList[0].drugName;
        company = detail.drugList[0].drugCompany;
        price = detail.drugList[0].drugPrice;
      }
    } else { // 물품 (002)
      if (detail.productList && detail.productList.length > 0) {
        name = detail.productList[0].productName;
        company = detail.productList[0].productCompany;
        price = detail.productList[0].productCost;
      }
    }
    return { name, company, price };
  };

  // 총 합계 금액 계산
  const calculateTotal = (details) => {
    if (!details) return 0;
    return details.reduce((sum, item) => {
      const { price } = getDetailInfo(item);
      return sum + (price * item.orderDetailCount);
    }, 0);
  };


  // ==========================================================================
  // [Render]
  // ==========================================================================
  return (
    <div className="app h-screen w-full flex flex-col bg-neutral-100 text-zinc-950 font-['Pretendard']">
      
      {/* Header */}
      <header className="w-full h-16 bg-white border-b border-gray-200">
        <Header />
      </header>

      <div className="main-container flex flex-1 overflow-hidden">
        {/* Sidebar */}
        <LeftAdmin />

        <main className="main-content flex-1 overflow-hidden p-4 flex gap-4">
            
            {/* ======================= */}
          {/* [Left] 주문 목록 영역 */}
          {/* ======================= */}
                <section className="w-[420px] shrink-0 rounded-2xl bg-white shadow-sm ring-1 ring-black/5 flex flex-col overflow-hidden text-zinc-950">
                    
                    {/* Top: Filters */}
                    <div className="p-5 border-b border-slate-100 bg-white shrink-0 space-y-4">
                    <h2 className="text-lg font-bold text-slate-900">발주 승인 관리</h2>

                    {/* Tabs: 물품 / 약품 */}
                    <div className="flex bg-slate-100 p-1 rounded-xl">
                        <button 
                        onClick={() => setCurrentType('002')} 
                        className={`flex-1 py-2 text-xs font-bold rounded-lg transition-all ${
                            currentType === '002' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'
                        }`}
                        >
                        물품 (Product)
                        </button>
                        <button 
                        onClick={() => setCurrentType('001')} 
                        className={`flex-1 py-2 text-xs font-bold rounded-lg transition-all ${
                            currentType === '001' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'
                        }`}
                        >
                        약품 (Medicine)
                        </button>
                    </div>

                    {/* Filters: Date & Status */}
                    <div className="space-y-2">
                        <div className="flex items-center gap-2">
                        <input 
                            type="date" 
                            value={startDate}
                            onChange={(e) => setStartDate(e.target.value)}
                            className="flex-1 bg-slate-50 border border-slate-200 rounded-lg px-2 py-1.5 text-[11px] font-bold outline-none focus:bg-white focus:border-blue-300" 
                        />
                        <span className="text-slate-400 text-xs">~</span>
                        <input 
                            type="date" 
                            value={endDate}
                            onChange={(e) => setEndDate(e.target.value)}
                            className="flex-1 bg-slate-50 border border-slate-200 rounded-lg px-2 py-1.5 text-[11px] font-bold outline-none focus:bg-white focus:border-blue-300" 
                        />
                        </div>
                        <div className="flex gap-2">
                        <select 
                            value={statusFilter}
                            onChange={(e) => setStatusFilter(e.target.value)}
                            className="flex-1 bg-slate-50 border border-slate-200 rounded-lg px-2 py-1.5 text-[11px] font-bold outline-none focus:bg-white focus:border-blue-300"
                        >
                            <option value="all">전체 상태</option>
                            <option value="001">승인대기</option>
                            <option value="002">주문중</option>
                            <option value="005">반려됨</option>
                        </select>
                        </div>
                    </div>
                    </div>

                    {/* List Body */}
                    <div className="flex-1 overflow-y-auto p-3 bg-slate-50/30 space-y-2">
                    {filteredList.length === 0 ? (
                        <div className="text-center text-slate-400 py-10 text-xs">
                        조건에 맞는 내역이 없습니다.
                        </div>
                    ) : (
                        filteredList.map((order) => {
                        const isActive = selectedOrder?.orderNo === order.orderNo;
                        const firstDetail = order.orderDetails?.[0];
                        const { name } = getDetailInfo(firstDetail);
                        const otherCount = (order.orderDetails?.length || 1) - 1;
                        const title = otherCount > 0 ? `${name} 외 ${otherCount}건` : name;

                        return (
                            <div 
                            key={order.orderNo}
                            onClick={() => setSelectedOrder(order)}
                            className={`
                                p-4 rounded-xl border cursor-pointer transition-all shadow-sm
                                ${isActive ? 'bg-blue-50 border-blue-300 ring-1 ring-blue-200' : 'bg-white border-slate-200 hover:border-blue-200'}
                            `}
                            >
                            <div className="flex justify-between items-start mb-2">
                                {renderStatusBadge(order.orderStatus)}
                                <span className="text-[11px] text-slate-400 font-medium">{order.orderDate.split(' ')[0]}</span>
                            </div>
                            <h3 className="text-sm font-bold text-slate-800 mb-1 truncate">{title}</h3>
                            <p className="text-xs text-slate-500 font-medium">
                                {/* 작성자 정보가 API에 있다면 표시, 없다면 임시 */}
                                Order No: #{order.orderNo}
                            </p>
                            </div>
                        );
                        })
                    )}
                    </div>
                </section>

{/* ======================= */}
                {/* [Right] 상세 정보 영역 */}
                <section className="flex-1 rounded-2xl bg-white shadow-sm ring-1 ring-black/5 flex flex-col overflow-hidden relative text-zinc-950">
                    
                    {!selectedOrder ? (
                    // Empty State
                    <div className="flex flex-col items-center justify-center h-full text-slate-400">
                        <div className="text-5xl mb-4">📑</div>
                        <p className="font-bold">목록에서 발주 건을 선택해 주세요</p>
                    </div>
                    ) : (
                    // Detail View
                    <div className="h-full flex flex-col animate-in fade-in duration-300">
                        {/* Header */}
                        <div className="p-6 border-b border-slate-100 flex justify-between items-center bg-white">
                        <div>
                            <h2 className="text-xl font-black text-slate-900">발주 상세 확인</h2>
                            <p className="text-xs text-slate-400 mt-1 uppercase font-bold">
                            Order ID: #{selectedOrder.orderNo} ({currentType === '001' ? '약품' : '물품'})
                            </p>
                        </div>
                        {renderStatusBadge(selectedOrder.orderStatus)}
                        </div>

                        {/* Content */}
                        <div className="flex-1 overflow-y-auto custom-scrollbar p-8">
                        
                        {/* 반려 사유가 있다면 표시 */}
                        {selectedOrder.orderStatus === '005' && selectedOrder.orderContent && (
                            <div className="mb-6 bg-red-50 border border-red-200 rounded-xl p-4">
                                <h4 className="text-red-600 font-bold text-sm mb-1">📌 반려 사유</h4>
                                <p className="text-slate-700 text-sm">{selectedOrder.orderContent}</p>
                            </div>
                        )}

                        {/* Info Grid (Optional - if user data exists) */}
                        <div className="grid grid-cols-2 gap-8 mb-8">
                            <div className="space-y-4">
                                <div>
                                    <label className="text-[11px] font-black text-slate-400 uppercase">신청일시</label>
                                    <p className="text-sm font-bold text-slate-800">{selectedOrder.orderDate}</p>
                                </div>
                            </div>
                        </div>

                        {/* Table */}
                        <div className="border border-slate-100 rounded-2xl overflow-hidden shadow-sm mb-6">
                            <table className="w-full text-sm text-left">
                            <thead className="bg-slate-50 text-slate-500 font-bold border-b border-slate-100">
                                <tr>
                                <th className="px-6 py-4">품목명 / 제조사</th>
                                <th className="px-6 py-4 text-right">단가</th>
                                <th className="px-6 py-4 text-right">주문량</th>
                                <th className="px-6 py-4 text-right">소계</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-50">
                                {selectedOrder.orderDetails.map((item, idx) => {
                                const { name, company, price } = getDetailInfo(item);
                                const subTotal = price * item.orderDetailCount;
                                return (
                                    <tr key={idx}>
                                    <td className="px-6 py-4">
                                        <div className="font-bold text-slate-800">{name}</div>
                                        <div className="text-xs text-slate-400">{company}</div>
                                    </td>
                                    <td className="px-6 py-4 text-right text-slate-500 font-medium">
                                        {price.toLocaleString()}원
                                    </td>
                                    <td className="px-6 py-4 text-right font-black text-slate-800">
                                        {item.orderDetailCount}
                                    </td>
                                    <td className="px-6 py-4 text-right font-black text-blue-600">
                                        {subTotal.toLocaleString()}원
                                    </td>
                                    </tr>
                                );
                                })}
                            </tbody>
                            </table>
                        </div>

                        {/* Total */}
                        <div className="bg-slate-50 rounded-2xl p-6 flex justify-between items-center">
                            <span className="text-sm font-bold text-slate-500 font-black">총 발주 합계 금액</span>
                            <span className="text-2xl font-black text-blue-600">
                            {calculateTotal(selectedOrder.orderDetails).toLocaleString()}원
                            </span>
                        </div>
                        </div>

                        {/* Footer Actions (Only for Pending Orders) */}
                        {selectedOrder.orderStatus === '001' && (
                        <div className="p-6 bg-slate-50 border-t border-slate-100 flex gap-3">
                            <button 
                            onClick={openRejectModal}
                            className="flex-1 py-4 bg-white border border-slate-200 text-red-500 font-bold rounded-2xl hover:bg-red-50 transition-colors"
                            >
                            발주 반려
                            </button>
                            <button 
                            onClick={handleApprove}
                            className="flex-[2] py-4 bg-blue-600 text-white font-black rounded-2xl shadow-lg shadow-blue-100 hover:bg-blue-700 transition-all"
                            >
                            최종 승인
                            </button>
                        </div>
                        )}
                    </div>
                    )}
                </section>           
        </main>
        </div>
      

      {/* ======================= */}
      {/* 반려 사유 모달 */}
      {/* ======================= */}
      {isRejectModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white w-[400px] rounded-[2rem] shadow-2xl overflow-hidden flex flex-col">
            <div className="p-6 border-b border-slate-100 flex justify-between items-center">
              <h3 className="text-lg font-bold text-slate-900">발주 반려 사유</h3>
              <button onClick={() => setIsRejectModalOpen(false)} className="text-slate-400 hover:text-slate-600 font-bold text-xl">✕</button>
            </div>
            <div className="p-8">
              <textarea 
                value={rejectReason}
                onChange={(e) => setRejectReason(e.target.value)}
                placeholder="반려 사유를 구체적으로 입력하세요." 
                className="w-full h-32 bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold outline-none resize-none focus:bg-white focus:border-red-300"
              ></textarea>
            </div>
            <div className="p-6 bg-slate-50 flex gap-3">
              <button 
                onClick={() => setIsRejectModalOpen(false)} 
                className="flex-1 py-3 bg-white border border-slate-200 rounded-xl text-slate-500 font-bold hover:bg-gray-50"
              >
                취소
              </button>
              <button 
                onClick={handleRejectConfirm} 
                className="flex-1 py-3 bg-red-500 text-white font-bold rounded-xl shadow-lg hover:bg-red-600"
              >
                반려 확정
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};

export default OrdersPage;