#!/bin/bash
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Update the registry.
find . -name sample.yaml -exec echo --- \; -exec cat {} \; -exec echo \; -exec echo \; >${SCRIPT_DIR}/registry.yaml

# And thanks
echo "Updated ${SCRIPT_DIR}/registry.yaml"
echo "Thanks for your contribution!"
