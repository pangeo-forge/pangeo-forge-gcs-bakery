#!/bin/sh
echo "------------------------------------------"
echo "       Pangeo Forge - GCE bakery"
echo "------------------------------------------"
echo "- Checking prerequisites..."
if [ -z "${BAKERY_NAMESPACE}" ]; then
  echo "[X] - BAKERY_NAMESPACE is not set"
  exit 1
fi

if [ -z "${BAKERY_IMAGE}" ]; then
  echo "[X] - BAKERY_IMAGE is not set"
  exit 2
fi

if [ -z "${PREFECT__CLOUD__AGENT__AUTH_TOKEN}" ]; then
  echo "[X] - PREFECT__CLOUD__AGENT__AUTH_TOKEN is not set"
  exit 3
fi
SCRIPT_DIR=`dirname $(realpath $0)`

echo "- Beginning Terraform"
cd $SCRIPT_DIR/terraform
terraform init
terraform plan
terraform apply

echo "- Beginning Kubernetes"
cd $SCRIPT_DIR/kubernetes
gcloud container clusters get-credentials alex-bush-gke-cluster --region us-central1 --project pangeo-forge-bakery-gcp
FILES="$SCRIPT_DIR/kubernetes/*.yaml"
for file in $FILES
do
  echo "Processing $file file...".
  cat $file | envsubst | kubectl apply -f -
done
echo "------------------------------------------"
echo "                All done!                 "
echo "------------------------------------------"
exit 0