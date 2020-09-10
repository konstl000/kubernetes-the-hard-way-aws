#!/bin/bash
set -e
GREEN='\e[32m'
DEF='\e[0m'
RED='\e[31m'
YELLOW='\e[93m'
function clearEnv(){
  unset AWS_ACCESS_KEY_ID
  unset AWS_SECRET_ACCESS_KEY
  unset AWS_SESSION_TOKEN
  unset AWS_EXPIRATION
}
function assumeRole(){
  CREDENTIALS=$(aws sts assume-role --role-arn $1 --role-session-name assumed-role)
  export AWS_ACCESS_KEY_ID="$(echo $CREDENTIALS | jq -r '.Credentials.AccessKeyId')"
  export AWS_SECRET_ACCESS_KEY="$(echo $CREDENTIALS | jq -r '.Credentials.SecretAccessKey')"
  export AWS_SESSION_TOKEN="$(echo $CREDENTIALS | jq -r '.Credentials.SessionToken')"
  export AWS_EXPIRATION=$(echo $CREDENTIALS | jq -r '.Credentials.Expiration')
  aws sts get-caller-identity
}
function runTerraform(){
  local cnt=0
  while [[ $cnt -lt ${MAX_ATTEMPTS} ]]
  do
    ./init.sh
    local res=0
    set +e
    terraform init
    res=$(($res+$?))
    terraform plan -out plan
    res=$(($res+$?))
    terraform apply plan
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
function updateToVault(){
  vault login -no-print -method=ldap username=${ROOT_USER}  password="$(getKeyFromSSM "${ROOT_PASSWORD_PATH}")"
  vault kv put /concourse/main/k8s-private-key value=@rsa/k8s.pem
  vault kv put /concourse/main/admin-kubeconfig value@/root/.kube/config
}
function main(){
  pushd ./repo
  runTerraform
  ./bootstrap/deploy_all.sh
  updateToVault
  popd
  echo -e "${GREEN}Env created successfully${DEF}"
}
assumeRole ${ROLE_TO_ASSUME}
main

