#!/bin/bash
function main(){
for index in 1 2 3; do
  for filename in etcd.sh
  do
    connectAndExecute "$(preparePayload $(echo "{\"payload\":\"${filename}\"}"))" "$masters" "$index"
  done
  for filename in kube_master.sh
  do
    HOSTNAME=$(echo "master-$index")
    POD_CIDR="10.200.0.0/16"
    getScriptName
    connectAndExecute "$(preparePayload $(echo "{\"payload\":\"${filename}\",\"background\":true,\"script_name\":\"${SCRIPT_NAME}\"}"))" "$masters" "$index" 1
  done
  for filename in crictl.sh
  do
    connectAndExecute "$(preparePayload $(echo "{\"payload\":\"${filename}\"}"))" "$masters" "$index"
  done
done
}
source ./executePayload.sh
USERNAME=ubuntu
CONTROLLER_CONFIG=""
ETCD_SERVERS=""
masters=$(getInstancesByTag k8smaster)
for index in 1 2 3; do
  ETCD_SERVERS=$(echo "$ETCD_SERVERS,https://$(getPrivateIp "$masters" "$index"):2379")
  CONTROLLER_CONFIG=$(echo "$CONTROLLER_CONFIG,$(getPrivateDnsName "$masters" "$index")=https://$(getPrivateIp "$masters" "$index"):2380")
  CONTROLLER_CONFIG=$(echo "$CONTROLLER_CONFIG" | sed 's/^,//')
  ETCD_SERVERS=$(echo "$ETCD_SERVERS" | sed 's/^,//')
done
main
