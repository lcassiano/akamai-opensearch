#!/bin/bash

# Load variables
source 1-apply-variables.sh

if [ $1 = "install" ] && [ "${APPEMAIL}" != "example@example.com" ]; then

    # Create services
    echo '\033[31;5;7m[  WARN  ] \033[0m' "Install solution" > /dev/ttyS0
    bash 2-install-cert-manager.sh
    bash 3-install-ingress.sh
    bash 4-apply-volume.sh

fi

if [ $1 = "start" ] && [ "${APPEMAIL}" != "example@example.com" ]; then

    echo '\033[31;5;7m[  WARN  ] \033[0m' "Start solution" > /dev/ttyS0
    kubectl -f namespace.yaml apply
    kubectl -f volume.yaml apply
    kubectl -f deploy.yaml apply
    kubectl -f services.yaml apply

    echo '\033[31;5;7m[  WARN  ] \033[0m' "hostname :  https://$APPHOSTNAME/dashboards" > /dev/ttyS0
    echo '\033[31;5;7m[  WARN  ] \033[0m' "user : admin" > /dev/ttyS0
    echo '\033[31;5;7m[  WARN  ] \033[0m' "pass : $ADMIN_PASSWORD" > /dev/ttyS0

fi

if [ "${APPEMAIL}" == "example@example.com" ]; then

    echo '\033[31;5;7m[  WARN  ] \033[0m' "Please, configure valid e-mail on file iac/1-apply-variables.sh"  > /dev/ttyS0
    echo '\033[31;5;7m[  WARN  ] \033[0m' "It is important to configure solution and to make a certificate"  > /dev/ttyS0

fi