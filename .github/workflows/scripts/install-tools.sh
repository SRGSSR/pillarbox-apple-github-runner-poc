#!/bin/sh

vm_name="$1"
vm_image="$2"
branch_name="$3"
repo_url="$4"
script_path="$5"

echo "=========> Debugging variables <========"
echo "script_path: $script_path"
echo "vm_name: $vm_name"
echo "vm_image: $vm_image"
echo "branch_name: $branch_name"
echo "repo_url: $repo_url"

"$script_path/brew-fetch.sh" "$vm_name" "swiftlint shellcheck markdownlint-cli yamllint ffmpeg"

"$script_path/create-vm-for-project.sh" "$vm_name" "$vm_image"
"$script_path/clone-repo-in-vm.sh" "$vm_name" "$branch_name" "$repo_url"

"$script_path/run-vm-shell-command.sh" "$vm_name" "brew install --quiet swiftlint shellcheck markdownlint-cli yamllint ffmpeg"
"$script_path/run-vm-shell-command.sh" "$vm_name" "rbenv install --skip-existing 3.3.5"
"$script_path/run-vm-shell-command.sh" "$vm_name" "echo 'export PATH=\"$HOME/.rbenv/bin:\$PATH\"' >> ~/.zshrc"
"$script_path/run-vm-shell-command.sh" "$vm_name" "rbenv init - >> ~/.zshrc"
"$script_path/run-vm-shell-command.sh" "$vm_name" "rbenv global 3.3.5"
"$script_path/run-vm-shell-command.sh" "$vm_name" "sudo gem install bundler -v 2.5.22"
"$script_path/run-vm-shell-command.sh" "$vm_name" "curl --location https://github.com/shaka-project/shaka-packager/releases/download/v3.2.0/packager-osx-arm64 -o /opt/homebrew/bin/shaka-packager"
"$script_path/run-vm-shell-command.sh" "$vm_name" "chmod a+x /opt/homebrew/bin/shaka-packager"
"$script_path/run-vm-shell-command.sh" "$vm_name" "source ~/.zshrc"