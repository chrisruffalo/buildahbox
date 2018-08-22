#!/bin/bash

# git tags
CRIO_BRANCH="v1.11.1"
CNI_BRANCH="v0.7.3"
RUNC_BRANCH="b4e2ecb"
BUILDAH_BRANCH="v1.3"
SKOPEO_BRANCH="master"
LIBPOD_BRANCH="v0.8.2.1"

# keep original dir
ORIGDIR=$(pwd)

# backports for proper golang version
echo "deb http://ftp.debian.org/debian stretch-backports main" > /etc/apt/sources.list.d/stretch-backports.list

# update again with new repos (project atomic, etc)
apt update

# install packages
apt -y install -t stretch-backports libostree-dev libostree-1-1 golang-1.8
apt -y install curl bats btrfs-tools git libapparmor-dev libdevmapper1.02.1 libdevmapper-dev libglib2.0-dev libgpgme11-dev libseccomp2 libseccomp-dev libselinux1 libselinux1-dev go-md2man build-essential python3-setuptools

# set up gopath and gopath root
export GOPATH=${HOME}/go
mkdir -p $GOPATH
cd $GOPATH

# export go to path
export PATH=/usr/lib/go-1.8/bin:$PATH

# cri-o (https://github.com/containers/libpod/blob/master/docs/tutorials/podman_tutorial.md#installing-runc)
git clone https://github.com/kubernetes-incubator/cri-o $GOPATH/src/github.com/kubernetes-incubator/cri-o
cd $GOPATH/src/github.com/kubernetes-incubator/cri-o
git checkout $CRIO_BRANCH
mkdir bin
make bin/conmon
if [[ $? != 0 ]]; then
	printf "Could not build 'conmon' from cri-o\n"
	exit $?	
fi
install -D -m 755 bin/conmon /usr/libexec/podman/conmon

# install configuration files (https://github.com/containers/libpod/blob/master/docs/tutorials/podman_tutorial.md#installing-runc)
mkdir -p /etc/containers
curl https://raw.githubusercontent.com/projectatomic/registries/master/registries.fedora -o /etc/containers/registries.conf
curl https://raw.githubusercontent.com/containers/skopeo/master/default-policy.json -o /etc/containers/policy.json
curl https://raw.githubusercontent.com/containers/skopeo/master/contrib/storage.conf -o /etc/containers/storage.conf

# CNI plugins (https://github.com/containers/libpod/blob/master/docs/tutorials/podman_tutorial.md#installing-runc)
git clone https://github.com/containernetworking/plugins.git $GOPATH/src/github.com/containernetworking/plugins
cd $GOPATH/src/github.com/containernetworking/plugins
git checkout $CNI_BRANCH
./build.sh
mkdir -p /usr/libexec/cni
cp bin/* /usr/libexec/cni

# runc (https://github.com/containers/libpod/blob/master/docs/tutorials/podman_tutorial.md#installing-runc)
git clone https://github.com/opencontainers/runc.git $GOPATH/src/github.com/opencontainers/runc
cd $GOPATH/src/github.com/opencontainers/runc
git checkout $RUNC_BRANCH
make static BUILDTAGS="apparmor selinux seccomp"
if [[ $? != 0 ]]; then
	printf "Could not build 'runc'\n"
	exit $?	
fi
cp runc /usr/bin/runc

# buildah (https://github.com/projectatomic/buildah/blob/master/install.md)
git clone https://github.com/projectatomic/buildah $GOPATH/src/github.com/projectatomic/buildah
cd $GOPATH/src/github.com/projectatomic/buildah
git checkout $BUILDAH_BRANCH
make all TAGS="apparmor selinux seccomp"
if [[ $? != 0 ]]; then
	printf "Could not build 'buildah'\n"
	exit $?	
fi
make install PREFIX=/usr

# skopeo (https://github.com/containers/skopeo)
git clone https://github.com/containers/skopeo $GOPATH/src/github.com/containers/skopeo
cd $GOPATH/src/github.com/containers/skopeo
git checkout $SKOPEO_BRANCH
make binary-local
if [[ $? != 0 ]]; then
	printf "Could not build 'skopeo'\n"
	exit $?	
fi
make install

# podman (https://github.com/containers/libpod/blob/master/docs/tutorials/podman_tutorial.md#installing-runc)
git clone https://github.com/containers/libpod/ $GOPATH/src/github.com/containers/libpod
cd $GOPATH/src/github.com/containers/libpod
git checkout $LIBPOD_BRANCH
make
if [[ $? != 0 ]]; then
	printf "Could not build 'podman'\n"
	exit $?	
fi
make install PREFIX=/usr

# return to original dir
cd $ORIGDIR

# remove libraries and other unused packages
apt-get purge -y curl git golang-1.8 bats build-essential python3-setuptools go-md2man libapparmor-dev libdevmapper-dev libglib2.0-dev libgpgme11-dev libseccomp-dev libostree-dev libselinux1-dev gcc
apt-get -y autoremove
apt-get clean
apt-get autoclean

# full clean apt cache directory
rm -rf /var/lib/apt/lists/*

# remove files that are no longer needed
rm -f /etc/apt/sources.list.d/stretch-backports.list 

# remove unused sources
rm -rf $GOPATH/*

# remove logs
rm -rf /var/log/*

# check to ensure that each binary has all of the libraries it needs still installed