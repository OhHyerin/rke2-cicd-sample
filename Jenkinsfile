pipeline {
  agent {
    kubernetes {
      label 'kaniko'        // 새로 추가한 Kaniko 템플릿
      defaultContainer 'jnlp'
    }
  }

  environment {
    REGISTRY = '34.22.80.2:30110'
    IMAGE    = 'fw-image'
    TAG      = 'test'
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/OhHyerin/rke2-cicd-sample.git', branch: 'main'
      }
    }

    stage('Build & Push with Kaniko') {
      steps {
        container('kaniko') {
          sh '''
            # 이미 executor 바이너리가 /kaniko/executor 위치에 있습니다
            /kaniko/executor \
              --dockerfile=Dockerfile \
              --context=/workspace \
              --destination=${REGISTRY}/${IMAGE}:${TAG} \
              --insecure \
              --skip-tls-verify
          '''
        }
      }
    }
  }
}
