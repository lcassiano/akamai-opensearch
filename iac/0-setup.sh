#!/bin/bash

# Load variables
source 1-apply-variables.sh

if [ $1 = "start" ] ; then

    # Create SSL
    #bash 2-apply-ssl-settings.sh

    # Create services
    bash 2-install-cert-manager.sh
    bash 3-configure-ingress.sh
    bash 4-install-ingress.sh
    bash 5-apply-volume.sh
    bash 6-apply-deploy.sh
    bash 7-apply-services.sh

    echo -e '\033[31;5;7m[  WARN  ] \033[0m' "hostname :  https://$APPHOSTNAME/dashboards";
    echo -e '\033[31;5;7m[  WARN  ] \033[0m' "user : admin";
    echo -e '\033[31;5;7m[  WARN  ] \033[0m' "pass : $ADMIN_PASSWORD"
    
fi