# ArgoCD

Followed https://magmax.org/en/blog/argocd/

References:
- https://kind.sigs.k8s.io/docs/user/ingress/
- https://cert-manager.io/docs/installation/

## Installation notes 

Kind:
```bash
kind create cluster --config=kind.yaml
````

Nginx-ingress:
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

Install cert-manager:
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.9.1/cert-manager.yaml
```
Wait until it has been started before:
```bash
kubectl apply -f cert-issuer.yaml
``` 

Install argo
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Add the following to etc/hosts
```
127.0.0.1       localhost argocd.local
```

Create the ingress:

```bash
kubectl apply -f ingress.yaml
```

The server should now be running and answering on https://argocd.local/

The username is `admin` and the password can be obtained by:

```bash
kubectl get secret argocd-initial-admin-secret -o go-template --template="{{.data.password|base64decode}}"
```

## Alternative to ingress

```bash
kubectl port-forward svc/argocd-server -n argocd 8443:443
```

# Example-apps

https://github.com/argoproj/argocd-example-apps/tree/master/guestbook

argocd login argocd.local

argocd app create guestbook --repo https://github.com/argoproj/argocd-example-apps.git \
       --path guestbook --dest-server https://kubernetes.default.svc --dest-namespace default

argocd app get guestbook

## Differences argo / flux

Notes from examination:

- ArgoCD can deploy to different clusters, so it is probably easy to run a control cluster, which deploys to an app cluster
- Seems like application objects need to be specified in the "argocd" namespace to get to be picked up
- Quirky limitations, cannot have an application with the same name in the same cluster:
  https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/#multiple-configuration-objects
- Why does the GUI support sync and refresh? All this should be	controlled with	just Kubernetes
- Argo seems geared for manual operations, for instance automated sync needs to be turned on explicitly:
  https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/#automated-sync-policy
- Automated prune is the same as with Fluxcd, i.e. you explicitly say you want to remove the element
- It does not seem like application creates ownerReferences on objects it creates
       - This makes it Argo's responsibility to clean up the resource when deleting the application object
- Sync phases and sync windows look very strange. This is not how one would use Kubernetes normally
- I have not fully explored if / how argo will support a number of applications defined with Kustomize

All in all, the impression is that much of the functionality which exist in Kubernetes is duplicated in 
Argo, in particular sync. I recognize the need for a developer team to be able to look at a GUI (or in 
an easy fashion) to see the status of a specific application. However, I do not think this warrants to 
use Argo as a tool.

With GitOps, it is the access rights for the git repository which determines what a someone has 
access to deploy on a cluster. With Argo you have access to the GUI in addition to this, which 
is an additional attack vector.
