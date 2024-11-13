#!/bin/zsh

scripts_path="$1"
vm_name="$2"
platform="$3"

if [[ -z $scripts_path || -z $vm_name || -z $platform ]]
then
    echo "[!] Usage: $(echo $0) <scripts_path> <vm_name> <platform>"
    exit 1
fi

source "$(dirname $(realpath $0))/constants.sh"
source "$(dirname $(realpath $0))/unlock-keychain.sh"

$scripts_path/run-vm-shell-command.sh $vm_name "cd $REPOSITORY_PATH && $unlock_keychain && make archive-demo-$(echo $platform)"
