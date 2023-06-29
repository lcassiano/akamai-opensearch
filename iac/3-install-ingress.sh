#!/bin/bash

# Install the NGINX Ingress Controller
echo '\033[31;5;7m[  WARN  ] \033[0m' "Adding https://kubernetes.github.io/ingress-nginx repo" > /dev/ttyS0
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx

echo '\033[31;5;7m[  WARN  ] \033[0m' "Update your Helm repositories." > /dev/ttyS0
helm repo update

echo '\033[31;5;7m[  WARN  ] \033[0m' "Install ingress-nginx" > /dev/ttyS0
helm install ingress-nginx ingress-nginx/ingress-nginx