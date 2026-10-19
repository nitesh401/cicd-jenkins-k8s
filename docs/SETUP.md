# Setup Guide

## Prerequisites

- A Jenkins controller (2.440+ recommended) that can reach a Kubernetes cluster
- A Kubernetes cluster for agents and deployments (EKS, AKS, GKE, on-prem or similar)
- A container registry (Docker Hub, ECR, ACR, Harbor, GHCR ...)
- A SonarQube server and a Snyk account (free tier is fine)

## 1. Jenkins plugins

Install: Pipeline, Git, Kubernetes, Kubernetes CLI, Credentials Binding, JUnit, SonarQube Scanner, Pipeline: Multibranch.

## 2. Connect Jenkins to Kubernetes

**Manage Jenkins → Clouds → New cloud → Kubernetes.** Set the cluster URL, the namespace where agent pods run (for example `jenkins-agents`) and a credential. Test the connection.

## 3. Registry secret for Kaniko

Create the secret in the **same namespace as the agent pods**:

```bash
kubectl create namespace jenkins-agents
kubectl create secret docker-registry regcred \
  --docker-server=<registry-host> \
  --docker-username=<user> \
  --docker-password=<token> \
  -n jenkins-agents
```

If the registry is private, also create `regcred` in `my-service-staging` and `my-service-production` and uncomment `imagePullSecrets` in `k8s/base/deployment.yaml`.

## 4. SonarQube

1. In Jenkins: **Manage Jenkins → System → SonarQube servers**, add a server named exactly `sonarqube` with a token credential.
2. In SonarQube add a webhook to `https://<jenkins>/sonarqube-webhook/` (required for `waitForQualityGate`).

## 5. Jenkins credentials

| ID | Type | Used for |
|---|---|---|
| `snyk-token` | Secret text | Snyk scan |
| `k8s-staging` | Secret file (kubeconfig) | Staging deploy |
| `k8s-prod` | Secret file (kubeconfig) | Production deploy |

Use a service account kubeconfig with rights limited to the target namespace, not cluster-admin.

## 6. Create the job

1. **New Item → Multibranch Pipeline**, add the Git repository as a branch source.
2. Add a webhook in your Git host pointing at `https://<jenkins>/github-webhook/` (or the GitLab / Bitbucket equivalent).
3. Edit `REGISTRY` at the top of the `Jenkinsfile`.

## 7. Push this repository to GitHub

```bash
cd jenkins-k8s-cicd
git init -b main
git add .
git commit -m "Initial commit: Jenkins to Kubernetes CI/CD pipeline"
git remote add origin https://github.com/<your-user>/<repo-name>.git
git push -u origin main
```

## Setup checklist

- [ ] Jenkins plugins installed
- [ ] Kubernetes cloud configured and tested
- [ ] `regcred` secret created in the agent namespace
- [ ] SonarQube server `sonarqube` configured and webhook added
- [ ] Credentials `snyk-token`, `k8s-staging`, `k8s-prod` created
- [ ] `REGISTRY` updated in `Jenkinsfile`
- [ ] Image pull secret added to app namespaces (private registry only)
- [ ] Multibranch job created and Git webhook added
- [ ] First run on a feature branch passes (build, scans, gate)
- [ ] First run on `main` deploys to staging and `/actuator/health` returns `UP`
- [ ] Production approval and deploy tested once
- [ ] Snyk step made blocking (remove `|| true`)

## Verify a deployment

```bash
kubectl get pods -n my-service-staging
kubectl port-forward svc/my-service 8080:80 -n my-service-staging
curl localhost:8080/actuator/health
```
