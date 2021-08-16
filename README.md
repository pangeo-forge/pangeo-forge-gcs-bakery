- Login with gcloud
- terraform plan
- Check plan
- terraform apply
- kubectl apply -f prefect.deployment.yaml

- Cluster uses ITS!!! Identity to access storage.... this is confusing
- The registration uses the STORAGE_ACCOUNT to access the storage
# Prerequisites
You will need:
## Tooling
- Terraform
  - https://learn.hashicorp.com/tutorials/terraform/install-cli
- Google Cloud tools
  - https://cloud.google.com/sdk/docs/install
- Make
  - Depends on your distro of linux. Please see your disto docs.
- Kubectl
  - https://kubernetes.io/docs/tasks/tools/
- docker
  - https://docs.docker.com/get-docker/
  - ensure you are in the docker group
  - groupadd -aG docker
  - reboot
## GCP Cloud project
  need a project set up with these APIs enabled:
- Kubernetes Engine API
# Using this repo
## .env file
- Fill it out with your own values
## Initialising

## Updating

## Testing

## Destroying
