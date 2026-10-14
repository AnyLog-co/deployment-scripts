#!/usr/bin/env bash

LOCAL="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --local) LOCAL=true; shift ;;
    *) shift ;;
  esac
done

IMAGE="anylogco/deployment-scripts"
BRANCH=$(git branch --show-current)
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${BRANCH}" == "main" ]] ; then
  TAG="latest"
else
  TAG_VERSION=$(grep ^version ${SOURCE_DIR}/setup.cfg | awk -F " = " '{print $2}' | awk -F " " '{print $1}' | xargs)
  TAG_COMMIT=$(grep ^version ${SOURCE_DIR}/setup.cfg | grep -oE '[a-f0-9]{6,}' | tail -1)
  TAG=${TAG_VERSION}-${TAG_COMMIT}
fi
if [[ -z ${TAG} ]]  ;  then TAG=$(git branch --show-current) ; fi

if [[ "${LOCAL}" == "true" ]] ; then
  docker build -f Dockerfile . -t ${IMAGE}:${TAG}
else
  docker buildx build --platform linux/amd64,linux/arm64 -f Dockerfile . -t ${IMAGE}:${TAG} --push
fi
