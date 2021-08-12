#!/bin/bash

function cleanup {
  echo "Removing storage key"
  rm -f kubernetes/storage_key.json
}

trap cleanup EXIT

function apply_file_with_subst {
  cat $1 | envsubst | kubectl apply -f -
}

echo "------------------------------------------"
echo "       Pangeo Forge - GCE bakery"
echo "------------------------------------------"
echo "- Checking prerequisites..."
OK=1
if [ -z "${BAKERY_NAMESPACE}" ]; then
  echo "[X] - BAKERY_NAMESPACE is not set"
  OK=0
fi

if [ -z "${BAKERY_IMAGE}" ]; then
  echo "[X] - BAKERY_IMAGE is not set"
  OK=0
fi

if [ -z "${PREFECT__CLOUD__AGENT__AUTH_TOKEN}" ]; then
  echo "[X] - PREFECT__CLOUD__AGENT__AUTH_TOKEN is not set"
  OK=0
fi

if [ -z "${STORAGE_SERVICE_ACCOUNT_NAME}" ]; then
  echo "[X] - STORAGE_SERVICE_ACCOUNT_NAME is not set"
  OK=0
fi

if [ $OK == 0 ]; then
  exit 1
fi

SCRIPT_DIR=`dirname $(realpath $0)`

echo "- Beginning Terraform"
cd $SCRIPT_DIR/terraform
terraform init
terraform plan
terraform apply
CLUSTER_NAME=`terraform output cluster_name | tr -d '"'`
CLUSTER_REGION=`terraform output cluster_region | tr -d '"'`
CLUSTER_PROJECT=`terraform output cluster_project | tr -d '"'`

echo "- Beginning storage operations"
gcloud projects add-iam-policy-binding $CLUSTER_PROJECT --member="serviceAccount:$STORAGE_SERVICE_ACCOUNT_NAME@$CLUSTER_PROJECT.iam.gserviceaccount.com" --role="roles/viewer"
gcloud iam service-accounts keys create $SCRIPT_DIR/kubernetes/storage_key.json --iam-account=$STORAGE_SERVICE_ACCOUNT_NAME@$CLUSTER_PROJECT.iam.gserviceaccount.com

echo "- Beginning Kubernetes operations"
echo "CLUSTER: $CLUSTER_NAME"
echo "REGION: $CLUSTER_REGION"
echo "PROJECT: $CLUSTER_PROJECT"

cd $SCRIPT_DIR/kubernetes
gcloud container clusters get-credentials $CLUSTER_NAME --region $CLUSTER_REGION --project $CLUSTER_PROJECT
CONTEXT_NAME="gke_${CLUSTER_PROJECT}_${CLUSTER_REGION}_${CLUSTER_NAME}"
kubectl config use-context $CONTEXT_NAME
FILES="$SCRIPT_DIR/kubernetes/*.yaml"

kubectl get ns | grep $BAKERY_NAMESPACE > /dev/null 2>&1
if [ $? -eq 1 ]; then
  echo "- Namespace \"$BAKERY_NAMESPACE\" does not exist, creating"
  apply_file_with_subst "$SCRIPT_DIR/kubernetes/prefect-agent.namespace.yaml"
else
  echo "- Namespace \"$BAKERY_NAMESPACE\" already exists, not creating"
fi

kubectl delete secret  -n $BAKERY_NAMESPACE google-credentials --ignore-not-found
kubectl create secret generic  -n $BAKERY_NAMESPACE google-credentials --from-file=$SCRIPT_DIR/kubernetes/storage_key.json

for file in $FILES
do
  echo "Processing $file file..."
  echo $file | grep namespace
  IS_NAMESPACE=$?
  if [ $IS_NAMESPACE -eq 1 ]; then
    apply_file_with_subst $file
  fi
done
echo "------------------------------------------"
echo "                All done!                 "
echo "------------------------------------------"
exit 0