import React, { useEffect, useState, useMemo } from 'react';
import { getYearsStats } from '../../../api/statsApi';
import { 
  Chart as ChartJS, CategoryScale, LinearScale, BarElement, ArcElement, Title, Tooltip, Legend 
} from 'chart.js';
import { Bar, Doughnut } from 'react-chartjs-2';

ChartJS.register(CategoryScale, LinearScale, BarElement, ArcElement, Title, Tooltip, Legend);

const YearsStatsChart = ({ statsType, year }) => {
  const [rawData, setRawData] = useState([]);
  
  const [chartViewData, setChartViewData] = useState({ labels: [], datasets: [] });

  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth() + 1);

  useEffect(() => { 
    fetchStats(); 
    setSelectedMonth(new Date().getMonth() + 1); 
  }, [year]);

  // 다른 월로 선택하면 초기화!
  useEffect(() => {
    updateChartView();
  }, [selectedMonth, rawData]);

  const fetchStats = async () => {
    try {
      const res = await getYearsStats({ year });
      if(res.data) processData(res.data);
    } catch (error) { console.error(error); }
  };

  const processData = (data) => {
    const months = Array.from({ length: 12 }, (_, i) => ({
      month: i + 1,
      displayMonth: `${i + 1}월`,
      revenue: 0,
      expense: 0,
      profit: 0,
      outCnt: 0,
      inCnt: 0,
      totalCnt: 0
    }));

    if (data && Array.isArray(data)) {
      data.forEach(item => {
        const monthIdx = parseInt(item.yearMonth.split('-')[1]) - 1;
        
        // 매출/지출/이익 계산
        if(item.amount) months[monthIdx].revenue += item.amount;
        
        // 환자수 계산
        if (item.typeCode === 'A0001') { // 외래
            months[monthIdx].outCnt += item.cnt;
        } else if (item.typeCode === 'A0002') { // 입원
            months[monthIdx].inCnt += item.cnt;
        }
      });
    }

    // 지출/이익 및 합계 계산
    months.forEach(m => {
        m.expense = Math.floor(m.revenue * 0.6); // 지출 임의 계산 (60%)
        m.profit = m.revenue - m.expense;
        m.totalCnt = m.outCnt + m.inCnt;
    });

    setRawData(months);
  };

  //  월 선택 여부에 따라 차트 데이터 변경
  const updateChartView = () => {
    if (rawData.length === 0) return;

    if (selectedMonth === 0) {
        // 전체 - 해당연도의 1월~에서 12월까지
        setChartViewData({
            labels: rawData.map(d => d.displayMonth),
            revenue: rawData.map(d => d.revenue),
            expense: rawData.map(d => d.expense),
            profit: rawData.map(d => d.profit),
            outCnt: rawData.map(d => d.outCnt),
            inCnt: rawData.map(d => d.inCnt)
        });
    } else {
        const targetData = rawData[selectedMonth - 1];
        const weeks = ['1주차', '2주차', '3주차', '4주차', '5주차'];
        const distribute = (total) => {
            if (!total) return [0, 0, 0, 0, 0];
            const parts = [0.15, 0.25, 0.30, 0.20, 0.10]; // 주차별 가중치 예시
            return parts.map(p => Math.floor(total * p));
        };

        setChartViewData({
            labels: weeks,
            revenue: distribute(targetData.revenue),
            expense: distribute(targetData.expense),
            profit: distribute(targetData.profit),
            outCnt: distribute(targetData.outCnt),
            inCnt: distribute(targetData.inCnt)
        });
    }
  };

  // 선택된 월에 따른 요약 데이터 계산 (Memoization)
  const summary = useMemo(() => {
    if (rawData.length === 0) return { revenue: 0, expense: 0, profit: 0, outCnt: 0, inCnt: 0, totalCnt: 0 };

    if (selectedMonth === 0) {
        return rawData.reduce((acc, curr) => ({
            revenue: acc.revenue + curr.revenue,
            expense: acc.expense + curr.expense,
            profit: acc.profit + curr.profit,
            outCnt: acc.outCnt + curr.outCnt,
            inCnt: acc.inCnt + curr.inCnt,
            totalCnt: acc.totalCnt + curr.totalCnt
        }), { revenue: 0, expense: 0, profit: 0, outCnt: 0, inCnt: 0, totalCnt: 0 });
    } else {
        return rawData[selectedMonth - 1] || { revenue: 0, expense: 0, profit: 0, outCnt: 0, inCnt: 0, totalCnt: 0 };
    }
  }, [rawData, selectedMonth]);

  // 차트 옵션
  const commonOptions = {
    responsive: true, maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: {
      x: { grid: { display: false }, ticks: { font: { size: 11, weight: 'bold' }, color: '#94a3b8' } },
      y: { beginAtZero: true, grid: { color: '#f1f5f9' }, ticks: { display: false } }
    }
  };

  // 메인 셀렉 박스
  const MonthSelector = () => (
    <div className="w-32">
        <select 
            value={selectedMonth} 
            onChange={(e) => setSelectedMonth(Number(e.target.value))}
            className="w-full bg-slate-50 border border-slate-200 text-slate-700 text-xs font-bold rounded-lg px-3 py-2 outline-none focus:border-blue-500 transition-colors cursor-pointer"
        >
            <option value={0}>전체 (1년)</option>
            {Array.from({ length: 12 }, (_, i) => (
                <option key={i+1} value={i+1}>{i+1}월</option>
            ))}
        </select>
    </div>
  );

  return (
    <div className="h-full flex flex-col gap-5 p-1">
      
      {/* 매출 탭 */}
      {statsType === 'revenue' && (
        <>
            {/* 상단 컨트롤 및 카드 */}
            <div className="flex gap-4 shrink-0 h-28">
                {/* 월 선택 필터 */}
                <div className="w-40 bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center">
                    <label className="text-xs text-slate-400 font-bold mb-2 uppercase">
                        {selectedMonth === 0 ? '연간 조회' : '월간 상세 조회'}
                    </label>
                    <MonthSelector />
                </div>

                {/* 정보 카드들 (반원 디자인) */}
                <div className="flex-1 grid grid-cols-3 gap-4">
                    {/* 매출 */}
                    <div className="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center relative overflow-hidden">
                        <div className="absolute right-0 top-0 w-20 h-20 bg-blue-50 rounded-bl-full -mr-4 -mt-4"></div>
                        <p className="text-[10px] text-slate-400 font-bold uppercase z-10">총 매출액</p>
                        <div className="flex items-baseline gap-1 mt-1 z-10">
                            <span className="text-3xl font-black text-slate-800">{summary.revenue.toLocaleString()}</span>
                            <span className="text-xs font-bold text-slate-400">원</span>
                        </div>
                    </div>
                    {/* 지출 */}
                    <div className="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center relative overflow-hidden">
                        <div className="absolute right-0 top-0 w-20 h-20 bg-rose-50 rounded-bl-full -mr-4 -mt-4"></div>
                        <p className="text-[10px] text-slate-400 font-bold uppercase z-10">총 지출액 (추정)</p>
                        <div className="flex items-baseline gap-1 mt-1 z-10">
                            <span className="text-3xl font-black text-rose-500">{summary.expense.toLocaleString()}</span>
                            <span className="text-xs font-bold text-rose-300">원</span>
                        </div>
                    </div>
                    {/* 이익 */}
                    <div className="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center relative overflow-hidden">
                        <div className="absolute right-0 top-0 w-20 h-20 bg-emerald-50 rounded-bl-full -mr-4 -mt-4"></div>
                        <p className="text-[10px] text-slate-400 font-bold uppercase z-10">영업 이익</p>
                        <div className="flex items-baseline gap-1 mt-1 z-10">
                            <span className="text-3xl font-black text-emerald-500">{summary.profit.toLocaleString()}</span>
                            <span className="text-xs font-bold text-emerald-300">원</span>
                        </div>
                    </div>
                </div>
            </div>

            {/* 하단 차트 & 테이블 */}
            <div className="flex-1 flex gap-4 min-h-0">
                {/* 차트 영역 */}
                <div className="flex-[2] bg-white border border-slate-200 rounded-2xl p-6 shadow-sm flex flex-col">
                    <div className="flex justify-between items-center mb-4 shrink-0">
                        <h3 className="text-base font-bold text-slate-700 flex items-center gap-2">
                            <span className="w-1.5 h-4 bg-blue-600 rounded-full"></span>
                            {selectedMonth === 0 ? '월별 손익 추이' : `${selectedMonth}월 주차별 상세 손익`}
                        </h3>
                        {/* 범례 */}
                        <div className="flex gap-3">
                            <div className="flex items-center gap-1.5 text-[10px] font-bold text-slate-500"><span className="w-2 h-2 rounded-full bg-blue-500"></span> 매출</div>
                            <div className="flex items-center gap-1.5 text-[10px] font-bold text-slate-500"><span className="w-2 h-2 rounded-full bg-rose-400"></span> 지출</div>
                            <div className="flex items-center gap-1.5 text-[10px] font-bold text-slate-500"><span className="w-2 h-2 rounded-full bg-emerald-400"></span> 이익</div>
                        </div>
                    </div>
                    <div className="flex-1 min-h-0">
                        <Bar options={commonOptions} data={{
                            labels: chartViewData.labels,
                            datasets: [
                                { label: '매출', data: chartViewData.revenue, backgroundColor: '#3b82f6', borderRadius: 4, barPercentage: 0.6 },
                                { label: '지출', data: chartViewData.expense, backgroundColor: '#fb7185', borderRadius: 4, barPercentage: 0.6 },
                                { label: '이익', data: chartViewData.profit, backgroundColor: '#34d399', borderRadius: 4, barPercentage: 0.6 }
                            ]
                        }} />
                    </div>
                </div>

                {/* 테이블 영역 (여기는 항상 월별 데이터를 유지하거나 선택된 달만 보여줌) */}
                <div className="flex-1 bg-white border border-slate-200 rounded-2xl shadow-sm flex flex-col overflow-hidden">
                    <div className="px-5 py-4 border-b border-slate-100 bg-white flex justify-between items-center shrink-0">
                         <h3 className="text-sm font-bold text-slate-700">
                             {selectedMonth === 0 ? '월별 상세 내역' : `${selectedMonth}월 상세`}
                         </h3>
                         <span className="text-[10px] font-bold text-slate-400 bg-slate-50 px-2 py-1 rounded">단위: 원</span>
                    </div>
                    <div className="flex-1 overflow-y-auto">
                        <table className="w-full text-left text-xs">
                            <thead className="bg-slate-50 text-slate-400 font-bold sticky top-0 z-10">
                                <tr>
                                    <th className="px-4 py-3">기간</th>
                                    <th className="px-4 py-3 text-right">매출</th>
                                    <th className="px-4 py-3 text-right">이익</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-50">
                                {selectedMonth === 0 ? (
                                    rawData.map((row, idx) => (
                                        <tr key={idx} className="hover:bg-slate-50 transition-colors">
                                            <td className="px-4 py-3 font-bold text-slate-600">{row.displayMonth}</td>
                                            <td className="px-4 py-3 text-right font-bold text-blue-600">{row.revenue.toLocaleString()}</td>
                                            <td className="px-4 py-3 text-right text-emerald-500">{row.profit.toLocaleString()}</td>
                                        </tr>
                                    ))
                                ) : (
                                    chartViewData.labels.map((label, idx) => (
                                    <tr key={idx} className="hover:bg-slate-50 transition-colors">
                                        <td className="px-4 py-3 font-bold text-slate-600">{label}</td>
                                        <td className="px-4 py-3 text-right font-bold text-blue-600">
                                            {chartViewData.revenue[idx]?.toLocaleString()}
                                        </td>
                                        <td className="px-4 py-3 text-right text-emerald-500">
                                            {chartViewData.profit[idx]?.toLocaleString()}
                                        </td>
                                    </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </>
      )}

      {/* 2. 환자 탭 */}
      {statsType === 'patient' && (
        <>
          <div className="flex gap-4 shrink-0 h-28">
                {/* 월 선택 필터 */}
                <div className="w-40 bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center">
                    <label className="text-xs text-slate-400 font-bold mb-2 uppercase">
                        {selectedMonth === 0 ? '연간 조회' : '월간 상세 조회'}
                    </label>
                    <MonthSelector />
                </div>

                {/* 정보 카드들 */}
                <div className="flex-1 grid grid-cols-3 gap-4">
                     {/* 총 환자 */}
                    <div className="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center relative overflow-hidden">
                        <div className="absolute right-0 top-0 w-20 h-20 bg-slate-100 rounded-bl-full -mr-4 -mt-4"></div>
                        <p className="text-[10px] text-slate-400 font-bold uppercase z-10">총 환자수</p>
                        <div className="flex items-baseline gap-1 mt-1 z-10">
                            <span className="text-3xl font-black text-slate-800">{summary.totalCnt.toLocaleString()}</span>
                            <span className="text-xs font-bold text-slate-400">명</span>
                        </div>
                    </div>
                     {/* 외래 환자 */}
                    <div className="bg-white border border-blue-100 rounded-2xl p-5 shadow-sm flex flex-col justify-center relative overflow-hidden bg-blue-50/20">
                        <div className="absolute right-0 top-0 w-20 h-20 bg-blue-100 rounded-bl-full -mr-4 -mt-4 opacity-50"></div>
                        <p className="text-[10px] text-blue-500 font-bold uppercase z-10">외래 환자</p>
                        <div className="flex items-baseline gap-1 mt-1 z-10">
                            <span className="text-3xl font-black text-blue-600">{summary.outCnt.toLocaleString()}</span>
                            <span className="text-xs font-bold text-blue-400">명</span>
                        </div>
                    </div>
                     {/* 입원 환자 */}
                    <div className="bg-white border border-indigo-100 rounded-2xl p-5 shadow-sm flex flex-col justify-center relative overflow-hidden bg-indigo-50/20">
                        <div className="absolute right-0 top-0 w-20 h-20 bg-indigo-100 rounded-bl-full -mr-4 -mt-4 opacity-50"></div>
                        <p className="text-[10px] text-indigo-500 font-bold uppercase z-10">입원 환자</p>
                        <div className="flex items-baseline gap-1 mt-1 z-10">
                            <span className="text-3xl font-black text-indigo-600">{summary.inCnt.toLocaleString()}</span>
                            <span className="text-xs font-bold text-indigo-400">명</span>
                        </div>
                    </div>
                </div>
          </div>

          {/* 하단 차트 영역 */}
          <div className="flex-1 grid grid-cols-2 gap-4 min-h-0">
             {/* 도넛 차트 */}
              <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm flex flex-col">
                  <h3 className="text-base font-bold text-slate-700 mb-4 flex items-center gap-2">
                        <span className="w-1.5 h-4 bg-indigo-500 rounded-full"></span>
                        외래/입원 비율 ({selectedMonth === 0 ? '전체' : `${selectedMonth}월`})
                  </h3>
                  <div className="flex-1 flex justify-center items-center min-h-0 relative">
                      <Doughnut 
                        data={{
                          labels: ['외래', '입원'],
                          datasets: [{
                            data: [summary.outCnt, summary.inCnt],
                            backgroundColor: ['#3b82f6', '#6366f1'],
                            borderWidth: 0,
                            hoverOffset: 4
                          }]
                        }} 
                        options={{ 
                            cutout: '70%', 
                            maintainAspectRatio: false, 
                            plugins: { legend: { position: 'right', labels: { usePointStyle: true, font: { size: 11, family: 'Pretendard' } } } } 
                        }} 
                      />
                      <div className="absolute inset-0 flex items-center justify-center pointer-events-none mb-2">
                        <div className="text-center">
                            <div className="text-xs text-slate-400 font-bold">Total</div>
                            <div className="text-xl font-black text-slate-700">{summary.totalCnt}</div>
                        </div>
                      </div>
                  </div>
              </div>
              
              {/* 바 차트 (추세 - 월별 or 주차별) */}
              <div className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm flex flex-col">
                    <h3 className="text-base font-bold text-slate-700 mb-4 flex items-center gap-2">
                        <span className="w-1.5 h-4 bg-slate-400 rounded-full"></span>
                        {selectedMonth === 0 ? '월별 환자 추이' : `${selectedMonth}월 주차별 상세 추이`}
                    </h3>
                    <div className="flex-1 min-h-0">
                      <Bar 
                        options={commonOptions} 
                        data={{
                          labels: chartViewData.labels,
                          datasets: [
                              { label: '외래', data: chartViewData.outCnt, backgroundColor: '#3b82f6', borderRadius: 4 },
                              { label: '입원', data: chartViewData.inCnt, backgroundColor: '#cbd5e1', borderRadius: 4 }
                          ]
                        }}
                      />
                    </div>
              </div>
          </div>
        </>
      )}
    </div>
  );
};

export default YearsStatsChart;