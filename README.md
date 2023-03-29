# docker-openjdk-base

## Build one version manually

Note: use `--platform linux/amd64` if running on an ARM platform (e.g. Apple Silicon), as we only support amd64 architecture for now. 

Example:

```shell
docker build \
  --platform linux/amd64 \
  --build-arg "base_version=20-jre-headless-latest" \
  --tag gatlingcorp/docker-openjdk-base:local \
  .
```

## Build all versions

```shell
./build_base_image.sh
```
