#!/bin/bash

TARGET_REGISTRY=${TARGET_REGISTRY:-"docker.io"}
TARGET_ORG=${TARGET_ORG:-"chrisruffalo"}
TARGET_REPO=${TARGET_REPO:-"buildah"}
TARGET="${TARGET_REGISTRY}/${TARGET_ORG}/${TARGET_REPO}"

# do remote push based on inputs
INPUT=$1
PUSH=${INPUT:-"0"} # default to 0/false

# get version from version file
VERSION=$(cat ./.version)
VERSION=${VERSION:-"SNAPSHOT"}
GITHASH=$(git rev-parse HEAD | head -c6)
# export output
export MAJOR_TAG="${VERSION}"
export BUILD_TAG="${VERSION}-git${GITHASH}"
export MAJOR_VER="${VERSION%%.*}"
MINOR_VER="${VERSION#*.}"
export MINOR_VER="${MINOR_VER%%.*}"

# use dockerfile to create minimal scratch container
docker build --rm -t ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} .

# remote push if true
if [ $PUSH -eq 1 ]; then
	docker login --username "${DOCKERUSERNAME}" --password "${DOCKERPASSWORD}" ${TARGET_REGISTRY}
	docker tag ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} ${TARGET}:${BUILD_TAG}
	docker tag ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} ${TARGET}:${MAJOR_TAG}
	docker tag ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} ${TARGET}:${MAJOR_VER}.${MINOR_VER}
	docker tag ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} ${TARGET}:${MAJOR_VER}.X
	docker tag ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} ${TARGET}:latest
	docker push ${TARGET}:${BUILD_TAG}
	docker push ${TARGET}:${MAJOR_TAG}
	docker push ${TARGET}:${MAJOR_VER}.${MINOR_VER}
	docker push ${TARGET}:${MAJOR_VER}.X
	docker push ${TARGET}:latest
fi