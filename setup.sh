#!/bin/bash
set -e

cd "$(dirname "$0")"

echo "=========================================="
echo "  교육이수 관리시스템 초기 설정"
echo "=========================================="
echo

# 1. Frontend npm install
echo "[1/3] 프론트엔드 패키지 설치 중..."
cd frontend
npm install
echo "프론트엔드 패키지 설치 완료."
echo
cd ..

# 2. Backend npm install
echo "[2/3] 백엔드 패키지 설치 중..."
cd backend
npm install
echo "백엔드 패키지 설치 완료."
echo
cd ..

# 3. .env 파일 생성
echo "[3/3] 환경 변수 설정"
echo "------------------------------------------"

if [ -f "backend/.env" ]; then
    echo "기존 .env 파일이 감지되었습니다."
    read -p "덮어쓰시겠습니까? (y/n): " OVERWRITE
    if [ "${OVERWRITE}" != "y" ] && [ "${OVERWRITE}" != "Y" ]; then
        echo "설정을 건너뜁니다."
        goto_done=1
    fi
fi

if [ -z "${goto_done}" ]; then
    # PORT 입력 (기본값 8180)
    PORT_DEFAULT=8180
    read -p "서버 포트를 입력하세요 (기본값: ${PORT_DEFAULT}): " INPUT_PORT
    INPUT_PORT="${INPUT_PORT:-$PORT_DEFAULT}"

    # JWT_SECRET 입력
    while true; do
        read -p "JWT 시크릿 키를 입력하세요 (필수): " INPUT_SECRET
        if [ -n "${INPUT_SECRET}" ]; then
            break
        fi
        echo "JWT 시크릿 키는 필수입니다. 다시 입력해주세요."
    done

    # .env 파일 작성
    cat > backend/.env <<EOF
PORT=${INPUT_PORT}
JWT_SECRET=${INPUT_SECRET}
EOF

    echo ".env 파일이 생성되었습니다."
fi

echo
echo "=========================================="
echo "  설정이 완료되었습니다."
echo "  백엔드 실행: cd backend && npm start"
echo "  프론트엔드 빌드: cd frontend && npm run build"
echo "=========================================="
