#!/bin/bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install loki-stack grafana/loki-stack \
                                --create-namespace \
                                --namespace loki-stack \
                                --set promtail.enabled=true,loki.persistence.enabled=true,loki.persistence.size=100Gi
helm install loki-grafana grafana/grafana \
                              --set persistence.enabled=true,persistence.type=pvc,persistence.size=10Gi \
                              --namespace=loki-stack