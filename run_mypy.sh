#!/bin/sh

set -eu

. ./docker_env/make_docker.sh

git fetch

run_in_docker "ci/mypy.sh" || echo "Failed!"

exit 0
