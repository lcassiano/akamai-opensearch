#!/bin/sh
set -e
set -o noglob


# --- setup dependencies for Akamai SIEM ---
setup_dependencies() {
    echo -e '\033[32;5;7m[  INFO  ] \033[0m' "Update packages"
    apt -y update
    echo -e '\033[32;5;7m[  INFO  ] \033[0m' "Installing dependencies"
    apt install -y git curl net-tools ca-certificates gnupg
}

setup_k3s() {
    echo -e '\033[32;5;7m[  INFO  ] \033[0m' "Install k3s from https://get.k3s.io"
    curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.25.7+k3s1 sh -
    ln -s /etc/rancher/k3s/k3s.yaml iac/kubeconfig
}

# --- setup dependencies for Akamai SIEM ---
setup_env() {
    echo -e '\033[32;5;7m[  INFO  ] \033[0m' "Setup ENV"
    export IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
    echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Configure este hostname: $APPHOSTNAME no seu DNS master apontando para o IP $IPADDR";
    echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Segue um exemplo: $APPHOSTNAME   IN   A   $IPADDR";
}

# --- run the install process --
{
    setup_dependencies
    setup_k3s
    setup_env
}