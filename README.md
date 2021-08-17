#Pangeo Forge Google Cloud Bakery
This repository serves as the provider of a Terraform and Kubernetes Application which deploys the necessary infrastructure to provide a pangeo-forge Bakery on Google Cloud

## Prerequisites
You will need:
### Tooling
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
- Lens (The Kubernetes IDE) - Optional
  - https://k8slens.dev/#download
  - Optional but makes debugging much much easier
### GCP Cloud project
  need a project set up with these APIs enabled:
- Kubernetes Engine API
- Cloud Storage API

## Using this repo
### .env file
- Fill it out with your own values
### Stages
- init
  - authenticates with Google Cloud to setup the default application credentials for use by later stages
- install
  - provisions the cluster and storage infrastructure in Google Cloud
- test
  - registers a test recipe against the prefect cloud instance for use by your agent(s)
- destroy
  - destroys all infrastructure from the last run of "make install"

### Initialising the bakery
1. Run `make init` to log in to Google Cloud
2. Run `make install` to set up the infrastructure against your Google Cloud account
3. Get a cup of tea whilst Prefect sorts itself out, this may take about 10 minutes.
4. Run `make test` to register the test flow against your new Prefect agent
5. Test the flow using the prefect cloud UI

### Updating
1. Run `make init` to ensure you are logged in to Google Cloud
2. Run `make install` to re-run terraform against your environment.
   1. NOTE: The Terraform configuration is designed to be idempotent, so you should normally see "no changes to be applied"
3. Run `make test` to register the test flow.

### Testing
1. Run `make test` to register the test flow against your new Prefect agent
2. Test the flow using the prefect cloud UI

### Destroying
1. Run `make init` to ensure you are logged in to Google Cloud
2. Run `make destroy` to destroy any infrastructure instantiated by terraform in the install step.

## Gotchas
- The Prefect agent pod in the cluster uses the cluster's own Google Managed Identity (CLUSTER_STORAGE_ACCOUNT) to access storage
- The Prefect flow registration uses the STORAGE_ACCOUNT to access the storage and plant the files
