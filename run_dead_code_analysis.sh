#!/bin/sh

set -eu

. ./docker_env/make_docker.sh

run_in_docker "ci/dead_code_analysis.sh" || echo "Failed!"

exit 0
