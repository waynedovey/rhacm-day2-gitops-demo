# BGD Argo Rollouts demo

This app is based on the Red Hat OpenShift GitOps Workshop `bgd` application image:

- `quay.io/rhdevelopers/bgd:1.0.0`

It replaces the normal Kubernetes `Deployment` with an Argo Rollouts `Rollout` and uses OpenShift Route traffic splitting.

## Sync order

| Wave | Resource | Why |
|---:|---|---|
| -5 | Namespace | Project first |
| -3 | Stable and canary services | Rollouts controller needs both services |
| -2 | OpenShift Route | Route starts at 100% stable / 0% canary |
| 0 | Rollout | Creates the app and controls progressive delivery |
| 5 | PostSync smoke test | Validates the stable service responds |

## Canary flow

Initial install sends 100% traffic to the stable version. A Git change to the Rollout pod template, for example changing `COLOR` from `blue` to `green`, starts a canary rollout:

1. 20% canary / 80% stable, then pause
2. Promote
3. 50% canary / 50% stable, then pause
4. Promote
5. 100% new version becomes stable

## Useful commands

```bash
oc --context dev-spoke -n bgd-rollouts-demo get rollout,svc,route,pods
oc --context dev-spoke -n bgd-rollouts-demo get route bgd -o yaml | egrep -A8 'to:|alternateBackends:'
kubectl-argo-rollouts --context dev-spoke get rollout bgd -n bgd-rollouts-demo --watch
```

Promote one step:

```bash
kubectl-argo-rollouts --context dev-spoke promote bgd -n bgd-rollouts-demo
```
