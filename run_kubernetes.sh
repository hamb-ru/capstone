#!/usr/bin/env bash

# Step 1:
# dockerpath=<>
dockerpath="hamb/capstone"

# Step 2
# Run the Docker Hub container with kubernetes
#x
kubectl create deployment capstone --image=$dockerpath

# Step 3:
# List kubernetes pods
kubectl get pods --all-namespaces

# Step 4:
# Forward the container port 8888 to a host port 7777 (8888 host port could be occupied by running docker container)
kubectl port-forward deployment/capstone 7777:8888
