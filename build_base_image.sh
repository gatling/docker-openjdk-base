#!/bin/bash

set -eux

java_version="$1"
if [ -z "${2-}" ]; then
  target_version="$java_version"
else
  target_version="$2"
fi

base_image="azul/zulu-openjdk:$java_version-jre-headless-latest"
target_image="gatlingcorp/openjdk-base:$target_version-jre-headless"

docker build \
  --platform linux/amd64 \
  --build-arg "BASE_IMAGE=$base_image" \
  --build-arg "JAVA_VERSION=$java_version" \
  --tag "$target_image" \
  .

docker push "$target_image"
