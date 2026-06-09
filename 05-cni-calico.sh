#!/bin/bash
set -e

kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.31.3/manifests/tigera-operator.yaml

# Apply custom Installation with dual-stack instead of the default
cat <<EOF | kubectl create -f -
apiVersion: operator.tigera.io/v1
kind: Installation
metadata:
  name: default
spec:
  calicoNetwork:
    bgp: Enabled
    hostPorts: Enabled
    ipPools:
    - allowedUses:
      - Workload
      - Tunnel
      assignmentMode: Automatic
      blockSize: 26
      cidr: 192.168.0.0/16
      encapsulation: VXLANCrossSubnet
      name: default-ipv4-ippool
      natOutgoing: Enabled
      nodeSelector: all()
    - allowedUses:
      - Workload
      - Tunnel
      assignmentMode: Automatic
      blockSize: 122
      cidr: fd00::/48
      encapsulation: None
      name: default-ipv6-ippool
      natOutgoing: Enabled
      nodeSelector: all()
    nodeAddressAutodetectionV4:
      firstFound: true
    nodeAddressAutodetectionV6:
      firstFound: true
EOF

# Wait for calico-node pods in calico-system namespace (tigera-operator uses calico-system, not kube-system)
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=calico-node -n calico-system --timeout=300s || true

kubectl get pods -n calico-system -l app.kubernetes.io/name=calico-node
kubectl get pods -n calico-system -l app.kubernetes.io/name=calico-kube-controllers

# Enable auto host endpoints
kubectl patch kubecontrollersconfiguration default --patch='{"spec": {"controllers": {"node": {"hostEndpoint": {"autoCreate": "Enabled"}}}}}'
