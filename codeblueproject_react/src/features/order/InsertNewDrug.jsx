import React, { useState } from 'react';

const InsertNewDrug = ({ isOpen, onClose, onSave }) => {
  // 초기 상태값 (DB 컬럼 매핑)
  const initialFormState = {
    drugCode: '',       // DRUG_CODE
    drugName: '',       // DRUG_NAME
    drugCompany: '',    // DRUG_COMPANY
    drugType: '내복',   // DRUG_TYPE (기본값 설정)
    drugSpec: '',       // DRUG_SPEC
    drugUnit: '',       // DRUG_UNIT
    drugAmount: 0,      // DRUG_AMOUNT
    drugSafetyStock: 0, // DRUG_SAFTY_STOKE (스펠링 교정: Safety)
    drugCost: 0,        // DRUG_COST
    drugPrice: 0,       // DRUG_PRICE
  };

  const [formData, setFormData] = useState(initialFormState);

  // 입력 핸들러
  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  // 저장 핸들러
  const handleSubmit = (e) => {
    e.preventDefault();
    // 유효성 검사 (예: 필수값 체크)
    if (!formData.drugName || !formData.drugCode) {
      alert("약품코드와 약품명은 필수입니다.");
      return;
    }
    
    // 부모 컴포넌트로 데이터 전달
    onSave(formData);
    
    // 폼 초기화 및 닫기
    setFormData(initialFormState);
    onClose();
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center overflow-y-auto overflow-x-hidden font-sans bg-black/50 backdrop-blur-sm">
      <div className="relative w-full max-w-3xl p-4 max-h-full">
        {/* Modal Content */}
        <div className="relative bg-white rounded-lg shadow-xl border border-slate-200">
          
          {/* Header */}
          <div className="flex items-center justify-between p-4 border-b border-slate-100 rounded-t">
            <h3 className="text-xl font-bold text-slate-800">
              신규 약품 등록
            </h3>
            <button
              onClick={onClose}
              type="button"
              className="text-slate-400 bg-transparent hover:bg-slate-100 hover:text-slate-900 rounded-lg text-sm w-8 h-8 ml-auto inline-flex justify-center items-center"
            >
              <svg className="w-3 h-3" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
                <path stroke="currentColor" strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"/>
              </svg>
              <span className="sr-only">Close modal</span>
            </button>
          </div>

          {/* Body */}
          <form onSubmit={handleSubmit} className="p-6 space-y-6">
            
            {/* 섹션 1: 기본 정보 */}
            <div>
              <h4 className="text-sm font-bold text-blue-600 mb-3 border-l-4 border-blue-600 pl-2">기본 정보</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* 약품 코드 */}
                <div>
                  <label htmlFor="drugCode" className="block mb-2 text-sm font-medium text-slate-700">약품 코드 <span className="text-red-500">*</span></label>
                  <input
                    type="text"
                    name="drugCode"
                    id="drugCode"
                    value={formData.drugCode}
                    onChange={handleChange}
                    className="bg-slate-50 border border-slate-300 text-slate-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                    placeholder="예: D-12345"
                    required
                  />
                </div>
                {/* 제조사 */}
                <div>
                  <label htmlFor="drugCompany" className="block mb-2 text-sm font-medium text-slate-700">제조사</label>
                  <input
                    type="text"
                    name="drugCompany"
                    id="drugCompany"
                    value={formData.drugCompany}
                    onChange={handleChange}
                    className="bg-slate-50 border border-slate-300 text-slate-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                    placeholder="제조사명 입력"
                  />
                </div>
                {/* 약품명 (전체 너비) */}
                <div className="md:col-span-2">
                  <label htmlFor="drugName" className="block mb-2 text-sm font-medium text-slate-700">약품명 <span className="text-red-500">*</span></label>
                  <input
                    type="text"
                    name="drugName"
                    id="drugName"
                    value={formData.drugName}
                    onChange={handleChange}
                    className="bg-slate-50 border border-slate-300 text-slate-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                    placeholder="약품 전체 명칭 입력"
                    required
                  />
                </div>
              </div>
            </div>

            <hr className="border-slate-200" />

            {/* 섹션 2: 분류 및 규격 */}
            <div>
              <h4 className="text-sm font-bold text-blue-600 mb-3 border-l-4 border-blue-600 pl-2">분류 및 규격</h4>
              <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
                {/* 투여 분류 */}
                <div>
                  <label htmlFor="drugType" className="block mb-2 text-sm font-medium text-slate-700">투여 분류</label>
                  <select
                    name="drugType"
                    id="drugType"
                    value={formData.drugType}
                    onChange={handleChange}
                    className="bg-slate-50 border border-slate-300 text-slate-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                  >
                    <option value="내복">내복</option>
                    <option value="주사">주사</option>
                    <option value="외용">외용</option>
                  </select>
                </div>
                {/* 규격 (용량) */}
                <div>
                  <label htmlFor="drugSpec" className="block mb-2 text-sm font-medium text-slate-700">규격 (용량)</label>
                  <input
                    type="text"
                    name="drugSpec"
                    id="drugSpec"
                    value={formData.drugSpec}
                    onChange={handleChange}
                    className="bg-slate-50 border border-slate-300 text-slate-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                    placeholder="예: 500mg"
                  />
                </div>
                {/* 단위 */}
                <div>
                  <label htmlFor="drugUnit" className="block mb-2 text-sm font-medium text-slate-700">단위</label>
                  <input
                    type="text"
                    name="drugUnit"
                    id="drugUnit"
                    value={formData.drugUnit}
                    onChange={handleChange}
                    className="bg-slate-50 border border-slate-300 text-slate-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5"
                    placeholder="예: 정, ml, amp"
                  />
                </div>
              </div>
            </div>

            <hr className="border-slate-200" />

            {/* 섹션 3: 재고 및 단가 */}
            <div>
              <h4 className="text-sm font-bold text-blue-600 mb-3 border-l-4 border-blue-600 pl-2">재고 및 단가 관리</h4>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {/* 매입가 */}
                <div>
                  <label htmlFor="drugCost" className="block mb-2 text-sm font-medium text-slate-700">매입가 (원)</label>
                  <input
                    type="number"
                    name="drugCost"
                    id="drugCost"
                    value={formData.drugCost}
                    onChange={handleChange}
                    className="bg-slate-50 border border-slate-300 text-slate-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 text-right"
                    placeholder="0"
                  />
                </div>
                {/* 출고가 */}
                <div>
                  <label htmlFor="drugPrice" className="block mb-2 text-sm font-medium text-slate-700">출고가 (원)</label>
                  <input
                    type="number"
                    name="drugPrice"
                    id="drugPrice"
                    value={formData.drugPrice}
                    onChange={handleChange}
                    className="bg-slate-50 border border-slate-300 text-slate-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 text-right"
                    placeholder="0"
                  />
                </div>
                {/* 현재 재고량 */}
                <div>
                  <label htmlFor="drugAmount" className="block mb-2 text-sm font-medium text-slate-700">현재 재고량</label>
                  <input
                    type="number"
                    name="drugAmount"
                    id="drugAmount"
                    value={formData.drugAmount}
                    onChange={handleChange}
                    className="bg-slate-50 border border-slate-300 text-slate-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 text-right"
                    placeholder="0"
                  />
                </div>
                {/* 안전 재고 */}
                <div>
                  <label htmlFor="drugSafetyStock" className="block mb-2 text-sm font-medium text-slate-700">안전 재고</label>
                  <input
                    type="number"
                    name="drugSafetyStock"
                    id="drugSafetyStock"
                    value={formData.drugSafetyStock}
                    onChange={handleChange}
                    className="bg-slate-50 border border-slate-300 text-slate-900 text-sm rounded-lg focus:ring-blue-500 focus:border-blue-500 block w-full p-2.5 text-right"
                    placeholder="0"
                  />
                </div>
              </div>
            </div>

            {/* Footer Buttons */}
            <div className="flex items-center justify-end pt-4 space-x-2 border-t border-slate-200">
              <button
                type="button"
                onClick={onClose}
                className="px-5 py-2.5 text-sm font-medium text-slate-900 focus:outline-none bg-white rounded-lg border border-slate-200 hover:bg-slate-100 focus:z-10 focus:ring-4 focus:ring-slate-200"
              >
                취소
              </button>
              <button
                type="submit"
                className="px-5 py-2.5 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 focus:ring-4 focus:outline-none focus:ring-blue-300"
              >
                등록하기
              </button>
            </div>

          </form>
        </div>
      </div>
    </div>
  );
};

export default InsertNewDrug;