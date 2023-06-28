#!/bin/sh
set -e
set -o noglob


# --- setup dependencies for Akamai SIEM ---
setup_dependencies() {
    echo -e '\033[32;5;7m[  INFO  ] \033[0m' "Update packages"
    apt -y update
    echo -e '\033[32;5;7m[  INFO  ] \033[0m' "Installing dependencies"
    apt install -y git curl net-tools ca-certificates gnupg apache2-utils
}

setup_k3s() {
    echo -e '\033[32;5;7m[  INFO  ] \033[0m' "Install k3s from https://get.k3s.io"
    curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable=traefik" sh -
    ln -s /etc/rancher/k3s/k3s.yaml kubeconfig
}

setup_helm() {
    echo -e '\033[32;5;7m[  INFO  ] \033[0m' "Install Helm"
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    apt-get update
    sudo apt-get install helm
}

# --- setup dependencies for Akamai SIEM ---
setup_env() {
    sysctl -w vm.max_map_count=262144
    echo -e '\033[32;5;7m[  INFO  ] \033[0m' "Setup ENV"
}

# --- run the install process --
{
    setup_dependencies
    setup_k3s
    setup_helm
    setup_env
}