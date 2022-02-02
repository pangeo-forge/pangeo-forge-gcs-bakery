#!/bin/bash

ROOT=$1
echo "------------------------------------------"
echo "       Pangeo Forge - GCE bakery"
echo "       ----  LOKI INSTALLER ----"
echo "------------------------------------------"
echo "- Running kubernetes connector script"
$ROOT/scripts/k8s-connect.sh

echo "- Adding helm repos"
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

echo "- Deploying the loki stack"
LOKI_NAMESPACE="loki-stack"
LOKI_OPTIONS="promtail.enabled=true,loki.persistence.enabled=true,loki.persistence.size=100Gi,grafana.enabled=true"
kubectl get ns | grep "$LOKI_NAMESPACE" > /dev/null 2>&1
if [ $? -eq 1 ]; then
  echo "- Namespace \"$LOKI_NAMESPACE\" does not exist, creating"
  helm install $LOKI_NAMESPACE grafana/loki-stack \
                                --create-namespace \
                                --namespace $LOKI_NAMESPACE \
                                --set $LOKI_OPTIONS
else
  echo "- Namespace \"$LOKI_NAMESPACE\" already exists, updating"
  helm upgrade --install $LOKI_NAMESPACE grafana/loki-stack \
                                --namespace $LOKI_NAMESPACE \
                                --set $LOKI_OPTIONS
fi
