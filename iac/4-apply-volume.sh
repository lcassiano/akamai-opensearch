#!/bin/bash

# GENERATE DEPLOYMENTS
cat <<EOF | $KUBECTL_CMD apply -f -
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: akamai-${APPNAME}-data1-claim
  namespace: ${APPNAMESPACE}-${APPNAME}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: akamai-${APPNAME}-data2-claim
  namespace: ${APPNAMESPACE}-${APPNAME}
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
EOF
