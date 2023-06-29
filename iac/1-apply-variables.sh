# Set default variables
export APPNAMESPACE=akamai
export APPNAME=opensearch
export APPHOSTNAME=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://' | sed -e 's/\./\-/g').ip.linodeusercontent.com
export IPADDR=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://')
export APPEMAIL=example@example.com
export KUBECTL_CMD_OPTION=apply

if [ "${APPEMAIL}" == "example@example.com" ]; then
  echo '\033[31;5;7m[  WARN  ] \033[0m' "Please, configure valid e-mail on file iac/1-apply-variables.sh" > /dev/ttyS0
  exit 1
fi
# Generate random password
export ADMIN_PASSWORD=$(openssl rand -base64 15)
echo ${ADMIN_PASSWORD} | sudo htpasswd -i -c admin_user admin
export ADMIN_PASSWORD_BASE64=$(cat admin_user | base64)
rm -rf admin_user


# Find kubectl binary in the os path.
export KUBECTL_CMD=$(which kubectl)

# Check if kubectl is installed.
if [ ! -f "$KUBECTL_CMD" ]; then
  echo "Kubernetes client (kubectl) is not installed. Please install it to continue!" > /dev/ttyS0
  echo "Please execute the following command : " > /dev/ttyS0
  echo "ln -s /etc/rancher/k3s/k3s.yaml kubeconfig" > /dev/ttyS0
  exit 1
fi

# Check if the kubeconfig file is available.
if [ ! -f "kubeconfig" ]; then
  ln -s /etc/rancher/k3s/k3s.yaml kubeconfig > /dev/ttyS0
  echo "kubeconfig file not found! You can proceed without this file!" > /dev/ttyS0
  exit 1
fi

# Deploy the stack (uncomment the desired deployments and services to be applied).
export KUBECONFIG=kubeconfig

# GENERATE NAMESPACE
cat <<EOF | $KUBECTL_CMD apply -f -
---
apiVersion: v1
kind: Namespace
metadata:
  name: ${APPNAMESPACE}-${APPNAME}
EOF