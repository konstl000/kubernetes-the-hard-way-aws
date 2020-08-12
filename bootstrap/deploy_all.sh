#!/bin/bash
wdir=$(cd "$(dirname $0)" && pwd)
pushd $wdir
./init.sh
./config.sh
./enc.sh
./dist.sh
./executePayloadMasters.sh
./nlb.sh
./access.sh
./executePayloadWorkers.sh
./dns.sh
./labelMasters.sh
./nginx.sh
popd
