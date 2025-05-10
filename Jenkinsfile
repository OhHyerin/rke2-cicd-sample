podTemplate(
  label: 'docker-build',
  containers: [
    containerTemplate(
      name: 'jnlp',
      image: 'jenkins/inbound-agent:latest',
      args: '${computer.jnlpmac} ${computer.name}'
    ),
    containerTemplate(
      name: 'dind',
      image: 'docker:20.10.23-dind',
      command: 'dockerd-entrypoint.sh',
      args: '--host=tcp://0.0.0.0:2375 --storage-driver=overlay2 --insecure-registry=34.64.159.32:30110',
      privileged: true,
      ttyEnabled: true,
      envVars: [
        envVar(key: 'DOCKER_HOST',       value: 'tcp://localhost:2375'),
        envVar(key: 'DOCKER_TLS_CERTDIR', value: '')
      ]
    ),
    containerTemplate(
      name: 'argocd',
      image: 'alpine:3.18',
      command: 'sh',
      args: '-c "apk add --no-cache curl && sleep infinity"',
      ttyEnabled: true
    )
  ],
  volumes: [
    emptyDirVolume(mountPath: '/var/lib/docker', memory: false)
  ]
) {
  node('docker-build') {

    stage('Checkout') {
      checkout scm
      script {
        env.TAG = sh(returnStdout: true, script: 'git rev-parse --short=7 HEAD').trim()
        echo "Using TAG=${env.TAG}"
      }
    }

    stage('Test Docker') {
      container('dind') {
        sh '''
          timeout 60 sh -c '
            until docker version > /dev/null 2>&1; do
              echo "Waiting for Docker daemon (no TLS)..."
              sleep 1
            done
          '
          docker version
        '''
      }
    }

    stage('Docker Login') {
      container('dind') {
        withCredentials([usernamePassword(
          credentialsId: 'nexus-ci-user',
          usernameVariable: 'NEXUS_USER',
          passwordVariable: 'NEXUS_PASS'
        )]) {
          sh 'docker login 34.64.159.32:30110 -u $NEXUS_USER -p $NEXUS_PASS'
        }
      }
    }

    stage('Build & Push') {
      container('dind') {
        sh '''
          docker build -t 34.64.159.32:30110/fw-images:${TAG} .
          docker push 34.64.159.32:30110/fw-images:${TAG}
        '''
      }
    }

    stage('Verify') {
      container('dind') {
        sh '''
          # 1) 레지스트리에서 Pull 시도 → 성공 메시지로 검증
          docker pull 34.64.159.32:30110/fw-images:${TAG}

          # 2) (선택) 로컬 이미지 리스트에 있는지 확인
          docker images 34.64.159.32:30110/fw-images:${TAG}
        '''
      }
    }

    stage('Update Manifests & Push') {
      container('dind') {
        withCredentials([
          usernamePassword(
            credentialsId: 'github-idpw',
            usernameVariable: 'GIT_USER',
            passwordVariable: 'GIT_PASS'
          )
        ]) {
          sh '''
            set -eux

            # 1) dind 에 git 설치
            apk add --no-cache git

            cd "$WORKSPACE"

            # 2) Git author 설정
            git config user.email "gpfls0506@gmail.com"
            git config user.name  "OhHyerin"

            # 3) remote URL 을 credentials 포함 형태로 변경
            git remote set-url origin \
              https://${GIT_USER}:${GIT_PASS}@github.com/OhHyerin/rke2-cicd-sample.git

            # 4) 이미지 태그 업데이트
            sed -i "s|image: 34.64.159.32:30110/fw-images:.*|image: 34.64.159.32:30110/fw-images:${TAG}|" k8s/deployment.yaml

            # 5) 커밋 & 푸시
            git add k8s/deployment.yaml
            git commit -m "ci: bump image tag to ${TAG}"
            git push origin main
         '''
        }
      }
    }

stage('Trigger ArgoCD Sync') {
  container('argocd') {
    withCredentials([
      usernamePassword(
        credentialsId: 'argocd-cli-user',
        usernameVariable: 'ARGOCD_USER',
        passwordVariable: 'ARGOCD_PASS'
      ),
      string(credentialsId: 'argocd-server', variable: 'ARGOCD_SERVER')
    ]) {
      sh '''
        set -eux

        # 1) argocd CLI 다운로드
        VERSION=v2.9.5
        curl -sSL https://github.com/argoproj/argo-cd/releases/download/${VERSION}/argocd-linux-amd64 \
          -o /usr/local/bin/argocd
        chmod +x /usr/local/bin/argocd

        # 2) 설치된 CLI 확인
        /usr/local/bin/argocd version --client

        # 3) 로그인 (HTTP일 땐 --plaintext, HTTPS self-signed일 땐 --insecure)
        /usr/local/bin/argocd login $ARGOCD_SERVER \
          --username $ARGOCD_USER \
          --password $ARGOCD_PASS \
          --plaintext \
          --insecure

        # Deployment 매니페스트의 image.tag 값을 동적 TAG로 설정
          /usr/local/bin/argocd app set fw-image-app -p image.tag=${TAG}

        # 4) 애플리케이션 동기화 및 완료 대기
        /usr/local/bin/argocd app sync fw-image-app
        /usr/local/bin/argocd app wait fw-image-app --timeout 300
      '''
    }
  }
}  //Trigger ArgoCD Sync

  }
}
