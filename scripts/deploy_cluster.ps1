# This script will deploy the application in a Kubernetes cluster (using Minikube)
# It assumes that you already have kubectl and minikube installed and configured

param (
  [string]$MEMORY = '16384',
  [string]$CPUS = '4'
)

# Start minikube
echo "INFO: Starting minikube..."
minikube start --memory=$MEMORY --cpus=$CPUS

# Wait for minikube to be up and running (this can take a while)
echo "INFO: Waiting for minikube to be up and running..."

$minikube_status = minikube status
while ($minikube_status -notlike '*host: Running*') {
  echo "INFO: Minikube is not yet running, waiting 5 seconds..."
  $minikube_status = minikube status
  Start-Sleep -s 5
}

# Enable the Ingress addon in minikube
echo "INFO: Enabling Ingress addon in minikube..."
minikube addons enable ingress

# Install istio into the cluster
echo "INFO: Installing Istio into the cluster..."
istioctl install

# Wait for istio to be up and running (this can take a while)
echo "INFO: Waiting for Istio to be up and running..."

$istio_status = kubectl get pods -n istio-system
while ($istio_status -notlike '*Running*') {
  echo "INFO: Istio is not yet running, waiting 5 seconds..."
  $istio_status = kubectl get pods -n istio-system
  Start-Sleep -s 5
}

# Instruct Istio to automatically inject proxy containers to new pods found in the default namespace of the cluster
echo "INFO: Instructing Istio to automatically inject proxy containers to new pods found in the default namespace of the cluster..."
kubectl label ns default istio-injection=enabled

# Deploy istio addons
echo "INFO: Deploying istio addons..."
kubectl apply -f addons

# Deploy the application
echo "INFO: Deploying the application..."
helm install application charts/application

echo "INFO: Application deployed successfully!"
exit 0
