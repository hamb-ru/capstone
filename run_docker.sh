#!/usr/bin/env bash

# Step 1:
# Build image 
docker build --tag=capstone .

# Step 2: 
# List docker images
docker image ls

# Step 3: 
# Run nginx container
docker run -p 80:80 capstone
