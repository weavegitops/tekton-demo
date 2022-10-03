# tekton-demo

## Getting Started
Before getting started it is important to fork this project into your own repo.  There are permission and access requirements that need to be configured that will not be possible without using your own forked version.

### Install Flux
If Flux is not already installed on your cluster, you will want to bootstrap it as documented [here](https://fluxcd.io/flux/installation/#bootstrap).  Alternatively you can do a [dev install](https://fluxcd.io/flux/installation/#dev-install) as well.

### Create Service Account and Credentials
The pipelines will need a special service account and some credential secrets created for everything to work properly.  You will need a GitHub API Token and you can follow the [GitHub docs](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) to generate a new token if needed.  Please make sure the token has at least `repo` and `write:packages` permissions.  For conveniance a template file called `pipeline-auth.yaml.tpl` has been provided that will generate the necessary auth resources and can be applied using `envsubst` with the command below:

```bash
export GITHUB_API_TOKEN="<GITHUB API TOKEN>"
envsubst < pipeline-auth.yaml.tpl | kubectl apply -f -
```
> If you are not using `ghcr.io` as your Docker registry you will need to update the `docker-credentials` auth config accordingly.

### Update `pipeline-config.yaml` and `flux.yaml`
The pipelines need to be configured to work with your forked version.  In the `flux.yaml` file, update the `tekton-demo` `GitRepository` to use your forked repo url.  In the `pipeline-config.yaml` file, update ALL of the data values to meet your environment settings.

For your ingress to work correctly you may need to add additional config to meet your environment requirements.  You can do this by patching the `sample-ci-pipeline` `Kustomization` in the `flux.yaml` file.
> The file includes an example patch that adds tls config to the ingress using cert-manager and letsencrypt.  Use this as a template to apply your settings.

### Apply `pipeline-config.yaml` and `flux.yaml`

```bash
kubectl apply -f pipeline-config.yaml
kubectl apply -f flux.yaml
```

### Create GitHub Webhook
For the CI Pipeline demo you need to configure a GitHub webhook to call the CI's event-listener ingress url on `push` events.  Set the Payload URL to the ingress you defined in the `pipeline-config.yaml` file, set the Content Type to `application/json` and set the Secret to `1234567`.  This is the default secret defined in the `sample-ci-event-listener.yaml` file.
