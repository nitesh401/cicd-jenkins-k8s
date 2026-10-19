# Changelog

All notable changes to this project are documented here. Format based on Keep a Changelog.

## [1.0.0] - 2026-10-19

### Added
- Declarative Jenkins pipeline: build, test, SonarQube, Snyk, quality gate, Kaniko image, staging and production deploys, manual approval and auto rollback.
- Ephemeral Kubernetes agent pods (maven, snyk, kaniko, kubectl).
- Kustomize base with staging and production overlays.
- Sample Spring Boot 3.3 / Java 21 service with Actuator health probes and a unit test.
- Design document, setup guide, runbook and four ADRs.
