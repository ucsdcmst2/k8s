#!/bin/bash
set -e

# Check if Calico is already installed
echo "Checking if primary CNI (Calico) is installed..."
if ! kubectl get pods -n kube-system -l k8s-app=calico-node &> /dev/null; then
    echo "WARNING: Calico CNI not found. Multus requires a primary CNI to be installed first."
    exit 1
fi

# Install Multus CNI
echo "Downloading and installing Multus CNI..."
kubectl apply -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/deployments/multus-daemonset-thick.yml

kubectl wait --for=condition=ready pod -l app=multus -n kube-system --timeout=300s || true

kubectl get pods -n kube-system -l app=multus