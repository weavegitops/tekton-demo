# tekton-demo

## Getting Started
### Fork and Configure Repo
Before getting started it is important to fork this project into your own repo.  There are permission and access requirements that need to be configured that will not be possible without using your own forked version.

***Make sure to uncheck `only main` when you fork.***  We'll be using gh-pages to host our helm repository and this project already has an empty `gh-pages` branch created that we will use.

After forking you will want to verify that GitHub Pages is enabled on the repo.  Go to `settings > Pages` and verify that pages are set to `Deploy from a branch` and that branch is configured to the root of the `gh-pages` branch.

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

## Demo
### Initial Tag
At this point Tekton and the sample pipelines should be deployed and we should have 3 demo environments defined.  Using the flux cli run
```bash
flux get helmrelease --all-namespaces
```
and you should see at least 3 objects showing the status of the `demo` release in the `dev`, `staging` and `prod` environments.  They are failing now because we do not have any charts created yet.  Lets fix that.  Create a `0.0.1` tag and push it to the repo.
```bash
git tag 0.0.1
git push --tags
```
This will trigger the CI pipeline to run and build version `0.0.1` of our chart.  This will take a few minutes to run and for Flux to reconcile, but eventually we should see `0.0.1` deployed to all the environments.

### Make Image Public
Depending on the image registry you are using for Docker you may need to update the visibility of the image so that the chart can pull the image.  Check your registry documentation for information on how to update the image visibility.

### RC Tag
Now lets create a RC
```bash
git tag 0.0.2-rc.1
git push --tags
```
Again this will kick off the CI pipeline, but this time only the dev environment should be updated.
```bash
flux get helmrelease --all-namespaces
NAMESPACE       NAME    REVISION        SUSPENDED       READY   MESSAGE                          
staging         demo    0.0.1           False           True    Release reconciliation succeeded
dev             demo    0.0.2-rc.1      False           True    Release reconciliation succeeded
prod            demo    0.0.1           False           True    Release reconciliation succeeded
```

### Release Tag
Now its time to make a new release
```bash
git tag 0.0.2
git push --tags
```
The CI pipeline will create a new version and it will automatically deploy to both the dev and staging environments
```bash
flux get helmrelease --all-namespaces
NAMESPACE       NAME    REVISION        SUSPENDED       READY   MESSAGE                          
staging         demo    0.0.2           False           True    Release reconciliation succeeded
dev             demo    0.0.2           False           True    Release reconciliation succeeded
prod            demo    0.0.1           False           True    Release reconciliation succeeded
```
After a successful deployment to the `staging` environment, the CD pipeline will trigger and modify the prod environment files, commit the changes back to the repo in a new branch, and automatically create a new pull-request.  This will allow for a manual approval/review before a change to prod is released.  Once this pr has been merged, Flux will detect the changes and release the new version.
```bash
flux get helmrelease --all-namespaces
NAMESPACE       NAME    REVISION        SUSPENDED       READY   MESSAGE                          
staging         demo    0.0.2           False           True    Release reconciliation succeeded
dev             demo    0.0.2           False           True    Release reconciliation succeeded
prod            demo    0.0.2           False           True    Release reconciliation succeeded
```
