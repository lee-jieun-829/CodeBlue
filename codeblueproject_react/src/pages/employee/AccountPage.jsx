import React, { useEffect, useRef, useState } from 'react'
import * as API from '../../api/accountApi.js';

import Header from "../../components/layout/Header.jsx";
import LeftAdmin from "../../components/layout/LeftAdmin.jsx";

import AccountManager from '../../features/employee/AccountManager';

function AccountPage() {
    
    return (
      <div className="app h-screen w-full flex flex-col bg-neutral-100 text-zinc-950 font-['Pretendard']">

        {/* --- 헤더 --- */}
        <header className='h-16 w-full bg-white border-b border-neutral-200 shrink-0'>
          <Header />
        </header>

        <div className="main-container body flex flex-1  overflow-hidden">
          {/* --- 사이드바 --- */}
          
            <LeftAdmin />
         

          {/* --- 메인 콘텐츠 --- */}
          <main className="main flex-1 overflow-hidden flex flex-col p-4">
            <AccountManager />
          </main>
        </div>
      </div>
    );
};

export default AccountPage;