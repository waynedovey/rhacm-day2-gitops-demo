# RHACM Day 2 GitOps Demo

This is a small, current RHACM/OpenShift GitOps demo pattern:

- **Argo CD/OpenShift GitOps** syncs the hub-side desired state from Git.
- **RHACM Governance** enforces Day 2 operator policies on managed clusters.
- **Argo CD ApplicationSet** deploys an example app to clusters selected by an RHACM/OCM `Placement`.

The demo deliberately uses the current `Placement` API, not deprecated `PlacementRule`.

## What this deploys

### RHACM policies

The `policies/` path creates a PolicySet with these enforced policies. Both `dev-spoke` and `prod-spoke` receive these policies when they are labelled `demo=day2`:

| Policy | Target | What it does |
|---|---|---|
| `policy-day2-standard-namespace` | `demo=day2` clusters | Creates a standard `day2-standard` namespace so you can demo drift remediation. |
| `policy-install-openshift-gitops` | `demo=day2` clusters | Installs the OpenShift GitOps Operator by using `OperatorPolicy`. |
| `policy-install-cert-manager` | `demo=day2` clusters | Installs cert-manager Operator for Red Hat OpenShift by using `OperatorPolicy`. |
| `policy-install-compliance-operator` | `demo=day2` clusters | Installs the Compliance Operator by using `OperatorPolicy`. |

### App deployment

The `applicationsets/` path creates:

- `GitOpsCluster` to register the selected RHACM managed clusters into the hub OpenShift GitOps instance.
- `Placement` named `placement-hello-dev` that selects clusters with:

```bash
oc label managedcluster <cluster-name> demo=day2 environment=dev --overwrite
```

- `ApplicationSet` named `guestbook-dev` that deploys the public Argo CD guestbook example to the selected `environment=dev` cluster. With your cluster names, that means `dev-spoke` gets the app first and `prod-spoke` only gets it when you promote it.


### With your two managed clusters

Expected behaviour with `dev-spoke` and `prod-spoke`:

| Cluster | Labels | RHACM policies | App deployment |
|---|---|---|---|
| `dev-spoke` | `demo=day2 environment=dev` | Yes | Yes, gets `guestbook-dev` |
| `prod-spoke` | `demo=day2 environment=prod` | Yes | No, until promoted |

## Prereqs

You need:

1. RHACM installed on the hub.
2. OpenShift GitOps installed on the hub in `openshift-gitops`.
3. At least one managed OpenShift cluster imported into RHACM.
4. The managed clusters in a ManagedClusterSet visible to the demo namespaces. The scripts default to the `global` ManagedClusterSet.
5. Cluster-admin on the hub.

## Quick start

Push this repo to your own GitHub first.

```bash
git init
git add .
git commit -m "rhacm day2 gitops demo"
git branch -M main
git remote add origin https://github.com/<you>/rhacm-day2-gitops-demo.git
git push -u origin main
```

Label your managed clusters on the hub. The helper script now defaults to `dev-spoke` and `prod-spoke`:

```bash
./scripts/label-clusters.sh
```

Or pass different names if needed:

```bash
./scripts/label-clusters.sh <dev-spoke> <prod-spoke>
```

Bootstrap from the hub. Use `global` if both managed clusters are visible through the global ManagedClusterSet:

```bash
./scripts/bootstrap.sh https://github.com/<you>/rhacm-day2-gitops-demo.git main global
```

Check the cluster set first if you are unsure:

```bash
oc get managedclusterset
oc get managedcluster dev-spoke prod-spoke --show-labels
```

## Watch it work

On the hub:

```bash
oc get applications -n openshift-gitops
oc get applicationsets -n openshift-gitops
oc get gitopscluster -n openshift-gitops
oc get placement,placementdecision -n openshift-gitops
oc get policies -n rhacm-policies
```

On the managed dev cluster:

```bash
oc get pods,svc -n guestbook
```

## Demo drift remediation

On a managed cluster, delete the standard namespace:

```bash
oc delete ns day2-standard
```

Back on the hub, watch RHACM mark the policy non-compliant and then put it back:

```bash
watch 'oc get policy -n rhacm-policies && echo && oc get ns day2-standard --context=<managed-cluster-context>'
```

## Promote the app from dev to prod

For a quick live demo, relabel prod so the existing dev Placement selects it:

```bash
./scripts/promote-app-to-prod.sh
```

The ApplicationSet should create another Argo CD Application for `prod-spoke`. For a cleaner long-running version, edit `applicationsets/10-placements.yaml` and change `placement-guestbook-dev` so the `environment` selector includes both `dev` and `prod`.

## Notes

- The policies use `OperatorPolicy`, which is cleaner for OLM-managed operators than hand-writing raw `Subscription` resources everywhere.
- The ApplicationSet uses the OCM/RHACM `PlacementDecision` generator via the `ocm-placement-generator` ConfigMap.
- This repo uses the push model for the app demo. For large fleets, consider the RHACM/OpenShift GitOps pull model or the Argo CD Agent path.
