name: inverse
layout: true
class: center, middle, inverse
---
# GitOps

.footnote[16.02.2022 Erlend Nossum]
???

Made with: https://github.com/gnab/remark

---
layout: false
## Agenda
.left-column[
] .right-column[
- Recapitulation of dependent technology
- Preliminaries
- What is GitOps?
- What is fluxcd?
- Sing-along (mac supported):
  - How to setup up fluxcd in kubernetes on your local computer
]
???
- Flux from weaveworks
---
## Tech recap
.left-column[
] .right-column[
- docker
- kubernetes
  - kustomize
- ops and devops
- ... and chatops
- cloud solutions
]
???
Alternatives to kustomize is jsonnet and helm
---
## Tooling - what is presented today

Install:
- https://docs.docker.com/install/
- https://kubernetes.io/docs/tasks/tools/install-kubectl/
- https://github.com/kubernetes-sigs/kind
- https://docs.fluxcd.io/en/latest/references/fluxctl/
```
kind --version        # Should yield at least 0.11.1
docker ps             # Should not give any errors
kubectl version       # Should at least give 1.21
flux version --client # Should at least give 1.27.3
#
docker pull kindest/node:v1.16.3
docker pull nginx:1.17.6
```
???
- Docker for containers
- kubectl for kubernetes interaction
- kind to run kubernetes in docker
- flux for gitops

---
## GitOps

- git repository is the source of **truth** for a system's configuration
- configuration as code <br/>https://rollout.io/blog/configuration-as-code-everything-need-know/
- when the actual state of the system drifts from the desired state
  - k8s good fit
  - kustomize, patches and namespace
- Easily set up as part of a CD / CI toolchain

---
## Fluxcd
- From https://weave.works
- A CNCF project
- Argo-flux collaboration
  - AWS wants to adopt flux
  - https://github.com/argoproj/gitops-engine/
  - Effectively merging Flux and ArgoCD into a single solution is a long term goal: https://github.com/argoproj/gitops-engine/blob/master/specs/design.md
    - https://github.com/fluxcd/flux/tree/gitops-engine-poc
    - https://github.com/argoproj/argo-cd/tree/gitops-engine-poc
???
* AWS wants to adopt flux: https://aws.amazon.com/blogs/containers/help-us-write-a-new-chapter-for-gitops-kubernetes-and-open-source-collaboration/
* TODO Azure too: Find and check reference
---
## Multi-tenancy

TODO Write slide, ref: https://github.com/fluxcd/flux2-multi-tenancy

roles:
- platform admin
- tenant

We want to be able to accommodate the following:
- Flux base system
- Tenant references
  - One tenant can create sub tenants
- Flux (sub-)tenant supplies dev with gitops repo


---
name: inverse
layout: true
class: center, middle, inverse
---
# Practical example
---
layout: false
## Fire up docker based kubernetes

```
# Create the cluster
kind create cluster
# Just test that it runs OK
kubectl get pods -A
kubectl config get-contexts
kubectl config use-context kind-kind  
```
---
## ...  and enable GitOps with kustomize

https://github.com/fluxcd/flux2-multi-tenancy

???
**BELOW** is old slide
Follow flux tutorial
- https://docs.fluxcd.io/en/latest/tutorials/get-started-kustomize/
- https://github.com/nostra/gitops-presentation

```
kubectl apply -k fluxcd
kubectl logs -n flux -f flux
kubectl get pods -A
fluxctl identity --k8s-fwd-ns flux
```

---
## Create new tenant

todo

---
## Load your own docker image

Create an example docker image...

```
cd dockerimage
docker build -t local-test:v1 .
kind load docker-image local-test:v1
fluxctl --k8s-fwd-ns=flux sync
kc port-forward svc/nginx-test 8080
```
* http://localhost:8080
---
## Update the example deployment

```
vi Dockerfile
docker build -t local-test:v2 .
kind load docker-image local-test:v2
vi k8s/nginx.yaml       # Update the image reference
git commit k8s/nginx.yaml -m "Update"
git push
kc port-forward svc/nginx-test 8080
```
* http://localhost:8080
---
name: inverse
layout: true
class: center, middle, inverse
---
# What did we learn?
