#!/usr/bin/env bash

# Step 1:
# dockerpath=<>
dockerpath="hamb/capstone"

# Step 2
# Run the Docker Hub container with kubernetes
#kubectl run --image=$dockerpath capstone --port=80
kubectl create deployment capstone --image=$dockerpath

# Step 3:
# List kubernetes pods
kubectl get pods --all-namespaces

# Step 4:
# Forward the container port to a host
kubectl port-forward deployment/capstone 8888:8888
