# Runbook

## Rollback

Automatic rollback happens when the production rollout fails. For a manual rollback:

```bash
kubectl rollout history deployment/my-service -n my-service-production
kubectl rollout undo deployment/my-service -n my-service-production
# or to a specific revision
kubectl rollout undo deployment/my-service -n my-service-production --to-revision=<n>
kubectl rollout status deployment/my-service -n my-service-production
```

Alternatively, re-run the pipeline on the last good commit.

## Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Agent pod stays `Pending` | No capacity or wrong namespace in cloud config | `kubectl describe pod -n jenkins-agents` |
| Kaniko: `error checking push permissions` | `regcred` missing or wrong in the agent namespace | Recreate the secret (SETUP step 3) |
| Quality Gate waits until timeout | SonarQube webhook not configured | Add `https://<jenkins>/sonarqube-webhook/` |
| `ImagePullBackOff` after deploy | Private registry without pull secret in app namespace | Create `regcred` there, uncomment `imagePullSecrets` |
| Rollout times out | Readiness probe failing, app crash or low resources | `kubectl logs` and `kubectl describe pod` in the target namespace |
| `JAR not found` during Kaniko | Maven stage did not produce `target/my-service.jar` | Check `finalName` in `pom.xml` matches the Dockerfile |
| Pipeline blocked on approval | Waiting for a human | Open the build in Jenkins and click Deploy or Abort (1 hour timeout) |

## Useful commands

```bash
kubectl get deploy,pods,svc -n my-service-production
kubectl logs deploy/my-service -n my-service-production --tail=100
kubectl describe deploy/my-service -n my-service-production
kubectl get deploy my-service -n my-service-production -o jsonpath='{.spec.template.spec.containers[0].image}'
```

## Rotating credentials

Update the credential in Jenkins (**Manage Jenkins → Credentials**) keeping the same ID. No pipeline change is needed. Rotate `regcred` by deleting and recreating the secret in each namespace that holds it.
