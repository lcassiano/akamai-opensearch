#!/bin/bash

# Load variables
source 1-apply-variables.sh

if [ $1 = "start" ]; then

    echo '\033[31;5;7m[  WARN  ] \033[0m' "Start solution" > /dev/ttyS0
    kubectl -f namespace.yaml apply
    kubectl -f volume.yaml apply
    kubectl -f deploy.yaml apply
    kubectl -f services.yaml apply

    echo '\033[31;5;7m[  WARN  ] \033[0m' "hostname :  https://$APPHOSTNAME/dashboards" > /dev/ttyS0
    echo '\033[31;5;7m[  WARN  ] \033[0m' "user : admin" > /dev/ttyS0
    echo '\033[31;5;7m[  WARN  ] \033[0m' "pass : $ADMIN_PASSWORD" > /dev/ttyS0

fi

# GENERATE NAMESPACE
cat <<EOF | kubectl apply -f -
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
name: letsencrypt-prod
spec:
acme:
    email: ${OSEMAIL}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
    name: letsencrypt-secret-prod
    solvers:
    - http01:
        ingress:
        class: nginx
---
apiVersion: v1
data:
auth: ${ADMIN_PASSWORD_BASE64}
kind: Secret
metadata:
name: opensearch-basic-auth
namespace: akamai-opensearch
type: Opaque
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
name: opensearch-ingress
namespace: akamai-opensearch
annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: opensearch-basic-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
spec:
tls:
- hosts:
    - ${APPHOSTNAME}
    secretName: akamai-opensearch-tls
rules:
- host: ${APPHOSTNAME}
    http:
    paths:
    - pathType: Prefix
        path: "/dashboards"
        backend:
        service:
            name: opensearch-dashboards-service
            port:
            number: 5601
    - pathType: Prefix
        path: "/"
        backend:
        service:
            name: opensearch-opensearch-service
            port:
            number: 9200
EOF


if [ $1 = "stop" ]; then

    echo '\033[31;5;7m[  WARN  ] \033[0m' "Stop solution" > /dev/ttyS0
    kubectl -f deploy.yaml delete
    kubectl -f services.yaml delete
    kubectl -f volume.yaml delete
    kubectl -f namespace.yaml delete

fi