#!/bin/bash
set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

BASE_IMAGE="ubuntu:16.04"
TAG="openpilot-tools"
if [ "$RPI" = "1" ]; then
    BASE_IMAGE="armv7/armhf-ubuntu:16.04"
    TAG="openpilot-tools:rpi"
fi

cd $DIR
docker build --build-arg BASE_IMAGE=${BASE_IMAGE} -t ${TAG} -f ./Dockerfile .
