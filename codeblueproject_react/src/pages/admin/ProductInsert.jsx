import React, { useMemo } from 'react';
import axios from 'axios';
import Swal from 'sweetalert2';

const ProductInsert = ({ isOpen, onClose, cartList, clearCart }) => {
  
  // 1. 총 합계금액 계산 (cartList가 변경될 때만 재계산)
  const grandTotal = useMemo(() => {
    if (!cartList || cartList.length === 0) return 0;
    return cartList.reduce((acc, item) => {
      const qty = parseInt(item.orderQty) || 0;
      return acc + (item.productCost * qty); // JSP: productCost 사용
    }, 0);
  }, [cartList]);

  // 2. 최종 신청 완료 핸들러
  const handleSubmit = async () => {
    // 유효성 검사 (수량 0인 항목 체크)
    const emptyQtyItem = cartList.find(item => !item.orderQty || item.orderQty <= 0);
    if (emptyQtyItem) {
      Swal.fire({
          title: '확인 필요',
          text: `[${emptyQtyItem.productName}]의 수량을 입력해주세요.`, 
          icon: 'warning',
          confirmButtonColor: '#3085d6',
          confirmButtonText: '확인'
      });
      return;
    }

    // 서버로 보낼 데이터 구성
    const orderData = {
      orderTotalamt: grandTotal,
      orderType: '002',       // JSP: '002' (물품 발주)
      orderStatus: '001',     // JSP: '001' (신청 상태)
      orderDetails: cartList.map(item => ({
        orderItemNo: item.productNo,        // JSP: productNo
        orderDetailCount: parseInt(item.orderQty),
        orderItemType: '002'  
      }))
    };

    try {
      // Axios 요청
      await axios.post('http://localhost:8060/api/order/orderInsert', orderData, {
        headers: { 'Content-Type': 'application/json' },
        withCredentials: true
      });

      // 성공 처리
      Swal.fire({
        title: '발주 신청 완료',
        text: '물품 발주 신청이 성공적으로 접수되었습니다.',
        icon: 'success',
        confirmButtonColor: '#2563eb', // Blue-600
        confirmButtonText: '확인'
      }).then((result) => {
        if (result.isConfirmed) {
          clearCart(); // 장바구니 비우기
          onClose();   // 모달 닫기
        }
      });

    } catch (error) {
      console.error(error);
      // 에러 처리
      const msg = (error.response && error.response.status === 404) 
        ? "발주 신청 처리에 실패했습니다. (결과값 없음)"
        : "서버오류, 발주 신청을 실패하였습니다";
        
      Swal.fire({
          icon: "warning",
          title: "오류",
          text: msg,
          confirmButtonColor: '#d33'
      });
    }
  };

  // 모달이 닫혀있으면 렌더링하지 않음
  if (!isOpen) return null;

  return (
    // 배경 (Backdrop)
    <div 
        className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50"
        onClick={(e) => { if(e.target === e.currentTarget) onClose(); }}
    >
        {/* 모달 창 */}
        <div className="bg-white rounded-lg shadow-lg w-full max-w-3xl mx-4 overflow-hidden flex flex-col max-h-[85vh]">
            
            {/* 헤더 */}
            <div className="flex justify-between items-center p-4 border-b border-blue-200 bg-blue-50">
                <div className="flex items-center gap-2">
                    <span className="text-2xl">📦</span>
                    <h3 className="text-lg font-bold text-blue-600">통합 발주 신청 (물품)</h3>
                </div>
                <button onClick={onClose} className="text-gray-500 hover:text-gray-700 text-2xl font-bold">&times;</button>
            </div>
            
            {/* 바디 */}
            <div className="p-6 overflow-y-auto flex-1">
                <div className="mb-4 text-sm text-gray-500 bg-gray-50 p-3 rounded border border-gray-100">
                    선택하신 물품의 발주 내역을 최종 확인해주세요.
                </div>

                <div className="border rounded-lg overflow-hidden border-gray-200">
                    <table className="w-full text-sm text-left">
                        <thead className="text-gray-700 bg-gray-100 border-b border-gray-200">
                            <tr>
                                <th className="px-4 py-3 w-[50px] text-center">No</th>
                                <th className="px-4 py-3">물품명 / 제조사</th>
                                <th className="px-4 py-3 text-right">단가</th>
                                <th className="px-4 py-3 text-center w-[100px]">신청갯수</th>
                                <th className="px-4 py-3 text-right">주문액</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y divide-gray-100">
                            {cartList.map((item, index) => {
                                const qty = parseInt(item.orderQty) || 0;
                                const itemTotal = item.productCost * qty;

                                return (
                                    <tr key={item.productNo || index} className="hover:bg-gray-50">
                                        <td className="px-4 py-3 text-center text-gray-500">{index + 1}</td>
                                        <td className="px-4 py-3">
                                            <div className="font-medium text-gray-900">{item.productName}</div>
                                            <div className="text-xs text-gray-400">{item.productCompany}</div>
                                        </td>
                                        <td className="px-4 py-3 text-right text-gray-600">
                                            {item.productCost.toLocaleString()}원
                                        </td>
                                        <td className="px-4 py-3 text-center">
                                            <span className="px-2 py-1 bg-blue-50 text-blue-600 rounded font-bold">
                                                {qty} 개
                                            </span>
                                        </td>
                                        <td className="px-4 py-3 text-right font-medium">
                                            {itemTotal.toLocaleString()}원
                                        </td>
                                    </tr>
                                );
                            })}
                        </tbody>
                    </table>
                </div>

                {/* 총계 표시 박스 */}
                <div className="mt-6 bg-slate-50 p-4 rounded-lg border border-gray-200 flex justify-end items-center gap-4 shadow-sm">
                    <span className="text-lg font-bold text-slate-500">총 합계금액</span>
                    <span className="text-2xl font-black text-blue-600">
                        {grandTotal.toLocaleString()}원
                    </span>
                </div>
            </div>
            
            {/* 푸터 */}
            <div className="p-4 border-t border-gray-200 flex justify-end gap-2 bg-gray-50">
                <button 
                    onClick={onClose}
                    className="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600 font-bold text-sm"
                >
                    취소
                </button>
                <button 
                    onClick={handleSubmit}
                    className="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700 font-bold text-sm shadow-md"
                >
                    최종 신청 완료
                </button>
            </div>

        </div>
    </div>
  );
};

export default ProductInsert;