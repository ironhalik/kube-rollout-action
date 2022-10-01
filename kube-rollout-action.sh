# This code is meant to be used with
# https://github.com/ironhalik/kubectl-action-base
if [ ! -n "${IS_KUBECTL_ACTION_BASE}" ]; then
    echo "The script should be used on it's own!"
    exit 1
fi

# kube-rollout-action specific code
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
