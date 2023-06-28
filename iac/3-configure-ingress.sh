#!/bin/bash

# NGINX CONFIG
cat <<EOF | $KUBECTL_CMD $KUBECTL_CMD_OPTION -f -
---
apiVersion: v1
data:
  auth: ${ADMIN_PASSWORD_BASE64}
kind: Secret
metadata:
  name: ${APPNAME}-basic-auth
  namespace: ${APPNAMESPACE}-${APPNAME}
type: Opaque
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ${APPNAME}-ingress
  namespace: ${APPNAMESPACE}-${APPNAME}
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: ${APPNAME}-basic-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required'
spec:
  tls:
  - hosts:
    - ${APPHOSTNAME}
    secretName: ${APPNAME}-tls
  rules:
  - host: ${APPHOSTNAME}
    http:
      paths:
      - pathType: Prefix
        path: "/dashboards"
        backend:
          service:
            name: ${APPNAME}-dashboards-service
            port:
              number: 5601
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: ${APPNAME}-opensearch-service
            port:
              number: 9200
EOF