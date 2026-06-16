import {
  useRouteError,
  isRouteErrorResponse,
  useNavigate,
} from "react-router-dom";

const ErrorPage = () => {
  const error = useRouteError();
  const navigate = useNavigate();

  let errorMessage = "알 수 없는 오류가 발생했습니다.";

  if (isRouteErrorResponse(error)) {
    switch (error.status) {
      case 404:
        errorMessage = "페이지를 찾을 수 없습니다.";
        break;
      case 401:
        errorMessage = "접근 권한이 없습니다.";
        break;
      default:
        errorMessage = error.statusText || errorMessage;
    }
  } else if (error instanceof Error) {
    errorMessage = error.message;
  }

  return (
    <div className="flex flex-col items-center justify-center h-screen bg-gray-100 dark:bg-gray-900 text-gray-800 dark:text-gray-200">
      <h1 className="text-4xl font-bold mb-4 text-red-500">Oops!</h1>
      <p className="text-xl mb-8">{errorMessage}</p>
      <div className="flex gap-4">
        <button
          onClick={() => navigate(-1)}
          className="px-4 py-2 bg-gray-200 dark:bg-gray-700 rounded hover:bg-gray-300 dark:hover:bg-gray-600 transition"
        >
          뒤로 가기
        </button>
        <button
          onClick={() => navigate("/")}
          className="px-4 py-2 bg-indigo-600 text-white rounded hover:bg-indigo-700 transition"
        >
          메인으로 이동
        </button>
      </div>
    </div>
  );
};

export default ErrorPage;
