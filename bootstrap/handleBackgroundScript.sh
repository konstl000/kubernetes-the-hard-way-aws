#!/bin/bash
script_name='${SCRIPT_NAME}'
function getFolderName(){
  local relpath=$(find ./ -maxdepth 2 -type f -name $script_name)
  local fldr=$(echo $relpath | sed -r 's`\./(.*)/.*$`\1`')
  echo $fldr
}
function followExec(){
  while true
  do
    local procinfo=$(ps -aux | grep $script_name | grep -v grep)
    if [[ "$procinfo" == "" ]]
    then
      echo "$script_name finished ..."
      break
    else
      echo "$script_name is still running ..."
      sleep 10
    fi
  done
}
fldr=$(getFolderName)
followExec
cat "/home/${USERNAME}/$fldr/exec.log"
if [[ "$fldr" != "" ]]
then
  rm -r -f "/home/${USERNAME}/$fldr"
fi

