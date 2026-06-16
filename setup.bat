@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ==========================================
echo   교육이수 관리시스템 초기 설정
echo ==========================================
echo.

:: 1. Frontend npm install
echo [1/3] 프론트엔드 패키지 설치 중...
cd frontend
call npm install
if errorlevel 1 (
    echo.
    echo [오류] 프론트엔드 패키지 설치에 실패했습니다.
    pause
    exit /b 1
)
echo 프론트엔드 패키지 설치 완료.
echo.

:: 2. Backend npm install
echo [2/3] 백엔드 패키지 설치 중...
cd ../backend
call npm install
if errorlevel 1 (
    echo.
    echo [오류] 백엔드 패키지 설치에 실패했습니다.
    pause
    exit /b 1
)
echo 백엔드 패키지 설치 완료.
echo.

:: 3. .env 파일 생성
echo [3/3] 환경 변수 설정
echo ------------------------------------------

:: .env 이미 존재하면 덮어쓸지 확인
if exist ".env" (
    echo 기존 .env 파일이 감지되었습니다.
    set /p OVERWRITE="덮어쓰시겠습니까? (y/n): "
    if /i not "%OVERWRITE%"=="y" (
        echo 설정을 건너뜁니다.
        goto DONE
    )
)

:: PORT 입력 (기본값 8180)
set PORT_DEFAULT=8180
set /p INPUT_PORT="서버 포트를 입력하세요 (기본값: %PORT_DEFAULT%): "
if "%INPUT_PORT%"=="" set INPUT_PORT=%PORT_DEFAULT%

:: JWT_SECRET 입력
:INPUT_SECRET
set /p INPUT_SECRET="JWT 시크릿 키를 입력하세요 (필수): "
if "%INPUT_SECRET%"=="" (
    echo JWT 시크릿 키는 필수입니다. 다시 입력해주세요.
    goto INPUT_SECRET
)

:: .env 파일 작성
(
    echo PORT=%INPUT_PORT%
    echo JWT_SECRET=%INPUT_SECRET%
) > .env

echo .env 파일이 생성되었습니다.

:DONE
echo.
echo ==========================================
echo   설정이 완료되었습니다.
echo   이제 start_server.bat 을 실행하세요.
echo ==========================================
pause
