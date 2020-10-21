### Dmitry Malinovsky - 
### The Makefile includes environment setup, docker, Jenkins installation, linting software, k8s installation and other steps for AWS AMI (release 2018.03)

pre:
# Installs needed pre-requisites (git,python,etc)
	sudo yum install git -y
	sudo yum install python36.x86_64 -y
	sudo python3 -m pip install --user --upgrade pip

docker:
# Installs needed pre-requisites (docker,it,python, etc)
	sudo yum install docker -y
	sudo service docker start
	sudo chkconfig docker on
	sudo usermod -a -G docker ec2-user
	echo "you need to re-login to work with docker & k8s"
###  Changing(setting) password to ec2-user  
#	echo $USER | sudo passwd $USER --stdin


jenkins:
### Jenkins installation
	sudo yum erase java-1.7.0-openjdk -y
	sudo yum install java-1.8.0 -y
	sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
	sudo rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key
	sudo yum install jenkins -y
	sudo service jenkins start
	sudo chkconfig jenkins on
	sudo usermod -aG docker jenkins
	sudo service jenkins restart
	curl -s http://169.254.169.254/latest/meta-data/public-hostname >> jenkins_url.txt
	echo ":8080" >> jenkins_url.txt
	cat jenkins_url.txt
	timeout 10
	sudo cat /var/lib/jenkins/secrets/initialAdminPassword

hadolint:
	# This is linter for Dockerfiles
	sudo wget -O /bin/hadolint https://github.com/hadolint/hadolint/releases/download/v1.18.0/hadolint-Linux-x86_64
	sudo chmod +x /bin/hadolint
	hadolint --version
#	hadolint --ignore DL3013 --ignore DL3018 --ignore DL3019 Dockerfile

tidy:
	# This is linter for HTML
	sudo yum install tidy -y 
	tidy --version
#	tidy nginx/htdocs/*.html

aws-eksctl:
# AWS EKSCTL installation
	curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
	sudo mv /tmp/eksctl /usr/local/bin
	eksctl version

k8s:
# kubernetes - Minikube
	curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
	sudo mv kubectl /bin
	sudo chmod +x /bin/kubectl
	curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
	sudo rpm -ivh minikube-latest.x86_64.rpm --force
### to run minikube user (ec2-user) needs to be in group 'docker'. It was added to this group in 'env-setup' step, but we need to re-login to activate this change
	minikube start --driver=docker

env: pre docker jenkins hadolint tidy aws-eksctl
all: pre docker jenkins hadolint tidy aws-eksctl k8s

aws-cli:
# AWS CLI installation - not needed on AWS ami
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
	unzip awscliv2.zip
	sudo ./aws/install

