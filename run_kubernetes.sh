#!/usr/bin/env bash

# Step 1:
# dockerpath=<>
dockerpath="hamb/capstone"

# Step 2
# Run the Docker Hub container with kubernetes via deployment
kubectl create deployment capstone --image=$dockerpath

# Step 3:
# List ALL kubernetes pods
kubectl get pods --all-namespaces

# Step 4:
# Forward the container port 8888 to a host port 7777 (8888 host port could be occupied by running docker container)
kubectl port-forward --address 0.0.0.0 deployment/capstone 7777:8888
