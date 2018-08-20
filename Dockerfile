FROM fedora:28

# install minimal required packages
RUN yum update -y --setopt=tsflags=nodocs && \
    yum install -y --setopt=tsflags=nodocs buildah podman runc skopeo && \
    yum clean all && \
    rm -rf /var/cache/yum/* && \
    rm -rf /var/lib/yum && \
    mkdir /working

# set the working directory
WORKDIR /working

# the filesystem mounted here needs to not be overlayfs (so volumes won't work)
VOLUME /var/lib/containers

# default entry point
ENTRYPOINT ["/usr/bin/buildah"]
