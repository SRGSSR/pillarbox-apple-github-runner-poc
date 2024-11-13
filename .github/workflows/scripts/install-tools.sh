#!/bin/zsh

scripts_path="$1"
vm_name="$2"
vm_image="$3"
branch_name="$4"
repo_url="$5"

if [[ -z $scripts_path || -z $vm_name || -z $vm_image || -z $branch_name || -z $repo_url ]]
then
    echo "[!] Usage: $(echo $0) <scripts_path> <vm_name> <vm_image> <branch_name> <repo_url>"
    exit 1
fi

tools="swiftlint shellcheck markdownlint-cli yamllint ffmpeg"
ruby_version="3.3.5"
bundler_version="2.5.22"

$scripts_path/brew-fetch.sh $vm_name $tools

$scripts_path/create-vm-for-project.sh $vm_name $vm_image 'reuse'
$scripts_path/clone-repo-in-vm.sh $vm_name $branch_name $repo_url

$scripts_path/run-vm-shell-command.sh $vm_name "brew install --quiet $tools"
$scripts_path/run-vm-shell-command.sh $vm_name "rbenv install --skip-existing $ruby_version"
$scripts_path/run-vm-shell-command.sh $vm_name "echo 'export PATH=\"$HOME/.rbenv/bin:\$PATH\"' >> ~/.zshrc"
$scripts_path/run-vm-shell-command.sh $vm_name "rbenv init - >> ~/.zshrc"
$scripts_path/run-vm-shell-command.sh $vm_name "rbenv global $ruby_version"
$scripts_path/run-vm-shell-command.sh $vm_name "sudo gem install bundler -v $bundler_version"
$scripts_path/run-vm-shell-command.sh $vm_name "curl --location https://github.com/shaka-project/shaka-packager/releases/download/v3.2.0/packager-osx-arm64 -o /opt/homebrew/bin/shaka-packager"
$scripts_path/run-vm-shell-command.sh $vm_name "chmod a+x /opt/homebrew/bin/shaka-packager"
$scripts_path/run-vm-shell-command.sh $vm_name "source ~/.zshrc"
