#!/bin/bash
set -uo

# This script will deploy the application in a Kubernetes cluster (using Minikube)
# It assumes that you already have kubectl and minikube installed and configured

show_usage() {
  echo "Usage: $0 [-h] [-m|--memory <memory>] [-c|--cpus <cpus>] [-prometheus] [-grafana] [-jaeger]"
  echo "CLI Optons:"
  echo "  -h|--help:      Show this help message and exit"
  echo "  -m|--memory:    Memory to allocate to minikube (default: 16384)"
  echo "  -c|--cpus:      CPUs to allocate to minikube (default: 4)"
}

# Get CLI arguments
MEMORY=16384
CPUS=4

while [ $# -ge 1 ]; do
  case "$1" in
    -h|--help)
      show_usage
      exit 0
      ;;
    -m|--memory)
      MEMORY="${1#*=}"
      shift
      ;;
    -c|--cpus)
      CPUS="${1#*=}"
      shift
      ;;
    *)
      echo "ERROR: Unknown argument: $1"
      show_usage
      exit 1
      ;;
  esac
done

# Start minikube
echo "INFO: Starting minikube..."
minikube start --memory=16384 --cpus=4

# Wait for minikube to be up and running (this can take a while)
echo "INFO: Waiting for minikube to be up and running..."
while ! minikube status &> /dev/null
do
  echo "INFO: Minikube is not yet running, waiting 5 seconds..."
  sleep 5
done

# Enable the Ingress addon in minikube
echo "INFO: Enabling the Ingress addon in minikube..."
minikube addons enable ingress

# Install istio into the cluster
echo "INFO: Installing istio into the cluster..."
istioctl install

# Wait for istio to be up and running (this can take a while)
echo "INFO: Waiting for istio to be up and running..."
while ! kubectl get pods -n istio-system | grep -q Running
do
  echo "INFO: Istio is not yet running, waiting 5 seconds..."
  sleep 5
done

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
