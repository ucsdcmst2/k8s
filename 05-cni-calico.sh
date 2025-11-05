#!/bin/bash
set -e

kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml

kubectl wait --for=condition=ready pod -l k8s-app=calico-node -n kube-system --timeout=300s || true

kubectl get pods -n kube-system -l k8s-app=calico-node
kubectl get pods -n kube-system -l k8s-app=calico-kube-controllers