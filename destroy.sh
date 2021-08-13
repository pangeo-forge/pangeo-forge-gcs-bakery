#!/bin/bash
echo "------------------------------------------"
echo "       Pangeo Forge - GCE bakery"
echo "       ----  DESTROY SCRIPT ----"
echo "------------------------------------------"
echo "- Checking prerequisites..."
OK=1
if [ -z "${STORAGE_SERVICE_ACCOUNT_NAME}" ]; then
 echo "[X] - STORAGE_SERVICE_ACCOUNT_NAME is not set"
 OK=0
fi

if [ -z "${CLUSTER_SERVICE_ACCOUNT_NAME}" ]; then
 echo "[X] - CLUSTER_SERVICE_ACCOUNT_NAME is not set"
 OK=0
fi

if [ $OK == 0 ]; then
  exit 1
fi
export TF_VAR_storage_service_account_name=$STORAGE_SERVICE_ACCOUNT_NAME
export TF_VAR_cluster_service_account_name=$CLUSTER_SERVICE_ACCOUNT_NAME
cd terraform
terraform destroy