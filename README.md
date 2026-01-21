
# K8S Cluster for UCSD CMS T2

Scripts to set up a Kubernetes cluster (controller + workers).

**These scripts are intended to be run as root**

## Controller (run on the controller node)

- Prepare node networking and kernel settings:

```bash
./01-net-config.sh
```

- Install container runtime and Kubernetes components:

```bash
./02-crio-install.sh
./03-k8s-install.sh
```

- Configure the controller and initialize the control-plane:

```bash
./04-controller-config.sh
```

- Install CNI plugins (Calico and Multus):

```bash
./05-cni-calico.sh
./06-cni-multus.sh
```

## New worker nodes (run on each worker)

1. Apply the same basic networking/kernel settings:

```bash
./01-net-config.sh
```

2. Install runtime and Kubernetes components:

```bash
./02-crio-install.sh
./03-k8s-install.sh
```

3. Join the cluster using the join command produced by the controller. The join command can be generated on the controller using

```bash
kubeadm token create --print-join-command
```