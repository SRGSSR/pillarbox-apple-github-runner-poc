#!/bin/sh

scripts_path="$1"
vm_name="$2"
platform="$3"

repository_path="~/_repo"

if [[ -z $scripts_path || -z $vm_name || -z $platform ]]
then
    echo "[!] Usage: $(echo $0) <scripts_path> <vm_name> <platform>"
    exit 1
fi

source "$(dirname $(realpath $0))/unlock-keychain.sh"

$scripts_path/run-vm-shell-command.sh $vm_name "cd $repository_path && echo $(unlock_keychain) && make archive-demo-$(echo $platform)"
