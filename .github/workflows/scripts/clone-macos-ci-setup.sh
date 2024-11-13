#!/bin/zsh

scripts_path_destination=$1
github_token=$2
git_branch=$3

if [[ -z $scripts_path_destination || -z $github_token || -z $git_branch ]]
then
    echo "[!] Usage: $(echo $0) <scripts_path_destination> <github_token> <git_branch>"
    exit 1
fi

rm -rf $scripts_path_destination
git clone -b $git_branch "https://$github_token@github.com/SRGSSR/macos-ci-setup.git" $scripts_path_destination
