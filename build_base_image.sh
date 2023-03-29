#!/bin/bash

set -eu

function build_image() {
  tag_version=$1
  base_version=$2
  java_version=$3

  echo
  echo "----------------------------------------"
  echo "Building image version $tag_version from base image version $base_version..."
  docker build \
    --platform linux/amd64 \
    --build-arg "BASE_VERSION=$base_version" \
    --build-arg "JAVA_VERSION=$java_version" \
    --tag "gatlingcorp/docker-openjdk-base:$tag_version" \
    .
  echo "Built image gatlingcorp/docker-openjdk-base:$tag_version."
  echo "----------------------------------------"
}

build_image "latest-jre-headless" "20-jre-headless-latest" "20"
build_image "17-jre-headless" "17-jre-headless-latest" "17"
build_image "11-jre-headless" "11-jre-headless-latest" "11"
build_image "8-jre-headless" "8-jre-headless-latest" "8"
