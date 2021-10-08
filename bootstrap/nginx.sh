#!/bin/bash
curl -L -o nginx.yaml "${NGINX_URL}" 
cnt=1
while true
do 
  kubectl apply -f nginx.yaml
  if [[ $? != 0 ]]
  then
    if [[ $cnt -gt 10 ]]
    then
      break
    else
      cnt=$(($cnt+1))
      echo "Deployment of nginx failed, $cnt attempt coming ..."
      sleep 10
    fi
  else
    break
  fi
done
