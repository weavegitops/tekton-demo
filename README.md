# tekton-demo

## Getting Started
For this demo to work properly, there is some 

### Install Flux
If Flux is not already installed on your cluster, you will want to bootstrap it as documented [here](https://fluxcd.io/flux/installation/#bootstrap).  Alternatively you can do a [dev install](https://fluxcd.io/flux/installation/#dev-install) as well.

### Create `github-api-token` Secret
The pipelines being created will need to write back to the GitHub repository.  To do this you will need to create a `github-api-token` secret that the pipelines can use.  You can follow the [GitHub docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) to generate a new token if needed.  Please make sure the token has at least `repo` and `write:packages` permissions.  Once you have the token value you can create the new secret by using the kubernetes-cli:

```bash
kubectl -n default create secret generic github-api-token --from-literal=token="<GITHUB API TOKEN>"
```

or by creating and applying a new secret yaml file:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: github-api-token
  namespace: default
type: Opaque
stringData:
  token: <GITHUB API TOKEN>
```
