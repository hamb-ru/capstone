############################################################################
################################   Capstone Project   ##############################
############################################################################

						# Capstone Project Overview

In this project you will apply the skills and knowledge which were developed throughout the Cloud DevOps Nanodegree program. These include:

- Working in AWS
- Using Jenkins to implement Continuous Integration and Continuous Deployment
- Building pipelines
- Working with Ansible and CloudFormation to deploy clusters
- Building Kubernetes clusters
- Building Docker containers in pipelines
- As a capstone project, the directions are rather more open-ended than they were in the previous projects in the program. You will also be able to make some of your own choices in this capstone, for the type of deployment you implement, which services you will use, and the nature of the application you develop.

You will develop a CI/CD pipeline for micro services applications with either blue/green deployment or rolling deployment. You will also develop your Continuous Integration steps as you see fit, but must at least include typographical checking (aka “linting”). To make your project stand out, you may also choose to implement other checks such as security scanning, performance testing, integration testing, etc.!

Once you have completed your Continuous Integration you will set up Continuous Deployment, which will include:

- Pushing the built Docker container(s) to the Docker repository (you can use AWS ECR, create your own custom Registry within your cluster, or another 3rd party Docker repository) ; and
- Deploying these Docker container(s) to a small Kubernetes cluster. For your Kubernetes cluster you can either use AWS Kubernetes as a Service, or build your own Kubernetes cluster. To deploy your Kubernetes cluster, use either Ansible or Cloudformation. Preferably, run these from within Jenkins as an independent pipeline.

# Project Directions

## Step 1: Propose and Scope the Project
- Plan what your pipeline will look like.
- Decide which options you will include in your Continuous Integration phase.
- Use Jenkins.
-Pick a deployment type - either rolling deployment or blue/green deployment.
-For the Docker application you can either use an application which you come up with, or use an open-source application pulled from the Internet, or if you have no idea, you can use an Nginx “Hello World, my name is (student name)” application.

## Step 2: Use Jenkins, and implement blue/green or rolling deployment.
- Create your Jenkins master box with either Jenkins and install the plugins you will need.
- Set up your environment to which you will deploy code.

## Step 3: Pick AWS Kubernetes as a Service, or build your own Kubernetes cluster.
- Use Ansible or CloudFormation to build your “infrastructure”; i.e., the Kubernetes Cluster.
- It should create the EC2 instances (if you are building your own), set the correct networking settings, and deploy software to these instances.
- As a final step, the Kubernetes cluster will need to be initialized. The Kubernetes cluster initialization can either be done by hand, or with Ansible/Cloudformation at the student’s discretion.

## Step 4: Build your pipeline
- Construct your pipeline in your GitHub repository.
- Set up all the steps that your pipeline will include.
- Configure a deployment pipeline.
- Include your Dockerfile/source code in the Git repository.
- Include with your Linting step both a failed Linting screenshot and a successful Linting screenshot to show the Linter working properly.

## Step 5: Test your pipeline
- Perform builds on your pipeline.
- Verify that your pipeline works as you designed it.
- Take a screenshot of the Jenkins pipeline showing deployment and a screenshot of your AWS EC2 page showing the newly created (for blue/green) or modified (for rolling) instances. Make sure you name your instances differently between blue and green deployments.

## Submitting your Project
Make sure you have taken all the screenshots you need, as directed above, and create a text file with a link to your GitHub repo.
Zip up these screenshots and text file into a single doc, and this will constitute your project submission.
Before you submit your project, please make sure you have checked all of your work against the project rubric. If you find that you have not satisfied any area of the rubric, please revise your work before you submit it. This rubric is what your reviewer will be using to assess your work.

============================================================================

						# Project implementation

## Initial setup
To start deploying/exploring the project we need any linux machine to run Jenkins and other attendant software (I've used EC2 t2.large instance in AWS).
As far AMI Linux image does not have git installed initially we need either to install it manually (sudo yum install git) and clone this repo or just copy the Makefile to the machine.

- Run 'make env' to install git, python, docker, jenkins, hadolint, tidy, aws-eksctland dependencies.
- Re-login or run another shell, to activate user's group 'docker' if minikube will be run locally for debugging. 

## Jenkins
Configure installed Jenkins with pluggins (Pipeline: AWS Steps, Amazon EC2 plugin, Aqua MicroScanner, Blue Ocean) and credentials for AWS and DOCKER hub access

## CI Pipeline
Create CI pipeline from Jenkinsfile. 
![pipeline screen1](screenshots/screenshot01_successful_pipeline.jpg)
It will have the following steps: 
- Lint Dockerfile with hadolint [failed Linting screenshot below]
![pipeline screen2](screenshots/screenshot02_failed_hadolint_check.jpg)
- Lint HTML with tidy [failed Linting screenshot below]
![pipeline screen3](screenshots/screenshot03_failed_tidy_check.jpg)
- Build Docker image with dummy web site running on nginx
![pipeline screen4](screenshots/screenshot04_successful_build.jpg)
- Run docker container from builded image (https://dmalinov-capstone.s3.us-west-2.amazonaws.com/docker_ps_output.txt)
- Push image to docker hub (https://hub.docker.com/repository/docker/hamb/capstone)
- Security Scan of builded image with AquaMicroscanner (https://dmalinov-capstone.s3.us-west-2.amazonaws.com/scanlatest.html)
- Upload artefacts to AWS S3 bucket (info about running docker container and image testing output)

## CD Pipeline
There could be two ways: 
1) Deploy kubernetes cluster to local minikube. 
Green/Blue deployment is implemented by running two different run_kubernetes_(green/blue).sh scripts with different forwarded ports:
	- minikube start
	- run_kubernetes_green.sh
	- run_kubernetes_blue.sh
![pipeline screen5](screenshots/screenshot05_minikube_deployment.jpg)
- minikube-deployment pipeline could be triggered after successfull finish of CI pipeline or run manually.
![pipeline screen6](screenshots/screenshot06_green-blue.jpg)

or

2) Deploy kubernetes cluster to AWS EKS with eksctl { https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html }
- make sure that AWS CLI is installed (it's pre-installed on AWS AMI) and eksctl installed ('make aws-eksctl' if not yet)
- configure AWS CLI
	[ec2-user@~]$ aws configure <br>
		AWS Access Key ID [****************UMFF]:  <br> AKIA4RNL6OMCJVBRUMFF
		AWS Secret Access Key [****************cjHK]: <br> 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
		Default region name [us-west-2]: <br>
		Default output format [yaml]: <br>
- Appropriate policies should be attached to IAM:user - IAM, EKS, EC2, VPC, etc [i did it manually via AWS IAM]
- run eks_cluster_ceate.sh script:
![pipeline screen7](screenshots/screenshot07_eks_cluster_00.jpg)
 it will deploy to EKS cluster "eksctl-capstone-cluster"
![pipeline screen8](screenshots/screenshot08_eks_cluster_01.jpg) 
 and nodegroup "eksctl-capstone-nodegroup-linux-nodes" according to settings in the script 
![pipeline screen9](screenshots/screenshot09_eks_cluster_02.jpg) 
 so we will see 3 new ec2 instances running
![pipeline screen10](screenshots/screenshot10_eks_cluster_03.jpg)

After we have deployed EKS cluster we can deploy our nginx dummy app to the k8s cluster and check how Rolling Update is working.
We will perform this by running two jenkins jobs consistently:
![pipeline screen11](screenshots/screenshot11_eks_app_deploy_01.jpg)
or it could be done manually by applying yaml files with app deployment and LoadBalancer service - app-deploy-<COLOR>.yaml & svc-<COLOR>.yaml

============================================================================

