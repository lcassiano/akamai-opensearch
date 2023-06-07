#!/bin/bash

# Load variables
source 1-apply-variables.sh

if [ $1 = "start" ] ; then

    # Create SSL
    #bash 2-apply-ssl-settings.sh

    # Create services
    bash 3-apply-settings.sh
    bash 4-apply-deploy.sh
    
fi