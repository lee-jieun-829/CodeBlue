import React, { useState, useEffect } from 'react';
import axios from 'axios';
import Swal from 'sweetalert2';

// SweetAlert 공통 스타일 정의
const swalOptions = {
    buttonsStyling: false,
    customClass: {
        confirmButton: 'bg-blue-600 text-white px-4 py-2 rounded-md font-bold hover:bg-blue-700',
        cancelButton: 'bg-gray-500 text-white px-4 py-2 rounded-md font-bold hover:bg-gray-600 ml-2'
    }
};

const ProductNotEnough = ({ isOpen, onClose, cartList, setCartList }) => {
    const [lowStockList, setLowStockList] = useState([]);

    // 모달이 열릴 때 데이터 가져오기
    useEffect(() => {
        if (isOpen) {
            fetchLowStockList();
        }
    }, [isOpen]);

    // 부족 수량 물품 조회 API 호출
    const fetchLowStockList = async () => {
        try { 
             const res = await axios.get('http://localhost:8060/api/order/notEnoughProduct', {
                withCredentials: true
            });
            
            setLowStockList(res.data || []);
            
            const list = res.data || [];
            if (list.length === 0) {
                Swal.fire({
                    icon: 'success',
                    title: '확인',
                    text: '재고 부족 물품이 없습니다.',
                    ...swalOptions
                }).then(() => {
                    onClose(); 
                });
            }
        } catch (error) {
            console.error(error);
            Swal.fire({
                icon: 'error',
                title: '오류',
                text: '부족한 물품 정보를 가져올 수 없습니다.',
                ...swalOptions
            });
            onClose();
        }
    };

    // 개별 담기
    const addSingleItem = (item) => {
        // 중복 체크 (productNo 기준)
        const isExist = cartList.some(cartItem => cartItem.productNo === item.productNo);
        if (isExist) {
            Swal.fire({
                icon: 'warning',
                title: '알림',
                text: '이미 장바구니에 담긴 물품입니다.',
                ...swalOptions
            });
            return;
        }
        
        // 부모 상태 업데이트 (기존 카트 + 새 아이템)
        setCartList([...cartList, { ...item, orderQty: '' }]);        
    };

    // 일괄 담기
    const addAllItems = () => {
        let addedCount = 0;
        let skippedNames = [];
        const newItems = [];

        lowStockList.forEach(item => {
            const isExist = cartList.some(cartItem => cartItem.productNo === item.productNo);
            if (!isExist) {
                newItems.push({ ...item, orderQty: '' });
                addedCount++;
            } else {
                skippedNames.push(item.productName);
            }
        });

        if (addedCount > 0) {
            setCartList([...cartList, ...newItems]);
        }

        onClose(); // 모달 닫기

        // 결과 알림창 구성
        let msgHtml = `총 <span style="color: #ef4444; font-weight: bold;">${addedCount}</span>건이 장바구니에 추가되었습니다.<br/>`;
        
        if (skippedNames.length > 0) {
             msgHtml += `<div style="font-size: 0.875rem; color: #6b7280; margin-top: 8px;">
                            이미 담겨있는 <br/>[ ${skippedNames[0]} 외 ${skippedNames.length - 1}건 ]<br/> 물품은 제외 하였습니다.
                        </div>`;
        }

        Swal.fire({
            title: '완료',
            html: msgHtml,
            icon: 'success',
            ...swalOptions
        });
    };

    // 모달이 닫혀있으면 렌더링 안 함
    if (!isOpen) return null;

    return (
        // 배경 (Backdrop)
        <div 
            className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50"
            onClick={(e) => { if(e.target === e.currentTarget) onClose(); }}
        >
            {/* 모달 창 */}
            <div className="bg-white rounded-lg shadow-lg w-full max-w-2xl mx-4 overflow-hidden flex flex-col max-h-[80vh]">
                
                {/* 헤더 - 경고(Red) 테마 */}
                <div className="flex justify-between items-center p-4 border-b border-red-200 bg-red-50">
                    <div className="flex items-center gap-2">
                        <span className="text-2xl">⚠️</span>
                        <h3 className="text-lg font-bold text-red-600">재고 부족 물품 목록</h3>
                    </div>
                    <button onClick={onClose} className="text-gray-500 hover:text-gray-700 text-2xl font-bold">&times;</button>
                </div>

                {/* 바디 (스크롤 영역) */}
                <div className="p-4 overflow-y-auto flex-1">
                    {lowStockList.map((item) => (
                        <div key={item.productNo} className="border-b border-gray-100 py-2 last:border-0">
                            <div className="flex justify-between items-center">
                                {/* 물품 정보 */}
                                <div className="flex flex-col">
                                    <span className="font-semibold text-sm">{item.productName}</span>
                                    <span className="text-xs text-gray-400">{item.productCompany}</span>
                                </div>
                                
                                {/* 재고 정보 */}
                                <div className="text-sm text-gray-600">
                                    현재: <span className="text-red-600 font-bold">{item.productAmount}</span> 개
                                    {/* 안전재고 정보가 API에 있다면 표시, 없으면 생략 */}
                                    {item.productSaftyStoke && ` / 안전재고: ${item.productSaftyStoke}`}
                                </div>

                                {/* 담기 버튼 */}
                                <button 
                                    onClick={() => addSingleItem(item)}
                                    className="px-3 py-1 bg-red-100 text-red-600 text-xs rounded border border-red-200 hover:bg-red-200"
                                >
                                    담기
                                </button>
                            </div>
                        </div>
                    ))}
                </div>

                {/* 푸터 */}
                <div className="p-4 border-t border-gray-200 flex justify-end gap-2 bg-gray-50">
                    <button 
                        onClick={onClose}
                        className="px-4 py-2 bg-gray-500 text-white rounded hover:bg-gray-600 font-bold text-sm"
                    >
                        닫기
                    </button>
                    <button 
                        onClick={addAllItems}
                        className="px-4 py-2 bg-red-600 text-white rounded hover:bg-red-700 font-bold text-sm"
                    >
                        부족 품목 일괄 담기
                    </button>
                </div>
            </div>
        </div>
    );
};

export default ProductNotEnough;