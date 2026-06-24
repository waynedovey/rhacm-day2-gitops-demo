---
apiVersion: cluster.open-cluster-management.io/v1beta2
kind: ManagedClusterSetBinding
metadata:
  name: ${CLUSTERSET}
  namespace: rhacm-policies
spec:
  clusterSet: ${CLUSTERSET}
---
apiVersion: cluster.open-cluster-management.io/v1beta2
kind: ManagedClusterSetBinding
metadata:
  name: ${CLUSTERSET}
  namespace: openshift-gitops
spec:
  clusterSet: ${CLUSTERSET}
