#!/bin/bash
set -e

function apply_file_with_subst {
  envsubst < "$1" | kubectl apply -f -
}

ROOT=$(pwd)
echo "------------------------------------------"
echo "       Pangeo Forge - GCE bakery"
echo "       ----  INSTALL SCRIPT ----"
echo "------------------------------------------"
echo "- Running prepare script"
source "$ROOT/scripts/prepare.sh" "$ROOT"
echo "- Checking prerequisites..."
OK=1
if [ -z "${BAKERY_NAMESPACE}" ]; then
  echo "[X] - BAKERY_NAMESPACE is not set"
  OK=0
else
  echo "BAKERY_NAMESPACE is set to ${BAKERY_NAMESPACE}"
fi

if [ -z "${BAKERY_IMAGE}" ]; then
  echo "[X] - BAKERY_IMAGE is not set"
  OK=0
else
  echo "BAKERY_IMAGE is set to ${BAKERY_IMAGE}"
fi

if [ -z "${PREFECT__CLOUD__AGENT__AUTH_TOKEN}" ]; then
  echo "[X] - PREFECT__CLOUD__AGENT__AUTH_TOKEN is not set"
  OK=0
else
  echo "PREFECT__CLOUD__AGENT__AUTH_TOKEN is set to ${PREFECT__CLOUD__AGENT__AUTH_TOKEN}"
fi

if [ -z "${STORAGE_SERVICE_ACCOUNT_NAME}" ]; then
  echo "[X] - STORAGE_SERVICE_ACCOUNT_NAME is not set"
  OK=0
else
  echo "STORAGE_SERVICE_ACCOUNT_NAME is set to ${STORAGE_SERVICE_ACCOUNT_NAME}"
fi

if [ -z "${CLUSTER_SERVICE_ACCOUNT_NAME}" ]; then
  echo "[X] - CLUSTER_SERVICE_ACCOUNT_NAME is not set"
  OK=0
else
  echo "CLUSTER_SERVICE_ACCOUNT_NAME is set to ${CLUSTER_SERVICE_ACCOUNT_NAME}"
fi

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

echo "- Beginning gCloud init"
gcloud config set project "$PROJECT_NAME"
echo "- Beginning Terraform"
cd "$ROOT/terraform"
export TF_VAR_storage_service_account_name="$STORAGE_SERVICE_ACCOUNT_NAME"
export TF_VAR_cluster_service_account_name="$CLUSTER_SERVICE_ACCOUNT_NAME"
export TF_VAR_identifier="$BAKERY_IDENTIFIER"
export TF_VAR_cluster_region="$CLUSTER_REGION"
export TF_VAR_project_name="$PROJECT_NAME"
terraform init
terraform plan
terraform apply

echo "- Beginning storage operations"
gcloud projects add-iam-policy-binding "$PROJECT_NAME" --member="serviceAccount:$STORAGE_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com" --role="roles/viewer"
gcloud iam service-accounts keys create "$ROOT/kubernetes/storage_key.json" --iam-account="$STORAGE_SERVICE_ACCOUNT_NAME@$PROJECT_NAME.iam.gserviceaccount.com"

echo "- Beginning Kubernetes operations"
echo "CLUSTER: $CLUSTER_NAME"
echo "REGION: $CLUSTER_REGION"
echo "PROJECT: $PROJECT_NAME"


echo "- Running kubernetes connector script"
set +e
cd "$ROOT"
$ROOT/scripts/k8s-connect.sh
cd "$ROOT/kubernetes"
FILES="*.yaml"
kubectl get ns | grep "$BAKERY_NAMESPACE" > /dev/null 2>&1
if [ $? -eq 1 ]; then
  echo "- Namespace \"$BAKERY_NAMESPACE\" does not exist, creating"
  apply_file_with_subst "$ROOT/kubernetes/prefect-agent.namespace.yaml"
else
  echo "- Namespace \"$BAKERY_NAMESPACE\" already exists, not creating"
fi

kubectl delete secret  -n "$BAKERY_NAMESPACE" google-credentials --ignore-not-found
kubectl create secret generic  -n "$BAKERY_NAMESPACE" google-credentials --from-file="$ROOT/kubernetes/storage_key.json"
for file in $FILES
do
  echo "Processing $file file..."
  echo "$file" | grep namespace
  IS_NAMESPACE=$?
  if [ $IS_NAMESPACE -eq 1 ]; then
    apply_file_with_subst "$file"
  fi
done
set -e
echo "------------------------------------------"
echo "            Install - All done!           "
echo "------------------------------------------"
exit 0