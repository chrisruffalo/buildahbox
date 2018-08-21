# BUILDAHBOX

## Overview
This is a containerized buildah/skopeo/runc/podman instance that allows you to use those tools somewhat transparently from a system that only supports Docker and that might not have compiled bianries for those things. With this toolkit you can keep your existing workflow on systems that only support Docker and use buildah and various other tools to support that workflow.

Buildahbox is built with buildahbox.

## Container
The container is hosted in the Docker Hub [here](https://hub.docker.com/r/chrisruffalo/buildahbox/).

## Use
The chrisruffalo/buildahbox image is published for use anywhere. The included scripts create a stand-alone environment using pre-configured options. They do **not** attempt to use `/var/lib/containers` for buildah and so will not conflict with a locally running copy. Instead the scripts use a `.buildahbox` directory in the user home. This ensures that `buildah` and other tools have a shot at having enough disk space to complete tasks.

For `podman` configuration (especially shared between runs and with local podman) the variable `XDG_RUNTIME_DIR` (typically `/run/user/<USERID>` or `/var/run/user/<USERID>`) is used to mount the run directory into the container.

Sample buildah usage:
```bash
[buildahbox]$ CONTAINER=$(./buildah from alpine)
[buildahbox]$ ./buildah run $CONTAINER -- apk add --no-cache git
[buildahbox]$ ./buildah commit $CONTAINER alpine-git:latest
```

Sample podman usage:
```bash
[buildahbox]$ ./podman login docker.io --username MYSUER --password MYPASS
```

## Building
As mentioned in the overview this project can build and deploy itself. To build with a local version of `buildah` you should set the environment variable `BUILDAHBOOTSTRAP` to any non-empty value. This will cause the system to use the locally installed `buildah` executable instead of pulling the `chrisruffalo/buildabox:latest` image. The bootstrap will store the image in `/var/lib/containers` using the default `buildah` configuration and locations.

```bash
[buildahbox]$ export BUILDAHBOOTSTRAP="1"
[buildahbox]$ ./build.sh
[buildahbox]$ export BUILDAHBOOTSTRAP=""
```