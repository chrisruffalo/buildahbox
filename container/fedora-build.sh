#!/bin/bash

# install target binaries
dnf upgrade-minimal -y --setopt=tsflags=nodocs
dnf install -y --setopt=tsflags=nodocs buildah podman runc skopeo

# clean out dnf/yum/rpm artifacts and reduce size of rpmdb to match
dnf clean all
rm -rf /var/cache/yum/* 
rm -rf /var/lib/yum

# remove logs from rpm/build process
rm -rf /var/log/{dnf*,anaconda/*}
