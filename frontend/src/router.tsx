import { createBrowserRouter } from "react-router-dom";
import Layout from "./components/Layout";
import ProtectedRoute from "./components/ProtectedRoute";
import LoginPage from "./pages/LoginPage";
import MainPage from "./pages/MainPage";
import AdminUserPage from "./pages/AdminUserPage";
import SettingPage from "./pages/SettingPage";
import ErrorPage from "./pages/ErrorPage";

const router = createBrowserRouter([
  {
    path: "/login",
    element: <LoginPage />,
    errorElement: <ErrorPage />,
  },
  {
    path: "/",
    element: <Layout />, // 상단 헤더 포함
    errorElement: <ErrorPage />,
    children: [
      // 로그인한 사용자만 접근 가능
      {
        element: <ProtectedRoute />,
        children: [
          { index: true, element: <MainPage /> }, // 메인(교육목록)
        ],
      },
      // 관리자만 접근 가능 (Admin Route)
      {
        path: "admin",
        element: <ProtectedRoute requireAdmin={true} />,
        children: [
          { path: "users", element: <AdminUserPage /> },
          { path: "settings", element: <SettingPage /> },
        ],
      },
    ],
  },
]);

export default router;
