import Dashboard from './pages/Dashboard'
import { Route, Routes } from 'react-router-dom'
import AccountPage from './pages/employee/AccountPage';
import DoctorCalendarPage from './pages/calendar/DoctorCalendarPage';
import DrugPage from './pages/order/DrugPage';
import ProductPage from './pages/order/ProductPage';
import OrdersPage from './pages/order/OrdersPage';
import MacroPage from './pages/macro/MacroPage';
import WaitingList from './pages/patient/WaitingList';
import StatisticsPage from './pages/statistics/StatisticsPage';

function App() {

  return (
    <div className="App">
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/waiting" element={<WaitingList />} />
        <Route path="/admin/employees" element={<AccountPage />} />
        <Route path="/calendar" element={<DoctorCalendarPage />} />   
        <Route path='/admin/drug' element={<DrugPage/>}/>
        <Route path='/admin/product' element={<ProductPage/>}/>
        <Route path='/admin/orders' element={<OrdersPage/>}/>
        <Route path='/admin/macro' element={<MacroPage />}/>
        <Route path='/admin/stats' element={<StatisticsPage />} />


      </Routes>
    </div>
  )
}
export default App