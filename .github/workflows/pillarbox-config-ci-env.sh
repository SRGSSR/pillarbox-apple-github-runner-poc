#!/bin/sh

# -- FOR DEBUG
# MACOS_CI_SETUP_TOKEN="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"
# VM_NAME="sequoia-for-pillarbox"
# VM_IMAGE="ghcr.io/cirruslabs/macos-sequoia-xcode:latest"

cd ~/macos-ci-setup
./create-vm-for-project.sh $VM_NAME $VM_IMAGE
./clone-repo-in-vm.sh "https://$MACOS_CI_SETUP_TOKEN@github.com/SRGSSR/fake-and-temporary-pa-for-runners.git" $VM_NAME
./brew-fetch-and-sync.sh $VM_NAME mint shellcheck markdownlint-cli yamllint ffmpeg
./run-vm-shell-command.sh $VM_NAME "brew install mint shellcheck markdownlint-cli yamllint ffmpeg"
./run-vm-shell-command.sh $VM_NAME "rbenv install --skip-existing 3.3.5"
./run-vm-shell-command.sh $VM_NAME "echo 'export PATH=\"$HOME/.rbenv/bin:$PATH\"' >> ~/.zshrc"
./run-vm-shell-command.sh $VM_NAME "rbenv init - >> ~/.zshrc"
./run-vm-shell-command.sh $VM_NAME "source ~/.zshrc"
./run-vm-shell-command.sh $VM_NAME "rbenv global 3.3.5"
./run-vm-shell-command.sh $VM_NAME "sudo gem install bundler -v 2.5.22"
./run-vm-shell-command.sh $VM_NAME "curl --location https://github.com/shaka-project/shaka-packager/releases/download/v3.2.0/packager-osx-arm64 -o /opt/homebrew/bin/shaka-packager"
./run-vm-shell-command.sh $VM_NAME "chmod a+x /opt/homebrew/bin/shaka-packager"
./run-vm-shell-command.sh $VM_NAME "source ~/.zshrc"
