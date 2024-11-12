#!/bin/bash

# Description: Script to scale the crypto-price-checker application pods in Kubernetes.
# Usage:
# ./scale_app.sh scale <replica_count>   - Scale the application to <replica_count> pods
# ./scale_app.sh status                 - Show the current number of replicas

NAMESPACE="default"
DEPLOYMENT_NAME="crypto-price-checker"

# Function to check the current number of replicas
show_status() {
  CURRENT_REPLICAS=$(kubectl get deployment $DEPLOYMENT_NAME -n $NAMESPACE -o jsonpath='{.status.replicas}')
  echo "Current number of replicas for $DEPLOYMENT_NAME: $CURRENT_REPLICAS"
}

# Function to scale the application
scale_app() {
  local REPLICAS=$1
  kubectl scale deployment $DEPLOYMENT_NAME --replicas=$REPLICAS -n $NAMESPACE
  echo "Scaled $DEPLOYMENT_NAME to $REPLICAS replicas"
}

# Main logic to handle different options
if [ "$1" == "scale" ]; then
  if [ -z "$2" ]; then
    echo "Please provide the number of replicas. Usage: ./scale_app.sh scale <replica_count>"
    exit 1
  fi
  scale_app "$2"
elif [ "$1" == "status" ]; then
  show_status
else
  echo "Invalid argument. Usage: ./scale_app.sh scale <replica_count> or ./scale_app.sh status"
  exit 1
fi
