#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
REPO_DIR="$(cd ${SCRIPT_DIR}/../ && pwd)"

# Update the registry.
find ${REPO_DIR} -name sample.yaml -exec echo --- \; -exec cat {} \; -exec echo \; -exec echo \; >${REPO_DIR}/registry.yaml
git add ${REPO_DIR}/registry.yaml

# And thanks
echo "Updated ${REPO_DIR}/registry.yaml"
echo "Thanks for your contribution!"
