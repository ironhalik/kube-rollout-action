FROM ghcr.io/ironhalik/kubectl-action:v1.0

COPY kube-rollout-action.sh /usr/local/bin/kubectl-action.d/
