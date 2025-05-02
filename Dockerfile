# 베이스로 nginx:alpine 사용
FROM nginx:alpine

# 커스텀 웹페이지 복사
COPY index.html /usr/share/nginx/html/index.html

# nginx 기본 포트(80) 그대로 사용
