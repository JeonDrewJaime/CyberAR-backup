import { useContext, useState } from 'react'
import './App.css'
import { AuthContext } from './auth/AuthContext';
import { Navigate, Route, Routes } from 'react-router-dom';
import { Landing } from './routes/Landing';
import { Login } from './routes/Login';
import { About } from './routes/About';
import { Contact } from './routes/Contact';
import { Users } from './routes/admin/Users';
import { Dashboard } from './routes/admin/Dashboard';
import { Assessments } from './routes/admin/Assessments';
import { Achievements } from './routes/admin/Achievements';
import Modules from './routes/admin/Modules';
import { NotFound } from './routes/NotFound';
import { PrivacyPolicy } from './routes/PrivacyPolicy';
import Sections from './routes/admin/Sections';

function App() {
  const { currentUser } = useContext(AuthContext)

  const RequireAuth = ({ children }) => {
    return currentUser ? children : <Navigate to="/login" />;
  };

  return (
    <Routes>
      {/* Public Routes */}
      <Route path="/">
        <Route index element={<Landing />} />
        <Route path="login" element={<Login />} />
        <Route path="about" element={<About />} />
        <Route path="contact" element={<Contact />} />
        <Route path="privacy" element={<PrivacyPolicy />} />

        {/* Protected Admin Routes */}
        <Route path="admin">
          <Route index element={
            <RequireAuth>
              <Dashboard />
            </RequireAuth>
          } />
          <Route path="modules" element={
            <RequireAuth>
              <Modules />
            </RequireAuth>
          } />
          <Route path="assessments" element={
            <RequireAuth>
              <Assessments />
            </RequireAuth>
          } />
          <Route path="achievements" element={
            <RequireAuth>
              <Achievements />
            </RequireAuth>
          } />
          <Route path="sections" element={
            <RequireAuth>
              <Sections />
            </RequireAuth>
          } />
          <Route path="users" element={
            <RequireAuth>
              <Users />
            </RequireAuth>
          } />
        </Route>
        {/* Protected Teacher Routes */}
        <Route path="teacher">
          <Route index element={
            <RequireAuth>
              <Dashboard />
            </RequireAuth>
          } />
          <Route path="modules" element={
            <RequireAuth>
              <Modules />
            </RequireAuth>
          } />
          <Route path="assessments" element={
            <RequireAuth>
              <Assessments />
            </RequireAuth>
          } />
          <Route path="achievements" element={
            <RequireAuth>
              <Achievements />
            </RequireAuth>
          } />
        </Route>
        <Route path='*' element={<NotFound />} />
      </Route>
    </Routes>
  )
}

export default App
