# tekton-demo

## Getting Started
For this demo to work properly, there is some 

### Install Flux
If Flux is not already installed on your cluster, you will want to bootstrap it as documented [here](https://fluxcd.io/flux/installation/#bootstrap).  Alternatively you can do a [dev install](https://fluxcd.io/flux/installation/#dev-install) as well.

### Create Service Account and Credentials
The pipelines will need a special service account and some credential secrets created for everything to work properly.  You will need a GitHub API Token and you can follow the [GitHub docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) to generate a new token if needed.  Please make sure the token has at least `repo` and `write:packages` permissions.  For conveniance a template file called `pipeline-auth.yaml.tpl` has been provided that will generate all the necessary resources and can be applied using `envsubst` and the command below:

```bash
export GITHUB_API_TOKEN="<GITHUB API TOKEN>"
envsubst < pipeline-auth.yaml.tpl | kubectl apply -f -
```
> If you are not using `ghcr.io` as your Docker registry you will need to update the `docker-credentials` auth config accordingly.
