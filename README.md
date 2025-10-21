# Kubernetes Demo

Some basic examples of how to run Kubernetes on the AWS and locally. 

As of this writing the examples here aren't 100% tested. I previously got the local example mostly working but not the
AWS example. Now the AWS example appears to be working but I haven't tested the local one. Just be aware that you may
need to tweak stuff until I can get around to making it all play nicely together. 


## Requirements

* A Linux/OpenBSD environment. MacOS is based on OpenBSD. 
  * Use Gitbash or WSL 2 if you're on Windows, you unwashed heathen.
* [Terraform](https://developer.hashicorp.com/terraform/install) or [Open Tofu](https://opentofu.org/docs/intro/install/)
* [kubectl + minikube](https://kubernetes.io/docs/tasks/tools/)
* [helm](https://helm.sh/docs/intro/install/)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
* [Podman](https://podman.io/docs/installation) or [Monokle](https://docs.monokle.io/getting-started/)
  * These will connect to your k8s cluster and you can inspect/modify various resources
  * Monokle is no longer under development, but is still good for now.
* [direnv](https://direnv.net/docs/installation.html) _(optional, but nice to have)_

## Usage

For now, follow instructions in the [README of the aws section](./aws/README.md). Eventually I'll get around to making 
sure the apps module gets along with both local and AWS at the same time.  