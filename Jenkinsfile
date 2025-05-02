pipeline {
  agent none

  stages {
    stage('Build & Push with Kaniko') {
      agent {
        kubernetes {
          // ① 기본(default) 템플릿 상속
          inheritFrom 'default'
          yamlMergeStrategy 'merge'

          // ② 이 라벨로만 호출
          label 'kaniko'

          // ③ Jenkins agent 역할은 기본 jnlp 컨테이너
          defaultContainer 'jnlp'

          // ④ Kaniko 사이드카 컨테이너 정의 (yaml 병합)
          yaml """
containers:
- name: kaniko
  image: gcr.io/kaniko-project/executor:debug
  command:
    - /busybox/sh
  args:
    - -c
    - sleep 3600
  tty: true
"""
        }
      }

      environment {
        REGISTRY = '34.22.80.2:30110'
        IMAGE    = 'fw-image'
        TAG      = 'test'
      }

      steps {
        // kaniko 컨테이너 안에서만 빌드/푸시
        container('kaniko') {
          sh '''
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
