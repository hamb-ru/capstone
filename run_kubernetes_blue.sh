#!/usr/bin/env bash

# Step 1:
# dockerpath=<>
dockerpath="hamb/capstone_green"

# Step 2
# Run the Docker Hub container with kubernetes
kubectl create deployment capstone --image=$dockerpath

# Step 3:
# List kubernetes pods
kubectl get pods --all-namespaces

# Step 4:
# Forward the container port 8888 to a host port 8877 (blue deployment)
kubectl port-forward --address 0.0.0.0 deployment/capstone 8877:8888
