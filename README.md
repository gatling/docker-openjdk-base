# docker-openjdk-base

## Build one version manually

Supported platforms: `linux/amd64`, `linux/arm64`

Example:

```shell
docker build \
  --platform linux/amd64 \
  --build-arg BASE_IMAGE=azul/zulu-openjdk:25-jre-headless-latest \
  --build-arg JAVA_VERSION=25 \
  --build-arg TARGETPLATFORM=linux/amd64 \
  --tag gatlingcorp/openjdk-base:local \
  .
```
