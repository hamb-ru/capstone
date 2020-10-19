pipeline {
  agent any
  stages {
    stage('Builds 	') {
      parallel {
        stage('Build1') {
          steps {
            sh 'echo "Hello World"'
            sh '''
                     echo "this is Build stage - the first one"
                     ls -latr
                 '''
          }
        }
      }
    }

        stage('Build Docker image and run it locally') {
            steps {
                sh 'echo "Now building Docker image"'
                withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'dockerPassword', usernameVariable: 'dockerUsername')]) {
                    sh "docker login -u ${env.dockerUsername} -p ${env.dockerPassword}"
                    sh "echo 'remove docker container if exists'"
                    sh "docker rm -f capstone || true"
                    sh "docker build --tag ${env.dockerUsername}/capstone:1.0 ."
                    sh "docker push ${env.dockerUsername}/capstone:1.0"
                    sh "docker run -d -p 8000:80 --name capstone ${env.dockerUsername}/capstone"
                }
            }
        }



    stage('Development') {
      parallel {
        stage('Development1') {
          steps {
            sh 'echo "This is dev stage1"'
            sh '''
                     echo "this is a kind of test"
                     hostname -f
                 '''
          }
        }
      }
    }

    stage('Staging') {
      parallel {
        stage('Staging1') {
          steps {
            sh 'echo "This is test stage"'
            sh '''
                     echo "this is a kind of test"
                     hostname -f
                 '''
          }
        }

        stage('Staging2') {
          steps {
            withAWS(region: 'us-west-2', credentials: 'aws-static') {
              sh 'echo "Downloading content with AWS creds"'
              s3Download(file: 'staging.txt', bucket: 'dmalinov-project3')
            }
          }
        }
      }
    }

    stage('Linting') {
      steps {
        sh "hadolint Dockerfile"
        sh "tidy -q -e *.html"
      }
    }

    stage('Lint HTML') {
      steps {
        sh 'tidy -q -e *.html'
      }
    }

    stage('Security Scan') {
      steps {
        aquaMicroscanner(imageName: 'alpine:latest', notCompliesCmd: 'exit 1', onDisallowed: 'fail', outputFormat: 'html')
      }
    }

    stage('Upload to AWS') {
      steps {
        withAWS(region: 'us-west-2', credentials: 'aws-static') {
          sh 'echo "Uploading content with AWS creds"'
          s3Upload(pathStyleAccessEnabled: true, payloadSigningEnabled: true, file: 'index.html', bucket: 'dmalinov-project3')
          s3Upload(file: 'jenkins-x.jpg', bucket: 'dmalinov-project3')
        }

      }
    }

  }
}