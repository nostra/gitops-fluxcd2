# gitops-presentation

What is gitops, and how to set it up on kubernetes with fluxcd

Render presentation with `make`, and then view [presentation.html](presentation.html) in a browser.

Alternatively, see http://nostra.github.io/gitops-fluxcd2/

You probably want to clone this repository if you want to do the examples.


## Installation on arch linux

``` 
pikaur -S flux-bin
pikaur -S kustomize
pikaur -S kind-bin
pikaur -S krew-bin 

flux check --pre  
```

## Start kind cluster with config

In order to get the sshd nodeport expoosed, do:

     kind create cluster --config kind-api-cluster.yaml 

