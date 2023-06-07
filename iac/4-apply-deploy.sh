#!/bin/bash

# GENERATE DEPLOYMENTS
cat <<EOF | $KUBECTL_CMD apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APPNAME}-node1-deployment
  namespace: ${APPNAMESPACE}-${APPNAME}
  labels:
    app: ${APPNAME}-node1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APPNAME}-node1
  template:
    metadata:
      labels:
        app: ${APPNAME}-node1
    spec:
      containers:
      - name: ${APPNAME}-node1
        image: opensearchproject/opensearch:latest
        ports:
        - containerPort: 9200
        - containerPort: 9600
        env:
        - name: cluster.name
          value: opensearch-cluster
        - name: node.name
          value: opensearch-node1
        - name: discovery.seed_hosts
          value: opensearch-node1,opensearch-node2
        - name: cluster.initial_cluster_manager_nodes
          value: opensearch-node1,opensearch-node2
        - name: bootstrap.memory_lock
          value: true
        - name: OPENSEARCH_JAVA_OPTS
          value: '-Xms512m -Xmx512m'
        volumeMounts:
        - name: ${APPNAME}-volume
          mountPath: /usr/share/opensearch/data
      volumes:
        - name: ${APPNAME}-volume
          hostPath:
            path: /mnt/opensearch-node1/data
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APPNAME}-node2-deployment
  namespace: ${APPNAMESPACE}-${APPNAME}
  labels:
    app: ${APPNAME}-node2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APPNAME}-node2
  template:
    metadata:
      labels:
        app: ${APPNAME}-node2
    spec:
      containers:
      - name: ${APPNAME}-node2
        image: opensearchproject/opensearch:latest
        ports:
        - containerPort: 9200
        - containerPort: 9600
        env:
        - name: cluster.name
          value: opensearch-cluster
        - name: node.name
          value: opensearch-node2
        - name: discovery.seed_hosts
          value: opensearch-node1,opensearch-node2
        - name: cluster.initial_cluster_manager_nodes
          value: opensearch-node1,opensearch-node2
        - name: bootstrap.memory_lock
          value: true
        - name: OPENSEARCH_JAVA_OPTS
          value: '-Xms512m -Xmx512m'
        volumeMounts:
        - name: ${APPNAME}-volume
          mountPath: /usr/share/opensearch/data
      volumes:
        - name: ${APPNAME}-volume
          hostPath:
            path: /mnt/opensearch-node2/data
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${APPNAME}-dashboards-deployment
  namespace: ${APPNAMESPACE}-${APPNAME}
  labels:
    app: ${APPNAME}-dashboards
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${APPNAME}-dashboards
  template:
    metadata:
      labels:
        app: ${APPNAME}-dashboards
    spec:
      containers:
      - name: ${APPNAME}-dashboards
        image: opensearchproject/opensearch-dashboards:latest
        ports:
        - containerPort: 5601
        env:
        - name: OPENSEARCH_HOSTS
          value: '["https://${APPNAME}-node1-service:9200","https://${APPNAME}-node2-service:9200"]'
EOF

# NGINX DEPLOYMENT
cat <<EOF | $KUBECTL_CMD apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: ${APPNAMESPACE}-${APPNAME}
  labels:
    app: nginx-proxy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx-proxy
  template:
    metadata:
      labels:
        app: nginx-proxy
    spec:
      containers:
      - name: nginx-proxy
        image: nginx
        ports:
        - containerPort: 8090
        volumeMounts:
         - name: nginx-default-volume
           mountPath: /etc/nginx/conf.d/default.conf
           subPath: default.conf
      volumes:
       - name: nginx-default-volume
         configMap:
           name: nginx-default
EOF
