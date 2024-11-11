#!/bin/sh

scripts_path="$1"
vm_name="$2"

if [[ -z $scripts_path || -z $vm_name ]]
then
    echo "[!] Usage: $(echo $0) <scripts_path> <vm_name>"
    exit 1
fi

source "$(dirname $(realpath $0))/constants.sh"

$scripts_path/run-vm-shell-command.sh $vm_name "cd $REPOSITORY_PATH && make test-streams-start"
