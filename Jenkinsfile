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
      image: 'bitnami/argocd-cli:2.9.5',
      command: 'cat',
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
          docker build -t 34.64.159.32:30110/fw-images:test1 .
          docker push 34.64.159.32:30110/fw-images:test1
        '''
      }
    }

    stage('Verify') {
      container('dind') {
        sh '''
          # 1) 레지스트리에서 Pull 시도 → 성공 메시지로 검증
          docker pull 34.64.159.32:30110/fw-images:test1

          # 2) (선택) 로컬 이미지 리스트에 있는지 확인
          docker images 34.64.159.32:30110/fw-images:test1
        '''
      }
    }

stage('Trigger ArgoCD Sync') {
  container('argocd') {
    withCredentials([
      string(credentialsId: 'argocd-server',   variable: 'ARGOCD_SERVER'),
      usernamePassword(
        credentialsId: 'argocd-cli-user',
        usernameVariable: 'ARGOCD_USER',
        passwordVariable: 'ARGOCD_PASS'
      )
    ]) {
      // shebang 없이, 매 줄 -eux 옵션 직접 추가
      sh '''
        set -eux

        # 1) CLI 버전 확인
        argocd version --client

        # 2) 로그인 (HTTP라면 --plaintext, HTTPS self-signed라면 --insecure)
        argocd login $ARGOCD_SERVER \
          --username $ARGOCD_USER \
          --password $ARGOCD_PASS \
          --plaintext \
          --insecure

        # 3) 애플리케이션 동기화
        argocd app sync fw-image-app

        # 4) 동기화 완료 대기 (최대 5분)
        argocd app wait fw-image-app --timeout 300
      '''
    }
  }
}  //Trigger ArgoCD Sync

  }
}
