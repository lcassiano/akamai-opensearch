#!/bin/bash

# GENERATE DEPLOYMENTS
cat <<EOF | $KUBECTL_CMD apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: opensearch-node1-deployment
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
        - containerPort: 9300
        env:
        - name: cluster.name
          value: ${APPNAME}-cluster
        - name: node.name
          value: ${APPNAME}-node1
        - name: discovery.seed_hosts
          value: ${APPNAME}-node1,${APPNAME}-node2
        - name: cluster.initial_cluster_manager_nodes
          value: ${APPNAME}-node1,${APPNAME}-node2
        - name: "bootstrap.memory_lock"
          value: "false"
        - name: ES_JAVA_OPTS
          value: "-Xms1g -Xms1g"
        - name: "DISABLE_INSTALL_DEMO_CONFIG"
          value: "true"
        - name: "DISABLE_SECURITY_PLUGIN"
          value: "true"
        volumeMounts:
            - name: ${APPNAME}-data1-volume
              mountPath: /usr/share/opensearch/data
      initContainers:
          - name: fix-disk-permissions
            image: busybox:latest
            command: ["sh","-c","mkdir -p /usr/share/opensearchsearch/data && chown -R 1000:root /usr/share/opensearchsearch/data"]
            resources:
              limits:
                cpu: "1"
                memory: 1Gi
            volumeMounts:
            - name: ${APPNAME}-data1-volume
              mountPath: /usr/share/opensearchsearch/data
          - name: max-map-count-setter
            image: docker.io/bash:5.2.15
            resources:
              limits:
                cpu: 100m
                memory: 32Mi
            securityContext:
              privileged: true
              runAsUser: 0
            command: ['/usr/local/bin/bash', '-e', '-c', 'echo 262144 > /proc/sys/vm/max_map_count']
      volumes:
        - name: ${APPNAME}-data1-volume
          persistentVolumeClaim:
            claimName: akamai-${APPNAME}-data1-claim
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
        - containerPort: 9300
        env:
        - name: cluster.name
          value: ${APPNAME}-cluster
        - name: node.name
          value: ${APPNAME}-node2
        - name: discovery.seed_hosts
          value: ${APPNAME}-node1,${APPNAME}-node2
        - name: cluster.initial_cluster_manager_nodes
          value: ${APPNAME}-node1,${APPNAME}-node2
        - name: "bootstrap.memory_lock"
          value: "false"
        - name: "ES_JAVA_OPTS"
          value: "-Xms1g -Xms1g"
        - name: "DISABLE_INSTALL_DEMO_CONFIG"
          value: "true"
        - name: "DISABLE_SECURITY_PLUGIN"
          value: "true"    
        volumeMounts:
            - name: ${APPNAME}-data2-volume
              mountPath: /usr/share/opensearchsearch/data
      initContainers:
          - name: fix-disk-permissions
            image: busybox:latest
            command: ["sh","-c","mkdir -p /usr/share/opensearchsearch/data && chown -R 1000:root /usr/share/opensearchsearch/data"]
            resources:
              limits:
                cpu: "1"
                memory: 1Gi
            volumeMounts:
            - name: ${APPNAME}-data2-volume
              mountPath: /usr/share/opensearchsearch/data
          - name: max-map-count-setter
            image: docker.io/bash:5.2.15
            resources:
              limits:
                cpu: 100m
                memory: 32Mi
            securityContext:
              privileged: true
              runAsUser: 0
            command: ['/usr/local/bin/bash', '-e', '-c', 'echo 262144 > /proc/sys/vm/max_map_count']
      volumes:
        - name: ${APPNAME}-data2-volume
          persistentVolumeClaim:
            claimName: akamai-${APPNAME}-data2-claim
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
          value: '["http://${APPNAME}-node1:9200","http://${APPNAME}-node2:9200"]'
        - name: "DISABLE_SECURITY_DASHBOARDS_PLUGIN"
          value: "true"
        - name: "SERVER_BASEPATH"
          value: "/dashboards"
        - name: "SERVER_REWRITEBASEPATH"
          value: "true"
EOF
