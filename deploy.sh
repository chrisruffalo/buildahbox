#!/bin/bash

TARGET_PUSH=${TARGET_PUSH:-"docker://"}
TARGET_REGISTRY=${TARGET_REGISTRY:-"docker.io"}
TARGET_ORG=${TARGET_ORG:-"chrisruffalo"}
TARGET_REPO=${TARGET_REPO:-"buildahbox"}
TARGET="${TARGET_REGISTRY}/${TARGET_ORG}/${TARGET_REPO}"

# do remote push based on inputs
INPUT=$1
PUSH=${INPUT:-"0"} # default to 0/false

# get version from version file
VERSION=$(cat ./.version)
VERSION=${VERSION:-"SNAPSHOT"}
GITHASH=$(git rev-parse HEAD | head -c6)
# export output
MAJOR_TAG="${VERSION}"
BUILD_TAG="${VERSION}-git${GITHASH}"
MAJOR_VER="${VERSION%%.*}"
MINOR_VER="${VERSION#*.}"
MINOR_VER="${MINOR_VER%%.*}"

# remote push if true
./podman login --username "${DOCKERUSERNAME}" --password "${DOCKERPASSWORD}" ${TARGET_REGISTRY}
./buildah push ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} ${TARGET_PUSH}${TARGET_REGISTRY}/${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG}
./buildah push ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} ${TARGET_PUSH}${TARGET_REGISTRY}/${TARGET_ORG}/${TARGET_REPO}:${MAJOR_TAG}
./buildah push ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} ${TARGET_PUSH}${TARGET_REGISTRY}/${TARGET_ORG}/${TARGET_REPO}:${MAJOR_VER}.${MINOR_VER}
./buildah push ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} ${TARGET_PUSH}${TARGET_REGISTRY}/${TARGET_ORG}/${TARGET_REPO}:${MAJOR_VER}.X
./buildah push ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} ${TARGET_PUSH}${TARGET_REGISTRY}/${TARGET_ORG}/${TARGET_REPO}:latest