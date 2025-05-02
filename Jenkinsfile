pipeline {
  agent {
    kubernetes {
      label 'kaniko'                // PodTemplate의 label
      defaultContainer 'jnlp'       // 기본 Agent 컨테이너를 사용
    }
  }

  environment {
    REGISTRY = '34.22.80.2:30110'   // Nexus Docker Registry
    IMAGE    = 'fw-image'          // 저장소 이름
    TAG      = 'test'              // 푸시할 태그
  }

  stages {

    stage('Checkout') {
      steps {
        git url: 'https://github.com/OhHyerin/rke2-cicd-sample.git', branch: 'main'
      }
    }

    stage('Build & Push with Kaniko') {
      steps {
        // jnlp 컨테이너 내에서 실행
        sh '''
          # 1) Kaniko executor 바이너리 다운로드
          curl -sSL -o executor \
            https://storage.googleapis.com/kaniko-project/executor:debug/executor

          chmod +x executor

          # 2) Dockerfile 빌드 & Nexus에 Push
          ./executor \
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
