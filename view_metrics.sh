#!/bin/bash

# Description: Script to view the Prometheus metrics for the crypto-price-checker application.
# Usage:
# ./view_metrics.sh pod <pod_name>      - View metrics for a specific pod
# ./view_metrics.sh deployment <deployment_name>  - View metrics for the entire deployment
# ./view_metrics.sh node <node_name>    - View node-level metrics
# ./view_metrics.sh help               - Display usage help

NAMESPACE="default"
PROMETHEUS_SERVER="prometheus-server"  # The name of your Prometheus server pod
PROMETHEUS_PORT="9090"                 # The port where Prometheus server is running

# Function to display metrics for a specific pod
view_pod_metrics() {
  POD_NAME=$1
  
  if [ -z "$POD_NAME" ]; then
    echo "Please specify a pod name. Usage: ./view_metrics.sh pod <pod_name>"
    exit 1
  fi

  echo "Fetching metrics for pod: $POD_NAME"

  # Query Prometheus for pod-specific metrics (e.g., CPU, Memory usage, etc.)
  curl -s "http://$PROMETHEUS_SERVER:$PROMETHEUS_PORT/api/v1/query?query=container_memory_usage_bytes{pod=\"$POD_NAME\",namespace=\"$NAMESPACE\"}"
  curl -s "http://$PROMETHEUS_SERVER:$PROMETHEUS_PORT/api/v1/query?query=container_cpu_usage_seconds_total{pod=\"$POD_NAME\",namespace=\"$NAMESPACE\"}"
}

# Function to display metrics for the entire deployment
view_deployment_metrics() {
  DEPLOYMENT_NAME=$1
  
  if [ -z "$DEPLOYMENT_NAME" ]; then
    echo "Please specify a deployment name. Usage: ./view_metrics.sh deployment <deployment_name>"
    exit 1
  fi

  echo "Fetching metrics for deployment: $DEPLOYMENT_NAME"
  
  # Query Prometheus for deployment-level metrics (e.g., CPU, Memory usage, etc.)
  curl -s "http://$PROMETHEUS_SERVER:$PROMETHEUS_PORT/api/v1/query?query=sum(container_memory_usage_bytes{deployment=\"$DEPLOYMENT_NAME\",namespace=\"$NAMESPACE\"})"
  curl -s "http://$PROMETHEUS_SERVER:$PROMETHEUS_PORT/api/v1/query?query=sum(container_cpu_usage_seconds_total{deployment=\"$DEPLOYMENT_NAME\",namespace=\"$NAMESPACE\"})"
}

# Function to display metrics for a specific node
view_node_metrics() {
  NODE_NAME=$1

  if [ -z "$NODE_NAME" ]; then
    echo "Please specify a node name. Usage: ./view_metrics.sh node <node_name>"
    exit 1
  fi

  echo "Fetching metrics for node: $NODE_NAME"
  
  # Query Prometheus for node-level metrics (e.g., CPU, Memory usage, etc.)
  curl -s "http://$PROMETHEUS_SERVER:$PROMETHEUS_PORT/api/v1/query?query=node_memory_MemAvailable_bytes{node=\"$NODE_NAME\"}"
  curl -s "http://$PROMETHEUS_SERVER:$PROMETHEUS_PORT/api/v1/query?query=node_cpu_seconds_total{node=\"$NODE_NAME\"}"
}

# Main logic to handle different options
if [ "$1" == "pod" ]; then
  view_pod_metrics "$2"
elif [ "$1" == "deployment" ]; then
  view_deployment_metrics "$2"
elif [ "$1" == "node" ]; then
  view_node_metrics "$2"
elif [ "$1" == "help" ]; then
  echo "Usage:"
  echo "./view_metrics.sh pod <pod_name>         - View metrics for a specific pod"
  echo "./view_metrics.sh deployment <deployment_name> - View metrics for the entire deployment"
  echo "./view_metrics.sh node <node_name>       - View node-level metrics"
else
  echo "Invalid argument. Usage: ./view_metrics.sh pod, deployment, node, or help"
  exit 1
fi
