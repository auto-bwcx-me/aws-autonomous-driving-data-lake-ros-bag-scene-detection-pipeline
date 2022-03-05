#!/bin/bash

# setting default region of ap-southeast-1
if [ $# -ne 1 ]; then
    rg="ap-southeast-1"
else
    rg=$1
fi

# define region list
rg_list=("us-east-1" "us-east-2" "us-west-1" "us-west-2" "af-south-1" "ap-east-1" "ap-south-1" "ap-southeast-1" "ap-southeast-2" "ap-southeast-3" "ap-northeast-1" "ap-northeast-2" "ap-northeast-3" "ca-central-1" "eu-central-1" "eu-west-1" "eu-west-2" "eu-west-3" "eu-south-1" "eu-north-1" "me-south-1" "sa-east-1")

# check input region is right
find="0"
for i in ${rg_list[@]}; do
    if [ $i == $rg ]; then
        find="1"
        break
    fi
done

# if find it
if [ $find == "1" ]; then
    echo "Find region of $rg, try to change the configuration"

    # specific for Mac and Linux
    uname -a | grep Darwin >/dev/null
    if [ $? -eq 0 ]; then
        echo "config region for cdk.json"
        sed -i "" "s/\"region\": \"[a-z]*-[a-z]*-[1-9]*\"/\"region\": \"$rg\"/" cdk.json
        echo "config region for deploy.sh"
        sed -i "" "s/^run_region=\"[a-z]*-[a-z]*-[1-9]*\"/run_region=\"$rg\"/" deploy.sh
        echo "config region for detect_scenes.py"
        sed -i "" "s/^run_region=\"[a-z]*-[a-z]*-[1-9]*\"/run_region=\"$rg\"/" spark_scripts/detect_scenes.py
        echo "config region for synchronize_topics.py"
        sed -i "" "s/^run_region=\"[a-z]*-[a-z]*-[1-9]*\"/run_region=\"$rg\"/" spark_scripts/synchronize_topics.py
    else
        echo "config region for cdk.json"
        sed -i "s/\"region\": \"[a-z]*-[a-z]*-[1-9]*\"/\"region\": \"$rg\"/" cdk.json
        echo "config region for deploy.sh"
        sed -i "s/^run_region=\"[a-z]*-[a-z]*-[1-9]*\"/run_region=\"$rg\"/" deploy.sh
        echo "config region for detect_scenes.py"
        sed -i "s/^run_region=\"[a-z]*-[a-z]*-[1-9]*\"/run_region=\"$rg\"/" spark_scripts/detect_scenes.py
        echo "config region for synchronize_topics.py"
        sed -i "s/^run_region=\"[a-z]*-[a-z]*-[1-9]*\"/run_region=\"$rg\"/" spark_scripts/synchronize_topics.py
    fi
    aws configure set region $rg
else
    echo "Region not exist"
    exit 1
fi
