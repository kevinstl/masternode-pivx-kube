pipeline {
  agent {
    label "jenkins-go"
  }
  environment {
    ORG = 'kevinstl'
    APP_NAME = 'masternode-pivx-kube'
    CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')

    NEW_VERSION_LOCAL = 'true'
    GITHUB_ADDRESS    = 'https://github.com/kevinstl'

    DEPLOY_NAMESPACE = "masternode-pivx-kube"

  }
  stages {

    stage('Determine Environment') {
      steps {
        script {
          kubeEnv = sh(returnStdout: true, script: 'echo "${KUBE_ENV}"')
        }
        echo "kubeEnv: ${kubeEnv}"
      }
    }

    stage('CI Build and push snapshot') {
      when {
        branch 'PR-*'
      }
      environment {
        PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
        PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
        HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
      }
      steps {
        container('go') {
          sh "./mvnw versions:set -DnewVersion=$PREVIEW_VERSION"
          sh "./mvnw install"
          sh "skaffold version"
          sh "export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml"
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          dir('charts/preview') {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."
          }
        }
      }
    }

    stage('Build Release - Checkout') {
      when {
        anyOf { branch 'master'; branch 'feature-*' }
      }
      steps {

        container('go') {

          // ensure we're not on a detached head
//          sh "git checkout master"
          sh "git checkout ${env.BRANCH_NAME}"

//                sh "git config remote.origin.url https://github.com/kevinstl/masternode-pivx-kube.git"
//                sh "git config --global credential.helper store"
//                sh "jx step git credentials"
//                sh "git pull origin ${env.BRANCH_NAME}"

          sh "./pull.sh ${env.BRANCH_NAME}"

          sh "git config --global credential.helper store"
          sh "jx step git credentials"

          // so we can retrieve the version in later steps
          sh "echo \$(jx-release-version) > VERSION"
//          sh "./mvnw versions:set -DnewVersion=\$(cat VERSION)"
        }

      }
    }

    stage('Build Release - Tag') {
      when {
        anyOf { branch 'master'; branch 'feature-*' }
      }
      steps {
        container('go') {

          sh 'cat ./charts/masternode-pivx-kube/Chart.yaml'
          sh 'cat ./charts/masternode-pivx-kube/values.yaml'

          sh "jx step tag --charts-value-repository $DOCKER_REGISTRY/$ORG/$APP_NAME --version \$(cat VERSION)"

          sh 'cat ./charts/masternode-pivx-kube/Chart.yaml'
          sh 'cat ./charts/masternode-pivx-kube/values.yaml'

        }
      }
    }

    stage('Build Release - Compile') {
      when {
        anyOf { branch 'master'; branch 'feature-*' }
      }
      steps {

        container('go') {
//          sh "./mvnw clean package -Pprod -Pswagger -DnewVersion=\$(cat VERSION) -DskipTests"

          sh "make build"

          sh "ls -al"
        }
      }
    }

    stage('Build Release - Package Docker') {
      when {
        anyOf { branch 'master'; branch 'feature-*' }
      }
      steps {
        container('go') {
          sh "cat ./Dockerfile"
          sh "skaffold version"
          sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml"
          sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
        }
      }
    }

    stage('Deploy Local') {
      when {
        anyOf { branch 'master'; branch 'feature-*' }
      }
//      environment {
////        DEPLOY_NAMESPACE = "jx-local"
//      }
      steps {
        script {
          if (kubeEnv?.trim() == 'local') {
            deployLocal()
          }
        }
      }
    }

    stage('Push Local') {
      steps {
        script {
          if (kubeEnv?.trim() == 'local') {
            container('go') {
              sh "echo branch: ${env.BRANCH_NAME}"
              sh "./push.sh ${env.BRANCH_NAME}"
            }
          }
        }
      }
    }

    stage('Promote to Environments') {
      when {
//        branch 'master'
        anyOf { branch 'master'; branch 'feature-*' }
      }
      steps {
        script {
          if (kubeEnv?.trim() != 'local') {
            if (env.BRANCH_NAME == 'master') {
              //                  def promoteCommand = "jx promote -b --env jx-production --timeout 1h --version \$(cat ../../VERSION)"
              promote("production")
            } else {
              //                  def promoteCommand = "jx promote -b --env jx-staging --timeout 1h --version \$(cat ../../VERSION)"
              promote("staging")
            }
          }
        }

      }
    }
  }
  post {
    always {
      cleanWs()
    }
  }
}

def deployLocal() {

  script {

    sh 'echo debug1'

    if (NEW_VERSION_LOCAL == 'true') {
      dir('./charts/masternode-pivx-kube') {
        container('go') {
          sh 'jx step helm release'
        }
      }
    }

    sh 'echo debug3'

    def envProjectDir = "./charts-local/env"
    dir(envProjectDir) {
      container('go') {
        sh 'cat ./requirements.yaml'
        sh " ./scripts/replace-version.sh . ./requirements.yaml masternode-pivx-kube \$(cat ../../VERSION)"
        sh " ./scripts/add-values-local.sh . ./values.yaml"

        sh 'pwd'
        sh 'ls -al'
        sh 'cat ./requirements.yaml'
        sh 'jx step helm build'
//                sh 'jx step helm apply --wait=false'
        sh 'jx step helm apply --namespace masternode-pivx-kube --wait=false'
      }
    }
  }
}

def promote( env ) {
  container('go') {
    dir('charts/masternode-pivx-kube') {
      sh "jx step changelog --version v\$(cat ../../VERSION)"

      // release the helm chart
      sh "jx step helm release"

      // promote through all 'Auto' promotion Environments
//            sh "jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)"
      sh "jx promote -b --env masternode-pivx-kube --timeout 1h --version \$(cat ../../VERSION)"
    }
  }
}
