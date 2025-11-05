#!/bin/bash
set -e

IPADDR=$(curl -s ifconfig.me)
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"

kubeadm init --kubernetes-version=1.32.0 --control-plane-endpoint=$IPADDR  --apiserver-cert-extra-sans=$IPADDR  --pod-network-cidr=$POD_CIDR --node-name $NODENAME

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubeadm token create --print-join-command > /root/kubeadm-join-command.sh
chmod +x /root/kubeadm-join-command.sh