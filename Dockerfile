FROM ghcr.io/ironhalik/kubectl-action:v1.1

COPY kube-rollout-action.sh /usr/local/bin/kubectl-action.d/
