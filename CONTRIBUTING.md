# Contributing

1. Branch from `main` (`feature/<short-name>`). The pipeline runs build, scans and the quality gate on every branch.
2. Keep pull requests small and green before requesting review.
3. If you change pipeline behaviour, update `docs/DESIGN.md`, `docs/SETUP.md` or `docs/RUNBOOK.md` in the same PR, and add an ADR in `docs/adr/` for significant decisions.
4. Add a line to `CHANGELOG.md` under an "Unreleased" heading.
5. Never commit secrets or kubeconfig files.
