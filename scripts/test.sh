#!/bin/bash

echo "------------------------------------------"
echo "       Pangeo Forge - GCE bakery"
echo "       ----  TEST SCRIPT ----"
echo "------------------------------------------"
FLOW_FILE=$1
STORAGE_KEY=$2
echo "- Running prepare script"
source $(pwd)/scripts/prepare.sh $(pwd)
echo "- Checking prerequisites..."
OK=1
if [ -z "${FLOW_FILE}" ]; then
  echo "[X] - FLOW_FILE is not specified as 1st parameter"
  OK=0
else
  echo "FLOW_FILE is set to ${FLOW_FILE}"
fi

if [ -z "${STORAGE_KEY}" ]; then
  echo "[X] - STORAGE_KEY is not specified as 2nd parameter"
  OK=0
else
  echo "STORAGE_KEY is set to ${STORAGE_KEY}"
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

if [ -z "${PROJECT_NAME}" ]; then
  echo "[X] - PROJECT_NAME is not set"
  OK=0
else
  echo "PROJECT_NAME is set to ${PROJECT_NAME}"
fi

if [ $OK == 0 ]; then
  exit 1
fi
echo "- Beginning gCloud init"
gcloud config set project $PROJECT_NAME

echo "- Starting docker container"
docker run -it --rm \
    -v $FLOW_FILE:/opt/$FLOW_FILE \
    -v $STORAGE_KEY:/opt/storage_key.json \
    -e GOOGLE_APPLICATION_CREDENTIALS="/opt/storage_key.json" \
    -e BAKERY_IMAGE \
    -e PREFECT__CLOUD__AGENT__LABELS \
    -e PREFECT_PROJECT \
    -e PREFECT__CLOUD__AUTH_TOKEN \
    -e PROJECT_NAME \
    $BAKERY_IMAGE python3 /opt/$FLOW_FILE
echo "Test running"