#!/bin/bash
ROOT=$(pwd)
echo "------------------------------------------"
echo "       Pangeo Forge - GCE bakery"
echo "   ----  KUBERNETES CONNECTOR ----"
echo "------------------------------------------"
echo "- Running prepare script"
source "$ROOT/scripts/prepare.sh" "$ROOT"
echo "- Checking prerequisites..."
OK=1

if [ -z "${PROJECT_NAME}" ]; then
  echo "[X] - PROJECT_NAME is not set"
  OK=0
else
  echo "PROJECT_NAME is set to ${PROJECT_NAME}"
fi

if [ -z "${BAKERY_IDENTIFIER}" ]; then
  echo "[X] - BAKERY_IDENTIFIER is not set"
  OK=0
else
  echo "BAKERY_IDENTIFIER is set to ${BAKERY_IDENTIFIER}"
fi

if [ -z "${CLUSTER_REGION}" ]; then
  echo "[X] - CLUSTER_REGION is not set"
  OK=0
else
  echo "CLUSTER_REGION is set to ${CLUSTER_REGION}"
fi

if [ $OK == 0 ]; then
  exit 1
fi
echo "- Beginning gCloud kubernetes init"
CLUSTER_NAME=STORAGE_TARGET_NAME="${BAKERY_IDENTIFIER}-bakery-cluster"
gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$CLUSTER_REGION" --project "$PROJECT_NAME"
CONTEXT_NAME="gke_${PROJECT_NAME}_${CLUSTER_REGION}_${BAKERY_IDENTIFIER}-bakery-cluster"
set -e
kubectl config use-context "$CONTEXT_NAME"