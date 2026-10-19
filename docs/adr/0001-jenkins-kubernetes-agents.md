# ADR-0001: Run Jenkins builds in ephemeral Kubernetes agent pods

- Status: Accepted
- Date: 2026-10-19

## Context
Static build agents drift, need patching and sit idle. Builds need several tools (JDK/Maven, Snyk, Kaniko, kubectl) with different versions.

## Decision
Use the Jenkins Kubernetes plugin. Each build starts a pod with one container per tool; the pod is deleted afterwards.

## Consequences
- (+) Clean, reproducible environments; tool versions pinned per image.
- (+) Scales with the cluster; no idle agents.
- (−) Pod start-up adds seconds per build; dependency caches need a PVC.
- (−) Jenkins needs permission to create pods in the agent namespace.
