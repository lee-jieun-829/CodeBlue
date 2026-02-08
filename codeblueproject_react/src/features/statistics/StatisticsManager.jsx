import React, { useState, useMemo, useEffect } from 'react';
import {
  Chart as ChartJS,
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  RadialLinearScale, // PolarArea 필수
  Title,
  Tooltip,
  Legend,
  Filler,
  LineController,
  BarController,
  PolarAreaController // PolarArea 필수
} from 'chart.js';
// 🛑 [수정됨] 여기에 PolarArea가 빠져있었습니다. 추가했습니다.
import { Bar, Doughnut, PolarArea, Line, Chart } from 'react-chartjs-2';

// Chart.js 등록
ChartJS.register(
  CategoryScale,
  LinearScale,
  PointElement,
  LineElement,
  BarElement,
  ArcElement,
  RadialLinearScale,
  Title,
  Tooltip,
  Legend,
  Filler,
  LineController,
  BarController,
  PolarAreaController
);

// 🛑 [날짜 컨트롤러] 
// 2026-01-29 : 리허설
// 2026-02-03 : 발표당일
const CURRENT_DATE_SIMULATION = '2026-01-31'; 

// --- [Master DB] ---
const DAILY_DATA = {
  '2025-12': {
    rev: [1600, 1800, 1500, 1300, 1900, 600, 0, 1700, 1850, 1600, 1500, 2000, 650, 0, 1650, 1800, 1550, 1400, 1950, 700, 0, 1750, 1900, 1700, 1600, 2100, 600, 0, 1700, 1800, 1600],
    pat: [70, 80, 65, 55, 85, 30, 0, 75, 82, 70, 65, 90, 35, 0, 72, 80, 68, 60, 88, 38, 0, 78, 85, 75, 70, 95, 30, 0, 75, 80, 70],
    revisitRate: 75.5
  },
  '2026-01': {
    rev: [1700, 1900, 1600, 1400, 2000, 700, 0, 1800, 1950, 1700, 1600, 2100, 750, 0, 1750, 1900, 1650, 1500, 2050, 800, 0, 1850, 2000, 1800, 1700, 0, 2200, 1800, 1950, 2100, 1600],
    pat: [75, 85, 70, 60, 90, 35, 0, 80, 88, 75, 70, 95, 40, 0, 78, 85, 72, 65, 92, 42, 0, 82, 90, 80, 75, 0, 100, 80, 88, 92, 70],
    revisitRate: 78.2
  },
  '2026-02': {
    // 2/3 데이터 정상값 입력 -> 로직이 알아서 20%만 반영함 (오전 10시 기준)
    rev: [0, 2300, 1900, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    pat: [0, 110, 85, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    revisitRate: 81.5
  }
};

// [비율 설정]
const RATIOS = {
  doctors: [0.35, 0.25, 0.15, 0.15, 0.10], 
  ages: [0.05, 0.15, 0.20, 0.35, 0.25],    
  diagnosis: [0.25, 0.20, 0.15, 0.10, 0.05], 
  exam: [30, 20, 15, 25, 10] 
};

const StatisticsManager = () => {
  const today = new Date(CURRENT_DATE_SIMULATION);
  const currentYear = today.getFullYear();
  const currentMonth = today.getMonth() + 1;
  const currentDay = today.getDate();
  const currentKey = `${currentYear}-${String(currentMonth).padStart(2, '0')}`;

  const availableMonths = useMemo(() => {
    const allMonths = ['2026-02', '2026-01', '2025-12'];
    return allMonths.filter(m => m <= currentKey);
  }, [currentKey]);

  const [yearMonth, setYearMonth] = useState(availableMonths[0]);
  const [patientTab, setPatientTab] = useState('all');

  useEffect(() => { setYearMonth(availableMonths[0]); }, [availableMonths]);

  // --- [데이터 계산] ---
  const data = useMemo(() => {
    const raw = DAILY_DATA[yearMonth];
    if (!raw) return null;

    const isCurrentMonth = yearMonth === currentKey;
    const daysPassed = isCurrentMonth ? currentDay : raw.rev.length;

    // 1. 일별 데이터 가공
    const dailyRev = raw.rev.map((v, i) => {
        if (!isCurrentMonth) return v;
        if (i + 1 > currentDay) return null; 
        if (i + 1 === currentDay) return Math.floor(v * 0.2); 
        return v;
    });

    const dailyPat = raw.pat.map((v, i) => {
        if (!isCurrentMonth) return v;
        if (i + 1 > currentDay) return null;
        if (i + 1 === currentDay) return Math.floor(v * 0.2);
        return v;
    });

    // 2. 누적 매출 계산
    let cumulativeSum = 0;
    const cumulativeRev = dailyRev.map(v => {
        if (v === null) return null;
        cumulativeSum += v;
        return cumulativeSum;
    });

    const totalRevenue = dailyRev.reduce((acc, v) => acc + (v || 0), 0);
    const totalPatients = dailyPat.reduce((acc, v) => acc + (v || 0), 0);

    const doctorStats = RATIOS.doctors.map(r => Math.floor(totalRevenue * r));
    const ageStats = RATIOS.ages.map(r => Math.floor(totalPatients * r));
    const diagnosisStats = [
        {c:'S52(골절)', v: Math.floor(totalPatients * 0.25)},
        {c:'M545(요통)', v: Math.floor(totalPatients * 0.20)},
        {c:'M17(무릎)', v: Math.floor(totalPatients * 0.15)},
        {c:'S934(염좌)', v: Math.floor(totalPatients * 0.12)},
        {c:'M75(어깨)', v: Math.floor(totalPatients * 0.08)},
    ];
    const drugStats = [
        {n:'오팔몬정', v: Math.floor(totalRevenue * 0.08)},
        {n:'프롤로주사', v: Math.floor(totalRevenue * 0.07)},
        {n:'세레브렉스', v: Math.floor(totalRevenue * 0.04)},
        {n:'리리카캡슐', v: Math.floor(totalRevenue * 0.03)},
        {n:'울트라셋', v: Math.floor(totalRevenue * 0.02)},
    ];

    return {
        dailyRev, dailyPat, cumulativeRev,
        revenue: totalRevenue,
        patients: totalPatients,
        doctors: doctorStats,
        ages: ageStats,
        diagnosis: diagnosisStats,
        drugs: drugStats,
        daysPassed,
        isLive: isCurrentMonth,
        revisitRate: raw.revisitRate,
        exam: RATIOS.exam,
        ptStats: [35, 25, 15, 15, 10]
    };
  }, [yearMonth, currentKey, currentDay]);

  const topPatients = {
    all: [
      { name: '황영수', age: 72, amount: Math.floor(data?.revenue * 0.05 * 10000), count: 5, type: '수술/입원', lastVisit: '2일 전' },
      { name: '김철수', age: 45, amount: Math.floor(data?.revenue * 0.03 * 10000), count: 12, type: '도수치료', lastVisit: '오늘' },
      { name: '이영희', age: 62, amount: Math.floor(data?.revenue * 0.02 * 10000), count: 8, type: 'MRI/시술', lastVisit: '1주 전' },
      { name: '박민수', age: 29, amount: Math.floor(data?.revenue * 0.015 * 10000), count: 18, type: '자보입원', lastVisit: '3일 전' },
      { name: '최자영', age: 55, amount: Math.floor(data?.revenue * 0.01 * 10000), count: 10, type: '체외충격파', lastVisit: '어제' },
    ],
    out: [
        { name: '김철수', age: 45, amount: Math.floor(data?.revenue * 0.03 * 10000), count: 12, type: '도수치료', lastVisit: '오늘' },
        { name: '최자영', age: 55, amount: Math.floor(data?.revenue * 0.01 * 10000), count: 10, type: '체외충격파', lastVisit: '어제' },
        { name: '한지민', age: 28, amount: Math.floor(data?.revenue * 0.005 * 10000), count: 4, type: 'X-ray/진료', lastVisit: '2주 전' },
    ],
    in: [
        { name: '황영수', age: 72, amount: Math.floor(data?.revenue * 0.05 * 10000), count: 5, type: '수술/입원', lastVisit: '재원중' },
        { name: '박민수', age: 29, amount: Math.floor(data?.revenue * 0.015 * 10000), count: 18, type: '교통사고', lastVisit: '재원중' },
    ]
  };
  const currentTopList = (topPatients[patientTab] && topPatients[patientTab].length > 0) ? topPatients[patientTab] : topPatients['all'];

  // --- 차트 옵션 ---
  const mainChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { 
        legend: { display: false },
        tooltip: {
            mode: 'index',
            intersect: false,
            backgroundColor: 'rgba(30, 41, 59, 0.95)',
            padding: 12,
            titleFont: { size: 13 },
            bodyFont: { size: 12 },
            callbacks: {
                label: (context) => {
                    let label = context.dataset.label || '';
                    if (label) label += ': ';
                    if (context.parsed.y !== null) label += context.parsed.y.toLocaleString();
                    if (context.dataset.yAxisID === 'y') label += ' 만원';
                    if (context.dataset.yAxisID === 'y2') label += ' 만원 (누적)';
                    if (context.dataset.yAxisID === 'y1') label += ' 명';
                    return label;
                }
            }
        }
    },
    scales: { 
      x: { grid: { display: false }, ticks: { font: { size: 11 }, color: '#94a3b8' } }, 
      y: { 
          type: 'linear', display: true, position: 'left',
          grid: { borderDash: [4, 4], color: '#f1f5f9' }, 
          ticks: { callback: (v) => v/10000 + '억', font: { size: 10 }, color: '#94a3b8' } 
      },
      y1: { 
          type: 'linear', display: true, position: 'right',
          grid: { display: false }, ticks: { display: false }, suggestedMax: 150
      },
      y2: { 
          type: 'linear', display: false, position: 'right', grid: { display: false }, beginAtZero: true
      }
    }
  };

  const simpleChartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } },
    scales: { x: { display: false }, y: { display: false } }
  };

  if (!data) return <div className="p-10 text-slate-500">데이터 처리 중...</div>;

  return (
    <div className="w-full h-full bg-slate-50 p-6 overflow-y-auto font-sans pb-24">
      
      {/* Header */}
      <div className="flex flex-col md:flex-row justify-between items-center mb-8 gap-4">
        <div>
          <h1 className="text-2xl font-bold text-slate-800 flex items-center gap-2">
             <span className="w-2 h-8 bg-indigo-600 rounded-full"></span> 
             SB 정형외과
          </h1>
          <p className="text-xs text-slate-500 mt-1 pl-4 font-medium tracking-wide flex items-center gap-2">
             {data.isLive ? (
                 <><span className="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span> 실시간 데이터 ({today.toLocaleDateString()})</>
             ) : (
                 <><span className="w-2 h-2 rounded-full bg-slate-400"></span> 과거 데이터 (마감)</>
             )}
          </p>
        </div>
        <div className="flex items-center bg-white border border-slate-200 rounded-xl px-2 py-1 shadow-sm hover:shadow-md transition-shadow">
          <select 
            value={yearMonth} 
            onChange={(e) => setYearMonth(e.target.value)}
            className="bg-transparent text-sm font-bold text-slate-700 px-4 py-2 outline-none cursor-pointer"
          >
            {availableMonths.map(month => (
                <option key={month} value={month}>
                    {month.split('-')[0]}년 {month.split('-')[1]}월 {month === currentKey ? '(Current)' : ''}
                </option>
            ))}
          </select>
        </div>
      </div>

      {/* KPI Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <KPICard title="월 누적 매출" value={data.revenue.toLocaleString()} unit="만원" subText={data.isLive ? "집계 진행 중" : "목표 달성"} color="indigo" icon="money" />
        <KPICard title="월 누적 환자" value={data.patients.toLocaleString()} unit="명" subText={`일 평균 ${Math.floor(data.patients / (data.daysPassed||1))}명`} color="blue" icon="users" />
        <KPICard title="재방문율" value={data.revisitRate} unit="%" subText="충성 고객 비율" color="emerald" icon="repeat" />
        <KPICard title="일 평균 매출" value={Math.floor(data.revenue / (data.daysPassed||1)).toLocaleString()} unit="만원" subText="객단가 14만원선" color="rose" icon="chart" />
      </div>

      {/* Main Charts */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6 mb-6">
        
        {/* Main Trend (3-Axis Combo) */}
        <div className="xl:col-span-2 bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
             <div className="flex justify-between items-center mb-6">
                <h3 className="text-base font-bold text-slate-800">매출 및 환자 추이 (누적 포함)</h3>
                <div className="flex gap-4">
                    <span className="text-xs font-bold text-slate-500 flex items-center gap-1"><span className="w-3 h-1 bg-emerald-400 rounded-full"></span>누적매출</span>
                    <span className="text-xs font-bold text-slate-500 flex items-center gap-1"><span className="w-3 h-3 rounded-full bg-indigo-500"></span>일매출</span>
                    <span className="text-xs font-bold text-slate-500 flex items-center gap-1"><span className="w-3 h-3 rounded-full bg-amber-400"></span>환자수</span>
                </div>
            </div>
            <div className="h-72">
                 <Chart 
                    type='bar'
                    data={{
                        labels: Array.from({length: data.dailyRev.length}, (_,i)=>`${i+1}`),
                        datasets: [
                            {
                                type: 'line',
                                label: '누적 매출',
                                data: data.cumulativeRev,
                                borderColor: '#10b981',
                                backgroundColor: 'rgba(16, 185, 129, 0.1)',
                                borderWidth: 2,
                                pointRadius: 0,
                                fill: true,
                                tension: 0.4,
                                yAxisID: 'y2',
                                order: 1
                            },
                            {
                                type: 'line',
                                label: '환자수',
                                data: data.dailyPat,
                                borderColor: '#fbbf24',
                                borderWidth: 3,
                                pointRadius: data.isLive ? 2 : 0, 
                                tension: 0.3,
                                yAxisID: 'y1',
                                order: 2
                            },
                            {
                                type: 'bar',
                                label: '일 매출',
                                data: data.dailyRev,
                                backgroundColor: '#6366f1',
                                borderRadius: 4,
                                barThickness: 10,
                                yAxisID: 'y',
                                order: 3
                            }
                        ]
                    }}
                    options={mainChartOptions}
                />
            </div>
        </div>

        {/* Doctor Performance */}
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
            <h3 className="text-base font-bold text-slate-800 mb-2">의료진 매출 기여도</h3>
            <p className="text-xs text-slate-400 mb-4 text-right">단위: 만원</p>
            <div className="h-72">
                <Chart 
                    type='bar'
                    data={{
                        labels: ['박정민', '최성훈', '강신성', '이철희', '김경희'],
                        datasets: [{
                            label: '매출',
                            data: data.doctors,
                            backgroundColor: [ '#6366f1', '#8b5cf6', '#a855f7', '#d946ef', '#ec4899' ],
                            borderRadius: 6,
                            barThickness: 30
                        }]
                    }}
                    options={{
                        ...simpleChartOptions,
                        scales: { 
                            y: { grid: { borderDash: [4, 4], color: '#f1f5f9' }, ticks: { font: {size: 11}, color: '#94a3b8' } },
                            x: { grid: { display: false }, ticks: { font: {size: 11, weight: 'bold'}, color: '#64748b' } }
                        }
                    }}
                />
            </div>
        </div>
      </div>

      {/* Middle Charts */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mb-6">
        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
             <h3 className="text-base font-bold text-slate-800 mb-4">물리치료 유형</h3>
             <div className="h-56 relative flex justify-center">
                <PolarArea 
                    data={{
                        labels: ['도수', '충격파', '견인', '열전기', '레이저'],
                        datasets: [{
                            data: data.ptStats,
                            backgroundColor: ['#6366f190', '#10b98190', '#f59e0b90', '#ef444490', '#8b5cf690'],
                            borderWidth: 0
                        }]
                    }}
                    options={{ maintainAspectRatio: false, scales: { r: { ticks: { display: false, backdropColor: 'transparent' }, grid: { color: '#e2e8f0' } } }, plugins: { legend: { position: 'right', labels: { boxWidth: 10, font: {size: 11} } } } }}
                />
             </div>
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
            <h3 className="text-base font-bold text-slate-800 mb-5">다빈도 상병 Top 5</h3>
            <div className="space-y-4 text-sm">
                 {data.diagnosis.map((d, i) => (
                    <div key={i} className="flex justify-between items-center">
                        <div className="flex items-center gap-3">
                            <span className={`w-6 h-6 rounded flex items-center justify-center text-xs font-bold text-white ${i===0 ? 'bg-indigo-500' : 'bg-slate-300'}`}>{i+1}</span>
                            <span className="font-bold text-slate-600">{d.c}</span>
                        </div>
                        <span className="font-bold text-slate-800 bg-slate-100 px-2 py-0.5 rounded text-xs">{d.v}건</span>
                    </div>
                ))}
            </div>
        </div>

        <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
            <h3 className="text-base font-bold text-slate-800 mb-2">연령대 분포</h3>
            <p className="text-xs text-slate-400 mb-2 text-right">단위: 명</p>
            <div className="h-52">
                 <Chart 
                    type='bar'
                    data={{
                        labels: ['10대', '2030', '4050', '6070', '80+'],
                        datasets: [{
                            label: '환자 수',
                            data: data.ages,
                            backgroundColor: '#10b981', barThickness: 24, borderRadius: 4
                        }]
                    }}
                    options={{
                        ...simpleChartOptions,
                        scales: {
                            y: { grid: { borderDash: [4, 4], color: '#f1f5f9' }, ticks: { font: {size: 10}, color: '#94a3b8' } },
                            x: { grid: { display: false }, ticks: { font: {size: 10}, color: '#64748b' } }
                        }
                    }}
                />
            </div>
        </div>
      </div>

      {/* Top Patient Table */}
      <div className="bg-white rounded-2xl p-6 shadow-sm border border-slate-100">
          <div className="flex justify-between items-center mb-6">
                <h3 className="text-base font-bold text-slate-800">
                    상위 매출 환자 현황
                </h3>
{/*                 <div className="flex bg-slate-100 p-1 rounded-lg">
                    {['all', 'out', 'in'].map(tab => (
                        <button key={tab} onClick={() => setPatientTab(tab)} className={`px-4 py-1.5 text-xs font-bold rounded-md transition-all ${patientTab === tab ? 'bg-white text-indigo-600 shadow-sm' : 'text-slate-500'}`}>{tab === 'all' ? '전체' : tab === 'out' ? '외래' : '입원'}</button>
                    ))}
                </div> */}
            </div>
            <div className="overflow-x-auto">
                <table className="w-full text-sm text-left border-collapse">
                    <thead>
                        <tr className="text-slate-400 border-b border-slate-100 text-xs uppercase tracking-wider">
                            <th className="py-3 px-4 font-semibold w-16 text-center">Rank</th>
                            <th className="py-3 px-4 font-semibold">성명</th>
                            <th className="py-3 px-4 font-semibold">나이</th>
                            <th className="py-3 px-4 font-semibold">주요 진료</th>
                            <th className="py-3 px-4 font-semibold">내원 횟수</th>
                            <th className="py-3 px-4 font-semibold">최근 방문</th>
                            <th className="py-3 px-4 font-semibold text-right">총 결제액</th>
                        </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-50">
                        {currentTopList.map((p, idx) => (
                            <tr key={idx} className="hover:bg-slate-50 transition-colors group">
                                <td className="py-3 px-4 text-center"><span className={`w-6 h-6 flex items-center justify-center rounded-full text-xs font-bold ${idx === 0 ? 'bg-amber-100 text-amber-600' : 'bg-slate-100 text-slate-400'}`}>{idx+1}</span></td>
                                <td className="py-3 px-4 font-bold text-slate-700">{p.name}</td>
                                <td className="py-3 px-4 text-slate-500">{p.age}세</td>
                                <td className="py-3 px-4"><span className={`px-2 py-1 rounded text-xs font-bold bg-slate-100 text-slate-600`}>{p.type}</span></td>
                                <td className="py-3 px-4 text-slate-500 font-medium">{p.count}회</td>
                                <td className="py-3 px-4 text-slate-500 text-xs">{p.lastVisit}</td>
                                <td className="py-3 px-4 text-right font-bold text-slate-800">{p.amount.toLocaleString()} 원</td>
                            </tr>
                        ))}
                    </tbody>
                </table>
            </div>
      </div>
    </div>
  );
};

const KPICard = ({ title, value, unit, subText, color, icon }) => (
    <div className="bg-white p-6 rounded-2xl shadow-sm border border-slate-100 relative overflow-hidden">
        <div className={`absolute -right-4 -top-4 w-24 h-24 bg-${color}-50 rounded-full opacity-50`}></div>
        <div className="relative z-10 flex justify-between items-start">
            <div>
                <p className="text-slate-500 text-xs font-bold uppercase tracking-wide">{title}</p>
                <div className="flex items-baseline gap-1 mt-2">
                    <h3 className="text-2xl font-extrabold text-slate-800">{value}</h3>
                    <span className="text-sm font-bold text-slate-400">{unit}</span>
                </div>
                <p className={`text-xs font-bold mt-3 flex items-center gap-1 ${subText.includes('▲') ? 'text-emerald-500' : 'text-slate-400'}`}>{subText}</p>
            </div>
            <div className={`w-12 h-12 rounded-xl bg-${color}-50 text-${color}-500 flex items-center justify-center shadow-sm`}>
                <span className="font-bold text-lg">{icon === 'money' ? '₩' : icon === 'users' ? 'Ω' : icon}</span>
            </div>
        </div>
    </div>
);

export default StatisticsManager;