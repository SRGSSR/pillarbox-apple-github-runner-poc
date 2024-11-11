#!/bin/sh

scripts_path="$1"
runner_name="$2"
github_output="$3"

if [[ -z $scripts_path || -z $runner_name || -z $github_output ]]
then
    echo "[!] Usage: $(echo $0) <scripts_path> <runner_name> <github_output>"
    exit 1
fi


runner_group_label=$($scripts_path/runner-group-label.sh $runner_name)
echo "runner_group_label=$runner_group_label" >> $github_output
