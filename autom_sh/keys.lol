#!/bin/bash
touch /tmp/asap1
while true
do
    rm -rf /tmp/wallet20
    rm -rf /tmp/wallet55
    rm -rf /tmp/wallet75
    rm -rf /tmp/all_address
    rm -rf /tmp/address20aa
    rm -rf /tmp/address20ab
    rm -rf /tmp/address20
    rm -rf /tmp/address55
    rm -rf /tmp/address55aa
    rm -rf /tmp/address55ab
    rm -rf /tmp/address75
    rm -rf /tmp/address75aa
    rm -rf /tmp/address75ab

    rdm=$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))
    rdm1=$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))
    rdm2=$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))$((1 + RANDOM % 99999))

    /tmp/keys btc $rdm > /tmp/wallet20
    /tmp/keys btc $rdm1 > /tmp/wallet55
    /tmp/keys btc $rdm2 > /tmp/wallet75

    cat /tmp/wallet20 | cut -d " " -f 2 > /tmp/address20
    cat /tmp/wallet55 | cut -d " " -f 2 > /tmp/address55
    cat /tmp/wallet55 | cut -d " " -f 2 > /tmp/address75

    split -l 64 /tmp/address20 /tmp/address20
    split -l 64 /tmp/address55 /tmp/address55
    split -l 64 /tmp/address55 /tmp/address75

    address1=$(cat /tmp/address20aa | tr "\n" "|" | sed 's/|$//')
    bilance=$(curl -s "https://blockchain.info/balance?cors=true&active=${address1}" | grep -Po '"final_balance":.*?[^\\],' | cut -d ":" -f 2 | tr -d ",","}" | awk '{if($1>0) print $1}' | tr "\n" ":" | cut -d ":" -f 1)

    if [[ "$bilance" -ne 0 ]]
    then
        echo "$(date +"%Y-%m-%d %H:%M:%S") - Found non-zero balance for addresses: $address1" >> /tmp/balance_log.txt
    else
        mov=$(curl -s "https://blockchain.info/balance?cors=true&active=${address1}" | grep -Po '"total_received":.*?[^\\],' | cut -d ":" -f 2 | tr -d ",","}" | awk '{if($1>0) print $1}' | tr "\n" ":" | cut -d ":" -f 1)
        if [[ "$mov" -ne 0 ]]
        then
            echo "$(date +"%Y-%m-%d %H:%M:%S") - Found non-zero total received for addresses: $address1" >> /tmp/received_log.txt
        else
            echo "$(date +"%Y-%m-%d %H:%M:%S") - No transactions for addresses: $address1" >> /tmp/no_transactions_log.txt
        fi
    fi

    # Repeat similar checks and logging for other addresses (address2, address3, ...)

    sleep 1  # Adjust sleep duration as needed
done
