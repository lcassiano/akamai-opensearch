#!/bin/bash

# GENERATE SERVICES
cat <<EOF | $KUBECTL_CMD $KUBECTL_CMD_OPTION -f -
---
apiVersion: v1
kind: Service
metadata:
  name: ${APPNAME}-node1-service
  namespace: ${APPNAMESPACE}-${APPNAME}
spec:
  selector:
    app: ${APPNAME}-node1
  ports:
    - port: 9200
      targetPort: 9200
    - port: 9600
      targetPort: 9600
---
apiVersion: v1
kind: Service
metadata:
  name: ${APPNAME}-node2-service
  namespace: ${APPNAMESPACE}-${APPNAME}
spec:
  selector:
    app: ${APPNAME}-node2
  ports:
    - port: 9200
      targetPort: 9200
    - port: 9600
      targetPort: 9600
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-proxy-service
  namespace: ${APPNAMESPACE}-${APPNAME}
spec:
  selector:
    app: nginx-proxy
  ports:
    - port: 8090
      targetPort: 8090
---
apiVersion: v1
kind: Service
metadata:
  name: ${APPNAME}-collector-service
  namespace: ${APPNAMESPACE}-${APPNAME}
spec:
  selector:
    app: ${APPNAME}
  ports:
    - port: 8088
      targetPort: 8088
EOF