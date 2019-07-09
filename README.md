# Google kaniko v0.10.0 dockerized on Alpine Linux 3.10 for Gitlab CI Runners

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
you need to write a custom configuration for kaniko. Please replace `<registry>`,
`<username>` and `<password>` accordingly:

```yaml
build:
  stage: build
  image:
    name: registry.gitlab.com/griffinplus/gitlab-kaniko:latest
  script:
    - echo "{\"auths\":{\"<registry>\":{\"username\":\"<username>\",\"password\":\"<password>\"}}}" > /kaniko/.docker/config.json
    - kaniko-build
      --context $CI_PROJECT_DIR
      --dockerfile Dockerfile
      --destination <registry>/<image_path>:latest
```
