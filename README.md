# Pangeo Forge Google Cloud Bakery

This repository serves as the provider of a Terraform and Kubernetes Application which deploys the necessary infrastructure to provide a pangeo-forge Bakery on Google Cloud

## Prerequisites
You will need:
### GCP Buckets
- A bucket for the terraform state, whose name is updated in `terraform/providers.tf`
  - You can create this by using the instructions here https://cloud.google.com/storage/docs/creating-buckets
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
- Helm
  - https://helm.sh/docs/intro/install/
### GCP Cloud project
  need a project set up with these APIs enabled:
- Kubernetes Engine API
- Cloud Storage API

## Using this repo
### .env file
- This will setup the relevant environment variables to install the bakery
- Fill it out with your own values
### Stages
- init
  - Authenticates with Google Cloud to setup the default application credentials for use by later stages
- install
  - Provisions the cluster and storage infrastructure in Google Cloud
- test
  - Registers a test recipe against the prefect cloud instance for use by your agent(s)
- destroy
  - destroys all infrastructure from the last run of "make deploy"
- generatebakeryyaml
  - Generates a bakery definition YAML

### Initialising the bakery
1. Run `make init` to log in to Google Cloud
2. Run `make deploy` to set up the infrastructure against your Google Cloud account
3. Get a cup of tea whilst Prefect sorts itself out, this may take about 10 minutes.
4. Run `make test-flow` to register the test flow against your new Prefect agent
4. Test infrastructure according to the procedure described in **Testing** section below.

### Updating
1. Run `make init` to ensure you are logged in to Google Cloud
2. Run `make deploy` to re-run terraform against your environment.
   1. NOTE: The Terraform configuration is designed to be idempotent, so you should normally see "No changes. Your infrastructure matches the configuration."
4. Test infrastructure according to the procedure described in **Testing** section below.

### Testing
1. Execute `make test-flow` to _register_ the test flow against your new Prefect agent

> **Note**: `make test-flow` _**DOES NOT**_ run the flow. It only _registers_ it. To run the flow, continue with the remaining steps, below.

2. Login to the Prefect Cloud UI at https://cloud.prefect.io/
3. From your Prefect project homepage, select `FLOWS`.
4. In the displayed table of flows, select the test flow, either by name or date.
5. From the flow details page, use either the `RUN` or `QUICK RUN` buttons to initiate a test run of this flow.
6. Introspect further details about this run using the **Debugging** instructions, below.

# Debugging
1. Open Lens and add your cluster (this will leverage your updated kubectl config).
2. To view pods in your namespace navigate to **Workloads > Pods**.
3. From the **Namespace:** dropdown at the top right of the table, select the namespace you specified when deploying.
4. Verify your Prefect agent pod is healthy.

### To view Dask cluster logs via Grafana
1. Get the info needed to access the Grafana instance with `make get-grafana-admin`.
2. In Lens, navigate to **Network > Services**.
3. From the **Namespace:** dropdown at the top right of the table, select `loki-stack`.
4. Select `loki-stack-granafa` from the displayed table. Within **Connection > Ports**, click the `80:3000/TCP` link and use username `admin` and the password obtained in step 1.
5. Browsing logs
    1. Return to the main page and select the Explore icon on the left.
    2. From the dropdown next to **Explore** in the top left of the page, select **Loki**, then click **Log Browser**.
    
       > _Register_ and _run_ a test flow according to the procedure described in **Testing** section above, before proceeding to step 3.
    
    3. Use `make getinfo` to view a list of flow runs.
    4. Select the flow run of interest and a set of Loki search terms will be provided.
    5. Enter the search term in the Log Browser bar and click Shift+Enter.
    6. To include additional search terms you can add `| "<your search term>" to the exising string.

### Dask dashboard
1. Once your flow is running and the Dask cluster pods have been created the Dask dashboard can be accessed at http://localhost:8787 once `make getinfo` has been run.

### Destroying
1. Run `make init` to ensure you are logged in to Google Cloud
2. Run `make destroy` to destroy any infrastructure instantiated by terraform in the install step.

## Gotchas
- The Prefect agent pod in the cluster uses the cluster's own Google Managed Identity (CLUSTER_SERVICE_ACCOUNT_NAME) to access storage
- The Prefect flow registration uses the STORAGE_SERVICE_ACCOUNT_NAME to access the storage and plant the files

## Tagging
- To apply tags to a resource, add them in `terraform/tags.tf`
- Tags MUST BE lowercase letters,dash,underscore or numbers

## Generating Bakery YAML files
- To generate a bakery YAML file, run `make generatebakeryyaml`.
- The resulting YAML can be added to the bakery definition repo here https://github.com/pangeo-forge/bakery-database/blob/main/bakeries.yaml