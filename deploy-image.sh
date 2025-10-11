#!/usr/bin/env bash

set -euo pipefail

timestamp=$(date +%s)
host="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
imageName="$host/k8s-demo-repo:$timestamp"

# Requires you to be logged in to the AWS CLI first
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$host"
docker build . -t "$imageName"
docker push "$imageName"

minikube image load "$imageName"

echo "tag: $timestamp"
