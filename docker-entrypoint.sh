#!/bin/bash
set -e
set -o pipefail

log_debug() {
    if [ -n "${RUNNER_DEBUG}" ]; then
        echo -e "${*}" | sed 's/^/[debug] /g'
    fi
}

echo "${INPUT_CONFIG}" > /tmp/config
if [ -n "${INPUT_CONTEXT}" ]; then
    kubectl config set-context "${INPUT_CONTEXT}"
fi
log_debug "Current kubectl context: $(kubectl config current-context)"

KUBECTL_ARGS="rollout status"
[ -n "${INPUT_RESOURCE}" ] && KUBECTL_ARGS="${KUBECTL_ARGS} ${INPUT_RESOURCE}"
[ -n "${INPUT_NAME}" ] && KUBECTL_ARGS="${KUBECTL_ARGS} ${INPUT_NAME}"
[ -n "${INPUT_NAMESPACE}" ] && KUBECTL_ARGS="${KUBECTL_ARGS} --namespace ${INPUT_NAMESPACE}"
[ -n "${INPUT_SELECTOR}" ] && KUBECTL_ARGS="${KUBECTL_ARGS} --selector ${INPUT_SELECTOR}"
[ -n "${INPUT_TIMEOUT}" ] && KUBECTL_ARGS="${KUBECTL_ARGS} --timeout ${INPUT_TIMEOUT}"

if [ -n "${INPUT_NAME}" ] && [ -n "${INPUT_SELECTOR}" ]; then
    echo "name and selector inputs cannot be used together."
    exit 1
fi

echo "Running: kubectl ${KUBECTL_ARGS}"
kubectl ${KUBECTL_ARGS} | tee /tmp/kubectl-output

if [ ! -s /tmp/kubectl-output ]; then 
    echo "Did not find any resources."
    exit 1
fi
