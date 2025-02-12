#!/bin/bash
set -e

IPADDR=$(curl ifconfig.me && echo "")
NODENAME=$(hostname -A | awk '{print $1}')
POD_CIDR="192.168.0.0/16"

kubeadm init --control-plane-endpoint=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=$POD_CIDR --node-name $NODENAME --ignore-preflight-errors Swap

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
 
 
