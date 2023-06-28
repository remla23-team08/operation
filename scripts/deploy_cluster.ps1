# This script will deploy the application in a Kubernetes cluster (using Minikube)
# It assumes that you already have kubectl and minikube installed and configured

# Show usage function
function show_usage {
  echo "Usage: deploy_cluster.ps1 [options]"
  echo "Options:"
  echo "  -h, --help:                  Show this help message and exit"
  echo "  -m=MEMORY, --memory=MEMORY:  Amount of RAM memory to allocate to the minikube VM (default: 16384)"
  echo "  -c=CPUS, --cpus=CPUS:        Number of CPUs to allocate to the minikube VM (default: 4)"
}

$MEMORY = '16384'
$CPUS = '4'

# Get CLI arguments
while ($args.Length -ge 1) {
  switch ($args[0]) {
    '-h', '--help' {
      show_usage
      exit 0
    }
    '-m=*', '--memory=*' {
      $MEMORY = $args[0] -replace '^-m=|--memory='
      $args = $args[1..($args.Length-1)]
    }
    '-c=*', '--cpus=*' {
      $CPUS = $args[0] -replace '^-c=|--cpus='
      $args = $args[1..($args.Length-1)]
    }
    default {
      Write-Host "ERROR: Unknown argument: $args[0]"
      show_usage
      exit 1
    }
  }
  $args = $args[1..($args.Length-1)]
}

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
