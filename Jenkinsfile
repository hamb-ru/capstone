pipeline {
	agent any
	stages {

		stage('Download from S3') {
			steps {
				withAWS(region: 'us-west-2', credentials: 'aws-static') {
				  sh 'echo "Downloading content with AWS creds"'
				  s3Download(file: 'staging.txt', bucket: 'dmalinov-project3')
				}
			}
		}

		stage('Build Docker image') {
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
					sh "date >> docker_ps_output.txt"
					sh "docker ps >> docker_ps_output.txt" 
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

		stage('Lint Dockerfile') {
			steps {
				sh "hadolint --ignore DL3013 --ignore DL3018 --ignore DL3019 Dockerfile"
			}
		}

		stage('Lint HTML') {
			steps {
				sh "tidy -q -e nginx/htdocs/*.html"
			}
		}

		stage('Security Scan') {
			steps {
				aquaMicroscanner(imageName: 'hamb/capstone', notCompliesCmd: 'exit 1', onDisallowed: 'fail', outputFormat: 'html')
			}
		}

		stage('Deploy to minikube') {
			steps {
				sh 'echo "If needed builded image could be deployed to k8s as well for testing purposes. To do it - uncomment next line (remove 'echo')"'
				sh 'echo "./run_kubernetes.sh"'
			}
		}

		stage('Upload to AWS') {
			steps {
			withAWS(region: 'us-west-2', credentials: 'aws-static') {
				sh 'echo "Uploading content with AWS creds"'
				s3Upload(pathStyleAccessEnabled: true, payloadSigningEnabled: true, file: 'docker_ps_output.txt', bucket: 'dmalinov-capstone')
				s3Upload(file: 'scanout.html', bucket: 'dmalinov-capstone')
				s3Upload(file: 'scanlatest.html', bucket: 'dmalinov-capstone')
				s3Upload(file: 'styles.css', bucket: 'dmalinov-capstone')
				}
			}
		}

	}
}