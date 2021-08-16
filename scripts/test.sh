#!/bin/bash

echo "------------------------------------------"
echo "       Pangeo Forge - GCE bakery"
echo "       ----  TEST SCRIPT ----"
echo "------------------------------------------"
echo "- Checking prerequisites..."

if [ -z "${FLOW_STORAGE_CONNECTION_STRING}" ]; then
  echo "[X] - FLOW_STORAGE_CONNECTION_STRING is not set"
  OK=0
else
  echo "FLOW_STORAGE_CONNECTION_STRING is set to ${FLOW_STORAGE_CONNECTION_STRING}"
fi

if [ -z "${FLOW_STORAGE_CONTAINER}" ]; then
  echo "[X] - FLOW_STORAGE_CONTAINER is not set"
  OK=0
else
  echo "FLOW_STORAGE_CONTAINER is set to ${FLOW_STORAGE_CONTAINER}"
fi

if [ -z "${FLOW_CACHE_CONTAINER}" ]; then
  echo "[X] - FLOW_CACHE_CONTAINER is not set"
  OK=0
else
  echo "FLOW_CACHE_CONTAINER is set to ${FLOW_CACHE_CONTAINER}"
fi

if [ -z "${BAKERY_IMAGE}" ]; then
  echo "[X] - BAKERY_IMAGE is not set"
  OK=0
else
  echo "BAKERY_IMAGE is set to ${BAKERY_IMAGE}"
fi

if [ -z "${PREFECT__CLOUD__AGENT__LABELS}" ]; then
  echo "[X] - PREFECT__CLOUD__AGENT__LABELS is not set"
  OK=0
else
  echo "PREFECT__CLOUD__AGENT__LABELS is set to ${PREFECT__CLOUD__AGENT__LABELS}"
fi

if [ -z "${PREFECT_PROJECT}" ]; then
  echo "[X] - PREFECT_PROJECT is not set"
  OK=0
else
  echo "PREFECT_PROJECT is set to ${PREFECT_PROJECT}"
fi

if [ -z "${PREFECT__CLOUD__AUTH_TOKEN}" ]; then
  echo "[X] - PREFECT__CLOUD__AUTH_TOKEN is not set"
  OK=0
else
  echo "PREFECT__CLOUD__AUTH_TOKEN is set to ${PREFECT__CLOUD__AUTH_TOKEN}"
fi

if [ $OK == 0 ]; then
  exit 1
fi

FLOW_FILE=$1
docker run -it --rm \
    -v $FLOW_FILE:/opt/$FLOW_FILE \
    -v $ROOT_PATH/kubernetes/storage_key.json:/opt/storage_key.json \
    -e GOOGLE_APPLICATION_CREDENTIALS="/opt/storage_key.json" \
    -e FLOW_STORAGE_CONNECTION_STRING \
    -e FLOW_STORAGE_CONTAINER \
    -e FLOW_CACHE_CONTAINER \
    -e BAKERY_IMAGE \
    -e PREFECT__CLOUD__AGENT__LABELS \
    -e PREFECT_PROJECT \
    -e PREFECT__CLOUD__AUTH_TOKEN \
    $BAKERY_IMAGE python3 /opt/$FLOW_FILE