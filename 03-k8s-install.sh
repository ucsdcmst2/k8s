#!/bin/bash
set -e
KUBERNETES_VERSION=1.32
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_VERSION}/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${KUBERNETES_VERSION}/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
apt update -y
apt install -y kubelet=${KUBERNETES_VERSION}.0-* kubectl=${KUBERNETES_VERSION}.0-* kubeadm=${KUBERNETES_VERSION}.0-*
apt-mark hold kubelet kubeadm kubectl

# Detect primary network interface
PRIMARY_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
local_ip="$(ip --json addr show $PRIMARY_INTERFACE | jq -r '.[0].addr_info[] | select(.family == "inet") | .local')"
local_ipv6="$(ip --json addr show $PRIMARY_INTERFACE | jq -r '.[0].addr_info[] | select(.family == "inet6" and .scope == "global" and (.local | startswith("fe80") | not)) | .local' | head -n1)"

if [ -n "$local_ipv6" ]; then
  node_ip="$local_ip,$local_ipv6"
else
  node_ip="$local_ip"
fi

cat > /etc/default/kubelet << EOF
KUBELET_EXTRA_ARGS=--node-ip=$node_ip
EOF

systemctl daemon-reload
systemctl enable kubelet

echo "Kubernetes components installed successfully!"
echo "Primary interface: $PRIMARY_INTERFACE"
echo "Node IP (v4): $local_ip"
echo "Node IP (v6): ${local_ipv6:-not detected}"
