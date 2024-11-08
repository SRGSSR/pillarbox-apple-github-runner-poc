#!/bin/sh

scripts_path="$1"
vm_name="$2"
github_token="$3"

if [[ -z $scripts_path || -z $vm_name || -z $github_token ]]
then
    echo "[!] Usage: $(echo $0) <scripts_path> <vm_name> <github_token>"
    exit 1
fi

repository_path="~/_repo"
keychain_password="admin"
keychain_path="~/Library/Keychains/login.keychain-db"
certificate_path="$repository_path/Configuration/6YXTQTG8JJ_development.p12"
certificate_password="6YXTQTG8JJ"

configuration_repo="github.com/SRGSSR/pillarbox-apple-configuration.git"
configuration_dir_path="$repository_path/Configuration"
configuration_script="$repository_path/Scripts/checkout-configuration.sh"
configuration_branch="certificate"
configuration_commit="HEAD"

function unlock_keychain {
    security unlock-keychain -p $keychain_password $keychain_path
}

function import_certificate {
    security import $certificate_path -k $keychain_path -P $certificate_password -T /usr/bin/security -T /usr/bin/codesign
}

function add_certificate_to_keychain {
    unlock_keychain && import_certificate
}

function authorize_access_to_certificate_private_key {
    security set-key-partition-list -S apple-tool:,apple: -s -k $keychain_password $keychain_path
}

$scripts_path/run-vm-shell-command.sh $vm_name "rm -rf $configuration_dir_path"
$scripts_path/run-vm-shell-command.sh $vm_name "$configuration_script https://$github_token@$configuration_repo $configuration_branch $configuration_commit $configuration_dir_path"
$scripts_path/run-vm-shell-command.sh $vm_name echo $(add_certificate_to_keychain)
$scripts_path/run-vm-shell-command.sh $vm_name echo $(authorize_access_to_certificate_private_key)
$scripts_path/run-vm-shell-command.sh $vm_name "cd $repository_path && make setup"
