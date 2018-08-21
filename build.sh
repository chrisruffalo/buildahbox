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
CONTAINER=$(./bin/buildah from fedora:28)

# run install in container
./bin/buildah run $CONTAINER -- dnf upgrade-minimal -y --setopt=tsflags=nodocs
./bin/buildah run $CONTAINER -- dnf install -y --setopt=tsflags=nodocs buildah podman runc skopeo

# clean out dnf/yum/rpm artifacts and reduce size of rpmdb to match
./bin/buildah run $CONTAINER -- dnf clean all
./bin/buildah run $CONTAINER -- rm -rf /var/cache/yum/* 
./bin/buildah run $CONTAINER -- rm -rf /var/lib/yum

# remove logs from rpm/build process
./bin/buildah run $CONTAINER -- rm -rf /var/log/{dnf*,anaconda/*}

# set up target directory and entrypoint
./bin/buildah run $CONTAINER -- mkdir /working

# set working directory (/working) and volume hint. the entrypoint is the magic user changer. the default user is chosen for compatibility.
./bin/buildah config --workingdir /working --volume /var/lib/containers --entrypoint '["/usr/bin/buildah"]' $CONTAINER

# commit image
./bin/buildah commit $CONTAINER ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG}
./bin/buildah tag ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG} ${TARGET_ORG}/${TARGET_REPO}:latest

# remove build container
./bin/buildah rm $CONTAINER