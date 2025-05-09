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
      image: 'quay.io/argoproj/argocd:v2.9.5',
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

    stage('Build & Push') {
      container('dind') {
        withCredentials([usernamePassword(
          credentialsId: 'nexus-ci-user',
          usernameVariable: 'NEXUS_USER',
          passwordVariable: 'NEXUS_PASS'
        )]) {
          sh '''
            TAG="test1"
            docker login 34.64.159.32:30110 -u $NEXUS_USER -p $NEXUS_PASS
            docker build -t 34.64.159.32:30110/fw-images:${TAG} .
            docker push 34.64.159.32:30110/fw-images:${TAG}
          '''
        }
      }
    }

    stage('Trigger ArgoCD Sync') {
      container('argocd') {
        withCredentials([usernamePassword(
          credentialsId: 'argocd-cli-user',
          usernameVariable: 'ARGOCD_USER',
          passwordVariable: 'ARGOCD_PASS'
        )]) {
          def server = "34.64.159.32:30111"
          sh """
            argocd login ${server} \
              --username ${ARGOCD_USER} \
              --password ${ARGOCD_PASS} \
              --plaintext

            argocd app sync fw-image-app
            argocd app wait fw-image-app --timeout 300
          """
        }
      }
    }
  }
}
