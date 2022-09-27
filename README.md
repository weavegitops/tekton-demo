# tekton-demo

## Getting Started
For this demo to work properly, there is some 

### Install Flux
If Flux is not already installed on your cluster, you will want to bootstrap it as documented [here](https://fluxcd.io/flux/installation/#bootstrap).  Alternatively you can do a [dev install](https://fluxcd.io/flux/installation/#dev-install) as well.

### Create Credential Secrets
The pipelines being created will need to write back to the GitHub repository and will need access to push and pull from a Docker registry.  To do this you will need to create `github-api-token` and `docker-credentials` secrets that the pipelines can use.  You can follow the [GitHub docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) to generate a new token if needed.  Please make sure the token has at least `repo` and `write:packages` permissions.  Once you have the token value you can create the new secrets by using the kubernetes-cli:

```bash
export GITHUB_API_TOKEN="<GITHUB API TOKEN>"
kubectl -n default create secret generic github-api-token --from-literal=token="$GITHUB_API_TOKEN"
kubectl -n default create secret generic docker-credentials --from-literal=config.json='{"auths":{"ghcr.io":{"username":"token","password":"'$GITHUB_API_TOKEN'"}}}'
```
 > If you are not using `ghcr.io` as your Docker registry you will need to update your Docker auth config accordingly.
 