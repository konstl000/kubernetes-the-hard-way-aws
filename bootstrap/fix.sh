#!/bin/bash
USERNAME=ubuntu
function getInstancesByTag () {
 aws ec2 describe-instances --filter "Name=tag-value,Values=$1" | jq -c '.Reservations[].Instances[] | select (.State.Name == "running")'
}
function getInstanceId(){
 echo "$1" | sed -n "$2p" | jq -r '.InstanceId'
}
masters=$(getInstancesByTag k8smaster)
workers=$(getInstancesByTag k8snode)
function connectAndExecute(){
      if [[ -z "$DRY_RUN" ]] || [[ "$DRY_RUN" == "" ]]
      then
      echo "connecting to $(getInstanceId "$2" "$3")"
      ssh -tt -i ../rsa/k8s.pem -o StrictHostKeyChecking=no -l ${USERNAME} $(getInstanceId "$2" "$3") <<EOF | tee protocol.txt
${1}
exit
EOF
else
  echo -e "PAYLOAD:\n"
  echo "$1"
fi
if [[ "$4" != "" ]] && [[ "$4" != 0 ]]
then
  local payload=$(preparePayload "$(echo "{\"payload\":\"handleBackgroundScript.sh\"}")")
  connectAndExecute "$payload" "$2" "$3"
fi
}
function preparePayload(){
  local content=$(cat "$(echo "$1" | jq -r '.payload')")
  varlines=$(echo -e "$content" | grep '\${' )
  while read -r varline
  do
    if [[ "$varline" != "" ]]
    then
      local varnames=$(echo "$varnames $(echo $varline | perl -ne 'print "$1 " while /(\$\{.*?\})/g')")
    fi
  done<<<"$varlines"
  for varname in $varnames
  do
    content=$(echo "$content" | sed 's`'"$varname"'`'"$(eval echo "$varname")"'`g')
  done
  if [[ $(echo "$1" | jq -r '.background') == "" ]] || [[ $(echo "$1" | jq -r '.background') == null ]]
  then
   echo '
    while true
    do
      name=$(dd if=/dev/urandom count=32 bs=1 | base64 -w0 | sed -e "s/[^[:alnum:]]//g" -e "s/$/.sh/")
      if [[ "$(ls $name 2>/dev/null)" == "" ]]
      then
        break
      fi
    done
'
  echo "echo '$(echo "$content" | base64)' | base64 -d > \$name"
  echo 'chmod +x $name'
  echo './$name'
  echo 'rm -f ./$name'
  else
    echo '
    while true
    do
      name=$(dd if=/dev/urandom count=32 bs=1 | base64 -w0 | sed -e "s/[^[:alnum:]]//g" -e "s/$//")
      if [[ "$(ls $name 2>/dev/null)" == "" ]]
      then
        break
      fi
    done
    '
    echo 'mkdir $name'
    echo "echo '$(echo "$content" | base64)' | base64 -d > \$name/$(echo "$1" | jq -r '.script_name')"
    echo "chmod +x \$name/$(echo "$1" | jq -r '.script_name')"
    echo "./\$name/$(echo "$1" | jq -r '.script_name') >> ./\$name/exec.log 2>> ./\$name/exec.log &"
  fi
}
function getScriptName(){
  SCRIPT_NAME="$(dd if=/dev/urandom count=32 bs=1 | base64 -w0 | sed -e "s/[^[:alnum:]]//g" -e "s/$/.sh/")"
}

for index in 1 2 3; do
  for filename in fix2.sh
  do
    connectAndExecute "$(preparePayload $(echo "{\"payload\":\"${filename}\"}"))" "$masters" "$index"
  done
  for filename in fix3.sh
  do
    connectAndExecute "$(preparePayload $(echo "{\"payload\":\"${filename}\"}"))" "$workers" "$index"
  done
done
