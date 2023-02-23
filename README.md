# internal-runtime-def

## required changes:

1. fork this repository (or copy it in any other way) into your own organization's git provider
1. replace all occurences of `<private_registry>` with your own docker registry
1. in `manifests/runtime.yaml`, replace `github.com/codefresh-contrib/internal-runtime-def-example` with your fork (or manual copy) of this repository
1. get the "Raw" link to `manifests/runtime.yaml`
1. run the install command with `--runtime-def`:
```shell
cf runtime install <runtime_name> --runtime-def <runtime_yaml_raw_link> ...
```

## for unprivileged install:

1. update `<runtime-namespace>` to final value in `manifests/argo-cd/cluster-resources/ns.yaml` and `manifests/argo-cd/cluster-resources/kustomization.yaml`
1. run the following command with a privileged user:
```shell
kustomize build manifests/argo-cd/clsuter-resources | kubectl apply -f -
```
3. continue with standard install process
1. after argo-cd is up and running in the clsuter (and runtime is ready) - edit `manifests/argo-cd/kustomization.yaml` and remove all `$delete` patches (argo-cd can now manage cluster-wide resources)

## image list for runtime 0.1.20:
```
argo-cd
-------
quay.io/codefresh/argocd:v2.4.15-cap-CR-15677-rollout-rollback
ghcr.io/dexidp/dex:v2.35.3-distroless
quay.io/codefresh/redis:7.0.4-alpine

argo-events
-----------
quay.io/codefresh/argo-events:v1.7.2-cap-CR-14600
nats-streaming:0.22.1
natsio/prometheus-nats-exporter:0.8.0
natsio/prometheus-nats-exporter:0.9.1
natsio/nats-server-config-reloader:0.7.0
nats:2.8.1
nats:2.8.2
nats:2.8.1-alpine
nats:2.8.2-alpine

argo-rollouts
-------------
quay.io/codefresh/argo-rollouts:v1.2.0-cap-CR-10626

argo-workflows
--------------
quay.io/codefresh/argocli:v3.4-cap-CR-15902
quay.io/codefresh/argoexec:v3.4-cap-CR-15902
quay.io/codefresh/workflow-controller:v3.4-cap-CR-15902

app-proxy
---------
quay.io/codefresh/cap-app-proxy:1.2056.0
alpine:3.16

internal-router
---------------
nginx:1.22-alpine

sealed-secrets
--------------
quay.io/codefresh/sealed-secrets-controller:v0.17.5

tunnel-client
-------------
quay.io/codefresh/frpc:2022.10.09-b0811fd
```
