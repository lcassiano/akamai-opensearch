#!/bin/bash

# Install the NGINX Ingress Controller
echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Adding https://kubernetes.github.io/ingress-nginx repo"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Update your Helm repositories."
helm repo update

echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Install ingress-nginx"
helm install ingress-nginx ingress-nginx/ingress-nginx