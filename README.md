# BUILDAHBOX

## Overview

This is a containerized buildah/skopeo/runc/podman instance that allows you to use those tools somewhat transparently from a system that only supports Docker and that might not have compiled bianries for those things. With this toolkit you can keep your existing workflow on systems that only support Docker and use buildah and various other tools to support that workflow.

Buildahbox can build buildahbox but we don't use it to deploy and build with Travis-CI because it causes a circular dependency issue.

## Use

The chrisruffalo/buildahbox image is published for use anywhere. The included scripts create a stand-alone environment using pre-configured options. They do **not** attempt to use `/var/lib/containers` for buildah and so will not conflict with a locally running copy. Instead the scripts use `XDG_RUNTIME_DIR` (typically `/run/users/<USERID>` or `/var/run/users/<USERID>`) for both container configuration (to share podman configuration with the local host) and a directory called `buildahbox/containers` is created in the runtime directory to store container data created by buildahbox.

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