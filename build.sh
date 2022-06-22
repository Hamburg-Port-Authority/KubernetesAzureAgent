#! /bin/bash
LAST_TAG=$(git describe --abbrev=0 --tags HEAD)
echo "Building azure agent image with tag $LAST_TAG"

docker \
    build . \
    -f src/docker/Dockerfile \
    -t ghcr.io/deb4sh/kubernetes-azure-agent:$LAST_TAG
    