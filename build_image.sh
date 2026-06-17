#!/usr/bin/env bash

LOCAL="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --local) LOCAL=true; shift ;;
    *) shift ;;
  esac
done

IMAGE="anylogco/deployment-scripts"
TAG=$(git branch --show-current)


if [[ "${TAG}" == "main" ]] ; then TAG="latest" ; fi

if [[ "${LOCAL}" == "true" ]] ; then
  docker build -f Dockerfile . -t ${IMAGE}:${TAG}
else
  echo docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile . -t ${IMAGE}:${TAG} --push
fi
