pipeline {
  agent any

  environment {
    IMAGE_NAME = "docker.io/gpfls0506@gmail.com/rke2-cicd-sample"
  }

  stages {
    stage('Checkout') {
      steps {
        // 기본 SCM 설정(scm) 이용
        checkout scm
      }
    }

    stage('Build & Push to Docker Hub') {
      steps {
        script {
          // dockerhub-creds 로 로그인하고 이미지 빌드·푸시
          docker.withRegistry('', 'dockerhub-creds') {
            // 태그: 빌드 번호, latest
            def img = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
            img.push()
            img.push('latest')
          }
        }
      }
    }

    stage('Update k8s Manifest & Commit') {
      steps {
        sh '''
          # 배포 매니페스트 image 태그 업데이트
          sed -i "s|image: .*|image: ${IMAGE_NAME}:${BUILD_NUMBER}|g" k8s/deployment.yaml

          # 깃 커밋 & 푸시
          git config user.email "jenkins@ci.local"
          git config user.name  "Jenkins CI"
          git add k8s/deployment.yaml
          git commit -m "ci: update image tag to ${BUILD_NUMBER}"
          git push origin HEAD:main
        '''
      }
    }

    stage('Trigger Argo CD Sync') {
      steps {
        // Argo CD CLI 설치되어 있어야 함 (또는 HTTP API 호출)
        sh '''
          argocd login argocd-server.argocd.svc.cluster.local:443 \
            --username admin --password <YOUR-ARGOCD-PW> --insecure
          argocd app sync rke2-cicd-sample
        '''
      }
    }
  }

  post {
    always {
      cleanWs()
    }
  }
}
