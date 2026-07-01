@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ==========================================
echo   GongEdu 설치
echo ==========================================
echo.

:: 1. .env 파일 생성
echo [1/4] 환경 변수 설정
echo ------------------------------------------

if exist "backend\.env" (
    echo 기존 .env 파일이 감지되었습니다.
    set /p OVERWRITE="덮어쓰시겠습니까? (y/n): "
    if /i not "%OVERWRITE%"=="y" goto SKIP_ENV
)

:INPUT_SECRET
set /p INPUT_SECRET="JWT 시크릿 키를 입력하세요 (필수): "
if "%INPUT_SECRET%"=="" (
    echo JWT 시크릿 키는 필수입니다.
    goto INPUT_SECRET
)

(
    echo PORT=8180
    echo JWT_SECRET=%INPUT_SECRET%
) > backend\.env
echo .env 파일이 생성되었습니다.

:SKIP_ENV
echo.

:: 2. DB 디렉토리 초기화
echo [2/4] DB 디렉토리 초기화...
if not exist "backend\data" (
    mkdir backend\data
    echo data 디렉토리가 생성되었습니다.
) else (
    echo data 디렉토리가 이미 존재합니다.
)
echo.

:: 3. 프론트엔드 배포 방식 선택
echo [3/4] 프론트엔드 배포 방식 선택
echo ------------------------------------------
echo   1) 미리 빌드된 이미지 사용 (권장)
echo      npm 환경이 없거나 빌드 오류가 있는 경우 선택하세요.
echo      GitHub Container Registry에서 이미지를 받아옵니다.
echo.
echo   2) 직접 빌드
echo      프론트엔드 소스를 수정하고 커스텀 빌드를 원하는 경우 선택하세요.
echo      Node.js 및 npm이 설치된 환경에서 빌드합니다.
echo.

:INPUT_MODE
set /p FRONTEND_MODE="선택하세요 (1 또는 2): "
if "%FRONTEND_MODE%"=="1" goto MODE_SELECTED
if "%FRONTEND_MODE%"=="2" goto MODE_SELECTED
echo 1 또는 2를 입력하세요.
goto INPUT_MODE

:MODE_SELECTED
echo.

:: 4. Docker Compose 실행
echo [4/4] 컨테이너 빌드 및 실행 중... (시간이 걸릴 수 있습니다)

if "%FRONTEND_MODE%"=="1" (
    echo 미리 빌드된 이미지를 다운로드합니다...
    docker compose pull frontend
    if errorlevel 1 (
        echo.
        echo [오류] 이미지 다운로드에 실패했습니다. 네트워크 연결을 확인하세요.
        pause
        exit /b 1
    )
    docker compose up -d
    if errorlevel 1 (
        echo.
        echo [오류] Docker 실행에 실패했습니다. Docker가 설치되어 있는지 확인하세요.
        pause
        exit /b 1
    )
) else (
    echo 프론트엔드를 직접 빌드합니다...
    docker compose -f docker-compose.yml -f docker-compose.build.yml up -d --build
    if errorlevel 1 (
        echo.
        echo [오류] Docker 빌드에 실패했습니다.
        echo npm 빌드 오류가 발생한 경우 옵션 1(미리 빌드된 이미지)을 사용해보세요.
        pause
        exit /b 1
    )
)

echo.
echo ==========================================
echo   설치가 완료되었습니다.
echo   브라우저에서 http://localhost:3396 로 접속하세요.
echo ==========================================
pause
