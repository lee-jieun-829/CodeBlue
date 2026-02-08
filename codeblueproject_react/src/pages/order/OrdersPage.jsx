import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Swal from 'sweetalert2';
import Header from '../../components/layout/Header.jsx';
import LeftAdmin from '../../components/layout/LeftAdmin.jsx';
import { useNavigate } from 'react-router-dom';
import { useNotification } from '../../features/notification/hooks/useNotification';

const OrdersPage = () => {
  const navigate = useNavigate();

  // ==========================================================================
  // [State Definitions]
  // ==========================================================================
  const [orderList, setOrderList] = useState([]);       
  const [filteredList, setFilteredList] = useState([]); 
  const [selectedOrder, setSelectedOrder] = useState(null); 

  // 필터 상태
  const [currentType, setCurrentType] = useState('001'); 
  
  // [수정] 날짜 필터 (연도/월 분리)
  const today = new Date();
  const [year, setYear] = useState(today.getFullYear().toString());
  const [month, setMonth] = useState(String(today.getMonth() + 1).padStart(2, '0'));
  
  const [statusFilter, setStatusFilter] = useState('all'); 

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
    setSelectedOrder(null);
  }, [currentType]); 

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
        const allData = res.data.content;
        const typeFiltered = allData.filter(item => item.orderType === currentType);
        setOrderList(typeFiltered);
      }
    } catch (error) {
      console.error("Error fetching orders:", error);
    }
  };

  // [수정] 로컬 필터링 (연도+월 조합, 상태)
  useEffect(() => {
    let result = [...orderList];

    // 1. 월별 필터 (YYYY-MM 문자열 생성하여 비교)
    const targetDatePrefix = `${year}-${month}`; // 예: "2026-01"

    if (year && month) {
      result = result.filter(order => {       
        // order.orderDate가 "2026-01-23 ..." 형태라면 startsWith로 비교
        return order.orderDate && order.orderDate.startsWith(targetDatePrefix);
      });
    }

    // 2. 상태 필터
    if (statusFilter !== 'all') {
      result = result.filter(order => order.orderStatus === statusFilter);
    }

    setFilteredList(result);
  }, [orderList, year, month, statusFilter]);


  // ==========================================================================
  // [Action Handlers] (동일함)
  // ==========================================================================
  const updateOrderStatus = async (status, content) => {
    console.log("dsfe",selectedOrder);
    try {      
      const payload = {
        orderNo: selectedOrder.orderNo,
        orderStatus: status,
        orderContent: content        
      };
      await axios.post('http://localhost:8060/api/order/orderupdate', payload, {
        headers: { 'Content-Type': 'application/json' },
        withCredentials: true 
      });       
      
      const isApprove = status === '002';
      const typeLabel = currentType === '001' ? '약품' : '물품';
      
      // 발주 신청자(empNo)에게 알림 전송
      sendNewNotification(
        selectedOrder.employeeNo, // 수신자 사번 (신청자)
        isApprove ? ` ${typeLabel} 발주 승인` : `[반려] ${typeLabel} 발주 반려`, // 제목
        isApprove 
          ? `신청하신 ${typeLabel} 발주(No.${selectedOrder.orderNo})가 승인되었습니다.` 
          : `신청하신 ${typeLabel} 발주(No.${selectedOrder.orderNo})가 반려되었습니다. 사유: ${content}`, // 내용
        '002', // 구분코드 (발주/재고 관련 코드로 적절히 변경 가능)
        currentType === '001' ? '/admin/drug' : '/admin/product', // 이동경로
        'N' // 긴급여부
      );

      Swal.fire({
        icon: 'success',
        title: '처리 완료',
        text: status === '002' ? '발주가 승인되었습니다.' : '발주가 반려되었습니다.',
        ...swalOptions
      });

      fetchOrderList(); 

      setSelectedOrder(prev => ({
        ...prev,
        orderStatus: status,
        orderContent: content
      }));
    } catch (error) {
      console.error(error);
      Swal.fire('오류', '처리 중 오류가 발생했습니다.', 'error');
    }
  };

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
    if (result.isConfirmed) updateOrderStatus('002', null);
  };

  const openRejectModal = () => {
    setRejectReason('');
    setIsRejectModalOpen(true);
  };

  const handleRejectConfirm = async () => {
    if (!rejectReason.trim()) {
      Swal.fire('알림', '반려 사유를 입력해주세요.', 'warning');
      return;
    }
    await updateOrderStatus('005', rejectReason);
    setIsRejectModalOpen(false);
  };

  // ==========================================================================
  // [Render Helpers]
  // ==========================================================================
  const renderStatusBadge = (status) => {
    switch (status) {
      case '001': return <span className="bg-orange-100 text-orange-600 px-2 py-0.5 rounded text-[10px] font-bold">승인대기</span>;
      case '002': return <span className="bg-blue-100 text-blue-600 px-2 py-0.5 rounded text-[10px] font-bold">주문중</span>;
      case '003': return <span className="bg-green-100 text-green-600 px-2 py-0.5 rounded text-[10px] font-bold">배송완료</span>;
      case '005': return <span className="bg-red-100 text-red-600 px-2 py-0.5 rounded text-[10px] font-bold">반려됨</span>;
      default: return <span className="bg-gray-100 text-gray-600 px-2 py-0.5 rounded text-[10px] font-bold">수령완료</span>;
    }
  };

  const getDetailInfo = (detail) => {
    let name = "-"; let company = "-"; let price = 0;
    if (!detail) return { name, company, price };
    if (currentType === '001') { 
      if (detail.drugList?.length > 0) {
        name = detail.drugList[0].drugName;
        company = detail.drugList[0].drugCompany;
        price = detail.drugList[0].drugPrice;
      }
    } else { 
      if (detail.productList?.length > 0) {
        name = detail.productList[0].productName;
        company = detail.productList[0].productCompany;
        price = detail.productList[0].productCost;
      }
    }
    return { name, company, price };
  };

  const calculateTotal = (details) => {
    if (!details) return 0;
    return details.reduce((sum, item) => {
      const { price } = getDetailInfo(item);
      return sum + (price * item.orderDetailCount);
    }, 0);
  };

  // 연도 생성 (현재 연도 기준 -5년 ~ +1년)
  const currentYear = new Date().getFullYear();
  const yearOptions = Array.from({ length: 7 }, (_, i) => currentYear - 5 + i).reverse();

  return (
    <div className="app h-screen w-full flex flex-col bg-neutral-100 text-zinc-950 font-['Pretendard']">
      <header className="w-full h-16 bg-white border-b border-gray-200">
        <Header />
      </header>

      <div className="main-container flex flex-1 overflow-hidden">
         
            <LeftAdmin />
          
        

        <main className="main-content flex-1 overflow-hidden p-4 ml-0">
          <div className="grid grid-cols-[200px_1fr] gap-4 h-full">
            
            {/* 1. Left Menu */}
            <div className="content-area flex flex-col h-full bg-white rounded-lg shadow-sm border border-gray-200 p-4">
              <div className="mb-4">
                <div style={{ fontSize: 'var(--font-lg)', fontWeight: 'var(--font-medium)' }}>
                  재고 관리 메뉴
                </div>
              </div>
              <hr className="mb-4 border-gray-200" />
              <div className="flex flex-col space-y-2">       
                <div className="p-2 bg-blue-50 text-blue-600 font-semibold rounded cursor-pointer" onClick={() => navigate('/admin/orders')}>
                  발주 승인 관리
                </div>
                <div className="p-2 hover:bg-gray-50 text-gray-700 cursor-pointer" onClick={() => navigate('/admin/drug')}>
                  약품 목록 조회
                </div>
                <div className="p-2 hover:bg-gray-50 text-gray-700 cursor-pointer" onClick={() => navigate('/admin/product')}>
                  물품 목록 조회
                </div>
              </div>
            </div>

            {/* 2. Right Content */}
            <div className="content-area flex h-full min-h-0 gap-4">
                
                {/* [Left Panel inside Content] List */}
                <section className="w-[420px] shrink-0 rounded-2xl bg-white shadow-sm ring-1 ring-black/5 flex flex-col overflow-hidden text-zinc-950">
                    
                    {/* Filters */}
                    <div className="p-5 border-b border-slate-100 bg-white shrink-0 space-y-4">
                        <h2 className="text-lg font-bold text-slate-900">발주 승인 관리</h2>

                        {/* Tabs */}
                        <div className="flex bg-slate-100 p-1 rounded-xl">                            
                            <button onClick={() => setCurrentType('001')} className={`flex-1 py-2 text-xs font-bold rounded-lg transition-all ${currentType === '001' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}>약품 (Medicine)</button>
                            <button onClick={() => setCurrentType('002')} className={`flex-1 py-2 text-xs font-bold rounded-lg transition-all ${currentType === '002' ? 'bg-white text-blue-600 shadow-sm' : 'text-slate-500 hover:text-slate-700'}`}>물품 (Product)</button>
                        </div>

                        {/* [수정] 예쁜 드롭다운 필터 */}
                        <div className="space-y-2">
                            {/* 연도 & 월 선택 (Flex로 배치) */}
                            <div className="flex gap-2">
                                {/* 연도 Select */}
                                <select 
                                    value={year}
                                    onChange={(e) => setYear(e.target.value)}
                                    className="flex-[2] bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 text-[12px] font-bold outline-none focus:bg-white focus:border-blue-300 transition-colors"
                                >
                                    {yearOptions.map(y => (
                                        <option key={y} value={y}>{y}년</option>
                                    ))}
                                </select>

                                {/* 월 Select */}
                                <select 
                                    value={month}
                                    onChange={(e) => setMonth(e.target.value)}
                                    className="flex-[1] bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 text-[12px] font-bold outline-none focus:bg-white focus:border-blue-300 transition-colors"
                                >
                                    {Array.from({ length: 12 }, (_, i) => i + 1).map(m => {
                                        const mStr = String(m).padStart(2, '0');
                                        return <option key={m} value={mStr}>{m}월</option>;
                                    })}
                                </select>
                            </div>

                            {/* 상태 필터 */}
                            <select 
                                value={statusFilter}
                                onChange={(e) => setStatusFilter(e.target.value)}
                                className="w-full bg-slate-50 border border-slate-200 rounded-lg px-3 py-2 text-[12px] font-bold outline-none focus:bg-white focus:border-blue-300 transition-colors"
                            >
                                <option value="all">전체 상태 보기</option>
                                <option value="001">승인대기</option>
                                <option value="002">주문중</option>
                                <option value="005">반려됨</option>
                            </select>
                        </div>
                    </div>

                    {/* List Body */}
                    <div className="flex-1 overflow-y-auto p-3 bg-slate-50/30 space-y-2">
                    {filteredList.length === 0 ? (
                        <div className="text-center text-slate-400 py-10 text-xs">
                        해당 기간에 내역이 없습니다.
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
                                Order No: #{order.orderNo}
                            </p>
                            </div>
                        );
                        })
                    )}
                    </div>
                </section>

                {/* [Right Panel inside Content] Detail Info */}
                <section className="flex-1 rounded-2xl bg-white shadow-sm ring-1 ring-black/5 flex flex-col overflow-hidden relative text-zinc-950">
                    {!selectedOrder ? (
                    <div className="flex flex-col items-center justify-center h-full text-slate-400">
                        <div className="text-5xl mb-4">📑</div>
                        <p className="font-bold">목록에서 발주 건을 선택해 주세요</p>
                    </div>
                    ) : (
                    <div className="h-full flex flex-col animate-in fade-in duration-300">
                        <div className="p-6 border-b border-slate-100 flex justify-between items-center bg-white">
                        <div>
                            <h2 className="text-xl font-black text-slate-900">발주 상세 확인</h2>
                            <p className="text-xs text-slate-400 mt-1 uppercase font-bold">
                            Order ID: #{selectedOrder.orderNo} ({currentType === '001' ? '약품' : '물품'})
                            </p>
                        </div>
                        {renderStatusBadge(selectedOrder.orderStatus)}
                        </div>

                        <div className="flex-1 overflow-y-auto custom-scrollbar p-8">
                        {selectedOrder.orderStatus === '005' && selectedOrder.orderContent && (
                            <div className="mb-6 bg-red-50 border border-red-200 rounded-xl p-4">
                                <h4 className="text-red-600 font-bold text-sm mb-1">📌 반려 사유</h4>
                                <p className="text-slate-700 text-sm">{selectedOrder.orderContent}</p>
                            </div>
                        )}
                        <div className="grid grid-cols-2 gap-8 mb-8">
                            <div className="space-y-4">
                                <div>
                                    <label className="text-[11px] font-black text-slate-400 uppercase">신청일시</label>
                                    <p className="text-sm font-bold text-slate-800">{selectedOrder.orderDate}</p>
                                </div>
                            </div>
                        </div>
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
                                    <td className="px-6 py-4 text-right text-slate-500 font-medium">{price.toLocaleString()}원</td>
                                    <td className="px-6 py-4 text-right font-black text-slate-800">{item.orderDetailCount}</td>
                                    <td className="px-6 py-4 text-right font-black text-blue-600">{subTotal.toLocaleString()}원</td>
                                    </tr>
                                );
                                })}
                            </tbody>
                            </table>
                        </div>
                        <div className="bg-slate-50 rounded-2xl p-6 flex justify-between items-center">
                            <span className="text-sm font-bold text-slate-500 font-black">총 발주 합계 금액</span>
                            <span className="text-2xl font-black text-blue-600">{calculateTotal(selectedOrder.orderDetails).toLocaleString()}원</span>
                        </div>
                        </div>

                        {selectedOrder.orderStatus === '001' && (
                        <div className="p-6 bg-slate-50 border-t border-slate-100 flex gap-3">
                            <button onClick={openRejectModal} className="flex-1 py-4 bg-white border border-slate-200 text-red-500 font-bold rounded-2xl hover:bg-red-50 transition-colors">발주 반려</button>
                            <button onClick={handleApprove} className="flex-[2] py-4 bg-blue-600 text-white font-black rounded-2xl shadow-lg shadow-blue-100 hover:bg-blue-700 transition-all">최종 승인</button>
                        </div>
                        )}
                    </div>
                    )}
                </section>

            </div>
          </div>
        </main>
      </div>

      {isRejectModalOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50 backdrop-blur-sm animate-in fade-in">
          <div className="bg-white w-[400px] rounded-[2rem] shadow-2xl overflow-hidden flex flex-col">
            <div className="p-6 border-b border-slate-100 flex justify-between items-center">
              <h3 className="text-lg font-bold text-slate-900">발주 반려 사유</h3>
              <button onClick={() => setIsRejectModalOpen(false)} className="text-slate-400 hover:text-slate-600 font-bold text-xl">✕</button>
            </div>
            <div className="p-8">
              <textarea value={rejectReason} onChange={(e) => setRejectReason(e.target.value)} placeholder="반려 사유를 구체적으로 입력하세요." className="w-full h-32 bg-slate-50 border border-slate-200 rounded-xl px-4 py-3 text-sm font-bold outline-none resize-none focus:bg-white focus:border-red-300"></textarea>
            </div>
            <div className="p-6 bg-slate-50 flex gap-3">
              <button onClick={() => setIsRejectModalOpen(false)} className="flex-1 py-3 bg-white border border-slate-200 rounded-xl text-slate-500 font-bold hover:bg-gray-50">취소</button>
              <button onClick={handleRejectConfirm} className="flex-1 py-3 bg-red-500 text-white font-bold rounded-xl shadow-lg hover:bg-red-600">반려 확정</button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};

export default OrdersPage;