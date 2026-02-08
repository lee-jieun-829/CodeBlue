import React from 'react';
import { NavLink } from 'react-router-dom';
// 아이콘이 바로 보이도록 lucide-react 아이콘을 사용했습니다.
import { 
  LayoutDashboard, Stethoscope, Bed, Users, FileText, Package, 
  Folder, Megaphone, Calendar, MessageSquare 
} from 'lucide-react';

const Sidebar = () => {
  return (
    // 하단이 잘리지 않고 스크롤이 생기도록 함.
    <aside className="sidebar sidebar-vertical w-64 h-[calc(100vh-4rem)] bg-white border-r border-slate-200 fixed left-0 top-16 z-40 overflow-y-auto">
      <nav className="gnb sidebar-nav p-4">
        
        {/* --- 그룹 1: 업무 영역 --- */}
        <div className="sidebar-nav-group flex flex-col gap-1 mb-6">
          
          <NavLink 
            to="/dashboard" 
            className={({ isActive }) => 
              `gnb-item sidebar-nav-item flex items-center gap-3 p-3 rounded-lg transition-colors ${
                isActive ? 'bg-blue-50 text-blue-600 font-bold' : 'text-slate-600 hover:bg-slate-50'
              }`
            }
          >
            <LayoutDashboard size={20} />
            <span className="sidebar-nav-label text-sm">대시보드</span>
          </NavLink>
          
          <NavLink 
            to="/nurse/outpatientnurse" 
            className={({ isActive }) => 
              `gnb-item sidebar-nav-item flex items-center gap-3 p-3 rounded-lg transition-colors ${
                isActive ? 'bg-blue-50 text-blue-600 font-bold' : 'text-slate-600 hover:bg-slate-50'
              }`
            }
          >
            <Stethoscope size={20} />
            <span className="sidebar-nav-label text-sm">외래 진료</span>
          </NavLink>

          <NavLink 
            to="/nurse/inpatientnurse" 
            className={({ isActive }) => 
              `gnb-item sidebar-nav-item flex items-center gap-3 p-3 rounded-lg transition-colors ${
                isActive ? 'bg-blue-50 text-blue-600 font-bold' : 'text-slate-600 hover:bg-slate-50'
              }`
            }
          >
            <Bed size={20} />
            <span className="sidebar-nav-label text-sm">입원 진료</span>
          </NavLink>
          
          <NavLink 
            to="/consultation/main" 
            className={({ isActive }) => 
              `gnb-item sidebar-nav-item flex items-center gap-3 p-3 rounded-lg transition-colors ${
                isActive ? 'bg-blue-50 text-blue-600 font-bold' : 'text-slate-600 hover:bg-slate-50'
              }`
            }
          >
            <Users size={20} />
            <span className="sidebar-nav-label text-sm">협진</span>
          </NavLink>
          
          <NavLink 
            to="/certificate/main" 
            className={({ isActive }) => 
              `gnb-item sidebar-nav-item flex items-center gap-3 p-3 rounded-lg transition-colors ${
                isActive ? 'bg-blue-50 text-blue-600 font-bold' : 'text-slate-600 hover:bg-slate-50'
              }`
            }
          >
            <FileText size={20} />
            <span className="sidebar-nav-label text-sm">환자 서류</span>
          </NavLink>
          
          <NavLink 
            to="/order/drug" 
            className={({ isActive }) => 
              `gnb-item sidebar-nav-item flex items-center gap-3 p-3 rounded-lg transition-colors ${
                isActive ? 'bg-blue-50 text-blue-600 font-bold' : 'text-slate-600 hover:bg-slate-50'
              }`
            }
          >
            <Package size={20} />
            <span className="sidebar-nav-label text-sm">물품 발주</span>
          </NavLink>
          
          <NavLink 
            to="/myorder" 
            className={({ isActive }) => 
              `gnb-item sidebar-nav-item flex items-center gap-3 p-3 rounded-lg transition-colors ${
                isActive ? 'bg-blue-50 text-blue-600 font-bold' : 'text-slate-600 hover:bg-slate-50'
              }`
            }
          >
            <Folder size={20} />
            <span className="sidebar-nav-label text-sm">나의 오더</span>
          </NavLink>

        </div>

        {/* --- 그룹 2: 일반 영역 --- */}
        <div className="sidebar-nav-group flex flex-col gap-1">
            <NavLink 
              to="/notice/list" 
              className={({ isActive }) => 
                `gnb-item sidebar-nav-item flex items-center gap-3 p-3 rounded-lg transition-colors ${
                  isActive ? 'bg-blue-50 text-blue-600 font-bold' : 'text-slate-600 hover:bg-slate-50'
                }`
              }
            >
                <Megaphone size={20} />
                <span className="sidebar-nav-label text-sm">공지사항</span>
            </NavLink>
            
            <NavLink 
              to="/calendar" 
              className={({ isActive }) => 
                `gnb-item sidebar-nav-item flex items-center gap-3 p-3 rounded-lg transition-colors ${
                  isActive ? 'bg-blue-50 text-blue-600 font-bold' : 'text-slate-600 hover:bg-slate-50'
                }`
              }
            >
                <Calendar size={20} />
                <span className="sidebar-nav-label text-sm">일정</span>
            </NavLink>
            
            <NavLink 
              to="/messenger" 
              className={({ isActive }) => 
                `gnb-item sidebar-nav-item unique-item flex items-center gap-3 p-3 rounded-lg transition-colors ${
                  isActive ? 'bg-blue-50 text-blue-600 font-bold' : 'text-slate-600 hover:bg-slate-50'
                }`
              }
            >
                <MessageSquare size={20} />
                <span className="sidebar-nav-label text-sm">메신저</span>
            </NavLink>
        </div>
      </nav>
    </aside>
  );
};

export default Sidebar;