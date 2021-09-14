#!/bin/bash
function cleanup {
  echo "Removing temporary JSON file"
  rm -f /tmp/input.json
}

trap cleanup EXIT

ROOT=$(pwd)
echo "------------------------------------------"
echo "       Pangeo Forge - GCE bakery"
echo " ----  BAKERY YAML GENERATOR SCRIPT ----"
echo "------------------------------------------"
echo "- Running prepare script"
source "$ROOT/scripts/prepare.sh" "$ROOT"
echo "- Checking prerequisites..."
OK=1

if [ -z "${BAKERY_IMAGE}" ]; then
  echo "[X] - BAKERY_IMAGE is not set"
  OK=0
else
  echo "BAKERY_IMAGE is set to ${BAKERY_IMAGE}"
fi

if [ -z "${CLUSTER_REGION}" ]; then
  echo "[X] - CLUSTER_REGION is not set"
  OK=0
else
  echo "CLUSTER_REGION is set to ${CLUSTER_REGION}"
fi

if [ -z "${STORAGE_NAME}" ]; then
  echo "[X] - STORAGE_NAME is not set"
  OK=0
else
  echo "STORAGE_NAME is set to ${STORAGE_NAME}"
fi

if [ $OK == 0 ]; then
  exit 1
fi

PLATFORM="google"
CLUSTER_TYPE="gke"
FLOW_STORAGE_PROTOCOL="gcsfs"
MAX_WORKERS="10"

REGION=$CLUSTER_REGION
STORAGE_PLATFORM=$PLATFORM
STORAGE_REGION=$REGION
STORAGE_TARGET_NAME=$STORAGE_NAME
FLOW_STORAGE=$STORAGE_NAME
PANGEO_FORGE_VERSION=$(echo "$BAKERY_IMAGE" | sed -En "s/.*pangeoforgerecipes-(.*)/\1/p")
PREFECT_VERSION=$(echo "$BAKERY_IMAGE" | sed -En "s/.*prefect-(.*)_pangeoforgerecipes.*/\1/p")
PANGEO_NOTEBOOK_VERSION=$(echo "$BAKERY_IMAGE" | sed -En "s/.*pangeonotebook-(.*)_prefect.*/\1/p")
WORKER_IMAGE=$BAKERY_IMAGE

cat > /tmp/input.json << EOF
{
  "devseed.bakery.development.$PLATFORM.$REGION":{
    "region":"$PLATFORM.$REGION",
    "targets": {
      "$STORAGE_TARGET_NAME":{
        "region":"$STORAGE_PLATFORM.$STORAGE_REGION",
        "description":"Flow output container",
        "private": {
          "protocol":"$FLOW_STORAGE_PROTOCOL"
        }
      }
    },
    "cluster": {
      "type":"$PLATFORM.$CLUSTER_TYPE",
      "pangeo_forge_version":"$PANGEO_FORGE_VERSION",
      "pangeo_notebook_version":"$PANGEO_NOTEBOOK_VERSION",
      "prefect_version":"$PREFECT_VERSION",
      "worker_image":"$WORKER_IMAGE",
      "flow_storage":"$FLOW_STORAGE",
      "flow_storage_protocol":"$FLOW_STORAGE_PROTOCOL",
      "max_workers":$MAX_WORKERS
    }
  }
}
EOF
python3 -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False, sort_keys=False)' < /tmp/input.json > bakery.yaml
