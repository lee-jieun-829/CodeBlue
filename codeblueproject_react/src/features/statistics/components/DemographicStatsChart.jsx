import React, { useEffect, useState } from 'react';
import { getDemographicsStats } from '../../../api/statsApi';
import { Chart as ChartJS, CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend, ArcElement } from 'chart.js';
import { Bar, Doughnut } from 'react-chartjs-2';

ChartJS.register(CategoryScale, LinearScale, BarElement, Title, Tooltip, Legend, ArcElement);

const DemographicStatsChart = ({ year }) => {
  const [chartData, setChartData] = useState(null);
  const [summary, setSummary] = useState({ total: 0, topAge: '-', topGender: '-' });

  // 초기화 훅 (연도)
  useEffect(() => {
    fetchData();
  }, [year]);

  const fetchData = async () => {
    try {
      const res = await getDemographicsStats({ year });
      processData(res.data);
    } catch (err) {
      console.error(err);
    }
  };

  const processData = (data) => {
    if (!data || data.length === 0) {
      setChartData(null); 
      return;
    }

    // 연령대 그룹
    const ageGroups = [...new Set(data.map(d => d.yearMonth))].sort(); // 10대, 20대...
    
    // 성별 데이터 세팅
    let totalMale = 0;
    let totalFemale = 0;

    // 남성 데이터
    const maleData = ageGroups.map(age => {
      const item = data.find(d => d.yearMonth === age && d.typeCode === '남성');
      const cnt = item ? item.cnt : 0;
      totalMale += cnt;
      return cnt;
    });

    // 여성 데이터
    const femaleData = ageGroups.map(age => {
      const item = data.find(d => d.yearMonth === age && d.typeCode === '여성');
      const cnt = item ? item.cnt : 0;
      totalFemale += cnt;
      return cnt;
    });

    // 요약 정보 계산 (인사이트 카드용)
    const total = totalMale + totalFemale;
    
    // 가장 많은 연령대 찾기
    const ageSums = ageGroups.map((age, idx) => ({ age, sum: maleData[idx] + femaleData[idx] }));
    const topAgeObj = ageSums.reduce((max, curr) => max.sum > curr.sum ? max : curr, { sum: -1 });

    // 요약
    setSummary({
      total,
      topAge: topAgeObj.age || '-',
      topGender: totalMale > totalFemale ? '남성' : totalFemale > totalMale ? '여성' : '동일',
      ratio: total > 0 ? Math.round((Math.max(totalMale, totalFemale) / total) * 100) : 0
    });

    // 차트 데이터 세팅
    setChartData({
      bar: {
        labels: ageGroups,
        datasets: [
          { label: '남성', data: maleData, backgroundColor: '#3b82f6', stack: 'stack1', borderRadius: 4 }, // Blue-500
          { label: '여성', data: femaleData, backgroundColor: '#f43f5e', stack: 'stack1', borderRadius: 4 }, // Rose-500
        ]
      },
      doughnut: {
        labels: ['남성', '여성'],
        datasets: [{
          data: [totalMale, totalFemale],
          backgroundColor: ['#3b82f6', '#f43f5e'],
          hoverOffset: 4
        }]
      }
    });
  };

  // 차트 옵션
  const barOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { position: 'top' } },
    scales: { x: { grid: { display: false } }, y: { beginAtZero: true, grid: { color: '#f1f5f9' } } }
  };

  const doughnutOptions = {
    cutout: '60%', 
    plugins: { legend: { position: 'bottom', labels: { usePointStyle: true, padding: 20 } } }
  };

  if (!chartData) return <div className="h-full flex items-center justify-center text-slate-400">데이터가 없습니다.</div>;

  return (
    <div className="h-full flex flex-col gap-5 p-1">
      
      {/* 상단 인사이트 */}
      <div className="grid grid-cols-3 gap-4 shrink-0 h-28">
        {/* 총 내원 환자 */}
        <div className="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center relative overflow-hidden">
            <div className="absolute right-0 top-0 w-20 h-20 bg-blue-50 rounded-bl-full -mr-4 -mt-4"></div>
            <p className="text-xs text-slate-500 font-bold uppercase z-10">총 환자수</p>
            <div className="flex items-baseline gap-1 mt-1 z-10">
                <span className="text-3xl font-black text-slate-800">{summary.total.toLocaleString()}</span>
                <span className="text-sm font-bold text-slate-400">명</span>
            </div>
        </div>

        {/* 주 연령층 */}
        <div className="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center relative overflow-hidden">
            <div className="absolute right-0 top-0 w-20 h-20 bg-emerald-50 rounded-bl-full -mr-4 -mt-4"></div>
            <p className="text-xs text-slate-500 font-bold uppercase z-10">주요 연령대층</p>
            <div className="mt-1 z-10">
                <span className="text-3xl font-black text-emerald-500">{summary.topAge}</span>
                <span className="text-xs text-slate-400 ml-2 font-medium">가장 많음</span>
            </div>
        </div>

        {/* 성별 비율 */}
        <div className="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm flex flex-col justify-center relative overflow-hidden">
            <div className="absolute right-0 top-0 w-20 h-20 bg-rose-50 rounded-bl-full -mr-4 -mt-4"></div>
            <p className="text-xs text-slate-500 font-bold uppercase z-10">진료 환자 성별 비율</p>
            <div className="flex items-center gap-2 mt-1 z-10">
                <span className={`text-3xl font-black ${summary.topGender === '남성' ? 'text-blue-500' : 'text-rose-500'}`}>
                    {summary.topGender}
                </span>
                <div className="flex flex-col">
                    <span className="text-xs font-bold text-slate-400">전체 중 {summary.ratio}%</span>
                </div>
            </div>
        </div>
      </div>

      {/* 하단 차트 영역 */}
      <div className="flex-1 flex gap-4 min-h-0">
        
        {/* 연령별 분포 */}
        <div className="flex-[2] bg-white border border-slate-200 rounded-2xl p-6 shadow-sm flex flex-col">
            <h3 className="text-base font-bold text-slate-700 mb-4 flex items-center gap-2">
                <span className="w-1.5 h-4 bg-slate-800 rounded-full"></span>
                연령대별 성별 분포
            </h3>
            <div className="flex-1 min-h-0">
                <Bar options={barOptions} data={chartData.bar} />
            </div>
        </div>

        {/* 전체 성별 비율 */}
        <div className="flex-1 bg-white border border-slate-200 rounded-2xl p-6 shadow-sm flex flex-col">
            <h3 className="text-base font-bold text-slate-700 mb-4 flex items-center gap-2">
                <span className="w-1.5 h-4 bg-slate-400 rounded-full"></span>
                전체 환자 성별 비율
            </h3>
            <div className="flex-1 flex items-center justify-center min-h-0 relative">
                 <Doughnut options={doughnutOptions} data={chartData.doughnut} />
                 {/* 도넛 가운데 텍스트 */}
                 <div className="absolute inset-0 flex items-center justify-center pointer-events-none mb-8">
                    <div className="text-center">
                        <div className="text-xs text-slate-400 font-bold">총 </div>
                        <div className="text-xl font-black text-slate-700">{summary.total}</div>
                    </div>
                 </div>
            </div>
        </div>

      </div>
    </div>
  );
};

export default DemographicStatsChart;