#!/bin/bash

ARCH="armhf"

# common directory variables
SYSCONFDIR="${SYSCONFDIR:-/etc}"
SRC_DIR="$(pwd)"
BUILD_DIR_TEMPLATE="_build_${ARCH}"
BUILD_DIR="${BUILD_DIR:-${SRC_DIR}/${BUILD_DIR_TEMPLATE}}"

# Debian package information
PACKAGE_NAME="${PACKAGE_NAME:-libCharon}"
RELEASE_VERSION="${RELEASE_VERSION:-999.999.999}"

build()
{
    mkdir -p "${BUILD_DIR}"
    cd "${BUILD_DIR}" || return
    echo "Building with cmake"
    cmake \
        -DCMAKE_BUILD_TYPE=Debug \
        -DCMAKE_PREFIX_PATH="${CURA_BUILD_ENV_PATH}" \
        -DCPACK_PACKAGE_VERSION="${RELEASE_VERSION}" \
        ..
}

create_debian_package()
{
    make package
    cp ./*.deb ../ || true
}

cleanup()
{
    rm -rf "${BUILD_DIR:?}"
}

usage()
{
    echo "Usage: ${0} [OPTIONS]"
    echo "  -c   Explicitly cleanup the build directory"
    echo "  -h   Print this usage"
    echo "NOTE: This script requires root permissions to run."
}

while getopts ":hcs" options; do
    case "${options}" in
    c)
        cleanup
        exit 0
        ;;
    h)
        usage
        exit 0
        ;;
    s)
        # Ignore for compatibility with other build scripts
        ;;
    :)
        echo "Option -${OPTARG} requires an argument."
        exit 1
        ;;
    ?)
        echo "Invalid option: -${OPTARG}"
        exit 1
        ;;
    esac
done
shift "$((OPTIND - 1))"

cleanup
build
create_debian_package
