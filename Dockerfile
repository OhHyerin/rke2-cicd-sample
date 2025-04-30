# syntax=docker/dockerfile:1
FROM alpine:3.19

LABEL maintainer="you@example.com"
LABEL description="Kaniko 빌드 테스트용 간단한 Dockerfile"

RUN echo "Hello from Kaniko build!" > /hello-kaniko.txt

CMD ["cat", "/hello-kaniko.txt"]
