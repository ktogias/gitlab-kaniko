# Google kaniko v0.10.0 dockerized on Alpine Linux 3.10 for Gitlab CI Runners

[![Pipeline Status](https://gitlab.com/griffinplus/gitlab-kaniko/badges/master/pipeline.svg)](https://gitlab.com/griffinplus/gitlab-kaniko/commits/master)
[![Docker Pulls](https://img.shields.io/docker/pulls/griffinplus/gitlab-kaniko.svg)](https://hub.docker.com/r/griffinplus/gitlab-kaniko)

## Overview

This projects builds a docker image containing [kaniko](https://github.com/GoogleContainerTools/kaniko)
shipped on top of Alpine Linux prepared for use on a *Gitlab CI Runner*.
The call to the kaniko `executor` application is wrapped into a script called
`kaniko-build` that sets up the kaniko configuration file according to environment
variables set on a *Gitlab CI Runner*. By default the configuration only contains
the credentials needed to push the built image to the registry of the Gitlab
project being built.

The image also contains the following tools commonly needed when working with
repositories on Gitlab:

- `curl`
- `git`

## Usage

To build the docker image specified by the `Dockerfile` in the root of your
project's repository and push the image to the Gitlab container registry of the
project, you can put something like this into your `.gitlab-ci.yml`:

```yaml
build:
  stage: build
  image:
    name: registry.gitlab.com/griffinplus/gitlab-kaniko:latest
  script:
    - kaniko-build
      --context $CI_PROJECT_DIR
      --dockerfile Dockerfile
      --destination $CI_REGISTRY_IMAGE:latest
```

If you want to push the image to some other registry, e.g. the [Docker Hub](https://hub.docker.com),
you need to write a custom configuration for kaniko. Note that if you provide your
own configuration, you should use `/kaniko/executor` instead of `kaniko-build`.
Please replace `<registry>`, `<username>` and `<password>` accordingly:

```yaml
build:
  stage: build
  image:
    name: registry.gitlab.com/griffinplus/gitlab-kaniko:latest
  script:
    - echo "{\"auths\":{\"<registry>\":{\"username\":\"<username>\",\"password\":\"<password>\"}}}" > /kaniko/.docker/config.json
    - /kaniko/executor
      --context $CI_PROJECT_DIR
      --dockerfile Dockerfile
      --destination <registry>/<image_path>:latest
```

The examples above pull the image from our Gitlab container registry
(`registry.gitlab.com/griffinplus/gitlab-kaniko`). Alternatively you can pull it
from the [Docker Hub](https://hub.docker.com/r/griffinplus/gitlab-kaniko) as well.
Simply replace the image name with `registry.hub.docker.com/griffinplus/gitlab-kaniko:latest`
or shorter `griffinplus/gitlab-kaniko:latest`.

## Customization

If you want to customize the CI image to fit your requirements, or simply if you
don't trust our images in the project's registry, you can fork this project and
let Gitlab CI runners build your own copy of the image fully under your control.
The scripts in this project do not contain any hardcoded stuff. Everything is
taken from the build environment, so after forking and running the CI pipeline
you should end up with the image in the container registry of your forked project.

If you want your image to be pushed to an external container registry, e.g.
the [Docker Hub](https://hub.docker.com), you can set the following environment
variables on your CI pipeline:

- `RELEASE_REGISTRY` (use `registry.hub.docker.com` for the *Docker Hub*)
- `RELEASE_REGISTRY_IMAGE` (name of the image incl. registry, e.g. `registry.hub.docker.com/griffinplus/gitlab-kaniko`)
- `RELEASE_REGISTRY_USER` (name of a user that is allowed to push the specified image)
- `RELEASE_REGISTRY_PASSWORD` (password of the user that is allowed to push the specified image)

After setting these variables, the next push to the *master* branch will trigger
pushing the image to the specified container registry.
