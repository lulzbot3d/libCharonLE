#!/bin/sh
#
# Copyright (C) 2019 Ultimaker B.V.
#

set -eu

DOCKER_BUILD_ONLY_CACHE="${DOCKER_BUILD_ONLY_CACHE:-no}"
DOCKER_IMAGE_NAME="${DOCKER_IMAGE_NAME:-libcharon}"
DOCKER_REGISTRY_NAME="ghcr.io/lulzbot3d/${DOCKER_IMAGE_NAME}"

echo "Checking for image updates"

# Creates a new docker driver named "ultimaker" if it doesnt exist yet.
docker buildx create --name lulzbot3d --driver=docker-container 2> /dev/null || true

if [ "${DOCKER_BUILD_ONLY_CACHE}" = "yes" ]; then
    docker buildx build --builder lulzbot3d --cache-to "${DOCKER_REGISTRY_NAME}" --cache-from "${DOCKER_REGISTRY_NAME}" -f docker_env/Dockerfile -t "${DOCKER_IMAGE_NAME}" .
else
    docker buildx build --builder lulzbot3d --load --cache-from "${DOCKER_REGISTRY_NAME}" -f docker_env/Dockerfile -t "${DOCKER_IMAGE_NAME}" .

    if ! docker run --rm --privileged "${DOCKER_IMAGE_NAME}" "./buildenv_check.sh"; then
        echo "Something is wrong with the build environment, please check your Dockerfile."
        docker image rm "${DOCKER_IMAGE_NAME}"
        exit 1
    fi
fi;

DOCKER_WORK_DIR="${WORKDIR:-/build/libcharon}"
PREFIX="/usr"

run_in_docker()
{
    echo "Running '${*}' in docker."
    docker run \
        --rm \
        --privileged \
        -u "$(id -u):$(id -g)" \
        -v "$(pwd):${DOCKER_WORK_DIR}" \
        -v "$(pwd)/../:${DOCKER_WORK_DIR}/.." \
        -e "USE_DUMMY_DBUS=true" \
        -e "PYTHONPATH=:../dbus-interface-lib:../libpalantir:../libPalantir:../charon:../libCharon:../libsmeagol:../libSmeagol:../marvin-service/src:../libLogger:../ultiLib/libs:../mqttHandler" \
        -e "PREFIX=${PREFIX}" \
        -e "RELEASE_VERSION=${RELEASE_VERSION:-}" \
        -e "ONLY_CHECK_STAGED=${ONLY_CHECK_STAGED:-}" \
        -w "${DOCKER_WORK_DIR}" \
        "${DOCKER_IMAGE_NAME}" \
        "${@}"
}
