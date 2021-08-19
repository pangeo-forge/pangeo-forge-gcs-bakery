#!/bin/bash

ROOT=$(pwd)
echo "------------------------------------------"
echo "       Pangeo Forge - GCE bakery"
echo "   ----  FLOW RUN INFO FINDER ----"
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

if [ -z "${CLUSTER_NAME}" ]; then
  echo "[X] - CLUSTER_NAME is not set"
  OK=0
else
  echo "CLUSTER_NAME is set to ${CLUSTER_NAME}"
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
gcloud container clusters get-credentials "$CLUSTER_NAME" --region "$CLUSTER_REGION" --project "$PROJECT_NAME"
CONTEXT_NAME="gke_${PROJECT_NAME}_${CLUSTER_REGION}_${CLUSTER_NAME}"
set -e
kubectl config use-context "$CONTEXT_NAME"
set +e
echo "- Gathering data"
mapfile -t < <(kubectl logs -n testgarry deployment/prefect-agent | sed -rn "s/\[([0-9]+-[0-9]+-[0-9]+) ([0-9]+:[0-9]+:[0-9]+).* agent \| Completed deployment of flow run (.*)/\1@\2-\3/p")
PS3="Select a run from the list:"
select run in ${MAPFILE[@]}
do
    echo "Selected character: $run"
    echo "Selected number: $REPLY"
    break
done
ID=$(echo $run | sed -rn "s/([0-9]+-[0-9]+-[0-9]+)@([0-9]+:[0-9]+:[0-9]+)-(.*)/\3/p")
echo "---------------------------------------------------------------------------------"
echo "Jobs for flow run $run"
echo "---------------------------------------------------------------------------------"
JOB_ID=$(kubectl get jobs -n testgarry --selector=prefect.io/flow_run_id=$ID -o jsonpath='{.items[*].metadata.name}')
echo $JOB_ID
echo "---------------------------------------------------------------------------------"
echo "Dask clusters spun up from job $JOB_ID for flow run $ID"
echo "---------------------------------------------------------------------------------"
LOGS=$(kubectl logs -n testgarry jobs/$JOB_ID)
DASK_CLUSTER=$(echo $LOGS | sed -rn "s/.* The Dask dashboard is available at http:\/\/(.*).testgarry.*/\1/p")
echo $DASK_CLUSTER
echo "---------------------------------------------------------------------------------"
echo "Your loki search terms are:"
echo "---------------------------------------------------------------------------------"
echo "{dask_org_cluster_name=\"$DASK_CLUSTER\",dask_org_component=\"worker\"}"
echo "{dask_org_cluster_name=\"$DASK_CLUSTER\",dask_org_component=\"scheduler\"}"
echo "---------------------------------------------------------------------------------"