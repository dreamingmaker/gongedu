#!/bin/bash
set -e
cd "$(dirname "$0")"

echo "=========================================="
echo "  GongEdu 설치"
echo "=========================================="
echo

# 1. .env 파일 생성
echo "[1/4] 환경 변수 설정"
echo "------------------------------------------"

SKIP_ENV=0
if [ -f "backend/.env" ]; then
    echo "기존 .env 파일이 감지되었습니다."
    read -p "덮어쓰시겠습니까? (y/n): " OVERWRITE
    if [ "${OVERWRITE}" != "y" ] && [ "${OVERWRITE}" != "Y" ]; then
        echo "설정을 건너뜁니다."
        SKIP_ENV=1
    fi
fi

if [ "${SKIP_ENV}" -eq 0 ]; then
    while true; do
        read -p "JWT 시크릿 키를 입력하세요 (필수): " INPUT_SECRET
        if [ -n "${INPUT_SECRET}" ]; then
            break
        fi
        echo "JWT 시크릿 키는 필수입니다."
    done

    cat > backend/.env <<EOF
PORT=8180
JWT_SECRET=${INPUT_SECRET}
EOF
    echo ".env 파일이 생성되었습니다."
fi
echo

# 2. DB 디렉토리 초기화
echo "[2/4] DB 디렉토리 초기화..."
if [ ! -d "backend/data" ]; then
    mkdir -p backend/data
    echo "data 디렉토리가 생성되었습니다."
else
    echo "data 디렉토리가 이미 존재합니다."
fi
echo

# 3. 프론트엔드 배포 방식 선택
echo "[3/4] 프론트엔드 배포 방식 선택"
echo "------------------------------------------"
echo "  1) 미리 빌드된 이미지 사용 (권장)"
echo "     npm 환경이 없거나 빌드 오류가 있는 경우 선택하세요."
echo "     GitHub Container Registry에서 이미지를 받아옵니다."
echo
echo "  2) 직접 빌드"
echo "     프론트엔드 소스를 수정하고 커스텀 빌드를 원하는 경우 선택하세요."
echo "     Node.js 및 npm이 설치된 환경에서 빌드합니다."
echo
while true; do
    read -p "선택하세요 (1 또는 2): " FRONTEND_MODE
    if [ "${FRONTEND_MODE}" = "1" ] || [ "${FRONTEND_MODE}" = "2" ]; then
        break
    fi
    echo "1 또는 2를 입력하세요."
done
echo

# 4. Docker Compose 실행
echo "[4/4] 컨테이너 빌드 및 실행 중... (시간이 걸릴 수 있습니다)"

if [ "${FRONTEND_MODE}" = "1" ]; then
    echo "미리 빌드된 이미지를 다운로드합니다..."
    if ! docker compose pull frontend; then
        echo
        echo "[오류] 이미지 다운로드에 실패했습니다. 네트워크 연결을 확인하세요."
        exit 1
    fi
    if ! docker compose up -d; then
        echo
        echo "[오류] Docker 실행에 실패했습니다. Docker가 설치되어 있는지 확인하세요."
        exit 1
    fi
else
    echo "프론트엔드를 직접 빌드합니다..."
    if ! docker compose -f docker-compose.yml -f docker-compose.build.yml up -d --build; then
        echo
        echo "[오류] Docker 빌드에 실패했습니다."
        echo "npm 빌드 오류가 발생한 경우 옵션 1(미리 빌드된 이미지)을 사용해보세요."
        exit 1
    fi
fi

echo
echo "=========================================="
echo "  설치가 완료되었습니다."
echo "  브라우저에서 http://서버IP:3396 로 접속하세요."
echo "=========================================="
