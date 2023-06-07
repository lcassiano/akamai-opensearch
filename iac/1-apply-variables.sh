# Set default variables
export APPNAMESPACE=akamai
export APPNAME=opensearch
export APPHOSTNAME=$(/sbin/ifconfig eth0 | awk '/inet / { print $2 }' | sed 's/addr://' | sed -e 's/\./\-/g').ip.linodeusercontent.com
export APPEMAIL=lcassian@akamai.com

# Set Opensearch variables
export OS_ADMIN_PASSWORD=admin123

# Find kubectl binary in the os path.
export KUBECTL_CMD=$(which kubectl)

# Check if kubectl is installed.
if [ ! -f "$KUBECTL_CMD" ]; then
  echo "Kubernetes client (kubectl) is not installed. Please install it to continue!"
  echo "Please execute the following command : "
  echo "ln -s /etc/rancher/k3s/k3s.yaml kubeconfig"
  exit 1
fi

# Check if the kubeconfig file is available.
if [ ! -f "kubeconfig" ]; then
  ln -s /etc/rancher/k3s/k3s.yaml iac/kubeconfig
  echo "kubeconfig file not found! You can proceed without this file!"
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