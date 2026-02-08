import React from 'react'
import Header from '../../components/layout/Header'
import LeftAdmin from '../../components/layout/LeftAdmin'

import StatisticsManager from '../../features/statistics/StatisticsManager'

function StatisticsPage() {
  return (
    <div className="app h-screen w-full flex flex-col bg-neutral-100 text-zinc-950 font-['Pretendard']">

        {/* --- 헤더 --- */}
        <header className='h-16 w-full bg-white border-b border-neutral-200 shrink-0'>
          <Header />
        </header>

        <div className="main-container body flex flex-1 w-full overflow-hidden">
          {/* --- 사이드바 --- */}
          <aside className="side-bar flex w-28 shrink-0 flex-col border-r border-neutral-200 bg-white overflow-y-auto custom-scrollbar">
            <LeftAdmin />
          </aside>

          {/* --- 메인 콘텐츠 --- */}
          <main className="main flex-1 overflow-hidden flex flex-col p-4">
            <StatisticsManager/>
          </main>
        </div>
      </div>
  )
}

export default StatisticsPage