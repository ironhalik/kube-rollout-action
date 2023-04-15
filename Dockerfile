FROM ghcr.io/ironhalik/kubectl-action:v1.2

COPY kube-rollout-action.sh /usr/local/bin/kubectl-action.d/
