#!/usr/bin/env bash

source src/utils.sh

# install --prefer-snap -dfpn nyancat
add_remote_signing_key -u "https://download.docker.com/linux/ubuntu/gpg"
add_package_repository -r "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
