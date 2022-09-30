#!/bin/bash
set -e
set -o pipefail

[ -n "${INPUT_DEBUG}" ] && RUNNER_DEBUG=1

log_debug() {
    echo -e "${*}" | sed 's/^/::debug:: /g'
}

if [ -n "${INPUT_CONFIG}" ]; then
    if [[ "${INPUT_CONFIG}" =~ ^([A-Za-z0-9+/]{4})*([A-Za-z0-9+/]{3}=|[A-Za-z0-9+/]{2}==)?$ ]]; then
        log_debug "Looks like config is in base64. Decoding."
        echo "${INPUT_CONFIG}" | base64 -d > /tmp/config
    else
        log_debug "Looks like config is plain yaml. Using it like it."
        echo "${INPUT_CONFIG}" > /tmp/config
    fi
elif [ -n "${INPUT_EKS_CLUSTER}" ]; then
    log_debug "Using AWS CLI to get the cluster config..."
    aws_output=$(aws eks update-kubeconfig --name "${INPUT_EKS_CLUSTER}")
    log_debug "${aws_output}"
else
    echo "::error:: Either config or eks_cluster must be specified."
    exit 1
fi
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
