#!/bin/bash

# NGINX CONFIG
cat <<EOF | $KUBECTL_CMD $KUBECTL_CMD_OPTION -f -
---
apiVersion: v1
data:
  default.conf: |
    server {
        listen       8090;
        listen  [::]:8090;
        server_name  localhost;

        #access_log  /var/log/nginx/host.access.log  main;

        location /${APPNAME}/ {

          proxy_pass http://${APPNAME}-node2-service:9200/;
          proxy_redirect off;
          proxy_buffering off;

          proxy_http_version 1.1;
          proxy_set_header Connection "Keep-Alive";
          proxy_set_header Proxy-Connection "Keep-Alive";
          rewrite ^/${APPNAME}/(.*)$ /$1 break;

        }

        # Kibana
        location / {

          proxy_pass http://${APPNAME}-dashboards-service:5601/;
          proxy_redirect off;
          proxy_buffering off;

          proxy_http_version 1.1;
          proxy_set_header Connection "Keep-Alive";
          proxy_set_header Proxy-Connection "Keep-Alive";

        }
    }
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: nginx-default
  namespace: ${APPNAMESPACE}-${APPNAME}
EOF