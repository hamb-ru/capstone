pipeline {
  agent any
  stages {
	stage('Build Docker image and run it locally') {
          steps {
			sh 'echo "Now building Docker image"'
			withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'dockerPassword', usernameVariable: 'dockerUsername')]) {
				sh "docker login -u ${env.dockerUsername} -p ${env.dockerPassword}"
				sh "echo 'remove docker container if exists'"
				sh "docker rm -f capstone || true"
				sh "docker build --tag ${env.dockerUsername}/capstone ."
				sh "docker push ${env.dockerUsername}/capstone"
                }
            }
        }

	stage('Run & Push') {
      parallel {
        stage('Run docker container') {
          steps {
			sh 'echo "Running builded image"'
			withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'dockerPassword', usernameVariable: 'dockerUsername')]) {
				sh "docker run -d -p 8888:8888 --name capstone ${env.dockerUsername}/capstone"
				sh "date >> docker_ps.output"
				sh "docker ps >> docker_ps.output"
				}
          }
        }

        stage('Push image to docker hub') {
          steps {
			sh 'echo "Push builded image to docker.hub"'
			withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'dockerPassword', usernameVariable: 'dockerUsername')]) {
				sh "docker push ${env.dockerUsername}/capstone"
				}
          }
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
					 pwd
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
        sh 'hadolint --ignore DL3013 --ignore DL3018 --ignore DL3019 Dockerfile'
      }
    }

    stage('Lint HTML') {
      steps {
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