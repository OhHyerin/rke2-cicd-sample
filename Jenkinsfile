pipeline {
  agent none

  stages {
    stage('Build & Push with Kaniko') {
      agent {
        kubernetes {
          // 기본(default) 템플릿의 설정을 모두 이어받습니다
          inheritFrom 'default'

          // 이 라벨에 맞는 PodTemplate을 스케줄링
          label 'kaniko'

          // Pod 안에 기본으로 올라오는 컨테이너
          defaultContainer 'jnlp'

          // 여기에 Kaniko 사이드카 컨테이너를 정의
          containers {
            containerTemplate(
              name: 'kaniko',
              image: 'gcr.io/kaniko-project/executor:debug',
              command: '/busybox/sh',
              args: '-c sleep 3600',
              ttyEnabled: true
            )
          }
        }
      }
      environment {
        REGISTRY = '34.22.80.2:30110'
        IMAGE    = 'fw-image'
        TAG      = 'test'
      }
      steps {
        container('kaniko') {
          sh '''
            # Kaniko executor 실행 (이미 컨테이너 안에 /kaniko/executor 가 있습니다)
            /kaniko/executor \
              --dockerfile=Dockerfile \
              --context=${WORKSPACE} \
              --destination=${REGISTRY}/${IMAGE}:${TAG} \
              --insecure \
              --skip-tls-verify
          '''
        }
      }
    }
  }
}
