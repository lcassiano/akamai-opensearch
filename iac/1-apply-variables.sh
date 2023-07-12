# Set default variables
export APPHOSTNAME=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://' | sed -e 's/\./\-/g').ip.linodeusercontent.com

# Generate random password
export ADMIN_PASSWORD=$(openssl rand -base64 15)
echo ${ADMIN_PASSWORD} | sudo htpasswd -i -c admin_user admin
export ADMIN_PASSWORD_BASE64=$(cat admin_user | base64)
rm -rf admin_user