podTemplate(
  label: 'kaniko',
  containers: [
    // Jenkins agent 컨테이너 (기본 역할)
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
  ]
) {
  node('kaniko') {
    stage('Checkout') {
      checkout scm
    }
    stage('Build & Push with Kaniko') {
      // Kaniko 컨테이너 안에서 실행
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
