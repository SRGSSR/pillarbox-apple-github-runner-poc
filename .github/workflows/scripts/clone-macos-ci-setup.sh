#!/bin/sh

scripts_path_destination=$1
github_token=$2
branch=$3

if [[ -z $scripts_path_destination || -z $github_token || -z $branch ]]
then
    echo "[!] Usage: $(echo $0) <scripts_path_destination> <github_token> <branch>"
    exit 1
fi

rm -rf $scripts_path_destination
git clone -b $branch "https://$github_token@github.com/SRGSSR/macos-ci-setup.git" $scripts_path_destination
