# ADR-0003: Manual approval gate before production

- Status: Accepted
- Date: 2026-10-19

## Context
Automated tests and scans reduce risk but cannot judge business timing (release windows, ongoing incidents).

## Decision
After a successful staging deploy, the pipeline pauses at an `input` step for up to one hour. Only a human approval proceeds to production.

## Consequences
- (+) A person confirms the exact image tag before production changes.
- (−) Adds latency; a build can wait on the approver. The timeout prevents orphaned builds.
- Revisit once automated smoke tests and canary analysis are in place.
