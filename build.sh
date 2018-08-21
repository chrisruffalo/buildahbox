#!/bin/bash

# targets
TARGET_ORG=${TARGET_ORG:-"chrisruffalo"}
TARGET_REPO=${TARGET_REPO:-"buildahbox"}
# version related variables
VERSION=$(cat ./.version)
VERSION=${VERSION:-"SNAPSHOT"}
GITHASH=$(git rev-parse HEAD | head -c6)
# version
MAJOR_TAG="${VERSION}"
BUILD_TAG="${VERSION}-git${GITHASH}"
MAJOR_VER="${VERSION%%.*}"
MINOR_VER="${VERSION#*.}"
MINOR_VER="${MINOR_VER%%.*}"

# use fedora or other modern centos with packages for buildah, podman, etc
CONTAINER=$(./buildah from fedora:28)

# run install in container
./buildah run $CONTAINER -- yum update -y --setopt=tsflags=nodocs
./buildah run $CONTAINER -- yum install -y --setopt=tsflags=nodocs buildah podman runc skopeo
./buildah run $CONTAINER -- yum clean all
./buildah run $CONTAINER -- rm -rf /var/cache/yum/* 
./buildah run $CONTAINER -- rm -rf /var/lib/yum

# set up target directory and entrypoint
./buildah run $CONTAINER -- mkdir /working

# set working directory (/working) and volume hint. the entrypoint is the magic user changer. the default user is chosen for compatibility.
./buildah config --workingdir /working --volume /var/lib/containers --entrypoint '["/usr/bin/buildah"]' $CONTAINER

# commit image
./buildah commit $CONTAINER ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG}
./buildah tag ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} ${TARGET_ORG}/${TARGET_REPO}:latest

# remove build container
./buildah rm $CONTAINER