#!/bin/bash

# GENERATE SERVICES
cat <<EOF | $KUBECTL_CMD apply -f -
---
apiVersion: v1
kind: Service
metadata:
  name: ${APPNAME}-node1
  namespace: ${APPNAMESPACE}-${APPNAME}
spec:
  selector:
    app: ${APPNAME}-node1
  ports:
    - name: http
      port: 9200
      targetPort: 9200
    - name: transport
      port: 9300
      targetPort: 9300
---
apiVersion: v1
kind: Service
metadata:
  name: ${APPNAME}-node2
  namespace: ${APPNAMESPACE}-${APPNAME}
spec:
  selector:
    app: ${APPNAME}-node2
  ports:
    - name: http
      port: 9200
      targetPort: 9200
    - name: transport
      port: 9300
      targetPort: 9300
---
# Ingress service definition.
apiVersion: v1
kind: Service
metadata:
  name: ${APPNAME}-dashboards-service
  namespace: ${APPNAMESPACE}-${APPNAME}
  labels:
    app: ${APPNAME}-dashboards
spec:
  type: ClusterIP
  ports:
    - name: http
      port: 5601
      targetPort: 5601
  selector:
    app: ${APPNAME}-dashboards
---
# Ingress service definition.
apiVersion: v1
kind: Service
metadata:
  name: ${APPNAME}-opensearch-service
  namespace: ${APPNAMESPACE}-${APPNAME}
  labels:
    app: ${APPNAME}-node2
spec:
  type: ClusterIP
  ports:
    - name: http
      port: 9200
      targetPort: 9200
  selector:
    app: ${APPNAME}-node2
EOF