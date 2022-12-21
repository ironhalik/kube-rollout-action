# shellcheck shell=bash
# This code is meant to be used with
# https://github.com/ironhalik/kubectl-action-base
if [ -z "${IS_KUBECTL_ACTION_BASE}" ]; then
    echo "::error:: The script is not meant to be used on it's own."
    exit 1
fi

# kube-rollout-action specific code
# prep inputs
RESOURCE="${INPUT_RESOURCE:-${RESOURCE}}"
NAME="${INPUT_NAME:-${NAME}}"
SELECTOR="${INPUT_SELECTOR:-${SELECTOR}}"
TIMEOUT="${INPUT_TIMEOUT:-${TIMEOUT}}"

if [ -n "${NAME}" ] && [ -n "${SELECTOR}" ]; then
    log error "name and selector inputs cannot be used together."
    exit 1
fi

KUBECTL_ARGS="rollout status"
[ -n "${RESOURCE}" ] && KUBECTL_ARGS="${KUBECTL_ARGS} ${RESOURCE}"
[ -n "${NAME}" ] && KUBECTL_ARGS="${KUBECTL_ARGS} ${NAME}"
[ -n "${SELECTOR}" ] && KUBECTL_ARGS="${KUBECTL_ARGS} --selector ${SELECTOR}"
[ -n "${TIMEOUT}" ] && KUBECTL_ARGS="${KUBECTL_ARGS} --timeout ${TIMEOUT}"

log info "Running: kubectl ${KUBECTL_ARGS}"
# shellcheck disable=SC2086
kubectl ${KUBECTL_ARGS} | tee /tmp/kubectl-output

if [ ! -s /tmp/kubectl-output ]; then 
    log error "Did not find any resources."
    exit 1
fi
