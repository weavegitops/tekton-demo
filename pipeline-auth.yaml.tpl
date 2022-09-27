apiVersion: v1
kind: ServiceAccount
metadata:
  name: sample-pipeline-sa
  namespace: default
secrets:
  - name: basic-user-pass
---
apiVersion: v1
kind: Secret
metadata:
  name: basic-user-pass
  namespace: default
  annotations:
    tekton.dev/git-0: https://github.com # Tekton auth convention
type: kubernetes.io/basic-auth
stringData:
  username: token
  password: $GITHUB_API_TOKEN
---
apiVersion: v1
kind: Secret
metadata:
  name: github-api-token
  namespace: default
type: Opaque
stringData:
  token: $GITHUB_API_TOKEN
---
apiVersion: v1
kind: Secret
metadata:
  name: docker-credentials
  namespace: default
type: Opaque
stringData:
  config.json: |
    {"auths":{"ghcr.io":{"username":"token","password":"$GITHUB_API_TOKEN"}}}
