# ADR-0004: Kustomize base and overlays for environments

- Status: Accepted
- Date: 2026-10-19

## Context
Staging and production differ in namespace and replica count but share the same workload definition.

## Decision
Keep common manifests in `k8s/base` and environment differences in `k8s/overlays/<env>`. Deploy with `kubectl apply -k`, which needs no extra tools.

## Consequences
- (+) One source of truth; environment differences are explicit and small.
- (+) No templating language to learn.
- (−) Less flexible than Helm for packaging and distribution. Switch to Helm if the chart must be shared externally.
