# ADR-0002: Build images with Kaniko and a runtime-only Dockerfile

- Status: Accepted
- Date: 2026-10-19

## Context
Building images inside Kubernetes pods with Docker-in-Docker requires privileged containers or mounting the host Docker socket, both significant security risks.

## Decision
Use Kaniko to build and push images without a daemon. Maven builds the JAR once in the `maven` container; the Dockerfile only copies `target/my-service.jar` into a JRE image.

## Consequences
- (+) No privileged mode or Docker socket.
- (+) The application is compiled once, and the tested JAR is exactly what is shipped.
- (−) `docker build` locally requires running `mvn package` first.
- (−) Kaniko layer caching needs a cache repository to be effective.
