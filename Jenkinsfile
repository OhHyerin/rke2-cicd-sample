pipeline {
  agent any
  environment {
    GITHUB_REPO  = "https://github.com/<your-user>/rke2-cicd-sample.git"
    GITHUB_TOKEN = credentials('github-pat')
  }
  stages {
    stage('Test GitHub Connection') {
      steps {
        script {
          echo "🔍 Testing access to ${GITHUB_REPO}"
          sh """
            git ls-remote ${GITHUB_REPO} -h HEAD \
              --quiet || (echo '❌ Cannot reach GitHub repo!' && exit 1)
          """
          echo "✅ GitHub repo is reachable."
        }
      }
    }
  }
}
