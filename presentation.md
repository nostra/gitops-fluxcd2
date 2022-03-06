name: inverse
layout: true
class: center, middle, inverse
---
# GitOps

.footnote[01.04.2022 Erlend Nossum]
???

- Made with: https://github.com/gnab/remark
- Presentation made for Scienta tech day

---
layout: false
## Agenda
.left-column[
] .right-column[
- Recapitulation of dependent technology
- Preliminaries
- What is GitOps?
- What is fluxcd?
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
- The technologies and methodologies sum up in which part of the world we are in
- Kubernetes manifests tends to be large, and repetative. Kustomize lets you template out much of the repetition
- Alternatives to kustomize is jsonnet and helm
  - Kustomize is the standard technolgo for manifest rendering
---
## Tooling - this gets presented today

Install:
- https://docs.docker.com/install/
- https://kubernetes.io/docs/tasks/tools/install-kubectl/
- https://github.com/kubernetes-sigs/kind
- https://fluxcd.io/docs/installation/#install-the-flux-cli
- https://kubectl.docs.kubernetes.io/references/kustomize/
```
kind --version        # Should yield at least 0.12.0
docker ps             # Should not give any errors
kubectl version       # Should at least give 1.21
flux version --client # Should at least give 0.28.3
kustomize version     # 4.4.1, most are good
```
Pull images:
```bash
docker pull nginx:1.17.6
docker pull alpine:3.15
```
???
- A lot of these technologies are the same as in 2019, the difference is
  the level of adoption and use
- Container Runtime Interface (CRI)
  - Docker 
  - containerd
  - CRI-O 
- kubectl for kubernetes interaction
- kind to run kubernetes in docker
- flux for gitops
---
# Infrastructure as code
.left-column[
## code
] .right-column[
- Configuration as Code / Infrastructure as code
- Define infrastructure as code instead of creating it manually
- Easy to replicate setup
- Network and polices as code too
- You end up with a configuration files for
  - terraform
  - ansible
  - k8s manifests
  - puppet
  - ...

Natural next step is to **put the code into git**
]
???
I do not make a distinction between IaC and CaC 
- https://dzone.com/articles/infrastructure-versus-config-as-code
- Some feel there is a **distinction** between 
  - creating, lets say, a VM, a storage volume, or a database
  - as opposed to make configuration for an application instance
- All these things are virtual elements which "does not really exist"
  - When you create a new storage volume, there is no person who physically walks by
    and plugs the extra storage into a server. You just get allocated a slice of existing
   storage virtually

Everything as code
- Infrastructure as code
- Network as code
- Policy as code

---
# Infrastructure as code
.left-column[
## code
## Git
] .right-column[
Putting configuration files into Git is easy enough. 

The IaC in Git needs to be applied / executed
- kubectl apply ...
- terraform apply ...

Typical first steps when externalizing configuration:
- The configuration / change is applied manually
- Manual application on test cluster to see that it works 
- Apply change manually to other environments

New **questions arise**:
- Who applies this? 
- How is it tested?
]
???
- different technologies have different idioms
  - puppet-sync
  - ansible-playbook
---
# Infrastructure as code
.left-column[
## code
## Git
## automate
] .right-column[
- Treat IaC code as how you would treat application code
  - PR and merge
  - Build pipeline with test step
  - Deploy if OK -&gt; Automated process 
- Automatically apply changes to cluster
  - Push based deployment: Deploys upon change
  - Pull: Active pull, regular pull: Actual state -&gt; desired state
  - Advantage: Git revert gets environment back to pre-break-state
  - The git repository is the source of **truth** for a system's configuration
- Fewer people need access to actual infrastructure
]
???
- Everyone can create a PR
- With push based deployment you need a webhook from your git server when something has changed on server
- PR gets automatically tested. Maybe. There are some security considerations
- Fewer people with access: Depends on how the organization is rigged in regard to this

---
# Infrastructure as code
.left-column[
## code
## Git
## automate
## GitOps
] .right-column[
![gitops](image/gitops.png )

- Easily set up as part of a CD / CI pipeline
- Gitops is: IaC + SCM + PR + CI/CD
- Benefits
  - Incresed **productivity**: Continuous deployment automation + feedback speeds up Mean Time to Deployment
  - Enhanced Developer Experience: Can **focus** on the application and not everything around it
  - Improved stabiliy: Git gives you convenient **audit trail**
  - High reliability: **Single source of truth** makes it feasible to quickly roll
    back and **reduce Mean Time to Recovery** (MTTR) from hours to minutes.
  - Consistency and Standardization: All setup and task **reproducible** through git
]
???
- Infrastructure as code + Source Control Management + Pull Requests + Continuous Integration / Deployment 
- Configuration as Code
- when the actual state of the system drifts from the desired state
  - k8s good fit
  - kustomize, patches and namespace
- Comprehensive gitops guide: https://www.weave.works/technologies/gitops/
- Image from https://www.weave.works/technologies/gitops/

---
## Fluxcd
- Canaries, feature flags, A/B
- 
  Feature set:
- GitOps
- Can push back automated container image updates
- Use S3 buckets in addition to git
- Supports kustomize and helm
- Admission controllers
- Alerts and notifications

About Flux:
- From https://weave.works
- A CNCF project: https://www.cncf.io/projects/flux/
- Argo-flux collaboration did not fly
- AWS embraces flux (11.01.2022)
  - https://aws.amazon.com/blogs/containers/gitops-model-for-provisioning-and-bootstrapping-amazon-eks-clusters-using-crossplane-and-flux/
- Azure (23.03.2022):
  - https://docs.microsoft.com/en-us/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2

???
- TODO Example of problem flux solves
- Feature set is more than just GitOps
- Admission controllers: Are this artifact legal to deploy. Example missing cpu limit
- Cloud Native Computing Foundation
- GCP does not have any specific instructions TODO double check
- Is it feasible to get the functionality Argo supports with FluxCD alone 
  - By creating a tenant out a single source repo
  - You don't get the nice visuals, though
---
## Multi-tenancy

You want to separate setup and access to a number of roles. Simplified:
- **Flux system** admin: Sets up the Flux installation for cluster use
- **Cluster** admins: Users of Flux system, creators of Tenants
- (Cluster) **Tenant**:
  - Users of a cluster, i.e. dev-team
  - Can set up their own applications within assigned sliced of kubernetes
  - Possibly: Set up their own sub-tenants
- Git **access rights** enforces isolation 
  - I.e: One tenant cannot change code for a different tenant
- https://github.com/fluxcd/flux2-multi-tenancy
  - Cluster admin can just se
  - t up cluster and tenants
  ???
- Tenant: Slice of kubernetes depends on the rules enforced by the cluster admin
- Sub-tenant: Depends on organization of flux
- Access rights: SSH key when self-hosting
---

name: inverse
layout: true
class: center, middle, inverse
---
# Practical example
---
layout: false
## Fire up docker based kubernetes

Create the cluster
```bash
kind create cluster --config kind-api-cluster.yaml
```
Test that it runs OK
```bash
kubectl get pods -A
kubectl config get-contexts
kubectl config use-context kind-kind  
```
We want to be able to accommodate the following:
- Flux base system
- Cluster setup
- Creation of tenant within the cluster

---
## Create ssh keys for git

```bash
ssh-keygen -f ~/.ssh/fluxpres -N "" -C "Key used for flux presentation"
```
As the different git repositories represent different access levels, we
would **use different keys** in a real life scenario.

For the demonstration, lets create a sshd service and use the key there:
```bash
pushd dockerimage/sshd/
cp ~/.ssh/fluxpres.pub .
docker build -t flux_sshd:v1 .
kind load docker-image flux_sshd:v1
kubectl apply -f sshd.yaml
popd
```
Test the connection:
```bash
ssh -i ~/.ssh/fluxpres -p 30022 fluxpres@localhost 
```


???
- keygen note: Modern algorithm, no passphrase
- https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
- https://medium.com/risan/upgrade-your-ssh-key-to-ed25519-c6e8d60d3c54
- Test key ` ssh -i ~/.ssh/fluxpres fluxpres@sshd `
- Consider ssh-keyscan -H sshd >> ~/.ssh/known_hosts
- Testing repository: git clone ssh://fluxpres@sshd.default:/home/en/scrap/flux-system.git
``` 
# Modern type key:
ssh-keygen -t ed25519 -f ~/.ssh/fluxpres -N "" -C "Key used for flux presentation dev on que"
flux bootstrap git --url=ssh://fluxpres@sshd.default:/home/fluxpres/flux-system.git --branch=master --ssh-key-algorithm=ed25519 --private-key-file=$HOME/.ssh/fluxpres
# commit into presentation directory
flux bootstrap github --owner=nostra --repository=gitops-fluxcd2 --branch=master path=/flux-system --personal=true --private=true  
```

---
## ...  and enable GitOps with kustomize
.left-column[
## system
] .right-column[
```bash
ssh -i ~/.ssh/fluxpres -p 30022 fluxpres@localhost git init --bare flux-system.git < /dev/null
```
```bash
echo "Clone and install flux system"
mkdir -p ~/scrap/work
cd ~/scrap/work
git clone ssh://fluxpres@localhost:30022/home/fluxpres/flux-system.git
flux install \
  --components=source-controller,kustomize-controller,helm-controller,notification-controller \
  --components-extra=image-reflector-controller,image-automation-controller \
  --export > ./flux-system/gotk-components.yaml
pushd flux-system
git add . ; git commit -a -m "Initial commit" ; git push
popd  
```
]
???
- System is the Flux system as such
- https://fluxcd.io/docs/installation/#air-gapped-environments
- https://github.com/fluxcd/flux2-multi-tenancy
- Open as module in IntelliJ
---
## ...  and enable GitOps with kustomize
.left-column[
## system
## secret
] .right-column[
Add ssh key as secret to flux system. Notice you need to have `PRESENTATION_DIR` set to directory of this presentation.
```bash
export PRESENTATION_DIR=$PWD
cd ~/scrap/work
pushd flux-system
flux create secret git flux-system \
    --url=ssh://fluxpres@localhost:30022/home/fluxpres/flux-system.git \
    --private-key-file=$HOME/.ssh/fluxpres --namespace=flux-system \
    --export > flux-system-secret.yaml
echo "Correct sshd hostname to what it is inside cluster"
sed -i 's|.localhost.:30022|sshd.default|g' flux-system-secret.yaml
cp $PRESENTATION_DIR/flux/system/*sync.yaml .
kustomize create --namespace=flux-system --autodetect .
git add .
git commit -a -m "Add secret and sync configurations" ; git push
popd
```
```bash
pushd flux-system
echo "Bootstrap flux system - might do it twice if kustomization crd is not registered"
kustomize build .|kubectl apply -f -
popd
```

Notice that the secret would be **encrypted with Mozilla SOPS or Sealed Secrets** in a 
real life scenario in order to avoid storing plain-text secrets in git.

]
???
- You want a way of encrypting secrets when you store them in git
---
## ...  and enable GitOps with kustomize
.left-column[
## system
## secret
## cluster
] .right-column[
Create cluster configuration:
```bash
ssh -i ~/.ssh/fluxpres -p 30022 fluxpres@localhost git init --bare flux-cluster.git </dev/null
```
Fulcrum of a cluster setup
```bash
export PRESENTATION_DIR=$PWD
cd ~/scrap/work
git clone ssh://fluxpres@localhost:30022/home/fluxpres/flux-cluster.git
echo "Add sync to flux-system"
cp $PRESENTATION_DIR/flux/cluster/*sync.yaml flux-cluster/.
pushd flux-cluster
flux create secret git flux-cluster \
    --url=ssh://fluxpres@localhost:30022/home/fluxpres/flux-cluster.git \
    --private-key-file=$HOME/.ssh/fluxpres --namespace=flux-cluster \
    --export > flux-cluster-secret.yaml
sed -i 's|.localhost.:30022|sshd.default|g' flux-cluster-secret.yaml
kustomize create --autodetect . 
git add .
git commit -a -m "Cluster setup" ; git push
popd  
```
]
???
- TODO ` kustomize create --autodetect --namespace=flux-cluster .` cannot be done 
  before sync files are in separate ns. See: ` grep namespace flux/cluster/*.yaml`
```
Notes to organize:

kustomize edit add resource flux-cluster-secret.yaml 
kustomize edit add resource flux-cluster.yaml

pushd flux-cluster
#  sed -i 's|fluxpres@sshd|xxxxx|g' * 
git add . ; git commit -a -m "Initial commit" ; git push

export PRESENTATION_DIR=$HOME/git/private/gitops-fluxcd2

# Alternative: 
flux bootstrap git --url=ssh://fluxpres@sshd.default:/home/fluxpres/flux-cluster.git --username=en --silent --branch=master
# Works, but adds flux-system to repo
flux bootstrap git --url=ssh://fluxpres@sshd.default:/home/fluxpres/flux-cluster.git --username=en --silent --branch=master --ssh-key-algorithm=ed25519 --private-key-file=$HOME/.ssh/fluxpres
```

---
## ...  and enable GitOps with kustomize
.left-column[
## system
## secret
## cluster
## tenant 
] .right-column[
Synchronization configuration for tenant was copied in previous step, now create secret for git:
```bash
cd ~/scrap/work
pushd flux-cluster
flux create secret git flux-tenant \
    --url=ssh://fluxpres@localhost:30022/home/fluxpres/flux-tenant.git \
    --private-key-file=$HOME/.ssh/fluxpres --namespace=flux-cluster \
    --export > flux-tenant-secret.yaml
sed -i 's|.localhost.:30022|sshd.default|g' flux-tenant-secret.yaml
git add flux-tenant-secret.yaml
kustomize edit add resource flux-tenant-secret.yaml
git commit -a -m "Add encrypted secret" ; git push
kustomize build .|kubectl apply -f - 
popd
```
]
???
- Not actually creating secret. 
  - Encryption of files in git is a different subject
  - Keys, repos and all I show is temporary anyway
---
## ...  and enable GitOps with kustomize
.left-column[
## system
## secret
## cluster
## tenant
## tenant-repo
] .right-column[

```bash
ssh -i ~/.ssh/fluxpres -p 30022 fluxpres@localhost git init --bare flux-tenant.git
```
```bash
cd ~/scrap/work
git clone ssh://fluxpres@localhost:30022/home/fluxpres/flux-tenant.git
pushd flux-tenant
flux create tenant dev-team \
    --with-namespace=frontend \
    --with-namespace=backend \
	--export > dev-team.yaml
kustomize create --autodetect .

git add . ; git commit -a -m "Initial commit" ; git push
popd  
```
]
???
- Note `--cluster-role something` otherwise it will get cluster-admin

---
## ...  and enable GitOps with kustomize
.left-column[
## system
## secret
## cluster
## tenant
## tenant-repo
## application
] .right-column[

Need to create and load an example docker image...

```bash
pushd dockerimage/example
docker build -t local-test:v1 .
kind load docker-image local-test:v1
popd
```
```bash
export PRESENTATION_DIR=$PWD
cd ~/scrap/work
pushd flux-tenant
cp -r $PRESENTATION_DIR/flux/tenant/backend .
kustomize edit add resource backend
git add . ; git commit -a -m "Add example" ; git push
popd 
```

After synchronization
```bash
kc port-forward -n backend svc/nginx-test 8080
```
* http://localhost:8080

Alternative: 
```bash
kubectl run multitool --rm -i --tty --image wbitt/network-multitool -- curl http://nginx-test.backend:8080
```
]
???
- NOT Showing:
- Update the example deployment (legacy)
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
# Questions?
