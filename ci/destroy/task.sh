#!/bin/bash
source repo/ci/common.sh
function runTerraform(){
  local cnt=0
  while [[ $cnt -lt ${MAX_ATTEMPTS} ]]
  do
    local res=0
    set +e
    terraform init
    res=$(($res+$?))
    terraform destroy -auto-approve
    res=$(($res+$?))
    set -e
    if [[ $res != 0 ]]
    then
      cnt=$(($cnt+1))
      echo -e "${YELLOW}Terraform state may be locked, new attempt in ${INTERVAL} seconds, remaining attempts: $((${MAX_ATTEMPTS}-$cnt))${DEF}"
      sleep ${INTERVAL}
    else
      echo -e "${GREEN}Terraform ran successfully"
      break
    fi
  done
}
function main(){
  local k8sCheck=$(checkK8S)
  if [[ "$k8sCheck" == 0 ]]
  then
    pushd repo
    curl -L -o nginx.yaml https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/aws/deploy.yaml
    kubectl delete -f nginx.yaml
    TERRAFORM_STATE=$(getFileFromVault "${KUBE_PATH}/terraform_state")
    if [[ -z $TERRAFORM_STATE ]]
    then
      echo -e "${RED}Could not retrieve the terraform state, please fix it manually!${DEF}"
      exit 1
    else
      echo "${TERRAFORM_STATE}">terraform.tfstate
      mkdir -p rsa
      echo -e "$(getFileFromVault "${KUBE_PATH}/ssh_private_key")">rsa/k8s.pem
      chmod 600 rsa/k8s.pem
      echo -e "$(getFileFromVault "${KUBE_PATH}/ssh_public_key")">rsa/k8s.pem.pub
      runTerraform
      deleteFromVault "${KUBE_PATH}/terraform_state"
      deleteFromVault "${KUBE_PATH}/ssh_private_key"
      deleteFromVault "${KUBE_PATH}/ssh_public_key"
    fi
    popd
  else
    echo -e "${RED}Kubernetes is not reachable, please destroy it manually to avoid orphaned resources!${DEF}"
    exit 1
  fi
}
vaultLogin
assumeRole ${ROLE_TO_ASSUME}
#fixDNS
main

