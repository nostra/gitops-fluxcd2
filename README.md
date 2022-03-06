# gitops-presentation

*******
MERK: Stoppet her.
*******

Plan:
- kjøre opp kind
- lage lokal bruker 
- lage lokal git-struktur
- lage ssh-nøkkel
- sette opp flux
- lage kataloger basert på templates


What is gitops, and how to set it up on kubernetes with fluxcd

Render presentation with `make`, and then view [presentation.html](presentation.html) in a browser.

You probably want to clone this repository if you want to do the examples.

Stjel innhold fra: 10 min intro til gitOps: https://www.youtube.com/watch?v=f5EpcWp0THw
Fine headlines: Infrastructure as code
- store in git (manually apply)
- treat the code as how you would treat applicaiton code
- PR and merge
- test and pipeline
- deploy if OK
-> Automated process
- automatically apply changes to cluster
- push based deployment: Deploy upon push
- pull : active pull, regular pull: Actual state -> desired state
- Advantage: Git revert get env back to pre-break-state
- Git as single source of truth
=> What if not k8s, alternatives ansible, puppet, chef
- Not actully necessary for all team members to have access to cluster
- less permissions
=> Gitops is: IaC + SCM + PR + CI/CD

## Installation

``` 
pikaur -S flux-bin
pikaur -S kustomize
pikaur -S kind-bin

flux check --pre  
```
