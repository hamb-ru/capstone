#!/usr/bin/env bash

# Step 1:
# Stop any running Capstone containers
docker rm -f capstone >> /dev/null 2>&1 

# Step 2:
# Set image path
dockerpath="hamb/capstone_blue"

# Step 3:
# Run the BLUE Docker container with kubernetes
kubectl create deployment capstone-blue --image=$dockerpath

# Step 4:
# Wait 30 seconds till the pod come up
sleep 30

# Step 5:
# List kubernetes pods
kubectl get pods --all-namespaces
sleep 10

# Step 6:
# Forward the container port 8888 to a host port 8877 (blue deployment)
kubectl port-forward --address 0.0.0.0 deployment/capstone-blue 8877:8888 &
