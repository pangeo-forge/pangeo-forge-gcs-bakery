SHELL := /bin/bash
#Composite Steps
.PHONY: deploy
deploy: deploy-cluster loki

#Individual Steps
.PHONY: init
init:
	scripts/init.sh

.PHONY: deploy-cluster
deploy-cluster:
	scripts/deploy.sh

.PHONY: destroy
destroy:
	scripts/destroy.sh

.PHONY: test
test:
	scripts/test.sh $$(pwd)/test/recipes/oisst_recipe.py $$(pwd)/kubernetes/storage_key.json

.PHONY: getinfo
getinfo:
	scripts/get-info.sh

.PHONY: loki
loki:
	scripts/loki.sh $$(pwd)

.PHONY: get-cluster-creds
get-cluster-creds:
	./scripts/k8s-connect.sh

.PHONY: generatebakeryyaml
generatebakeryyaml:
	scripts/generate-yaml.sh
