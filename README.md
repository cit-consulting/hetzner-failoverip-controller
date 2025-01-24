# Hetzner Failover IP Controller

Simple Kubernetes operator that routes Hetzner Failover IP (bare metal only) to desired node. This operator **do not
provide** IPAM nor IP to network device assigment, so it is compatible with any possible IP management solution (
MetalLB, KubeVIP, Cilium LB and so on).

## Usage

See `k8s/example`.

## Development

Run Skaffold:

`skaffold dev --port-forward`

Manual image build:

`docker build docker --label "git-commit=$(git rev-parse HEAD)" --tag ghcr.io/cit-consulting/hetzner-failoverip-controller:1.0.1`

This operator implementation is based on Flant Shell Operator https://github.com/flant/shell-operator .
