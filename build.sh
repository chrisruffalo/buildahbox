#!/bin/bash

# targets
TARGET_ORG=${TARGET_ORG:-"chrisruffalo"}
TARGET_REPO=${TARGET_REPO:-"buildahbox"}

# version related variables
VERSION=$(cat ./.version)
VERSION=${VERSION:-"SNAPSHOT"}
GITHASH=$(git rev-parse HEAD | head -c6)

# container
SRC_CONTAINER=${SRC_CONTAINER:-"fedora"}
SRC_TAG=${SRC_TAG:-"28"}

# version
PREFIX=${PREFIX:-""}
BUILD_TAG="${PREFIX}${VERSION}-git${GITHASH}"

# print status
printf "Building ${BUILD_TAG} based on ${SRC_CONTAINER}:${SRC_TAG}\n"

# use fedora or other modern centos with packages for buildah, podman, etc
WORKING_CONTAINER=$(./bin/buildah from ${SRC_CONTAINER}:${SRC_TAG})

# run install in container
./bin/buildah copy $WORKING_CONTAINER ./container/${SRC_CONTAINER}-build.sh /build.sh
./bin/buildah run $WORKING_CONTAINER -- /bin/bash /build.sh
./bin/buildah run $WORKING_CONTAINER -- rm -f /build.sh

# set up target directory and entrypoint
./bin/buildah run $WORKING_CONTAINER -- mkdir /working

# set working directory (/working) and volume hint. the entrypoint is the magic user changer. the default user is chosen for compatibility.
./bin/buildah config --workingdir /working --volume /var/lib/containers --entrypoint '["/usr/bin/buildah"]' $WORKING_CONTAINER

# commit image
./bin/buildah commit $WORKING_CONTAINER ${TARGET_ORG}/${TARGET_REPO}:${BUILD_TAG}

# remove build WORKING_CONTAINER
./bin/buildah rm $WORKING_CONTAINER

# status
printf "Commited image ${BUILD_TAG}\n"