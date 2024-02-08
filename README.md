# Hetzner Failover IP Controller

Ops TODOs:
- liveness probe
- metrics


## Development

Run Skaffold:

`skaffold dev --port-forward`

Manual image build:

`docker build docker --label "git-commit=$(git rev-parse HEAD)" --tag ghcr.io/cit-consulting/hetzner-failoverip-controller:0.1`
