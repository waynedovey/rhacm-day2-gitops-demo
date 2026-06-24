# BGD progressive delivery demo with OpenShift GitOps Rollouts

This demo uses the Red Hat workshop BGD app image:

```text
quay.io/rhdevelopers/bgd:1.0.0
```

It turns the normal BGD `Deployment` into an Argo Rollouts `Rollout` and uses OpenShift Route traffic splitting:

```text
Route bgd
├── bgd-stable service: 100% initially
└── bgd-canary service: 0% initially
```

When you change the Rollout pod template in Git, Argo CD syncs the change and Argo Rollouts gradually moves traffic:

```text
20% canary → pause → 50% canary → pause → 100% stable
```

## Prerequisites

Each target cluster needs:

1. Red Hat OpenShift GitOps installed
2. A `RolloutManager` created in `openshift-gitops`
3. The Argo Rollouts CLI plugin if you want to promote from the command line

Install the CLI plugin on macOS:

```bash
brew install argoproj/tap/kubectl-argo-rollouts
```

Use the standalone binary form in this repo:

```bash
kubectl-argo-rollouts --context dev-spoke get rollout bgd -n bgd-rollouts-demo
kubectl-argo-rollouts --context dev-spoke promote bgd -n bgd-rollouts-demo
```

Do not use `oc --context dev-spoke argo rollouts ...`; that puts the context flag before the plugin name and can fail with `flags cannot be placed before plugin name`.

This repo includes an RHACM policy to create the `RolloutManager`:

```text
policies/policy-enable-openshift-gitops-rollouts.yaml
```

## Deploy to dev

Commit and push the repo, then refresh ApplicationSets:

```bash
oc config use-context hub
oc -n openshift-gitops annotate applications.argoproj.io/rhacm-day2-applicationsets \
  argocd.argoproj.io/refresh=hard --overwrite
```

Check dev:

```bash
oc --context dev-spoke -n bgd-rollouts-demo get rollout,svc,route,pods
oc --context dev-spoke -n bgd-rollouts-demo get route bgd -o yaml | egrep -A8 'to:|alternateBackends:'
```

## Trigger a canary

Change the BGD color in Git:

```bash
./scripts/update-bgd-rollout-color.sh green
git add apps/bgd-rollouts/04-rollout.yaml
git commit -m "Update BGD rollout color to green"
git push
```

Watch the rollout:

```bash
./scripts/watch-bgd-rollout.sh dev-spoke
```

Check the current status without watching:

```bash
./scripts/status-bgd-rollout.sh dev-spoke
```

Promote each pause:

```bash
./scripts/promote-bgd-rollout-step.sh dev-spoke
./scripts/promote-bgd-rollout-step.sh dev-spoke
```

Abort if needed:

```bash
./scripts/abort-bgd-rollout.sh dev-spoke
```

## Promote to prod

```bash
./scripts/promote-bgd-rollouts-to-prod.sh
git add applicationsets/10-placements.yaml
git commit -m "Promote BGD Rollouts demo to prod"
git push
```

Refresh:

```bash
oc -n openshift-gitops annotate applications.argoproj.io/rhacm-day2-applicationsets \
  argocd.argoproj.io/refresh=hard --overwrite
```

## Demo talk track

> RHACM ensures the Rollouts capability exists on each managed cluster. OpenShift GitOps deploys the BGD application from Git. Argo Rollouts controls how the new version reaches users. OpenShift Routes split traffic between stable and canary services. If the canary looks good, we promote it. If not, we abort and roll back.
