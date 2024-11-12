#!/bin/bash

# Description: Script to check logs from crypto-price-checker pods.
# Usage:
# ./check_logs.sh            - Show logs of all crypto-price-checker pods
# ./check_logs.sh tail       - Tail logs of crypto-price-checker pods
# ./check_logs.sh search "ERROR" - Search for "ERROR" in logs

NAMESPACE="default"
DEPLOYMENT_NAME="crypto-price-checker"

# Fetch all pod names of the deployment
PODS=$(kubectl get pods -n $NAMESPACE -l app=$DEPLOYMENT_NAME -o jsonpath='{.items[*].metadata.name}')

# Function to display logs
show_logs() {
  for POD in $PODS; do
    echo "Showing logs for pod: $POD"
    kubectl logs $POD -n $NAMESPACE
    echo "-------------------------------------------"
  done
}

# Function to tail logs
tail_logs() {
  for POD in $PODS; do
    echo "Tailing logs for pod: $POD"
    kubectl logs $POD -n $NAMESPACE -f &
  done
  wait
}

# Function to search logs for a specific term
search_logs() {
  local TERM="$1"
  for POD in $PODS; do
    echo "Searching logs for pod: $POD with term: $TERM"
    kubectl logs $POD -n $NAMESPACE | grep -i "$TERM"
    echo "-------------------------------------------"
  done
}

# Main logic to handle different options
if [ "$1" == "tail" ]; then
  tail_logs
elif [ "$1" == "search" ]; then
  if [ -z "$2" ]; then
    echo "Please provide a search term. Usage: ./check_logs.sh search \"TERM\""
    exit 1
  fi
  search_logs "$2"
else
  show_logs
fi
