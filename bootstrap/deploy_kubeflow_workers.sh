#!/bin/bash
wdir=$(cd "$(dirname $0)" && pwd)
pushd $wdir
./init_kubeflow.sh
./config_kubeflow.sh
./dist_kubeblow.sh
./executePayloadKubeflow.sh
popd

