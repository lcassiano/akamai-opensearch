#!/bin/bash
# Generate random password
#export ADMIN_PASSWORD=$(openssl rand -base64 15)
export OSEMAIL=$1
export OSUSER=$2
export ADMIN_PASSWORD=$3
export APPHOSTNAME=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://' | sed -e 's/\./\-/g').ip.linodeusercontent.com
echo ${ADMIN_PASSWORD} | sudo htpasswd -i -c admin_user ${OSUSER}
export ADMIN_PASSWORD_BASE64=$(cat admin_user | base64)
rm -rf admin_user

echo ${OSEMAIL} ${OSUSER} ${ADMIN_PASSWORD} ${APPHOSTNAME}

cat <<EOF | kubectl apply -f -
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
cat <<EOF | kubectl apply -f -
apiVersion: v1
data:
  auth: ${ADMIN_PASSWORD_BASE64}
kind: Secret
metadata:
  name: opensearch-basic-auth
  namespace: akamai-opensearch
type: Opaque
---
cat <<EOF | kubectl apply -f -
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
    secretName: opensearch-tls
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

