#!/bin/bash

$KUBECTL_CMD apply -f https://github.com/jetstack/cert-manager/releases/download/v1.11.0/cert-manager.yaml
echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Waiting to install cert-manager"
sleep 30

# Waiting for DNS configuration
export IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
while ! $(host $APPHOSTNAME >/dev/null); do
  echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Configure este hostname: $APPHOSTNAME no seu DNS master apontando para o IP $IPADDR"
  echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Segue um exemplo: $APPHOSTNAME   IN   A   $IPADDR"
  sleep 5
done

# Generate ssl configuration
cat <<EOF | $KUBECTL_CMD apply -f -
---
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: ${APPNAMESPACE}-${APPNAME}
spec:
  acme:
    email: ${APPEMAIL}
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: traefik
EOF

cat <<EOF | $KUBECTL_CMD apply -f -
---
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: redirect-https
spec:
  redirectScheme:
    scheme: https
    permanent: true
EOF

cat <<EOF | $KUBECTL_CMD apply -f -
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${APPNAME}-tls-ingress
  namespace: ${APPNAMESPACE}-${APPNAME}
  annotations:
    kubernetes.io/ingress.class: traefik
    cert-manager.io/cluster-issuer: letsencrypt-prod
    traefik.ingress.kubernetes.io/router.middlewares: default-redirect-https@kubernetescrd
spec:
  rules:
    - host: ${APPHOSTNAME}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: nginx-proxy-service
                port:
                  number: 8090
  tls:
    - secretName: ${APPNAME}-tls
      hosts:
        - ${APPHOSTNAME}
EOF

