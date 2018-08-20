# BUILDAHBOX

## Overview

This is a containerized buildah/skopeo/runc/podman instance that allows you to use those tools somewhat transparently from a system that only supports Docker and that might not have compiled bianries for those things. With this toolkit you can keep your existing workflow on systems that only support Docker and use buildah and various other tools to support that workflow.

Buildahbox can build buildahbox.

## Use

The chrisruffalo/buildahbox image is published for use anywhere. The included scripts create a stand-alone environment using pre-configured options. They do **not** attempt to use `/var/lib/containers` for buildah and so will not conflict with a locally running copy. Instead the script creates a ".containers" directory local to where the script is run. The `podman` script also mounts the `XDG_USER_DIR` (typically /var/run/users/<USERID>/) inside the container to maintain compatibility in case you have already logged in with podman.

Sample buildah usage:
```bash
[buildahbox]$ CONTAINER=$(./buildah from alpine)
[buildahbox]$ ./buildah run $CONTAINER -- apk add --no-cache git
[buildahbox]$ ./buildah commit $CONTAINER alpine-git:latest
```

Sample podman usage:
```bash
[buildahbox]$ ./podman login docker.io --username MYSUER --password MYPASS
``

