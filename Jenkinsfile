pipeline {
  agent none

  stages {
    stage('Build & Push with Kaniko') {
      agent {
        kubernetes {
          inheritFrom 'default'
          label 'kaniko'
          defaultContainer 'jnlp'
          // Kaniko 사이드카 추가
          containerTemplate(
            name: 'kaniko',
            image: 'gcr.io/kaniko-project/executor:debug',
            command: '/busybox/sh',
            args: '-c sleep 3600',
            ttyEnabled: true
          )
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
