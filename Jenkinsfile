podTemplate(
  label: 'kaniko',
  // 기본 jnlp 에이전트 컨테이너
  containers: [
    containerTemplate(
      name: 'jnlp', 
      image: 'jenkins/inbound-agent:latest',
      args: '${computer.jnlpmac} ${computer.name}'
    ),
    // Kaniko 사이드카 컨테이너
    containerTemplate(
      name: 'kaniko',
      image: 'gcr.io/kaniko-project/executor:debug',
      command: '/busybox/sh',
      args: '-c sleep 3600',
      ttyEnabled: true
    )
  ],
  // 워크스페이스 공유용 빈볼륨 (default가 이미 설정돼 있을 거예요)
  volumes: [
    emptyDirVolume(mountPath: '/home/jenkins/agent', memory: false)
  ]
) {
  node('kaniko') {
    stage('Checkout') {
      checkout scm
    }
    stage('Build & Push with Kaniko') {
      // Kaniko 컨테이너 내에서만 실행
      container('kaniko') {
        sh '''
          /kaniko/executor \
            --dockerfile=Dockerfile \
            --context=${WORKSPACE} \
            --destination=34.22.80.2:30110/fw-image:test \
            --insecure \
            --skip-tls-verify
        '''
      }
    }
  }
}
