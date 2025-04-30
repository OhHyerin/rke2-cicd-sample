pipeline {
    agent {
        kubernetes {
            label 'kaniko' // 앞서 등록한 Pod Template의 label
        }
    }

    environment {
        REGISTRY = '34.22.80.2:30110'      // Nexus Docker Registry 주소
        IMAGE = 'fw-image'                 // Nexus에 생성한 저장소 이름
        TAG = 'test'                       // 원하는 태그명
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/OhHyerin/rke2-cicd-sample.git'
            }
        }

        stage('Build & Push with Kaniko') {
            steps {
                container('kaniko') {
                    sh """
                      /kaniko/executor \
                        --dockerfile=Dockerfile \
                        --context=/workspace \
                        --destination=${REGISTRY}/${IMAGE}:${TAG} \
                        --insecure \
                        --skip-tls-verify
                    """
                }
            }
        }
    }
}
