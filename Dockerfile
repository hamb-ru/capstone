FROM nginx:alpine

## Step 1:
# Copy nginx config
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

## Step 2:
# Copy html source
COPY nginx/htdocs/ /usr/share/nginx/html

## Step 3:
# Install packages from requirements.txt
# hadolint ignore=DL3013
RUN apk add python3 py3-pip
RUN apk update
RUN pip install --upgrade pip
#RUN pip install --trusted-host pypi.python.org -r requirements.txt
RUN pip install --trusted-host pypi.python.org pylint 

## Step 4:
# Expose port 8888
EXPOSE 8888

## Step 5:
# Test command run inside the container
#CMD ["echo", "docker container is ready"]
