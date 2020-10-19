pipeline {
  agent any
  stages {
    stage('Builds 	') {
      parallel {
        stage('Initial') {
          steps {
            sh 'echo "working directory is -"'
			pwd
            sh '''
                     echo "Initial code was cloning from GitHub:"
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
                    sh "docker build --tag ${env.dockerUsername}/capstone ."
                    sh "docker push ${env.dockerUsername}/capstone"
                    sh "docker run -d -p 8888:8888 --name capstone ${env.dockerUsername}/capstone"
					sh "date >> docker_ps.output"
					sh "docker ps >> docker_ps.output"
                }
            }
        }


    stage('Staging') {
      parallel {
        stage('Staging1') {
          steps {
            sh 'echo "This is test stage1"'
            sh '''
                     echo "this is a kind of test stage (1)"
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

    stage('Lint Dockerfile') {
      steps {
	    sh 'sudo wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v1.18.0/hadolint-Linux-x86_64'
		sh 'sudo chmod +x /bin/hadolint'
        sh 'hadolint Dockerfile'
      }
    }

    stage('Lint HTML') {
      steps {
        sh 'sudo yum install tidy -y'
		sh 'tidy -q -e nginx/htdocs/*.html'
      }
    }

    stage('Security Scan') {
      steps {
        aquaMicroscanner(imageName: 'nginx:alpine', notCompliesCmd: 'exit 1', onDisallowed: 'fail', outputFormat: 'html')
      }
    }

    stage('Upload to AWS') {
      steps {
        withAWS(region: 'us-west-2', credentials: 'aws-static') {
          sh 'echo "Uploading content with AWS creds"'
          s3Upload(pathStyleAccessEnabled: true, payloadSigningEnabled: true, file: 'index.html', bucket: 'dmalinov-capstone')
          s3Upload(file: 'docker_ps.output', bucket: 'dmalinov-capstone')
        }

      }
    }

  }
}