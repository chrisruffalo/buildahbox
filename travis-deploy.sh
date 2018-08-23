#!/bin/bash

# set VERSION to the travis pull request/branch version
export VERSION=${TRAVIS_PULL_REQUEST_BRANCH:-$TRAVIS_BRANCH}

# since travis only accepts one "script" deploy instruction...
./deploy.sh
PREFIX="debian-" ./deploy.sh