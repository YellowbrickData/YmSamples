SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

ln -sf "${SCRIPT_DIR}/scripts/pre-commit" "${SCRIPT_DIR}/.git/hooks"
echo "Setup commit hook for registry.yaml maintenance"
