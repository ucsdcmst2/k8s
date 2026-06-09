#!/bin/bash
set -e

IPADDR=$(curl -s ifconfig.me)
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16,fd00::/48"
SERVICE_CIDR="10.96.0.0/12,fd00:1::/108"

# Detect primary interface IPv6
PRIMARY_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
IPV6ADDR=$(ip --json addr show $PRIMARY_INTERFACE | jq -r '.[0].addr_info[] | select(.family == "inet6" and .scope == "global" and (.local | startswith("fe80") | not)) | .local' | head -n1)

kubeadm init \
  --kubernetes-version=1.32.0 \
  --control-plane-endpoint=$IPADDR \
  --apiserver-cert-extra-sans=$IPADDR,$IPV6ADDR \
  --pod-network-cidr=$POD_CIDR \
  --service-cidr=$SERVICE_CIDR \
  --node-name $NODENAME

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubeadm token create --print-join-command > /root/kubeadm-join-command.sh
chmod +x /root/kubeadm-join-command.sh
