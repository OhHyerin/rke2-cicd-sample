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
      args: '--host=tcp://0.0.0.0:2375 --storage-driver=overlay2',
      privileged: true,
      ttyEnabled: true,
      envVars: [
        envVar(key: 'DOCKER_HOST',       value: 'tcp://localhost:2375'),
        envVar(key: 'DOCKER_TLS_CERTDIR', value: '')
      ]
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
          sh 'docker login 34.22.80.2:30110 -u $NEXUS_USER -p $NEXUS_PASS'
        }
      }
    }

    stage('Build & Push') {
      container('dind') {
        sh '''
          docker build -t 34.22.80.2:30110/fw-image:test .
          docker push 34.22.80.2:30110/fw-image:test
        '''
      }
    }

    stage('Verify') {
  container('dind') {
    sh '''
      # 1) 이미지가 레지스트리에 있는지 pull 해보기
      docker pull 34.22.80.2:30110/fw-image:test

      # 2) (선택) manifest inspect 으로 메타 정보 확인
      docker manifest inspect 34.22.80.2:30110/fw-image:test
    '''
  }
}

  }
}
