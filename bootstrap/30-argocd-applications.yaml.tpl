---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: rhacm-day2-policies
  namespace: openshift-gitops
spec:
  project: default
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${TARGET_REVISION}
    path: policies
  destination:
    server: https://kubernetes.default.svc
    namespace: rhacm-policies
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: rhacm-day2-applicationsets
  namespace: openshift-gitops
spec:
  project: default
  source:
    repoURL: ${REPO_URL}
    targetRevision: ${TARGET_REVISION}
    path: applicationsets
  destination:
    server: https://kubernetes.default.svc
    namespace: openshift-gitops
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
