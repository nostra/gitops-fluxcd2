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