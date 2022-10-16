A simple action providing kubectl and its configuration.  

----
### Example usage:
```
steps:
# Will watch all deployments labeled with current commit.
- name: Watch rollout
  uses: ironhalik/kube-rollout-action@v1
  with:
    config: ${{ secrets.CONFIG }} # base64 encoded or neat
    namespace: my-awesome-app
    selector: commit==${{ github.sha }}
```

Supported inputs are: 
- `debug` can be enabled explicitly via action input, or is implicitly enabled when a job is rerun with debug enabled. Will make kubectl and related scripts verbose.
- `config` kubectl config file. Can be either a whole config file (e.g. via ${{ secrets.CONFIG }}), or base64 encoded.
- `eks_cluster` The name of the EKS cluster to get config for. Will use AWS CLI to generate a valid config. Will need standard `aws-cli` env vars and eks:DescribeCluster permission. Mutually exclusive with `config`.
- `context` kubectl config context to use. Not needed if the config has a context already selected.
- `eks_role_arn` IAM role ARN that should be assumed by `aws-cli` when interacting with EKS cluster.
- `namespace` namespace to use. You can use env vars here.
- `resource` resource to watch.
- `name` name of the deployment to watch. Incompatible with selector.
- `selector` kubectl selector for the deployments to watch. Incompatible with name.
- `timeout` How long to try tailing for.

Many thanks to the creators of the tools included:  
[kubectl](https://github.com/kubernetes/kubectl), [helm](https://github.com/helm/helm), [stern](https://github.com/wercker/stern), [aws-cli](https://github.com/aws/aws-cli)