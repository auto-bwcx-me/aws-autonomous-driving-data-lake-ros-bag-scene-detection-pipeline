#!/bin/bash

cmd=$1
build=$2

run_region="ap-southeast-1"

REPO_NAME=rosbag-scenes-detection  # Should match the ecr repository name given in config.json
IMAGE_NAME=rosbag-scenes-detection # Should match the image name given in config.json

python3 -m venv .env
source .env/bin/activate
pip install -r requirements.txt | grep -v 'already satisfied'

if [ $build = true ]; then
  docker build ./service -t $IMAGE_NAME:latest
  last_image_id=$(docker images | awk '{print $3}' | awk 'NR==2')
  account=$(aws sts get-caller-identity --query Account --output text)
  docker tag $last_image_id $account.dkr.ecr.${run_region}.amazonaws.com/$REPO_NAME
  echo login ecr
  aws ecr get-login-password --region ${run_region} | docker login --username AWS --password-stdin $account.dkr.ecr.${run_region}.amazonaws.com
  echo docker push $account.dkr.ecr.${run_region}.amazonaws.com/$REPO_NAME
  aws ecr describe-repositories --repository-names $REPO_NAME || aws ecr create-repository --repository-name $REPO_NAME
  docker push $account.dkr.ecr.${run_region}.amazonaws.com/$REPO_NAME
else
  echo Skipping build
fi

cdk $cmd --region ${run_region} --all --require-approval never
