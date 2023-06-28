#!/bin/bash

# Create a TLS Certificate Using cert-manager
echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Create a TLS Certificate Using cert-manager"

# Install cert-manager’s CRDs.
echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Install cert-manager’s CRDs."
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.crds.yaml

# Create a cert-manager namespace.
echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Create a cert-manager namespace."
kubectl create namespace cert-manager

# Add the Helm repository which contains the cert-manager Helm chart.
echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Add the Helm repository which contains the cert-manager Helm chart."
helm repo add cert-manager https://charts.jetstack.io

# Update your Helm repositories.
echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Update your Helm repositories."
helm repo update

echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Update helm repo"
sleep 30

# Install the cert-manager Helm chart.
echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Install the cert-manager Helm chart."
helm install ${APPNAME}-cert-manager cert-manager/cert-manager --namespace cert-manager --version v1.8.0

# Create a ClusterIssuer Resource
cat <<EOF | $KUBECTL_CMD apply -f -
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: ${APPEMAIL}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-secret-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOF