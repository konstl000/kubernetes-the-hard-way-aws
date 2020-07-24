# k8s-the-hard-way-aws

This is my adaptation of https://github.com/kelseyhightower/kubernetes-the-hard-way to AWS. 
Albeit the most of the stuff is taken from Kelsey Hightower's repo, this adaptation uses AWS cni as well as supports AWS LoadBalancers.

Assumes https://github.com/konstl000/terraform-modules to be in ../shared/
Assumes that you have a linux workstation or a mac with GNU sed

## Deployment
 - Install terraform
 - Install kubectl 1.18 (https://storage.googleapis.com/kubernetes-release/release/v1.18.6/bin/linux/amd64/kubectl)
 - Install cfssl (https://github.com/cloudflare/cfssl/releases)
 - Install cfssljson (https://github.com/cloudflare/cfssl/releases)
 - Clone https://gitlab.fme.de/bu4/shared-terraform-modules.git as ../shared (with respect to the root folder of this repo)
 - Run ```terraform init``` in the root folder of the repo
 - Run ```terraform plan -out plan```
 - Run ```terraform apply```
 - Run ```./bootstrap/deploy_all.sh```
 - The test folder contains a test deployment and service to check the resulting cluster
