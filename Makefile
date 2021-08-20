SHELL := /bin/bash

.PHONY: init
init:
	scripts/init.sh

.PHONY: install
install:
	scripts/install.sh

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

.PHONY: generatebakeryyaml
generatebakeryyaml:
	scripts/generate-yaml.sh