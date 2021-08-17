#!/bin/bash
echo "------------------------------------------"
echo "       Pangeo Forge - GCE bakery"
echo "       ----  DESTROY SCRIPT ----"
echo "------------------------------------------"
echo "- Running prepare script"
source "$(pwd)/scripts/prepare.sh" "$(pwd)"

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

if [ -z "${PROJECT_NAME}" ]; then
  echo "[X] - PROJECT_NAME is not set"
  OK=0
else
  echo "PROJECT_NAME is set to ${PROJECT_NAME}"
fi

if [ -z "${STORAGE_NAME}" ]; then
  echo "[X] - STORAGE_NAME is not set"
  OK=0
else
  echo "STORAGE_NAME is set to ${STORAGE_NAME}"
fi

if [ -z "${CLUSTER_NAME}" ]; then
  echo "[X] - CLUSTER_NAME is not set"
  OK=0
else
  echo "CLUSTER_NAME is set to ${CLUSTER_NAME}"
fi

if [ $OK == 0 ]; then
  exit 1
fi
export TF_VAR_storage_service_account_name=$STORAGE_SERVICE_ACCOUNT_NAME
export TF_VAR_cluster_service_account_name=$CLUSTER_SERVICE_ACCOUNT_NAME
export TF_VAR_storage_name=$STORAGE_NAME
export TF_VAR_cluster_name=$CLUSTER_NAME
export TF_VAR_project_name=$PROJECT_NAME

cd terraform || exit
terraform destroy


echo "------------------------------------------"
echo "            Destroy - All done!           "
echo "------------------------------------------"
exit 0