// Declarative pipeline: Java 21 / Maven / Spring Boot -> Kaniko image -> Kubernetes (Kustomize)
// Requires: Jenkins Kubernetes plugin. See docs/SETUP.md for credentials and plugins.
pipeline {
  agent {
    kubernetes {
      yaml '''
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: maven
      image: maven:3.9-eclipse-temurin-21
      command: ["sleep"]
      args: ["infinity"]
    - name: snyk
      image: snyk/snyk:maven-3-jdk-21
      command: ["sleep"]
      args: ["infinity"]
    - name: kaniko
      image: gcr.io/kaniko-project/executor:debug
      command: ["sleep"]
      args: ["infinity"]
      volumeMounts:
        - name: registry-creds
          mountPath: /kaniko/.docker
    - name: kubectl
      image: bitnami/kubectl:1.30
      command: ["sleep"]
      args: ["infinity"]
  volumes:
    - name: registry-creds
      secret:
        secretName: regcred
        items:
          - key: .dockerconfigjson
            path: config.json
'''
    }
  }

  environment {
    REGISTRY = 'registry.example.com/myteam'   // TODO: your registry path
    APP_NAME = 'my-service'
  }

  options {
    timeout(time: 45, unit: 'MINUTES')
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '20'))
    timestamps()
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        script {
          env.IMAGE_TAG = "${env.BUILD_NUMBER}-${env.GIT_COMMIT.take(7)}"
          env.IMAGE     = "${env.REGISTRY}/${env.APP_NAME}:${env.IMAGE_TAG}"
        }
      }
    }

    stage('Build & Unit Test') {
      steps {
        container('maven') { sh 'mvn -B -ntp clean verify' }
      }
      post { always { junit '**/target/surefire-reports/*.xml' } }
    }

    stage('Quality & Security') {
      parallel {
        stage('SonarQube') {
          steps {
            container('maven') {
              withSonarQubeEnv('sonarqube') {
                sh 'mvn -B -ntp org.sonarsource.scanner.maven:sonar-maven-plugin:4.0.0.4121:sonar'
              }
            }
          }
        }
        stage('Snyk dependency scan') {
          steps {
            container('snyk') {
              withCredentials([string(credentialsId: 'snyk-token', variable: 'SNYK_TOKEN')]) {
                // Report-only at first. Remove "|| true" to make high-severity findings fail the build.
                sh 'snyk test --severity-threshold=high || true'
              }
            }
          }
        }
      }
    }

    stage('Quality Gate') {
      steps {
        timeout(time: 10, unit: 'MINUTES') { waitForQualityGate abortPipeline: true }
      }
    }

    stage('Build & Push Image') {
      when { branch 'main' }
      steps {
        container('kaniko') {
          sh '''
            /kaniko/executor \
              --context "$WORKSPACE" \
              --dockerfile Dockerfile \
              --destination "$IMAGE" \
              --cache=true
          '''
        }
      }
    }

    stage('Deploy to Staging') {
      when { branch 'main' }
      steps {
        container('kubectl') {
          withKubeConfig([credentialsId: 'k8s-staging']) {
            sh '''
              sed -i "s|IMAGE_PLACEHOLDER|$IMAGE|g" k8s/base/deployment.yaml
              kubectl apply -k k8s/overlays/staging
              kubectl rollout status deployment/$APP_NAME -n my-service-staging --timeout=180s
            '''
          }
        }
      }
    }

    stage('Approve Production') {
      when { branch 'main' }
      steps {
        timeout(time: 1, unit: 'HOURS') {
          input message: "Deploy ${env.IMAGE} to PRODUCTION?", ok: 'Deploy'
        }
      }
    }

    stage('Deploy to Production') {
      when { branch 'main' }
      steps {
        container('kubectl') {
          withKubeConfig([credentialsId: 'k8s-prod']) {
            sh '''
              sed -i "s|IMAGE_PLACEHOLDER|$IMAGE|g" k8s/base/deployment.yaml
              kubectl apply -k k8s/overlays/production
              kubectl rollout status deployment/$APP_NAME -n my-service-production --timeout=300s
            '''
          }
        }
      }
      post {
        failure {
          container('kubectl') {
            withKubeConfig([credentialsId: 'k8s-prod']) {
              sh 'kubectl rollout undo deployment/$APP_NAME -n my-service-production || true'
            }
          }
        }
      }
    }
  }

  post {
    // mail to: 'team@example.com', subject: "${currentBuild.currentResult}: ${env.JOB_NAME} #${env.BUILD_NUMBER}", body: env.BUILD_URL
    always { cleanWs() }
  }
}
