#!/bin/sh

scripts_path="$1"
vm_name="$2"

repository_path="~/_repo"

if [[ -z $scripts_path || -z $vm_name ]]
then
    echo "[!] Usage: $(echo $0) <scripts_path> <vm_name>"
    exit 1
fi

$scripts_path/run-vm-shell-command.sh $vm_name "cd $repository_path && make test-streams-start"
