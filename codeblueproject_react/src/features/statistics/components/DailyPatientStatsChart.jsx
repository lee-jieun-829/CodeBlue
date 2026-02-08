import React, { useEffect, useState } from 'react';
import { getDailyPatientStats } from '../../../api/statsApi'; // API 경로가 맞는지 확인해주세요
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  BarElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend,
} from 'chart.js';
import { Chart } from 'react-chartjs-2';

// 차트 플러그인 등록
ChartJS.register(
  CategoryScale,
  LinearScale,
  BarElement,
  PointElement,
  LineElement,
  Title,
  Tooltip,
  Legend
);

const DailyPatientStatsChart = ({ year }) => {
  const [chartData, setChartData] = useState(null);
  const [selectedMonth, setSelectedMonth] = useState(new Date().getMonth() + 1);
  const [summary, setSummary] = useState({ total: 0, newCnt: 0, oldCnt: 0, maxDay: '-' });

  const months = Array.from({ length: 12 }, (_, i) => i + 1);

  // 연도나 월이 변경될 때마다 데이터 조회
  useEffect(() => {
    fetchData();
  }, [year, selectedMonth]);

  const fetchData = async () => {
    try {
      const res = await getDailyPatientStats({ year, month: selectedMonth });
      processData(res.data);
    } catch (err) {
      console.error("로딩 실패:", err);
      setChartData(null);
    }
  };

  const processData = (data) => {
    if (!data || data.length === 0) {
      setChartData(null);
      setSummary({ total: 0, newCnt: 0, oldCnt: 0, maxDay: '-' });
      return;
    }

    const labels = [...new Set(data.map((item) => item.yearMonth))].sort();

    const newPatients = labels.map((date) => {
      const found = data.find((item) => item.yearMonth === date && item.typeCode === 'NEW');
      return found ? found.cnt : 0;
    });

    const oldPatients = labels.map((date) => {
      const found = data.find((item) => item.yearMonth === date && item.typeCode === 'OLD');
      return found ? found.cnt : 0;
    });

    // 총합
    const totalPatients = labels.map((_, i) => newPatients[i] + oldPatients[i]);

   // 써머리
    const sumNew = newPatients.reduce((a, b) => a + b, 0);
    const sumOld = oldPatients.reduce((a, b) => a + b, 0);
    const maxTotal = Math.max(...totalPatients);
    const maxDayIdx = totalPatients.indexOf(maxTotal);

    setSummary({
      total: sumNew + sumOld,
      newCnt: sumNew,
      oldCnt: sumOld,
      maxDay: labels[maxDayIdx] || '-',
    });

    // 차트 데이터 구성
    setChartData({
      labels: labels,
      datasets: [
        {
          type: 'line',
          label: '전체 환자',
          borderColor: '#6366f1',
          borderWidth: 2,
          borderDash: [5, 5], 
          pointRadius: 3,
          pointBackgroundColor: '#fff',
          pointBorderColor: '#6366f1',
          fill: false,
          data: totalPatients,
          tension: 0.3,
          order: 0, 
        },
        {
          // 신규 환자
          type: 'bar', 
          label: '신규 환자',
          backgroundColor: '#2dce89',
          data: newPatients,
          borderRadius: 4,
          order: 1,
        },
        {
          // 재방문 환자
          type: 'bar',
          label: '재방문 환자',
          backgroundColor: '#3b82f6',
          data: oldPatients,
          borderRadius: 4,
          order: 2,
        },
      ],
    });
  };

  // 옵션
  const options = {
    responsive: true,
    maintainAspectRatio: false,
    interaction: {
      mode: 'index',
      intersect: false,
    },
    plugins: {
      legend: {
        position: 'top',
        labels: { usePointStyle: true, boxWidth: 8, font: { size: 11 } },
      },
      tooltip: {
        backgroundColor: 'rgba(255, 255, 255, 0.9)',
        titleColor: '#1e293b',
        bodyColor: '#475569',
        borderColor: '#e2e8f0',
        borderWidth: 1,
        padding: 10,
        boxPadding: 4,
        usePointStyle: true,
      },
    },
    scales: {
      x: {
        grid: { display: false },
        ticks: { font: { size: 11, weight: 'bold' }, color: '#64748b' },
      },
      y: {
        beginAtZero: true,
        grid: { color: '#f1f5f9' },
        ticks: { display: false }, // 기존 디자인처럼 Y축 숫자 숨김
      },
    },
  };

  return (
    <div className="h-full flex flex-col gap-5 p-1">
      
      {/* 월 선택 및 요약 카드 */}
      <div className="flex gap-4 shrink-0 h-28">
        
        {/*  월 선택 */}
        <div className="w-40 bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center">
            <label className="text-xs text-slate-400 font-bold mb-2 uppercase">조회 월 선택</label>
            <div className="relative">
                <select 
                    value={selectedMonth} 
                    onChange={(e) => setSelectedMonth(Number(e.target.value))}
                    className="w-full appearance-none bg-slate-50 border border-slate-200 text-slate-700 font-bold text-sm rounded-lg pl-3 pr-8 py-2 focus:outline-none focus:border-blue-500 transition-colors cursor-pointer"
                >
                    {months.map(m => (
                        <option key={m} value={m}>{m}월</option>
                    ))}
                </select>
                <div className="pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-slate-500">
                    <svg className="fill-current h-4 w-4" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path d="M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z"/></svg>
                </div>
            </div>
        </div>

        {/* 총합/ 신규 / 재방문 */}
        <div className="flex-1 grid grid-cols-3 gap-4">
            {/* 총 환자수 */}
            <div className="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center relative overflow-hidden">
                <div className="absolute right-0 top-0 w-20 h-20 bg-indigo-50 rounded-bl-full -mr-4 -mt-4"></div>
                <p className="text-xs text-slate-500 font-bold uppercase z-10">월간 총 환자</p>
                <div className="flex items-baseline gap-1 mt-1 z-10">
                    <span className="text-3xl font-black text-slate-800">{summary.total.toLocaleString()}</span>
                    <span className="text-sm font-bold text-slate-400">명</span>
                </div>
            </div>

            {/* 신규 환자 */}
            <div className="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center relative overflow-hidden">
                <div className="absolute right-0 top-0 w-20 h-20 bg-emerald-50 rounded-bl-full -mr-4 -mt-4"></div>
                <p className="text-xs text-slate-500 font-bold uppercase z-10">신규 방문</p>
                <div className="flex items-baseline gap-1 mt-1 z-10">
                    <span className="text-3xl font-black text-emerald-500">{summary.newCnt.toLocaleString()}</span>
                    <span className="text-sm font-bold text-slate-400">명</span>
                </div>
            </div>

            {/* 재방문 환자 */}
            <div className="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center relative overflow-hidden">
                <div className="absolute right-0 top-0 w-20 h-20 bg-blue-50 rounded-bl-full -mr-4 -mt-4"></div>
                <p className="text-xs text-slate-500 font-bold uppercase z-10">재방문</p>
                <div className="flex items-baseline gap-1 mt-1 z-10">
                    <span className="text-3xl font-black text-blue-500">{summary.oldCnt.toLocaleString()}</span>
                    <span className="text-sm font-bold text-slate-400">명</span>
                </div>
            </div>
        </div>
      </div>

      {/* 하단: 메인 차트 영역 */}
      <div className="flex-1 bg-white border border-slate-200 rounded-2xl p-6 shadow-sm flex flex-col min-h-0">
         <div className="flex justify-between items-center mb-4 shrink-0">
            <h3 className="text-base font-bold text-slate-700 flex items-center gap-2">
                <span className="w-1.5 h-4 bg-slate-800 rounded-full"></span>
                일별 신규/재방문 유입 추이 ({selectedMonth}월)
            </h3>
            {summary.maxDay !== '-' && (
                <div className="text-xs font-bold text-slate-400 bg-slate-50 px-3 py-1.5 rounded-lg border border-slate-100">
                    최다 방문일: <span className="text-indigo-600 ml-1">{summary.maxDay}</span>
                </div>
            )}
         </div>
         
         <div className="flex-1 min-h-0 w-full relative">
            {chartData ? (<Chart type='bar' data={chartData} options={options} />
            ) : (
                <div className="absolute inset-0 flex items-center justify-center text-slate-400 text-sm">
                    데이터가 존재하지 않습니다.
                </div>
            )}
         </div>
      </div>

    </div>
  );
};

export default DailyPatientStatsChart;