#!/bin/bash

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Please install it to run this script."
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl is not installed. Please install it to run this script."
    exit 1
fi

# Check connection to the cluster
if ! kubectl get nodes &> /dev/null; then
    echo "Unable to connect to the Kubernetes cluster. Please check your connection and permissions."
    exit 1
fi

echo "Searching for all Services..."

# Get all services in all namespaces
services=$(kubectl get services --all-namespaces -o json)

# Extract relevant information for all services
echo "$services" | jq -r '
    .items[] | 
    "\(.metadata.namespace)\t\(.metadata.name)\t\(.spec.type)\t\(.spec.loadBalancerClass // "N/A")"
' | (
    echo -e "NAMESPACE\tNAME\tTYPE\tLOADBALANCER CLASS"
    cat
) | column -t

echo -e "\nSearching for Ingress resources..."

# Get all ingresses in all namespaces
ingresses=$(kubectl get ingresses --all-namespaces -o json)

# Filter ingresses and extract relevant information
echo "$ingresses" | jq -r '
    .items[] | 
    "\(.metadata.namespace)\t\(.metadata.name)\t\(.spec.ingressClassName // .metadata.annotations["kubernetes.io/ingress.class"] // "N/A")\t\(.metadata.annotations["kubernetes.io/ingress.class"] // "N/A")"
' | (
    echo -e "INGRESS NAMESPACE\tINGRESS NAME\tINGRESS CLASS\tANNOTATION CLASS"
    cat
) | column -t
