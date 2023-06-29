#!/bin/bash

# Load variables
source 1-apply-variables.sh

if [ $1 = "install" ] && [ "${APPEMAIL}" != "example@example.com" ]; then

    # Create services
    bash 2-install-cert-manager.sh
    bash 3-install-ingress.sh
    bash 4-apply-volume.sh

fi

if [ $1 = "start" ] && [ "${APPEMAIL}" != "example@example.com" ]; then

    bash 5-apply-deploy.sh
    bash 6-apply-services.sh
    bash 7-configure-ingress.sh

    echo -e '\033[31;5;7m[  WARN  ] \033[0m' "hostname :  https://$APPHOSTNAME/dashboards";
    echo -e '\033[31;5;7m[  WARN  ] \033[0m' "user : admin";
    echo -e '\033[31;5;7m[  WARN  ] \033[0m' "pass : $ADMIN_PASSWORD"

fi

if [ "${APPEMAIL}" == "example@example.com" ]; then

    echo -e '\033[31;5;7m[  WARN  ] \033[0m' "Please, configure valid e-mail on file iac/1-apply-variables.sh";
    echo -e '\033[31;5;7m[  WARN  ] \033[0m' "It is important to configure solution and to make a certificate";

fi