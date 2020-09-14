#!/bin/bash
curl -L -o nginx.yaml https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/aws/deploy.yaml
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
